import 'package:flutter/material.dart';
import 'package:plant/search_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_search),
            onPressed: () {
              // Search 페이지로 네비게이션
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchImage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}
