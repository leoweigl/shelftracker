# ShelfTracker

A personal Flutter app for managing your own book collection: search, rate, document,
and decide whether to keep or sell each book.

## Features

- **Bookshelf** — your collection with star ratings (half-star support), keep/sell status
- **Wishlist** — with pre-order status and duplicate detection (warns if a book is
  already on your shelf or wishlist)
- **Reading log** — tracks books you've read with a date, independent of current
  ownership status
- **Categories/tags** — freely assignable, with suggestions pulled from the book API
- **Search & scan** — title/author search plus ISBN barcode scanning (`mobile_scanner`),
  automatic ISBN detection in the search field
- **Multiple data sources** — Google Books as primary API, Open Library as fallback
- **Favorites**, cover caching, sorting by several criteria

## Tech stack

- **Flutter** (Dart) — Android & iOS
- **Drift** (SQLite) for local, reactive persistence (`StreamBuilder`-based)
- **Google Books API** (primary) + **Open Library API** (fallback) for book data
- `mobile_scanner`, `cached_network_image`, `intl`

## Setup

```bash
flutter pub get
flutter run --dart-define=GOOGLE_BOOKS_API_KEY=your_api_key --dart-define=HARDCOVER_API_TOKEN=your_token
```

The `--dart-define` for Google Books is required for it to work as the primary data
source. Without a key, the app automatically falls back to Open Library (still works,
but e.g. won't have book descriptions).

`HARDCOVER_API_TOKEN` is optional and enables the "Series" section on the book detail
screen (suggests other volumes in a book's series via the Hardcover API). Get a
personal token from your Hardcover account's API settings page. Without it, the
series section is simply hidden. Neither key is included in this repo.

The same applies to release builds:

```bash
flutter build apk --release --dart-define=GOOGLE_BOOKS_API_KEY=your_api_key --dart-define=HARDCOVER_API_TOKEN=your_token
```

## Project structure

```
lib/
├── database/     # Drift schema (app_database.dart) + repository (book_repository.dart)
├── models/       # Book, BookStatus, WishlistAddResult, ...
├── screens/      # Dashboard, Bookshelf, Wishlist, Reading Log, Search, Scanner, Detail
├── services/     # BookApiService (orchestrator), GoogleBooksService, OpenLibraryService
├── utils/        # book_actions.dart (add flow), dialogs.dart
└── widgets/      # StarRating
```

## Status & roadmap

Development status, open items, and planned features live in
[`ROADMAP.md`](./ROADMAP.md) — updated after each major feature.

Project-specific context for continued development with Claude lives in
[`CLAUDE.md`](./CLAUDE.md).

