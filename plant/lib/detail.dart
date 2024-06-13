import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:plant/main.dart';
import 'package:shimmer/shimmer.dart';

class DetailPage extends StatefulWidget {
  final String name;
  final String nickname;
  final Timestamp date;
  final String lux;
  final String humidity;
  final String temp;
  final String water;
  final String info;
  final String special;

  const DetailPage({
    required this.name,
    required this.nickname,
    required this.date,
    required this.lux,
    required this.humidity,
    required this.info,
    required this.temp,
    required this.water,
    required this.special,
    super.key,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _weatherData;
  bool _isFetchingWeather = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLocationAndWeather();
    _checkWateringStatus();
  }

  Future<void> _fetchLocationAndWeather() async {
    setState(() {
      _isFetchingWeather = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      Map<String, dynamic> weatherData =
          await fetchWeather(position.latitude, position.longitude);
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      // 에러 처리
      print(e);
    } finally {
      setState(() {
        _isFetchingWeather = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    const apiKey = '3621bc74ad5b93efe4651dd92bb5378c'; // OpenWeatherMap API 키
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_channel',
      'Water Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'watered',
    );
  }

  void _checkWateringStatus() {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(widget.date.toDate()).inDays;

    if (difference % 5 == 0) {
      _showNotification('물주기 알림', '식물에게 물을 줄 시간입니다.');
    }
  }

  double _getWateringProgress() {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(widget.date.toDate()).inDays;
    return (difference % 5) / 5;
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

    if (difference >= 40) {
      lottieFile = 'images/plant3.json';
    } else if (difference >= 20) {
      lottieFile = 'images/plant2.json';
    } else {
      lottieFile = 'images/plant1.json';
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(widget.nickname,
              style: TextStyle(
                color: Color(0xffFFFCF2),
                fontWeight: FontWeight.w600,
              )),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const Search()),
          //       );
          //     },
          //   ),
          // ],
          iconTheme: const IconThemeData(color: Color(0xffFFFCF2))),
      backgroundColor: Color(0xffFFFCF2),
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    // BoxShadow(
                    //   color: Colors.white,
                    //   blurRadius: 10,
                    //   offset: Offset(0, 5),
                    // ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Lottie.asset(lottieFile),
                ),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getWateringProgress(),
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 7, 69, 69),
                  highlightColor: const Color.fromARGB(255, 140, 188, 96),
                  child: Text(
                    widget.nickname,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 135, 197, 65),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.lightGreen, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.lightBlue,
                    highlightColor: const Color.fromARGB(255, 169, 176, 159),
                    child: Text(
                      widget.special,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.green, // 탭 선택 시 아래쪽에 표시되는 선 색상
              labelColor: Colors.green, // 선택된 탭의 텍스트 색상
              unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 텍스트 색상
              tabs: const [
                Tab(text: '현재 날씨 상태'),
                Tab(text: '키우는 법'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 현재 상태 탭 내용
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: _isFetchingWeather
                            ? const CircularProgressIndicator()
                            : _weatherData != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.thermostat_outlined,
                                              color: Colors.orange),
                                          const Text(
                                            '온도: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff3D3D3D)),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                          ),
                                          SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  PieChartSectionData(
                                                    value:
                                                        (_weatherData!['main']
                                                                ['temp'] as num)
                                                            .toDouble(),
                                                    title:
                                                        '${_weatherData!['main']['temp']}°C',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    color: Color.fromRGBO(
                                                        245, 162, 7, 1),
                                                    radius: 70,
                                                  ),
                                                  PieChartSectionData(
                                                    value: (40 -
                                                            (_weatherData![
                                                                        'main']
                                                                    ['temp']
                                                                as num))
                                                        .toDouble(),
                                                    title: '',
                                                    color: Color.fromRGBO(
                                                        240, 186, 85, 1),
                                                    radius: 70,
                                                  ),
                                                ],
                                                centerSpaceRadius: 0,
                                                sectionsSpace: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.opacity_outlined,
                                              color: Colors.lightGreen),
                                          const Text(
                                            '습도: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff3D3D3D)),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                          ),
                                          SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  PieChartSectionData(
                                                    value:
                                                        (_weatherData!['main']
                                                                    ['humidity']
                                                                as num)
                                                            .toDouble(),
                                                    title:
                                                        '${_weatherData!['main']['humidity']}%',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    color: Colors.green,
                                                    radius: 70,
                                                  ),
                                                  PieChartSectionData(
                                                    value: (100 -
                                                            (_weatherData![
                                                                        'main']
                                                                    ['humidity']
                                                                as num))
                                                        .toDouble(),
                                                    title: '',
                                                    color: Color.fromARGB(
                                                        255, 187, 244, 209),
                                                    radius: 70,
                                                  ),
                                                ],
                                                centerSpaceRadius: 0,
                                                sectionsSpace: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.wind_power_outlined,
                                            color: Color.fromARGB(
                                                255, 127, 203, 238),
                                          ),
                                          const Text(
                                            '풍속: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff3D3D3D)),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            height: 60,
                                          ),
                                          SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: PieChart(
                                              PieChartData(
                                                sections: [
                                                  PieChartSectionData(
                                                    value:
                                                        (_weatherData!['wind']
                                                                    ['speed']
                                                                as num)
                                                            .toDouble(),
                                                    title:
                                                        '${_weatherData!['wind']['speed']}%',
                                                    titleStyle: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    color: Colors.lightBlue,
                                                    radius: 70,
                                                  ),
                                                  PieChartSectionData(
                                                    value: (54 -
                                                            (_weatherData![
                                                                        'wind']
                                                                    ['speed']
                                                                as num))
                                                        .toDouble(),
                                                    title: '',
                                                    color: Color.fromARGB(
                                                        255, 132, 210, 255),
                                                    radius: 70,
                                                  ),
                                                ],
                                                centerSpaceRadius: 0,
                                                sectionsSpace: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '날씨 정보를 불러올 수 없습니다.',
                                    style: TextStyle(fontSize: 18),
                                  ),
                      ),
                    ),
                  ),
                  // 키우는 법 탭 내용
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny_outlined,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.lux,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff3D3D3D)),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.thermostat_outlined,
                                color: Colors.lightGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.temp,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff3D3D3D)),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.opacity_outlined,
                                color: Color.fromARGB(255, 127, 203, 238),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.humidity,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff3D3D3D)),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.format_color_fill,
                                color: Colors.lightBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.water,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff3D3D3D)),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.info}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff3D3D3D)),
                          ),
                        ],
                      ),
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
