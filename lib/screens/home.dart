import 'package:ai_powered_marketplace/widgets/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'upload_product.dart';
import 'product_list.dart'; // Import the product list page
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String firstName = "User";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() => firstName = userDoc['firstName'] ?? "User");
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  /// **Select Image and Navigate to Upload Page**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadProductPage(imageUrl: _imageFile?.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hello, $firstName"),
        actions: [
          // List icon (Navigates to Product List)
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductListPage()),
              );
            },
          ),
          // Upload icon
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: //_pickImage,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadProductPage()),
              );
            },
          ),
          // Logout icon
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('userId', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return GridView.builder(
                  padding: EdgeInsets.all(8), // Small spaces around tiles
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8, // Horizontal space
                    mainAxisSpacing: 8, // Vertical space
                    childAspectRatio: 1,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var product = snapshot.data!.docs[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadProductPage(
                            productId: product.id,
                            imageUrl: product['imageUrl'],
                            initialTitle: product['title'],
                            initialPrice: product['price'],
                            initialDescription: product['description'],
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(product['imageUrl'],
                            fit: BoxFit.cover),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
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
    );
  }
}
