/// One cataloged edition/translation of a series volume. Hardcover tracks
/// these as separate "book" records flagged as duplicates of a canonical
/// one, rather than as editions of a single work - so a volume can have
/// several candidates (English original, German translation, box set, ...)
/// that all represent "the same volume" for our matching purposes.
class SeriesVolumeCandidate {
  final int hardcoverBookId;
  final String title;

  SeriesVolumeCandidate({required this.hardcoverBookId, required this.title});

  factory SeriesVolumeCandidate.fromJson(Map<String, dynamic> json) =>
      SeriesVolumeCandidate(
        hardcoverBookId: json['hardcoverBookId'] as int,
        title: json['title'] as String,
      );

  Map<String, dynamic> toJson() => {
        'hardcoverBookId': hardcoverBookId,
        'title': title,
      };
}

class SeriesVolume {
  final double? position;
  final String? details;

  /// All known editions/translations of this volume, most popular first.
  final List<SeriesVolumeCandidate> candidates;

  SeriesVolume({
    required this.position,
    required this.details,
    required this.candidates,
  });

  /// The most popular candidate - used to display/search this volume when
  /// none of its candidates match anything on the local shelf.
  SeriesVolumeCandidate get primary => candidates.first;

  factory SeriesVolume.fromJson(Map<String, dynamic> json) => SeriesVolume(
        position: (json['position'] as num?)?.toDouble(),
        details: json['details'] as String?,
        candidates: (json['candidates'] as List)
            .map(
              (c) => SeriesVolumeCandidate.fromJson(c as Map<String, dynamic>),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'position': position,
        'details': details,
        'candidates': candidates.map((c) => c.toJson()).toList(),
      };
}

class SeriesInfo {
  final String seriesName;
  final String? authorName;
  final List<SeriesVolume> volumes;

  /// Hardcover book id of the volume this lookup was originally performed
  /// for. Used to flag the current book by id rather than by title string,
  /// since the local title may be a translation.
  final int? currentVolumeId;

  SeriesInfo({
    required this.seriesName,
    required this.authorName,
    required this.volumes,
    this.currentVolumeId,
  });

  factory SeriesInfo.fromJson(Map<String, dynamic> json) => SeriesInfo(
        seriesName: json['seriesName'] as String,
        authorName: json['authorName'] as String?,
        volumes: (json['volumes'] as List)
            .map((v) => SeriesVolume.fromJson(v as Map<String, dynamic>))
            .toList(),
        currentVolumeId: json['currentVolumeId'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'seriesName': seriesName,
        'authorName': authorName,
        'volumes': volumes.map((v) => v.toJson()).toList(),
        'currentVolumeId': currentVolumeId,
      };
}

String normalizeTitle(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[’‘\'`´"]'), '')
    .replaceAll(RegExp(r'[\-:,.]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
