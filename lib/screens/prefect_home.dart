import 'package:flutter/material.dart';
import 'login_page.dart';

class PrefectHome extends StatelessWidget {
  const PrefectHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prefect Home"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context,
            MaterialPageRoute(builder: (_) =>  LoginPage())); // Goes back to previous page
          },
        ),
      ),
      body: const Center(
        child: Text(
          "Welcome, Prefect! 🎉",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
