import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/series_info.dart';

/// Looks up the series a book belongs to via the Hardcover GraphQL API.
///
/// Two sequential requests: search for the book (verifying the top candidates
/// actually look like the local title/author before trusting one) to get its
/// featured series id, then fetch that series' full volume list. Kept as two
/// requests (rather than one nested query) because Hardcover enforces a max
/// GraphQL query depth of 3.
class HardcoverService {
  static const String _endpoint = 'https://api.hardcover.app/v1/graphql';

  static const String _apiToken = String.fromEnvironment(
    'HARDCOVER_API_TOKEN',
    defaultValue: '',
  );

  static const _requestTimeout = Duration(seconds: 8);

  Future<SeriesInfo?> findSeriesForBook(String title, String? author) async {
    if (_apiToken.isEmpty) return null;

    try {
      final match = await _resolveVerifiedMatch(title, author);
      if (match == null) return null;

      final info = await _fetchSeries(match.seriesId);
      if (info == null) return null;

      return SeriesInfo(
        seriesName: info.seriesName,
        authorName: info.authorName,
        volumes: info.volumes,
        currentVolumeId: match.bookId,
      );
    } catch (e) {
      debugPrint('Hardcover series lookup failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _query(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiToken',
          },
          body: jsonEncode({'query': query, 'variables': variables}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Hardcover: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['errors'] != null) {
      throw Exception('Hardcover: ${decoded['errors']}');
    }
    return decoded['data'] as Map<String, dynamic>?;
  }

  /// Searches for the book and returns the Hardcover book id + featured
  /// series id of the first candidate that plausibly matches [title]/
  /// [author] - never trusts a top search hit blindly, since Hardcover's
  /// catalog may not contain an exact match and a loosely-related book could
  /// otherwise be cached as "the" series for this book.
  ///
  /// Typesense (the search backend) matches across translated/alternate
  /// titles, so this also works for e.g. a German edition - it resolves to
  /// the same canonical Hardcover book id used in the (English-dominated,
  /// deduped) series volume list.
  Future<({int bookId, int seriesId})?> _resolveVerifiedMatch(
    String title,
    String? author,
  ) async {
    final query = [title, author]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();
    if (query.isEmpty) return null;

    final data = await _query(
      r'''
      query FindBook($q: String!) {
        search(query: $q, query_type: "Book", per_page: 3) {
          results
        }
      }
      ''',
      {'q': query},
    );

    final hits = data?['search']?['results']?['hits'] as List?;
    if (hits == null) return null;

    for (final hit in hits) {
      final document = (hit as Map<String, dynamic>)['document'] as Map<String, dynamic>?;
      if (document == null) continue;

      final candidateTitle = document['title'] as String?;
      final bookId = document['id'] as num?;
      if (candidateTitle == null || bookId == null) continue;

      final alternativeTitles = (document['alternative_titles'] as List?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];
      final authorNames = (document['author_names'] as List?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];

      if (!_looksLikeMatch(
        title,
        author,
        candidateTitle,
        alternativeTitles,
        authorNames,
      )) {
        continue;
      }

      final seriesId = document['featured_series']?['series']?['id'] as num?;
      if (seriesId != null) {
        return (bookId: bookId.toInt(), seriesId: seriesId.toInt());
      }
    }

    return null;
  }

  /// Requires the local title to resemble the candidate's title (primary or
  /// one of its alternative/translated titles), and - if we have a local
  /// author - the candidate's author list to resemble it too.
  bool _looksLikeMatch(
    String localTitle,
    String? localAuthor,
    String candidateTitle,
    List<String> alternativeTitles,
    List<String> authorNames,
  ) {
    final normalizedLocalTitle = normalizeTitle(localTitle);
    if (normalizedLocalTitle.isEmpty) return false;

    final titleMatches = [candidateTitle, ...alternativeTitles]
        .map(normalizeTitle)
        .any(
          (candidate) =>
              candidate.isNotEmpty &&
              (candidate == normalizedLocalTitle ||
                  candidate.contains(normalizedLocalTitle) ||
                  normalizedLocalTitle.contains(candidate)),
        );
    if (!titleMatches) return false;

    final normalizedLocalAuthor = normalizeTitle(localAuthor ?? '');
    if (normalizedLocalAuthor.isEmpty) return true;

    return authorNames.map(normalizeTitle).any(
          (candidate) =>
              candidate.isNotEmpty &&
              (candidate.contains(normalizedLocalAuthor) ||
                  normalizedLocalAuthor.contains(candidate)),
        );
  }

  Future<SeriesInfo?> _fetchSeries(int seriesId) async {
    final data = await _query(
      r'''
      query SeriesVolumes($id: Int!) {
        series(where: {id: {_eq: $id}}) {
          name
          author {
            name
          }
          book_series(
            order_by: [{position: asc}, {book: {users_count: desc}}]
            where: {
              book: {is_partial_book: {_eq: false}}
              compilation: {_eq: false}
            }
          ) {
            position
            details
            book {
              id
              title
              canonical_id
              users_count
            }
          }
        }
      }
      ''',
      {'id': seriesId},
    );

    final seriesList = data?['series'] as List?;
    if (seriesList == null || seriesList.isEmpty) return null;
    final series = seriesList.first as Map<String, dynamic>;

    final bookSeries = series['book_series'] as List? ?? [];
    final volumes = _groupIntoVolumes(bookSeries);
    if (volumes.isEmpty) return null;

    return SeriesInfo(
      seriesName: series['name'] as String,
      authorName:
          (series['author'] as Map<String, dynamic>?)?['name'] as String?,
      volumes: volumes,
    );
  }

  /// Groups book_series rows by their canonical book identity, since
  /// Hardcover models translated/alternate editions as separate "book"
  /// records that merely point at a canonical one via [canonical_id],
  /// rather than as editions of a single work. Position/details can be
  /// tagged inconsistently across such variants, so the canonical id - not
  /// position - is what reliably keeps one volume's candidates together.
  List<SeriesVolume> _groupIntoVolumes(List bookSeries) {
    final groups = <int, List<Map<String, dynamic>>>{};

    for (final bs in bookSeries) {
      final row = bs as Map<String, dynamic>;
      final book = row['book'] as Map<String, dynamic>?;
      if (book == null || book['title'] == null) continue;

      final canonicalId =
          (book['canonical_id'] as num?)?.toInt() ?? (book['id'] as num).toInt();
      groups.putIfAbsent(canonicalId, () => []).add(row);
    }

    final volumes = groups.values.map((rows) {
      rows.sort((a, b) {
        final aUsers = (a['book']['users_count'] as num?) ?? 0;
        final bUsers = (b['book']['users_count'] as num?) ?? 0;
        return bUsers.compareTo(aUsers);
      });

      // The canonical (non-duplicate) row is the source of truth for
      // position/details; its variants can be tagged inconsistently.
      final root = rows.firstWhere(
        (r) => r['book']['canonical_id'] == null,
        orElse: () => rows.first,
      );

      // Box sets/collections often aren't correctly flagged as
      // `compilation` on Hardcover, but they do get a details range like
      // "1-6" instead of a single position - filter those out here since
      // the server-side compilation filter alone doesn't catch them.
      if ((root['details'] as String?)?.contains('-') ?? false) {
        return null;
      }

      return SeriesVolume(
        position: (root['position'] as num?)?.toDouble(),
        details: root['details'] as String?,
        candidates: rows
            .map(
              (r) => SeriesVolumeCandidate(
                hardcoverBookId: (r['book']['id'] as num).toInt(),
                title: r['book']['title'] as String,
              ),
            )
            .toList(),
      );
    }).whereType<SeriesVolume>().toList();

    volumes.sort((a, b) {
      final ap = a.position;
      final bp = b.position;
      if (ap == null && bp == null) return 0;
      if (ap == null) return 1;
      if (bp == null) return -1;
      return ap.compareTo(bp);
    });

    return volumes;
  }
}
