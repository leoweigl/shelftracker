# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Regenerate Drift ORM code after schema changes
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Architecture

Flutter app with Material 3 theming. All UI text is in German (target audience).

**Dependency injection pattern:** `main.dart` creates `AppDatabase` and `BookRepository` as top-level globals, passed down to screens via constructor arguments.

**Data layer:**
- `lib/database/app_database.dart` — Drift ORM schema. The `Books` table definition generates `BookEntry` and `BooksCompanion` classes via `build_runner`. After any schema change, run `build_runner build`.
- `lib/database/book_repository.dart` — All DB access goes through here. `watchAll()` returns a `Stream<List<BookEntry>>` for reactive UI updates.

**External data:** `lib/services/book_api_service.dart` calls the OpenLibrary search API (`https://openlibrary.org/search.json`). `lib/models/book.dart` parses the response and maps `cover_i` to an image URL on `covers.openlibrary.org`.

**Screens:**
- `BookListScreen` — main screen, uses `StreamBuilder` on `BookRepository.watchAll()` to reactively display saved books.
- `SearchScreen` — calls `BookApiService`, user selects a result, which is then inserted via `BookRepository.insertFromBook()` and the screen is popped with the new book.

**Database:** SQLite via `drift_flutter`, stored at the platform default path. Schema version 1, single `Books` table. When updating the schema, increment `schemaVersion` in `AppDatabase` and add a migration in `migration`.
