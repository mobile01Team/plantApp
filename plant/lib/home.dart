import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant/search_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

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
      body: user == null
          ? const Center(child: Text('로그인이 필요합니다'))
          : PlantList(userid: user!.uid),
    );
  }
}

class PlantList extends StatelessWidget {
  final String userid;
  const PlantList({required this.userid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('PlantList')
          .where('userid', isEqualTo: userid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final plants = snapshot.data!.docs;

        return ListView.builder(
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return ListTile(
              title: Text(plant['name']),
              subtitle: Text(plant['nickname']),
            );
          },
        );
      },
    );
  }
}
