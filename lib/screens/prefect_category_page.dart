import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'prefect_detail_page.dart';

class PrefectCategoryPage extends StatelessWidget {
  final String category;

  const PrefectCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> prefectStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'prefect')
        .where('status', isEqualTo: 'approved')
        .where('skills', arrayContains: category)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: prefectStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No approved prefects available."));
          }

          final prefects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: prefects.length,
            itemBuilder: (context, index) {
              final data = prefects[index].data() as Map<String, dynamic>;
              final userId = prefects[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.shade100,
                    child: const Icon(Icons.person, color: Colors.pink),
                  ),
                  title: Text(
                    data['name'] ?? 'Unknown Prefect',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    (data['skills'] != null && data['skills'].isNotEmpty)
                        ? (data['skills'] as List).join(', ')
                        : 'No skills listed',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrefectDetailPage(
                          prefectId: userId,
                          prefectName: data['name'] ?? '',
                        ),
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
