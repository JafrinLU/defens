import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'pending_approval_page.dart';
import 'student_home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedRole = 'student';
  bool isLoading = false;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pink.shade500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.pink.shade500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.pink.shade500, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.pink.shade500),
    );
  }

  bool _validateEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _validatePhone(String phone) =>
      RegExp(r'^\d{10,15}$').hasMatch(phone);

  bool _validatePassword(String password) =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password);

  Future<void> _signUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    if (!_validateEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid email')));
      return;
    }
    if (!_validatePhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid phone number')));
      return;
    }
    if (!_validatePassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters and contain letters & numbers')));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final user = {
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': selectedRole,
        'status': selectedRole == 'prefect' ? 'pending' : 'approved',
        'skills': selectedRole == 'prefect' ? [_expertiseController.text.trim()] : [],
        'phone': phone,
        'studentId': _studentIdController.text.trim(),
        'batch': _batchController.text.trim(),
        'department': _deptController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userCredential.user!.uid).set(user);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signup successful!')));

      if (selectedRole == 'prefect') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PendingApprovalPage()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomePage(userName: name),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Logo
              Center(
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(360),
                  ),
                  child: const Center(
                    child: Text(
                      "ExpertLink",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu',
                        color: Colors.pink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Sign Up",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu',
                    color: Colors.pinkAccent),
              ),
              const SizedBox(height: 5),
              const Text(
                "Create your ExpertLink account",
                style: TextStyle(
                    fontSize: 16, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Role Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade500),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'prefect', child: Text('Prefect')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
                  decoration: const InputDecoration(
                    labelText: 'Select Role',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              _buildRoundedTextField(_nameController, "Full Name", Icons.person),
              const SizedBox(height: 10),
              _buildRoundedTextField(_emailController, "Email", Icons.alternate_email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildRoundedTextField(_passwordController, "Password", Icons.password, obscureText: true),
              const SizedBox(height: 10),
              _buildRoundedTextField(_confirmPasswordController, "Confirm Password", Icons.password, obscureText: true),
              const SizedBox(height: 10),
              _buildRoundedTextField(_phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildRoundedTextField(_studentIdController, "Student ID", Icons.school),
              const SizedBox(height: 10),
              _buildRoundedTextField(_batchController, "Batch", Icons.date_range),
              const SizedBox(height: 10),
              _buildRoundedTextField(_deptController, "Department", Icons.account_balance),
              const SizedBox(height: 10),
              if (selectedRole == 'prefect')
                _buildRoundedTextField(_expertiseController, "Expertise Field", Icons.star),

              const SizedBox(height: 20),

              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 10),

              // Already have an account
              TextButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.pink.shade500),
      decoration: _inputDecoration(label, icon),
    );
  }
}
