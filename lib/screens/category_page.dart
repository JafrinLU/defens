import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Firestore reference for current user
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userRef.get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User data not found.")),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final userRole = userData['role'];

        // 🔹 CASE 1: If user is PREFECT → show only their info
        if (userRole == 'prefect') {
          final Stream<QuerySnapshot> selfInfoStream = FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: currentUser.uid)
              .snapshots();

          return Scaffold(
            appBar: AppBar(
              title: Text("Your Profile (${category})"),
              backgroundColor: Colors.pink,
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: selfInfoStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No profile information found."),
                  );
                }

                final data =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.pink,
                              child: const Icon(Icons.person,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text("👤 Name: ${data['name'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 18)),
                          Text("🎓 Batch: ${data['batch'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 18)),
                          Text("💼 Expertise: ${data['category'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 18)),
                          Text("📧 Email: ${data['email'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 25),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon:
                              const Icon(Icons.message, color: Colors.white),
                              label: const Text("Message"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        // 🔹 CASE 2: If user is STUDENT → show all approved prefects in that category
        else if (userRole == 'student') {
          final Stream<QuerySnapshot> prefectStream = FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'prefect')
              .where('status', isEqualTo: 'approved')
              .where('category', isEqualTo: category)
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
                  return const Center(
                    child: Text("No approved prefects available."),
                  );
                }

                final prefects = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: prefects.length,
                  itemBuilder: (context, index) {
                    final data =
                    prefects[index].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          data['name'] ?? 'Unknown',
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(data['category'] ?? ''),
                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        // 🔹 Default (just in case)
        else {
          return const Scaffold(
            body: Center(child: Text("Invalid user role.")),
          );
        }
      },
    );
  }
}
