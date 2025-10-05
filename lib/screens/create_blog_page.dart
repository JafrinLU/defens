import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'blog_model.dart';
import 'edit_blog_page.dart';

class CreateBlogPage extends StatefulWidget {
  final String userId;

  const CreateBlogPage({super.key, required this.userId});

  @override
  State<CreateBlogPage> createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _addBlog() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('blogs').add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'authorId': widget.userId,
        'createdAt': Timestamp.now(),
      });
      _titleController.clear();
      _contentController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Blog Added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Blog"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (val) =>
                    val!.isEmpty ? "Enter a title" : null,
                  ),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: "Content"),
                    maxLines: 4,
                    validator: (val) =>
                    val!.isEmpty ? "Enter blog content" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBlog,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white),
                    child: const Text("Add Blog"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Blogs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('blogs')
                    .where('authorId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No blogs yet."));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final blog = BlogModel.fromFirestore(docs[index]);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(blog.title),
                          subtitle: Text(blog.content,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditBlogPage(blog: blog),
                                  ),
                                );
                              } else if (value == 'delete') {
                                await FirebaseFirestore.instance
                                    .collection('blogs')
                                    .doc(blog.id)
                                    .delete();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text("Edit")),
                              const PopupMenuItem(
                                  value: 'delete', child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
