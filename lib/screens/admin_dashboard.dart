// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const PendingPrefectApprovalsPage(),
      const StudentProfilesPage(),
      const PrefectProfilesPage(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications.")),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: "Pending Prefects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Students",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Prefects",
          ),
        ],
      ),
    );
  }
}

// ---------- Helper: safe fetch field and fallback ----------
String _getFirstNonEmpty(Map<String, dynamic> data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v != null) {
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is List && v.isNotEmpty) return v.join(', ');
      if (v is num) return v.toString();
    }
  }
  return '';
}

// ---------- Reusable card widget (uses Row + Expanded so text won't stack) ----------
Widget _userCard({
  required BuildContext context,
  required String docId,
  required Map<String, dynamic> data,
  required bool isPending,
  required VoidCallback onApprove,
  required VoidCallback onReject,
  required VoidCallback onDelete,
  required VoidCallback onTap,
}) {
  final name = _getFirstNonEmpty(data, ['name', 'fullName']) ;
  final email = _getFirstNonEmpty(data, ['email']) ;
  final batch = _getFirstNonEmpty(data, ['batch', 'year']) ;
  final contact = _getFirstNonEmpty(data, ['contact', 'phone', 'mobile']) ;
  // category might be string or skills array
  final category = _getFirstNonEmpty(data, ['category', 'expertise', 'skills']) ;

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.pink,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Expanded column for all text details (prevents vertical letter stacking)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name.isNotEmpty ? name : 'No name',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Email (single line, ellipsis if long)
                  if (email.isNotEmpty)
                    Text(
                      "Email: $email",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Batch
                  if (batch.isNotEmpty)
                    Text(
                      "Batch: $batch",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Contact
                  if (contact.isNotEmpty)
                    Text(
                      "Contact: $contact",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Category / Expertise
                  if (category.isNotEmpty)
                    Text(
                      "Expertise: $category",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right side actions
            isPending
                ? Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: onApprove,
                  child: const Text("Approve"),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: onReject,
                  child: const Text("Reject"),
                ),
              ],
            )
                : IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    ),
  );
}

// -------------------- 1️⃣ Pending Prefect Approvals Page --------------------
class PendingPrefectApprovalsPage extends StatelessWidget {
  const PendingPrefectApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'prefect')
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text('No pending prefects.'));
        }
        final docs = snap.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _userCard(
              context: context,
              docId: doc.id,
              data: data,
              isPending: true,
              onApprove: () async {
                await FirebaseFirestore.instance.collection('users').doc(doc.id).update({'status':'approved'});
                // add notification entry for this user (optional)
                await FirebaseFirestore.instance.collection('notifications').add({
                  'toUserId': doc.id,
                  'title': 'Your Prefect application approved',
                  'message': 'Congrats! Your account is approved by admin.',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getFirstNonEmpty(data, ['name'])} approved')));
              },
              onReject: () async {
                await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getFirstNonEmpty(data, ['name'])} rejected & removed')));
              },
              onDelete: () {},
              onTap: () => _showDetailDialog(context, data),
            );
          },
        );
      },
    );
  }
}

// -------------------- 2️⃣ Student Profiles Page --------------------
class StudentProfilesPage extends StatelessWidget {
  const StudentProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('No students found.'));
        final docs = snap.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _userCard(
              context: context,
              docId: doc.id,
              data: data,
              isPending: false,
              onApprove: () {},
              onReject: () {},
              onDelete: () async {
                await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getFirstNonEmpty(data, ['name'])} removed')));
              },
              onTap: () => _showDetailDialog(context, data),
            );
          },
        );
      },
    );
  }
}

// -------------------- 3️⃣ Prefect Profiles Page --------------------
class PrefectProfilesPage extends StatelessWidget {
  const PrefectProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'prefect')
        .where('status', isEqualTo: 'approved')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.docs.isEmpty) return const Center(child: Text('No approved prefects.'));
        final docs = snap.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _userCard(
              context: context,
              docId: doc.id,
              data: data,
              isPending: false,
              onApprove: () {},
              onReject: () {},
              onDelete: () async {
                await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getFirstNonEmpty(data, ['name'])} removed')));
              },
              onTap: () => _showDetailDialog(context, data),
            );
          },
        );
      },
    );
  }
}

// ------------------- show detail dialog -------------------
void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
  final name = _getFirstNonEmpty(data, ['name']);
  final email = _getFirstNonEmpty(data, ['email']);
  final batch = _getFirstNonEmpty(data, ['batch', 'year']);
  final contact = _getFirstNonEmpty(data, ['contact', 'phone', 'mobile']);
  final category = _getFirstNonEmpty(data, ['category', 'expertise', 'skills']);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.pink, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(child: Text(name.isNotEmpty ? name : 'No name')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (email.isNotEmpty) Text("📧 Email: $email"),
          if (batch.isNotEmpty) Text("🎓 Batch: $batch"),
          if (contact.isNotEmpty) Text("📞 Contact: $contact"),
          if (category.isNotEmpty) Text("💼 Expertise: $category"),
          if (data['bio'] != null && (data['bio'] as String).trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text("About:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data['bio']),
          ]
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.pink))),
      ],
    ),
  );
}
