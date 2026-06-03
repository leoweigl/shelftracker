# ShelfTracker — Roadmap

Persönliche Flutter-App zum Verwalten der eigenen Büchersammlung:
Bücher suchen, bewerten, dokumentieren und entscheiden, ob behalten oder verkaufen.

Dieses Dokument hält den Entwicklungsstand fest und sammelt Ideen für kommende Stages.
Erledigte Stages werden abgehakt, neue Ideen unten ergänzt.

---

## Erledigt

- [x] **Stage 1 — Statische Bücherliste**
- [x] **Stage 2 — StarRating-Widget** (Half-Star-Unterstützung, "noch nicht bewertet")
- [x] **Stage 3 — Open Library API** (`search.json`)
- [x] **Stage 4 — Lokale Persistenz (Drift / SQLite)**
  `BookRepository` als zentrale DB-Schicht, reaktive UI über `StreamBuilder` + `watchAll()`.
- [x] **Stage 5 — Detail-Screen** (interaktives Rating, Keep/Sell, reaktiv über `watchById()`)

- [x] **Stage 6 — Politur**
  - [x] Such-Debouncing (400 ms via `Timer`)
  - [x] Cover-Caching (`cached_network_image`)
  - [x] ISBN-Barcode-Scanner (`mobile_scanner`, EAN-13/EAN-8, `ScannerScreen`, `searchByIsbn()`)
  - [x] Duplikat-Prüfung in `insertFromBook` (Titel + Autor, "ist schon im Regal")

- [x] **Stage 7 — Sortierung & Detail-Politur**
  - [x] Sortierung: Titel, Autor, Bewertung, Behalten, Hinzugefügt (DB-seitig via `orderBy`)
  - [x] Richtungs-Toggle (auf-/absteigend)
  - [x] Datum-Formatierung (`dd.MM.yyyy` via `intl`)
  - [x] Lösch-Bestätigung über wiederverwendbaren `confirmDialog` in `utils/dialogs.dart`

- [x] **Stage 8 — Google Books als zusätzliche API**
  - [x] `OpenLibraryService` + `GoogleBooksService` als eigene Klassen
  - [x] `BookApiService` als Orchestrator — **Google Books zuerst** (bessere deutsche Abdeckung), Open Library als Fallback
  - [x] `Book.fromGoogleBooks` (http→https Cover-Fix, `publishedDate`-Parsing)
  - [x] Mindestlänge 3 Zeichen in der Suche
  - [x] Fehler (z. B. 429) werden gefangen statt Crash
  - [x] Google Books API-Key via `--dart-define=GOOGLE_BOOKS_API_KEY` (nicht im Repo), API auf Books beschränkt

- [x] **Theme & Status-Anzeige**
  - [x] Seed-Color `Colors.blueGrey` (ruhiges Theme), Material 3 generiert Palette automatisch
  - [x] "Verkaufen"-Pill in der Liste (tertiaryContainer, nur wenn nicht behalten)
  - [x] Trennlinien zwischen Listeneinträgen (`ListView.separated`, `indent: 72`, `outlineVariant`)

- [x] **Stage 9 (Etappen 1–4) — Kategorien / Tags**
  - [x] Datenmodell: Tabellen `Categories` (name unique) + `BookCategories` (n:m-Verknüpfung), Foreign Keys mit `onDelete: cascade`
  - [x] DB-Migration `schemaVersion` 1 → 2 (`MigrationStrategy` mit `onUpgrade`, bestehende Bücher bleiben erhalten)
  - [x] Repository-Methoden: `getOrCreateCategory` (case-insensitiv), `watchCategories`, `addCategoryToBook`, `removeCategoryFromBook`, `watchCategoriesForBook` (JOIN), `deleteCategory`
  - [x] API-Genres als Vorschlag: `categories` (Google Books, an "/" gesplittet) bzw. `subject` (Open Library, `.take(5)`) beim Hinzufügen übernommen; OL-`fields` um `subject` erweitert
  - [x] Kategorie-Editor-Dialog (eigenes StatefulWidget): zugewiesene Kategorien als Chips, Suchfeld, alphabetische Auswahlliste, "neu anlegen" aus der Suche heraus
  - [x] Kategorie-Chips im Detail-Screen

- [x] **Favoriten / Lieblingsbücher**
  - [x] `isFavorite`-Spalte in `Books`, DB-Migration `schemaVersion` 2 → 3 (`addColumn` mit Default)
  - [x] Repository: `setFavorite(id, value)`
  - [x] Herz-Icon im Detail-Screen (AppBar, `primary` mit Transparenz statt knallrot)
  - [x] "Favorit"-Pill in der Liste (Outline-Stil)

- [x] **Detail-Screen Layout vereinheitlicht**
  - Hero-Bereich (Cover/Titel/Autor) zentriert, alle Sektionen darunter linksbündig
  - Switch `contentPadding: EdgeInsets.zero` für bündige Ausrichtung

