import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to login page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  LoginPage()),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Approve Prefect Applications"),
            trailing: const Icon(Icons.check),
            onTap: () {
              // Navigate to Pending Prefect Approvals page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PendingPrefectApprovalsPage()),
              );
            },
          ),
          ListTile(
            title: const Text("Manage Users"),
            trailing: const Icon(Icons.people),
            onTap: () {
              // You can implement user management page here
            },
          ),
          ListTile(
            title: const Text("Notifications"),
            trailing: const Icon(Icons.notifications),
            onTap: () {
              // You can implement notifications page here
            },
          ),
        ],
      ),
    );
  }
}

// -------------------- Pending Prefect Approvals Page --------------------
class PendingPrefectApprovalsPage extends StatelessWidget {
  const PendingPrefectApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prefect Approvals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ✅ back to AdminDashboard
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'prefect')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending prefects.'));
          }

          final pendingPrefects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingPrefects.length,
            itemBuilder: (context, index) {
              final doc = pendingPrefects[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${data['email'] ?? ''}'),
                      Text('Expertise: ${data['skills'] != null ? (data['skills'] as List).join(', ') : ''}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    child: const Text('Approve'),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(doc.id)
                          .update({'status': 'approved'});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${data['name']} approved!')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
