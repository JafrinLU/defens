import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_blog_page.dart';
import 'prefect_profile_page.dart';

class PrefectHomePage extends StatefulWidget {
  final String userName;
  final String userId;
  final String category;

  const PrefectHomePage({
    super.key,
    required this.userName,
    required this.userId,
    required this.category,
  });

  @override
  State<PrefectHomePage> createState() => _PrefectHomePageState();
}

class _PrefectHomePageState extends State<PrefectHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- Firestore category fetching ---
  Stream<QuerySnapshot> _fetchApprovedPrefects() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'prefect')
        .where('status', isEqualTo: 'approved')
        .where('category', isEqualTo: widget.category)
        .snapshots();
  }

  Widget _buildHomeView() {
    final List<Map<String, String>> categories = [
      {"name": "Competitive Programming", "image": "lib/assets/CP.png"},
      {"name": "UI/UX Design", "image": "lib/assets/UiUx.png"},
      {"name": "AI/ML", "image": "lib/assets/aiMl.png"},
      {"name": "Web Development", "image": "lib/assets/webDevelopment.png"},
      {"name": "App Development", "image": "lib/assets/CP.png"},
      {"name": "Cyber Security", "image": "lib/assets/UiUx.png"},
      {"name": "Data Science", "image": "lib/assets/aiMl.png"},
      {"name": "Networking", "image": "lib/assets/webDevelopment.png"},
    ];

    return Scaffold(
      body: Column(
        children: [
          // --- Pink Welcome Section ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${widget.userName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search Categories...",
                    prefixIcon: const Icon(Icons.search, color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // --- Grid View of categories ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        final clickedCategory = category['name']!;

                        if (clickedCategory == widget.category) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrefectProfilePage(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrefectCategoryPage(
                                category: clickedCategory,
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                category["image"]!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              category["name"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Build all 3 pages ---
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(),
      CreateBlogPage(userId: widget.userId),
      PrefectProfilePage(userId: widget.userId),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Create Blog"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}

//
// 🔹 PAGE: PrefectCategoryPage
// Shows all approved prefects in selected category
//
class PrefectCategoryPage extends StatelessWidget {
  final String category;

  const PrefectCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
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
              final data = prefects[index].data() as Map<String, dynamic>;
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['category'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
