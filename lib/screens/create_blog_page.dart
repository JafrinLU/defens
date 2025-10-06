// updated create_blog_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBlogPage extends StatefulWidget {
  final String userId;

  const CreateBlogPage({super.key, required this.userId});

  @override
  State<CreateBlogPage> createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final linkController = TextEditingController();


  bool _isLoading = false;

  Future<void> _saveBlog() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Content are required.')));
      return;
    }

    if (linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a Direct Link for the asset.')));
      return;
    }

    setState(() => _isLoading = true);


    await FirebaseFirestore.instance.collection('blogs').add({
      'title': titleController.text,
      'content': contentController.text,
      'prefectId': widget.userId,
      'assetUrl': linkController.text.trim(),
      'assetName': linkController.text.isNotEmpty ? 'Direct Link' : null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    titleController.clear();
    contentController.clear();
    linkController.clear();

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blog uploaded successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Blog"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(labelText: "Content"),
            ),

            const SizedBox(height: 20),


            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: "Asset Link (e.g., Google Drive, GitHub)",
                hintText: "Paste full URL here",
                prefixIcon: Icon(Icons.link, color: Colors.pink),
              ),
            ),

            const SizedBox(height: 30),


            ElevatedButton(
              onPressed: _isLoading ? null : _saveBlog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Upload Blog"),
            ),
          ],
        ),
      ),
    );
  }
}