import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final String firstName;

  const UserPage({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hello $firstName')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Search', border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: 10, // Replace with uploaded images count
              itemBuilder: (context, index) {
                return Card(
                    child: Image.network('https://via.placeholder.com/150'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
