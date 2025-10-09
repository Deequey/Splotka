import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/services/file_service.dart';
import '../../providers/pattern_providers.dart';
import '../details/details_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _addPdf(BuildContext context, WidgetRef ref) async {
    final fileService = ref.read(fileServiceProvider);
    await fileService.pickAndSavePdf();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodano nowy wzór!')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(patternProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Wzory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Szukaj po nazwie...',
                prefixIcon: const Icon(Icons.search, color: kBrown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: patterns.isEmpty
                ? const Center(
                    child: Text('Brak wzorów. Dodaj nowy za pomocą przycisku +.', style: TextStyle(color: kBrown)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: patterns.length,
                    itemBuilder: (context, index) {
                      final pattern = patterns[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(patternId: pattern.id),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(child: Icon(Icons.picture_as_pdf, size: 50, color: kBrown.withAlpha(128))),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  pattern.customName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPdf(context, ref),
        tooltip: 'Dodaj PDF',
        child: const Icon(Icons.add),
      ),
    );
  }
}
