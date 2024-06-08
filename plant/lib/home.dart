import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'add_list_page.dart';
import 'detail.dart';
import 'login.dart';
import 'search.dart';
import 'search_image.dart';

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
              leading: const Icon(
                Icons.add,
                color: Colors.lightBlue,
              ),
              title: const Text('식물 추가하기'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_florist,
                color: Colors.lightGreen,
              ),
              title: const Text('내 주변 꽃집 찾기'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Search()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.image_search,
                color: Colors.deepOrange,
              ),
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
              leading: const Icon(
                Icons.logout,
                color: Colors.deepPurple,
              ),
              title: const Text('로그아웃'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: user == null
                ? const Center(child: Text('로그인이 필요합니다'))
                : PlantList(userid: user!.uid),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            child: Weather(),
          ),
        ],
      ),
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
          itemExtent: 100,
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(255, 198, 212, 183),
                    width: 0.2), // 테두리 두께를 1로 지정
              ),
              child: ListTile(
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset('images/seed.png'),
                ),
                title: Text(
                  plant['nickname'],
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 105, 114, 118)),
                ),
                subtitle: Text(
                  plant['name'],
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 135, 197, 65)),
                ),
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
              ),
            );
          },
        );
      },
    );
  }
}

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  List<Map<String, dynamic>> data = [];
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://apis.data.go.kr/B552584/UlfptcaAlarmInqireSvc/getUlfptcaAlarmInfo?serviceKey=Bq6DjrvIf%2Fb5oaNZWPWvLHgaiTUOk67Iaj9Gfij2hloyxagHOmXrTJBKB7Hp4KYsPx46M%2B9zeb6mmPPU4CFJug%3D%3D&returnType=xml&numOfRows=100&pageNo=1&year=2024'));

    if (response.statusCode == 200) {
      final parsed = xmlParse(response.body);
      setState(() {
        data = parsed;
      });

      timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
        setState(() {
          currentIndex = (currentIndex + 1) % data.length;
        });
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<Map<String, dynamic>> xmlParse(String responseBody) {
    final xmlDocument = XmlDocument.parse(responseBody);
    final items = xmlDocument.findAllElements('item');
    return items.map((item) {
      return {
        'districtName': item.findElements('districtName').single.text,
        'issueGbn': item.findElements('issueGbn').single.text,
        'itemCode': item.findElements('itemCode').single.text,
      };
    }).toList();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    var currentItem = data[currentIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("District Name: ${currentItem['districtName']}"),
          Text("Issue Type: ${currentItem['issueGbn']}"),
          Text("Item Code: ${currentItem['itemCode']}"),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}
