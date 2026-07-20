# ShelfTracker — Roadmap

Persönliche Flutter-App zum Verwalten der eigenen Büchersammlung:
Bücher lesen, bewerten, dokumentieren und entscheiden, ob behalten oder verkaufen.

Dieses Dokument hält den Entwicklungsstand fest und sammelt Ideen für kommende Stages.
Erledigte Stages werden abgehakt, neue Ideen unten ergänzt.

---

## Erledigt

- [x] **Stage 1 — Statische Bücherliste**

- [x] **Stage 2 — StarRating-Widget**
  Half-Star-Unterstützung (0.5-Schritte), GestureDetector mit Tap + Drag.

- [x] **Stage 3 — Open Library API**
  Bücher über `/search.json` suchen und hinzufügen.

- [x] **Stage 4 — Lokale Persistenz (Drift / SQLite)**
  `BookRepository` als zentrale DB-Schicht, reaktive UI über `StreamBuilder` + `watchAll()`.

- [x] **Stage 5 — Detail-Screen**
  Interaktives Rating, Keep/Sell-Toggle, reaktiv über `watchById()`.
  Layout: Hero-Bereich (Cover/Titel/Autor) zentriert, Sektionen darunter linksbündig.

- [x] **Stage 6 — Politur**
  - [x] Such-Debouncing (400 ms via `Timer`, Mindestlänge 3 Zeichen)
  - [x] Cover-Caching (`cached_network_image` in Liste, Detail, Suche)
  - [x] ISBN-Barcode-Scanner (`mobile_scanner`, EAN-13/EAN-8, `ScannerScreen`)
  - [x] Duplikat-Prüfung via Titel + Autor

- [x] **Stage 7 — Sortierung**
  - [x] 5 Kategorien: Titel, Autor, Bewertung, Behalten, Hinzugefügt (DB-seitig via `orderBy`)
  - [x] Richtungs-Toggle (auf-/absteigend)
  - [x] `confirmDialog` in `utils/dialogs.dart` (wiederverwendbar)
  - [x] Datum-Formatierung (`dd.MM.yyyy` via `intl`)

- [x] **Stage 8 — Google Books als zusätzliche API**
  - [x] `OpenLibraryService` + `GoogleBooksService` als eigene Klassen
  - [x] `BookApiService` als Orchestrator — Google Books zuerst, Open Library als Fallback
  - [x] `Book.fromGoogleBooks` (http→https Cover-Fix, `publishedDate`-Parsing)
  - [x] Fehler (z. B. 429) werden gefangen statt Crash
  - [x] API-Key via `--dart-define=GOOGLE_BOOKS_API_KEY` (nicht im Repo)

- [x] **Theme & Status-Anzeige**
  - [x] Seed-Color `Colors.blueGrey`, Material 3 generiert Palette automatisch
  - [x] „Verkaufen"-Pill (tertiaryContainer), „Favorit"-Pill (secondaryContainer) in der Liste
  - [x] Trennlinien (`ListView.separated`, `indent: 72`, `outlineVariant`)

- [x] **Stage 9 — Kategorien / Tags**
  - [x] Tabellen `Categories` + `BookCategories` (n:m, `onDelete: cascade`), schemaVersion → 2
  - [x] Repository: `getOrCreateCategory` (case-insensitiv), `watchCategories`, `addCategoryToBook`,
    `removeCategoryFromBook`, `watchCategoriesForBook` (JOIN), `deleteCategory`
  - [x] API-Genres als Vorschlag beim Erfassen (Google Books + Open Library)
  - [x] `_CategoryEditorDialog`: zugewiesene Chips, Suchfeld, alphabetische Liste, „neu anlegen" inline

- [x] **Favoriten**
  - [x] `isFavorite`-Spalte in `Books`, schemaVersion → 3
  - [x] Herz-Icon in AppBar (BookDetailScreen + LogDetailScreen)
  - [x] „Favorit"-Pill in Bücherliste und Leseprotokoll

