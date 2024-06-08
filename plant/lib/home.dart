import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail.dart'; // detail.dart 파일을 임포트합니다
import 'search_image.dart'; // 검색 이미지 페이지를 임포트합니다
import 'add_list_page.dart'; // add_list_page.dart 파일을 임포트합니다
import 'search.dart'; // 내 주변 꽃집 찾기 페이지를 임포트합니다
import 'login.dart'; // 로그인 페이지를 임포트합니다

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

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 식물 리스트'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add,color: Colors.lightBlue,),
              title: const Text('식물 추가하기'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_florist, color: Colors.lightGreen,),
              title: const Text('내 주변 꽃집 찾기'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Search()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_search, color: Colors.deepOrange,),
              title: const Text('텍스트 이미지로 식물 찾기'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchImage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurple,),
              title: const Text('로그아웃'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('로그인이 필요합니다'))
          : PlantList(userid: user!.uid),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddListPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlantList extends StatelessWidget {
  final String userid;
  const PlantList({super.key, required this.userid});

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
                      special: plant['special'],
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
