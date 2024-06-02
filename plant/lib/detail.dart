import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:plant/search.dart';
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

  const DetailPage({
    required this.name,
    required this.nickname,
    required this.date,
    required this.lux,
    required this.humidity,
    required this.info,
    required this.temp,
    required this.water,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Search()),
              );
            },
          ),
        ],
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(66, 226, 247, 213),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Lottie.asset(lottieFile),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 70, 69, 69),
              highlightColor: const Color.fromARGB(255, 140, 188, 96),
              child: Text(
                widget.nickname,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 135, 197, 65),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
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
                      child: _isFetchingWeather
                          ? const CircularProgressIndicator()
                          : _weatherData != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '온도: ${_weatherData!['main']['temp']}°C',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '최저 온도: ${_weatherData!['main']['temp_min']}°C',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '최고 온도: ${_weatherData!['main']['temp_max']}°C',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '습도: ${_weatherData!['main']['humidity']}%',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '풍속: ${_weatherData!['wind']['speed']} m/s',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '풍향: ${_weatherData!['wind']['deg']}°',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '돌풍: ${_weatherData!['wind']['gust']} m/s',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '구름량: ${_weatherData!['clouds']['all']}%',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )
                              : const Text(
                                  '날씨 정보를 불러올 수 없습니다.',
                                  style: TextStyle(fontSize: 18),
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
                            const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.lux,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.thermostat_outlined,
                                color: Colors.lightGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.temp,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.opacity_outlined,
                                color:
                                    Color.fromARGB(255, 127, 203, 238)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.humidity,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.format_color_fill,
                                color: Colors.lightBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.water,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Text(
                            widget.info,
                            style: const TextStyle(fontSize: 18),
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
