import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:plant/dictionary.dart';
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
        backgroundColor: Colors.green,
        title: const Text('내 식물 리스트',
            style: TextStyle(
              color: Color(0xffFFFCF2),
              fontWeight: FontWeight.w600,
            )),
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
        iconTheme: const IconThemeData(color: Color(0xffFFFCF2)),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffFFFCF2), // Drawer 배경 색 설정
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                      color: Color(0xffFFFCF2),
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
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
                    MaterialPageRoute(
                        builder: (context) => const AddListPage()),
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
                    MaterialPageRoute(
                        builder: (context) => const SearchImage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.bookmark_outlined,
                  color: Colors.pinkAccent,
                ),
                title: const Text('식물 도감'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Dictionary()),
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
      ),
      backgroundColor: Color(0xffFFFCF2), // 배경 색 설정
      body: Column(
        children: [
          Expanded(
            child: user == null
                ? const Center(child: Text('로그인이 필요합니다'))
                : AnimatedPlantList(userid: user!.uid),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          color: Color(0xffFFF8D5),
        ),
        height: 100,
        child: Weather(), // WeatherWidget을 사용하여 미세먼지 농도 표시
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green, // 버튼 배경색
        foregroundColor: Color(0xffFFFCF2), // 아이콘 색상
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

class AnimatedPlantList extends StatelessWidget {
  final String userid;
  const AnimatedPlantList({Key? key, required this.userid}) : super(key: key);

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

        return AnimationLimiter(
          child: ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 1575),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Color.fromARGB(255, 198, 212, 183),
                            width: 0.6),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 80,
                          height: 80,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset('images/seed.png'),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            plant['nickname'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff3D3D3D)),
                          ),
                        ),
                        subtitle: Text(
                          plant['name'],
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 135, 197, 65)),
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
                    ),
                  ),
                ),
              );
            },
          ),
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
      padding: const EdgeInsets.fromLTRB(30, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, color: Colors.lightBlue),
              SizedBox(width: 10),
              Text(
                "지역: ${currentItem['districtName']}",
                style: TextStyle(color: Color(0xff3D3D3D)),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "미세먼지 경보: ${currentItem['issueGbn']}",
                style: TextStyle(color: Color(0xff3D3D3D)),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.masks, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                "미세먼지 농도: ${currentItem['itemCode']}",
                style: TextStyle(color: Color(0xff3D3D3D)),
              ),
            ],
          ),
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
