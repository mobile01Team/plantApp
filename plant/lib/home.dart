import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail.dart'; // detail.dart 파일을 임포트합니다
import 'search_image.dart'; // 검색 이미지 페이지를 임포트합니다

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
              leading: Image.asset('images/seed.png'), 
              title: Text(plant['nickname']),
              subtitle: Text(plant['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      name: plant['name'],
                      nickname: plant['nickname'],
                      date: plant['date'],
                      lux: plant['lux'],
                      temp: plant['temp'],
                      humidity: plant['humidity'],
                      info: plant['info'],
                      water: plant['water'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