- [x] **Stage 10 — Leseprotokoll + Dashboard + Soft Delete**

  **Soft Delete:**
  - [x] `isDeleted`-Spalte in `Books`, schemaVersion → 5
  - [x] `delete()` setzt `isDeleted = true` statt hartem Löschen
  - [x] `watchAll()` filtert `isDeleted = false`
  - [x] `getOrCreateBookId()` reaktiviert soft-gelöschte Bücher (case-insensitive Suche via `.lower()`)

  **Leseprotokoll:**
  - [x] `ReadingLog`-Tabelle: Snapshot-Felder + nullable `bookId` (`onDelete: setNull`) + `readDate`,
    schemaVersion → 4
  - [x] `ReadingLogItem` mit LEFT JOIN auf `Books` für `userRating`, `isFavorite`, `inShelf`
  - [x] Repository: `logBookAsRead()`, `watchReadingLog()`, `watchReadingLogById()`,
    `updateReadDate()`, `deleteLogEntry()`
  - [x] `ReadingLogScreen`: Cover, Bewertung, Favorit-Pill, „nicht mehr im Besitz"-Pill,
    Lesedatum (antippbar)
  - [x] `LogDetailScreen`: verschachtelte StreamBuilder (`ReadingLogEntry` + `BookEntry?`),
    Bewertung nur wenn `book != null`

  **Dashboard (erster Stand):**
  - [x] `DashboardScreen` als Startbildschirm, zwei Sektionen: „Leseprotokoll" / „Buchverwaltung"
  - [x] 2×2-Kacheln mit `_CardGrid`, `_SectionHeader`, `_DashboardCard`
  - [x] „Gelesenes Buch erfassen" öffnet Dialog mit Scan / Suche-Auswahl
  - [x] `book_actions.dart`: `logReadViaSearch`, `logReadViaScanner`, `showLogReadOptions`
  - [x] Repository-Cleanup: `insertFromBook`, `setFinished`, `getAll` entfernt

- [x] **Stage 11 — Wunschliste + Buch-Status + Dashboard-Umbau**
  - [x] `BookStatus`-Enum (`wishlist`, `preordered`, `owned`) in `lib/models/book_status.dart`
  - [x] `status`-Spalte in `Books`, schemaVersion → 6, Migration via `addColumn`
  - [x] `watchAll()` mit optionalem `status`-Filter
  - [x] `setStatus()`, `watchWishlist()`, `addToWishlist()`, `addToShelf()` im Repository
  - [x] `getOrCreateBookId()` setzt wishlist/preordered-Bücher beim Erfassen auf `owned`
  - [x] `logBookAsReadFromEntry()` für Bücher die bereits in der DB sind
  - [x] `WishlistScreen` mit Filter-Pills (All / Wishlisted / Pre-ordered) und `pickMode`
  - [x] `BookListScreen` zeigt nur noch `owned`-Bücher
  - [x] `book_actions.dart`: `addToWishlistViaSearch`, `addToShelfViaSearch`,
    `addToShelfViaScanner`, `showAddOptions`, „From Wishlist"-Option in `showLogReadOptions`
  - [x] Dashboard-Umbau: 2×2 Leseprotokoll + 2×2 Buchverwaltung (Regal, Wunschliste,
    Hinzufügen, Kategorien)

- [x] **Bug-Fixes & Wishlist-Erweiterungen**
  - [x] `addToWishlist()`: soft-deleted Bücher werden korrekt reaktiviert mit `status = wishlist`
  - [x] `BookDetailScreen`: Bewertung, Favorit-Herz und Keep/Sell-Toggle werden für
    `wishlist`/`preordered`-Bücher ausgeblendet (`isOwned`-Flag)
  - [x] Klappentext (`description`) in `Book`-Modell und `Books`-Tabelle ergänzt,
    schemaVersion → 7; wird von Google Books API befüllt und im `BookDetailScreen`
    für Wunschlisten-Bücher angezeigt
  - [x] Pre-order-Status in `WishlistScreen`: "Mark as pre-ordered" / "Remove pre-order"
    im Popup-Menü; `preordered`-Pill inline im Subtitle der Listeneinträge
  - [x] UI-Labels auf Englisch vereinheitlicht
  - [x] Klärung: Kategorien bleiben beim Soft-Delete erhalten (kein Bug, sondern
    bewusstes Verhalten) — beim Reaktivieren eines gelöschten Buchs (Regal oder
    Wunschliste) sollen die früher zugewiesenen Kategorien zurückkehren, statt
    verloren zu gehen.
  - [x] ISBN-Eingabe in der Suchleiste: `SearchScreen` erkennt ISBN (10/13 Ziffern,
    getrimmt) und ruft `searchByIsbn()` statt der normalen Titel/Autor-Suche auf.
  - [x] Such- und Filtermöglichkeit in `BookListScreen` und `ReadingLogScreen`: Such-Icon
    in der AppBar klappt ein `TextField` auf, filtert client-seitig nach Titel/Autor.
    `ReadingLogScreen` dafür von `StatelessWidget` zu `StatefulWidget` umgebaut.
    Streams (`_bookStream` / `_logStream`) werden in `initState()` einmalig erzeugt statt
    live in `build()`, um Neuladen/Flackern beim Umschalten der Suche zu vermeiden.

