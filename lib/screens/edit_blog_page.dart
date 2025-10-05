import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'blog_model.dart';

class EditBlogPage extends StatefulWidget {
  final BlogModel blog;

  const EditBlogPage({super.key, required this.blog});

  @override
  State<EditBlogPage> createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog.title);
    _contentController = TextEditingController(text: widget.blog.content);
  }

  Future<void> _updateBlog() async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blog.id)
        .update({
      'title': _titleController.text,
      'content': _contentController.text,
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Blog Updated")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Blog"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
          TextField(controller: _contentController, decoration: const InputDecoration(labelText: "Content"), maxLines: 4),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateBlog,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}
