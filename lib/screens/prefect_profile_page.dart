import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrefectProfilePage extends StatelessWidget {
  final String userId;

  const PrefectProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.pink.shade50,
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.pink),
                    ),
                    const SizedBox(height: 10),
                    Text(data['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Email: ${data['email']}"),
                    Text("Phone: ${data['phone']}"),
                    Text("Batch: ${data['batch']}"),
                    Text("Department: ${data['department']}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
