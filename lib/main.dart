
import 'package:flutter/material.dart';
import 'article_model.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: BeritaScreen(),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Article>> _articlesFuture;

  final ScrollController _scrollController = ScrollController();

  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    _articlesFuture = ApiService().fetchArticles();

    _scrollController.addListener(() {
      setState(() {
        _showButton = _scrollController.offset > 300;
      });
    });
  }

  // Fungsi pull-to-refresh
  Future<void> _refreshArticles() async {
    setState(() {
      _articlesFuture = ApiService().fetchArticles();
    });

    try {
      await _articlesFuture;
    } catch (_) {}
  }

  // Fungsi kembali ke atas
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Berita'),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: FutureBuilder(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final articles = snapshot.data!;

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];

                  return Card(
                    child: ListTile(
                      leading: article.urlToImage != null
                          ? Image.network(
                              article.urlToImage!,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image),

                      title: Text(article.title),

                      subtitle: Text(
                        article.description ?? 'Tidak ada deskripsi',
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 500,
                    child: Center(
                      child: Text(
                        'Terjadi kesalahan: ${snapshot.error}',
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),

      // Tombol kembali ke atas
      floatingActionButton: _showButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}