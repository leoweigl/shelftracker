# ShelfTracker — Roadmap

Persönliche Flutter-App zum Verwalten der eigenen Büchersammlung:
Bücher suchen, bewerten, als gelesen markieren und entscheiden, ob behalten oder verkaufen.

Dieses Dokument hält den Entwicklungsstand fest und sammelt Ideen für kommende Stages.
Erledigte Stages werden abgehakt, neue Ideen unten ergänzt.

---

## Erledigt

- [x] **Stage 1 — Statische Bücherliste**
  Erste Liste mit fest eingebauten Beispielbüchern.

- [x] **Stage 2 — StarRating-Widget**
  Eigenes Bewertungs-Widget mit Half-Star-Unterstützung.

- [x] **Stage 3 — Open Library API**
  Bücher über die Open-Library-Suche (`search.json`) finden und hinzufügen.

- [x] **Stage 4 — Lokale Persistenz (Drift / SQLite)**
  Bücher dauerhaft speichern. `BookRepository` als zentrale DB-Schicht,
  reaktive UI über `StreamBuilder` + `watchAll()`.

- [x] **Stage 5 — Detail-Screen**
  Eigener Screen pro Buch mit interaktivem Rating, Read/Finished-Toggle
  und Keep/Sell-Toggle. Reaktiv über `watchById()`.

- [x] **Stage 6 — Politur**
  - [x] Such-Debouncing (400 ms via `Timer` im `SearchScreen`) — weniger API-Calls
  - [x] Cover-Caching (`cached_network_image` statt `Image.network`) in Listen-, Detail- und Such-Screen
  - [x] ISBN-Barcode-Scanner (`mobile_scanner`, EAN-13/EAN-8, `ScannerScreen`, `searchByIsbn()` im `BookApiService`)
  - [x] Duplikat-Prüfung: `insertFromBook` prüft auf gleichen Titel + Autor, fügt nichts ein bei Duplikat ("ist schon im Regal")

- [x] **Stage 7 — Sortierung & Detail-Politur**
  - [x] Sortierfunktionen: Titel, Autor, Bewertung, Behalten, Hinzugefügt
  - [x] Richtungs-Toggle (auf-/absteigend) per IconButton
  - [x] Sortier-Auswahl via PopupMenuButton in der AppBar
  - [x] DB-seitige Sortierung über Drifts `orderBy` (effizient, mit null-handling und Tiebreakern)
  - [x] Datum-Anzeige im Detail-Screen formatiert (`dd.MM.yyyy` via `intl`)
  - [x] Datum dezent gestylt und auf Höhe der SwitchListTile eingerückt
  - [x] Switch-Subtitle aufgeräumt (kein doppeltes "Behalten")
  - [x] Lösch-Bestätigung mit wiederverwendbarem `confirmDialog` in `utils/dialogs.dart`
  - [x] Confirm-Dialog in BookListScreen und BookDetailScreen verwendet

- [x] **Stage 8 — Google Books als zusätzliche API**
  - [x] Service-Aufteilung: `OpenLibraryService` + `GoogleBooksService` als eigene Klassen
  - [x] `BookApiService` als Orchestrator (Google Books zuerst, Fallback auf Open Library bei leerem Ergebnis oder Fehler)
  - [x] `Book.fromGoogleBooks` Factory mit http→https Cover-URL-Fix und uneinheitlicher `publishedDate`-Behandlung
  - [x] Mindestlänge 3 Zeichen im SearchScreen (weniger API-Last)
  - [x] Google-Books-Fehler (z. B. 429) werden gefangen statt zu crashen
  - [x] Google Books API-Key via `--dart-define=GOOGLE_BOOKS_API_KEY` (nicht im Source Code, IntelliJ-Run-Configuration)
  - [x] API-Einschränkung in Google Cloud Console: nur Books API erlaubt

---

## Geplant — Stage 9 (Ideen)

- [ ] **DNB (Deutsche Nationalbibliothek) API als dritte Quelle**
  - Pflichtexemplar-Datenbank: jedes in Deutschland erschienene Buch ist erfasst → vollständigste Quelle für deutsche Titel
  - Endpoint: SRU/SRW-Schnittstelle, z. B. `https://services.dnb.de/sru/dnb?...`
  - Aufwand: XML statt JSON parsen, eigene Such-Syntax (CQL), weniger/keine Cover-Bilder
  - Idee: `DnbService` als dritter Service neben Open Library und Google Books;
    der `BookApiService`-Orchestrator entscheidet je nach Heuristik (z. B. erstmal weiter Google Books,
    DNB als Fallback bei deutschen ISBNs oder bei leerem Ergebnis)
  - Cover-Lücken könnten über bestehende Quellen (Google Books / Open Library)
    nachgeladen werden, falls man Lust auf ein Hybrid-Setup hat

---

## Weitere Ideen (unsortiert, für später)

- [ ] Filter nach Status (gelesen / ungelesen, behalten / verkaufen)
- [ ] Suchfeld / Filter innerhalb der eigenen Bücherliste
- [ ] "Gelesen"-Statistik (Anzahl gelesen, Durchschnittsbewertung etc.)
- [ ] Export der Liste (z. B. als CSV oder JSON)
- [ ] Cover-Schatten / Card-Wrapper im Detail-Screen für mehr Tiefe
- [ ] Sortier-Einstellung über App-Neustarts persistieren (`shared_preferences`)
- [ ] CLAUDE.md auf aktuellen Stand bringen (Scanner, Duplikat-Prüfung, Sortierung, Google Books fehlen dort noch)
- [ ] Bei breiterer Verteilung (mehr als ~10 Nutzer): Backend-Proxy für Google Books API-Key (z. B. Cloudflare Workers)
- [ ] API-Key auf Android-Apps mit SHA-1-Fingerprint einschränken
