import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  final String categoryTitle;

  const CategoryPage({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text(
          "All prefects of this category will appear here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
