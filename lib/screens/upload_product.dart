import 'package:flutter/material.dart';
import 'dart:io';

class UploadProductPage extends StatefulWidget {
  final File imageFile;

  const UploadProductPage({super.key, required this.imageFile});

  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: Text("Upload Product", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: () {
              // TODO: Save to Firebase
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **Uploaded Image**
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.4, // 2/5th of the screen height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(widget.imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// **AI Generated Title**
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "AI Generated Title",
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                SizedBox(height: 10),

                /// **Price Input**
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 20, width: 10),

                /// **About This Product**
                Text(
                  "About this product",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black),
                ),
                SizedBox(height: 10),

                /// **Description Input**
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "AI Generated Description",
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
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
