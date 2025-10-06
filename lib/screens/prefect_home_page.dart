import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_blog_page.dart';
import 'prefect_profile_page.dart';
import 'prefect_category_page.dart';

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

  Widget _buildHomeView() {
    final List<Map<String, String>> categories = [
      {"name": "Competitive Programming", "image": "lib/assets/CP.png"},
      {"name": "UI/UX Design", "image": "lib/assets/UiUx.png"},
      {"name": "AI/ML", "image": "lib/assets/aiMl.png"},
      {"name": "Web Development", "image": "lib/assets/webDevelopment.png"},
      {"name": "App Development", "image": "lib/assets/app_development.png"},
      {"name": "Cyber Security", "image": "lib/assets/cyberSecurity.png"},
      {"name": "Data Science", "image": "lib/assets/CP.png"},
      {"name": "Networking", "image": "lib/assets/UiUx.png"},
    ];

    return Scaffold(
      body: Column(
        children: [
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrefectCategoryPage(
                              category: category['name']!,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(category["image"]!,
                                  fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category["name"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(),
      CreateBlogPage(userId: widget.userId),
      PrefectProfilePage(userId: widget.userId),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Create Blog'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