---

## Offen / zurückgestellt

- [ ] **Stage 9 — Etappe 5: Kategorien-Navigation & Filter**
  - Eigener Kategorien-Übersichts-Screen (Ordner-Ansicht); Antippen öffnet gefilterte Bücherliste
  - Hängt mit dem Dashboard zusammen (Kachel "Kategorien")
  - Repository-Methode "Bücher einer Kategorie" (JOIN in Gegenrichtung) noch zu bauen

---

## NEU geplant — großer Umbau: Leseprotokoll + Dashboard

### Leseprotokoll (Reading Log)
Zusätzlich zum **Bücherregal** (= aktueller Bestand) ein **Leseprotokoll** (= Lese-Historie).

- [ ] Eigene Ansicht "Leseprotokoll" neben dem Bücherregal
- [ ] Ein Buch wird ins Leseprotokoll an dem **Datum aufgenommen, an dem man es ausgelesen hat**
- [ ] Dieses "Ausgelesen am"-Datum soll **nachträglich änderbar** sein
- [ ] Im Leseprotokoll wird das "Ausgelesen am"-Datum angezeigt — **kein** Löschen-Button
- [ ] "Verkauft"-/"nicht mehr im Besitz"-Anzeige im Leseprotokoll (Begriff noch festzulegen)
- [ ] Ein Buch kann **mehrfach** im Leseprotokoll vorkommen (mehrmals gelesen → mehrere Einträge)

  **Offene Design-Fragen (vor Implementierung klären):**
  - Eigene Tabelle (z. B. `ReadingLog`) mit Lesedatum + Bezug zum Buch — Buch kann mehrere Einträge haben (1:n)
  - Was passiert mit Protokoll-Einträgen, wenn das Buch aus dem Regal entfernt/verkauft wird?
    → Eintrag soll bleiben (man hat es ja gelesen), mit Markierung "nicht mehr im Besitz".
    Das bedeutet: Protokoll-Eintrag darf nicht per `cascade` mitgelöscht werden bzw. relevante Buchdaten
    (Titel/Autor/Cover) müssen erhalten bleiben — Konzept noch festzulegen.
  - Verhältnis Bücherregal ↔ Leseprotokoll sauber definieren (Bestand vs. Historie)

### Dashboard-Umbau (ersetzt den bisherigen Dashboard-Entwurf)
- [ ] Dashboard als Startbildschirm mit Kacheln (2×2-Raster, große Karten)
- [ ] **Hinzufügen auf EINE Kachel beschränken** (nicht mehr getrennt Suche + Scanner)
- [ ] Diese Hinzufügen-Kachel führt zu einem **Menüpunkt/Auswahl**: ISBN-Scan **oder** manuelle Suche
- [ ] **Leseprotokoll** als eigene Dashboard-Kachel
- [ ] Voraussichtliche Kacheln: Bücherregal · Hinzufügen (→ Scan/Suche) · Leseprotokoll · Kategorien
- [ ] Such-/Scan-Logik nach `utils/book_actions.dart` auslagern (war für altes Dashboard geplant, gilt weiter)

### Suche erweitern
- [ ] **ISBN-Eingabe direkt in der Suchleiste** ermöglichen (SearchScreen erkennt, ob die Eingabe eine ISBN ist, und nutzt dann `searchByIsbn`)

---

## Geplant — DNB (Deutsche Nationalbibliothek) als dritte Quelle
- [ ] Pflichtexemplar-Datenbank: vollständigste Quelle für deutsche Titel
- [ ] SRU-Schnittstelle (`https://services.dnb.de/sru/dnb?...`), XML statt JSON, CQL-Syntax, wenig Cover
- [ ] `DnbService` als dritter Service im Orchestrator; Cover ggf. aus Google Books/Open Library nachladen

---

## Weitere Ideen (unsortiert, für später)
- [ ] Filter nach Status (gelesen / ungelesen, behalten / verkaufen)
- [ ] Suchfeld / Filter innerhalb der eigenen Bücherliste
- [ ] "Gelesen"-Statistik (Anzahl gelesen, Durchschnittsbewertung etc.) — passt thematisch zum Leseprotokoll
- [ ] Export der Liste (CSV / JSON)
- [ ] Cover-Schatten / Card-Wrapper im Detail-Screen (BoxShadow oder Card `elevation`)
- [ ] Sortier-Einstellung über App-Neustarts persistieren (`shared_preferences`)
- [ ] CLAUDE.md auf aktuellen Stand bringen (Scanner, Duplikat-Prüfung, Sortierung, Google Books, Kategorien, Favoriten fehlen dort)
- [ ] Bei breiterer Verteilung (>~10 Nutzer): Backend-Proxy für Google Books API-Key (z. B. Cloudflare Workers)
- [ ] API-Key auf Android-Apps mit SHA-1-Fingerprint einschränken
