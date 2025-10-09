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

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(PatternModelAdapter());
  await Hive.openBox<PatternModel>('patterns');

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
    // Nasłuchujemy zmian w themeNotifierProvider
    final isDarkMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Crofty - Organizer Wzorów',
      debugShowCheckedModeBanner: false,
      theme: crochetLightTheme, // Motyw jasny
      darkTheme: crochetDarkTheme, // Motyw ciemny
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Wybieramy tryb
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
    const LibraryScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // Usunięto zduplikowane ustawienia kolorów, teraz będą pobierane z motywu
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


//NIE USUWAJ LINII PONIZEJ
//git add .
//git commit -m "zmiana"
//git push origin main