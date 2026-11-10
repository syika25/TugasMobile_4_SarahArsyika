import 'dart:convert';
import 'article_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=apple&from=2026-10-27&to=2026-10-27&sortBy=popularity&apiKey=589f26cc01f64da786167d1f79fac595'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List articlesJson = json['articles'];

      return articlesJson.map((item) => Article.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil berita');
    }
  }
}