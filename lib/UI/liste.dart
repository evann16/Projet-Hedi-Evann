import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail.dart'; 

class Article {
  final int id;
  final String title;
  final String image;
  final double price;
  final String description;

  Article({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.description,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? "",
      image: (json['images'] != null && json['images'].length > 0)
          ? json['images'][0]
          : "https://via.placeholder.com/150",
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? "",
    );
  }
}

// --------- PAGE LISTE ---------
class ListeArticles extends StatelessWidget {
  const ListeArticles({super.key});

  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http
          .get(Uri.parse("https://api.escuelajs.co/api/v1/products"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => Article.fromJson(e)).toList();
      } else {
        debugPrint("Erreur HTTP : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des articles")),
      body: FutureBuilder<List<Article>>(
        future: fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final articles = snapshot.data ?? [];

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(article.image),
                  ),
                  title: Text(article.title),
                  subtitle: Text("${article.price} €"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}