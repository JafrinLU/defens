import 'package:flutter/material.dart';
import 'student_dashboard.dart';

import 'admin_dashboard.dart';

class HomePage extends StatelessWidget {
  final String role = "student";

  @override
  Widget build(BuildContext context) {
    if (role == "student") return StudentDashboard();
    //if (role == "prefect") return PrefectDashboard();
    if (role == "admin") return AdminDashboard();
    return Scaffold(body: Center(child: Text("Role not assigned")));
  }
}

