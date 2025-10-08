import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme.dart';
import 'core/models/pattern_model.dart';
import 'features/library/library_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicjalizacja Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(PatternModelAdapter()); // Wymagane przez Hive
  await Hive.openBox<PatternModel>('patterns'); // Otwieramy główne pudełko

  runApp(
    const ProviderScope(
      child: CroftyApp(),
    ),
  );
}

class CroftyApp extends ConsumerWidget {
  const CroftyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Użyjemy Providera do zarządzania motywem (prosty przykład)
    // final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Crofty - Organizer Wzorów',
      debugShowCheckedModeBanner: false,
      theme: crochetLightTheme, // Nasz zdefiniowany motyw
      // themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LibraryScreen(), // 📚 Biblioteka
    const FavoritesScreen(), // ⭐ Ulubione
    const SettingsScreen(), // ⚙️ Ustawienia
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: kMint,
        unselectedItemColor: kBrown.withOpacity(0.6),
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Biblioteka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Ulubione',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ustawienia',
          ),
        ],
      ),
    );
  }
}
// Potrzebujesz jeszcze pustych plików LibraryScreen, FavoritesScreen i SettingsScreen
// aby projekt się kompilował.//mordooo

//github commit push
//git add .
// git commit -m "Twoja zmiana"
// git push origin main