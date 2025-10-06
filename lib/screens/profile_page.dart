import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'student_home.dart';
import 'notification_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 1;
  File? _image;
  bool _isUploading = false;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentHomePage(userName: user?.email ?? ""),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _uploadImageToCloudinary();
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    const cloudName = 'dyyvjmjlj';
    const uploadPreset = 'defense_app_preset';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = res.body;
        final imageUrl = RegExp(r'"secure_url":"(.*?)"').firstMatch(data)?.group(1);

        if (imageUrl != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'profileImage': imageUrl});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image updated successfully!")),
          );
          setState(() {}); // Refresh UI
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _editProfile(Map<String, dynamic> userData) async {
    final nameController = TextEditingController(text: userData['name']);
    final phoneController = TextEditingController(text: userData['phone']);
    final deptController = TextEditingController(text: userData['department']);
    final batchController = TextEditingController(text: userData['batch']);

    File? newImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickNewImage() async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setDialogState(() => newImage = File(pickedFile.path));
              }
            }

            return AlertDialog(
              title: const Text("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickNewImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: newImage != null
                            ? FileImage(newImage!)
                            : userData['profileImage'] != null
                            ? NetworkImage(userData['profileImage']) as ImageProvider
                            : const AssetImage('assets/default_avatar.png'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: pickNewImage,
                      child: const Text("Change Photo", style: TextStyle(color: Colors.pink)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                    TextField(
                      controller: deptController,
                      decoration: const InputDecoration(labelText: "Department"),
                    ),
                    TextField(
                      controller: batchController,
                      decoration: const InputDecoration(labelText: "Batch"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    String? imageUrl;
                    if (newImage != null) {
                      setState(() => _image = newImage);
                      await _uploadImageToCloudinary();
                      final doc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .get();
                      final updatedData = doc.data() as Map<String, dynamic>?;
                      imageUrl = updatedData?['profileImage'];
                    }

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .update({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'department': deptController.text.trim(),
                      'batch': batchController.text.trim(),
                      if (imageUrl != null) 'profileImage': imageUrl,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully!")),
                    );
                    setState(() {}); // refresh UI
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentHomePage(userName: "")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(userName: user?.email ?? ""),
              ),
            );
          },
        ),
      ),
      body: user == null
          ? const Center(child: Text("No user found"))
          : FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: userData['profileImage'] != null
                      ? NetworkImage(userData['profileImage'])
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileRow("Name", userData['name']),
                        _buildProfileRow("Email", userData['email']),
                        _buildProfileRow("Phone", userData['phone']),
                        _buildProfileRow("Department", userData['department']),
                        _buildProfileRow("Batch", userData['batch']),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _editProfile(userData),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text("Edit", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                            ),
                            ElevatedButton.icon(
                              onPressed: _deleteAccount,
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: const Text("Delete", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildProfileRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
