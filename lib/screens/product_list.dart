import 'package:ai_powered_marketplace/widgets/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Product List")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No products found"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// **Left Column: Product Image**
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 12),

                      /// **Right Column: Title, Price & Description**
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "₦${product['price']}",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              product['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
