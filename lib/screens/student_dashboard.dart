import 'package:flutter/material.dart';
import 'login_page.dart'; // make sure you import your login page

class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Dashboard"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(title: Text("Search Mentors"), trailing: Icon(Icons.search)),
          ListTile(title: Text("Learning Blogs"), trailing: Icon(Icons.book)),
          ListTile(title: Text("My Profile"), trailing: Icon(Icons.person)),
        ],
      ),
    );
  }
}
