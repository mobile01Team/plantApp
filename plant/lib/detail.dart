import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final String nickname;
  final Timestamp date;
  final String lux;
  final String humidity;
  final String temp;
  final String water;
  final String info;

  const DetailPage({
    required this.name,
    required this.nickname,
    required this.date,
    required this.lux,
    required this.humidity,
    required this.info,
    required this.temp,
    required this.water,
    Key? key,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final plantDate = widget.date.toDate();
    final difference = currentDate.difference(plantDate).inDays;

    String lottieFile;

    if (difference >= 20) {
      lottieFile = 'images/plant3.json';
    } else if (difference >= 10) {
      lottieFile = 'images/plant2.json';
    } else {
      lottieFile = 'images/plant1.json';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), // 둥근 테두리
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(66, 226, 247, 213),
                      blurRadius: 10,
                      offset: Offset(0, 5), // 그림자 위치 조정
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16), // 클립을 둥글게
                  child: Lottie.asset(lottieFile), // 선택된 Lottie 애니메이션 파일 표시
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${widget.nickname}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.name}',
              
              style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 135, 197, 65)),
            ),
            SizedBox(height: 16),
        
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '현재 상태'),
                Tab(text: '키우는 법'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 현재 상태 탭 내용
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '이곳은 날씨에 따른 현재 상태를 나타냅니다',
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // 키우는 법 탭 내용
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny_outlined, color: Colors.orange,), // Lux 아이콘
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.lux}',
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.thermostat_outlined, color: Colors.lightGreen,), // Temperature 아이콘
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.temp}',
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.opacity_outlined, color: const Color.fromARGB(255, 127, 203, 238),), // Humidity 아이콘
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.humidity}',
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.format_color_fill, color: Colors.lightBlue,), // Water 아이콘
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.water}',
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Expanded(
                              child: Text(
                                '${widget.info}',
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
