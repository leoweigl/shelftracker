import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'database/book_repository.dart';
import 'screens/book_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

late final AppDatabase database;
late final BookRepository bookRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  bookRepository = BookRepository(database);

  await initializeDateFormatting('de_DE');
  runApp(const ShelfTrackerApp());
}

class ShelfTrackerApp extends StatelessWidget {
  const ShelfTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const BookListScreen(),
    );
  }
}