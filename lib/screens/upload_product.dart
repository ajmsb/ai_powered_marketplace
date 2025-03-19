import 'dart:io';
import 'package:ai_powered_marketplace/widgets/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';

class UploadProductPage extends StatefulWidget {
  final String? productId;
  final String? imageUrl;
  final String? initialTitle;
  final String? initialPrice;
  final String? initialDescription;

  UploadProductPage({
    this.productId,
    this.imageUrl,
    this.initialTitle,
    this.initialPrice,
    this.initialDescription,
  });

  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _imageUrl;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      // Editing an existing product
      _imageUrl = widget.imageUrl;
      _titleController.text = widget.initialTitle ?? "";
      _priceController.text = widget.initialPrice ?? "";
      _descriptionController.text = widget.initialDescription ?? "";
    }
  }

  /// **Pick Image from Gallery**
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  /// **Upload Image to Firebase Storage**
  Future<String> _uploadImage(File imageFile) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = _storage.ref().child('product_images/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// **Save Product (New or Update Existing)**
  Future<void> _saveProduct() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        (_imageFile == null && _imageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields and an image are required!")),
      );
      return;
    }

    setState(() => _isUploading = true);
    User? user = _auth.currentUser;
    if (user == null) return;

    String imageUrl = _imageUrl ?? "";
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    Map<String, dynamic> productData = {
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': imageUrl,
      'userId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (widget.productId == null) {
      // **Create New Product**
      await _firestore.collection('products').add(productData);
    } else {
      // **Update Existing Product**
      await _firestore
          .collection('products')
          .doc(widget.productId)
          .update(productData);
    }

    setState(() => _isUploading = false);

    // Navigate back to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.productId != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Product" : "Upload Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isUploading ? null : _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Image Preview & Upload**
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : (widget.imageUrl != null
                        ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, color: Colors.grey, size: 50)),
              ),
            ),
            SizedBox(height: 20),

            /// **Title Input**
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Product Title"),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 10),

            /// **Price Input**
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: "Product Price"),
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),

            /// **Description Input**
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Product Description"),
              style: TextStyle(color: Colors.black),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            /// **Save Button**
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveProduct,
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? "Update Product" : "Save Product"),
              ),
            ),
          ],
        ),
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
