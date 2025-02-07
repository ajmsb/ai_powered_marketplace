import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import 'login.dart';
import '../widgets/bottom_nav.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false; // Show loading indicator

  /// **Function to Register User & Save Data**
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // **Create User in Firebase Authentication**
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          // **Save User Data in Firestore**
          await _firestore.collection('users').doc(user.uid).set({
            'firstName': firstNameController.text.trim(),
            'lastName': lastNameController.text.trim(),
            'username': usernameController.text.trim(),
            'email': emailController.text.trim(),
            'uid': user.uid,
            'createdAt': Timestamp.now(),
          });

          // **Navigate to Home Page**
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        String errorMessage = "An error occurred";
        if (e.code == 'email-already-in-use') {
          errorMessage = "This email is already registered";
        } else if (e.code == 'weak-password') {
          errorMessage = "Your password is too weak";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email format";
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100), // Space at the top
                  Text(
                    "Let's create for you a new account",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// **First & Last Name Fields (Side by Side)**
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: firstNameController,
                                decoration:
                                    InputDecoration(labelText: "First Name"),
                                validator: (value) => value!.isEmpty
                                    ? "Enter your first name"
                                    : null,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: lastNameController,
                                decoration:
                                    InputDecoration(labelText: "Last Name"),
                                validator: (value) => value!.isEmpty
                                    ? "Enter your last name"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),

                        /// **Username Field**
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(labelText: "Username"),
                          validator: (value) =>
                              value!.isEmpty ? "Enter a username" : null,
                        ),
                        SizedBox(height: 15),

                        /// **Email Field**
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: "Email"),
                          validator: (value) =>
                              value!.isEmpty ? "Enter a valid email" : null,
                        ),
                        SizedBox(height: 15),

                        /// **Password Field**
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                          validator: (value) => value!.length < 6
                              ? "Password must be 6+ characters"
                              : null,
                        ),
                        SizedBox(height: 25),

                        /// **Create Account Button**
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("Create Account",
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 20),

                        /// **Already Have Account? Login**
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// **Bottom Navbar & FAB Icon**
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              clipBehavior: Clip.none, // Allows FAB to overflow navbar
              alignment: Alignment.bottomCenter,
              children: [
                BottomNavBar(selectedIndex: 0, onItemTapped: (index) {}),
                Positioned(
                  bottom: 35, // Adjusted to ensure full visibility
                  child: Container(
                    width: 70, // Ensures proper circular FAB with border
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 4), // Thick white border
                      color: Colors.black, // Black background
                    ),
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.black, // Ensure black background
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.white, width: 4),
                      ),
                      elevation: 8, // Ensures it's in front
                      child: Icon(Icons.add,
                          color: Colors.white, size: 32), // Plus (+) icon
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
