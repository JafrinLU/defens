import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateBlogPage extends StatefulWidget {
  final String prefectId; // correct prefect UID passed
  const CreateBlogPage({super.key, required this.prefectId});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Content are required.')),
      );
      return;
    }

    if (linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a Direct Link for the asset.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('blogs').add({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'prefectId': widget.prefectId, // ✅ save correct prefect UID
        'assetUrl': linkController.text.trim(),
        'assetName': 'Direct Link',
        'createdAt': FieldValue.serverTimestamp(),
      });

      titleController.clear();
      contentController.clear();
      linkController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog uploaded successfully!')),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading blog: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                labelText: "Asset Link (Google Drive, GitHub, etc.)",
                hintText: "Paste full URL here",
                prefixIcon: Icon(Icons.link, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBlog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: _isLoading
                  ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Upload Blog"),
            ),
          ],
        ),
      ),
    );
  }
}
