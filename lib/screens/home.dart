import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'upload_product.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String firstName = "User"; // Default placeholder

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch First Name from Firebase**
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            firstName = userDoc['firstName'] ?? "User";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  /// **Logout User**
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  /// **Select Image and Navigate to Upload Page**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadProductPage(imageFile: File(image.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100), // Space at the top
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, $firstName",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.upload, color: Colors.black),
                          onPressed: _pickImage,
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.black),
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// **Bottom Navigation Bar & FAB**
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none, // Ensures FAB is in front
              children: [
                /// **FAB Icon (Now in Front)**
                Positioned(
                  top: -35, // Ensuring full visibility
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.black,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.white, width: 4),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),

                /// **Bottom Navigation Bar**
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.white),
                        onPressed: () {},
                      ),
                      SizedBox(width: 60), // Space for FAB
                      IconButton(
                        icon: Icon(Icons.email, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
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