- [x] **Add-Flow vereinheitlicht + Dashboard vereinfacht**
  - [x] `book_actions.dart` komplett neu geschrieben: ein einziger Einstiegspunkt
    `showAddBookOptions()` — erst Scan/Suche (`_findBook`), dann Auswahl „Save as“
    (Already read / To shelf / Wishlist) über `_showSaveAsDialog`. ISBN-Scan ist jetzt
    auch für Wishlist-Einträge möglich (bewusste Änderung gegenüber der ursprünglichen
    Stage-11-Einschränkung „nur Suche“).
  - [x] Alte, redundante Funktionen entfernt: `logReadViaSearch`, `logReadViaScanner`,
    `logReadFromWishlist` (unbenutzt), `_logAndConfirm`, `showLogReadOptions`,
    `addToShelfViaSearch`, `addToShelfViaScanner`, `showAddOptions`,
    `_showAddToShelfOptions`
  - [x] `WishlistAddResult`-Enum (`added` / `alreadyOwned` / `alreadyWishlisted` /
    `alreadyPreordered`) in `lib/models/wishlist_add_result.dart`; `addToWishlist()`
    gibt jetzt Auskunft statt stillschweigend nichts zu tun — Nutzer bekommt eine
    passende Meldung, wenn ein Buch beim Hinzufügen zur Wishlist bereits besessen,
    gewunschlistet oder vorbestellt ist
  - [x] `DashboardScreen`: keine Sektionsüberschriften mehr, ein einziges 2×2-Grid
    (Reading Log, Bookshelf, Add Book, Wishlist); Kategorien-Kachel vorerst entfernt
    (kommt zurück, sobald die Kategorien-Navigation gebaut ist); „Log Read“-Kachel
    entfernt, läuft jetzt über „Add Book“
  - [x] Aufgeräumt: unbenutzter Import in `book_list_screen.dart`, falscher Tooltip
    „Log read book“ → „Add to wishlist“ in `WishlistScreen`

---

---

## Offen / zurückgestellt

- [ ] **Kategorien-Navigation (Stage 9 — Etappe 5)**
  Eigener Kategorien-Übersichts-Screen; Antippen öffnet gefilterte Bücherliste.
  Repository-Methode „Bücher einer Kategorie" (JOIN in Gegenrichtung) noch zu bauen.
  Verdrahtet nicht mehr automatisch — benötigt eine neue Kachel im Dashboard-Grid
  (aktuell 2×2 mit 4 Einträgen; Layout müsste bei 5 Kacheln angepasst werden).

- [ ] **`getOrCreateBookId` Rückgabe verbessern**
  `Future<(int, BookLogResult)>` mit Enum `created | reactivated | alreadyInShelf` für
  differenziertere Snackbar-Texte in `_logAndConfirm`.

---

## Geplant — Stage 12: Buchreihen

### Konzept

Anhand eines Buchs die zugehörige Reihe ableiten und andere Bände anzeigen.
Pro Band ist sichtbar, welchen Status er hat (wishlist / owned / gelesen / nicht vorhanden).

### Datenquelle

- **Hardcover.app API** — vollständigste freie Reihen-Datenbank, speziell für Bücher gebaut
- Als vierter Service im `BookApiService`-Orchestrator
- Abruf lazy (nur wenn Buch-Detailscreen geöffnet wird), Ergebnis gecacht

### Geplante Änderungen

- [ ] `HardcoverService` in `lib/services/`
- [ ] Reihen-Sektion im `BookDetailScreen`: Bandnummer, Titel, Cover, Status-Pill
- [ ] Tippen auf einen Band → öffnet `BookDetailScreen` (falls vorhanden) oder Suche (falls nicht)
- [ ] Optional: eigener `SeriesScreen` für die Gesamtübersicht einer Reihe

---

## Geplant — DNB (Deutsche Nationalbibliothek)
- [ ] Pflichtexemplar-Datenbank: vollständigste Quelle für deutsche Titel
- [ ] SRU-Schnittstelle, XML statt JSON, CQL-Syntax, kaum Cover
- [ ] `DnbService` als dritter Service im Orchestrator

---

## Weitere Ideen (unsortiert, für später)
- [ ] Klappentext auch für owned-Bücher anzeigen (sofern vorhanden)
- [ ] Filter nach Status (behalten / verkaufen) in der Bücherliste
- [ ] Lese-Statistik (Anzahl gelesen, Durchschnittsbewertung etc.)
- [ ] Export der Liste (CSV / JSON)
- [ ] Cover-Schatten im Detail-Screen (Card mit `elevation`)
- [ ] Sortier-Einstellung über App-Neustarts persistieren (`shared_preferences`)
- [ ] Bei breiterer Verteilung: Backend-Proxy für Google Books API-Key
- [ ] API-Key auf Android-Apps mit SHA-1-Fingerprint einschränken
- [ ] CLAUDE.md auf aktuellen Stand bringen
- [ ] Unit-Tests für `book_repository.dart` (v. a. `addToWishlist()`, `getOrCreateBookId()`,
  Soft-Delete/Kategorien-Logik) — In-Memory-Testdatenbank für Drift als Einstieg
