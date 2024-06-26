import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;
  final String _openweatherkey = '3621bc74ad5b93efe4651dd92bb5378c';
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(
        'Current Position: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    await getWeatherData(
        lat: position.latitude.toString(), lon: position.longitude.toString());
  }

  Future<void> getWeatherData({
    required String lat,
    required String lon,
  }) async {
    var url =
        'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_openweatherkey&units=metric';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = response.body;
      var dataJson = jsonDecode(data); // string to json
      setState(() {
        _weatherData = dataJson;
      });
    } else {
      print('response status code = ${response.statusCode}');
      setState(() {
        _weatherData = {'error': 'Error fetching weather data'};
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController.moveCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  void _showWeatherDialog() {
    if (_weatherData == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text(
            '내 위치 날씨 정보',
            style: TextStyle(color: Color(0xffFFFCF2)),
          ),
          content: _weatherData != null
              ? _buildWeatherContent()
              : const CircularProgressIndicator(),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '닫기',
                style: TextStyle(color: Color(0xffFFFCF2)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeatherContent() {
    final TextStyle textStyle = TextStyle(
      color: Color(0xffFFFCF2),
      fontSize: 16.0, // 텍스트 크기를 18로 설정
    );

    if (_weatherData == null || _weatherData!.containsKey('error')) {
      return Text(
        _weatherData?['error'] ?? 'Unknown error',
        style: textStyle,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('도시: ${_weatherData!['name']}', style: textStyle),
        Text('온도: ${_weatherData!['main']['temp']}°C', style: textStyle),
        Text('체감온도: ${_weatherData!['main']['feels_like']}°C',
            style: textStyle),
        Text('기압: ${_weatherData!['main']['pressure']} hPa', style: textStyle),
        Text('습도: ${_weatherData!['main']['humidity']}%', style: textStyle),
        Text('날씨: ${_weatherData!['weather'][0]['description']}',
            style: textStyle),
        Text('풍속: ${_weatherData!['wind']['speed']} m/s', style: textStyle),
        Text('풍향: ${_weatherData!['wind']['deg']}°', style: textStyle),
        Text('구름: ${_weatherData!['clouds']['all']}%', style: textStyle),
        Text('가시거리: ${_weatherData!['visibility']} meters', style: textStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('내 주변 꽃집 찾기',
              style: TextStyle(
                color: Color(0xffFFFCF2),
                fontWeight: FontWeight.w600,
              )),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.wb_sunny),
              onPressed: _showWeatherDialog,
            ),
          ],
          iconTheme: const IconThemeData(color: Color(0xffFFFCF2))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14.0,
              ),
              markers: _currentPosition == null
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentPosition!,
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("녹심"),
                        position: LatLng(36.089890, 129.389751),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("꽃집르지오"),
                        position: LatLng(36.088771, 129.388273),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("여리"),
                        position: LatLng(36.084761, 129.397347),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("솔레유플라워"),
                        position: LatLng(36.083162, 129.396231),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("벨로아츠"),
                        position: LatLng(36.082149, 129.397136),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("플라워로그"),
                        position: LatLng(36.082307, 129.399282),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("메이릴리플라워"),
                        position: LatLng(36.082650, 129.401111),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("엔플레르"),
                        position: LatLng(36.083281, 129.401305),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("은꽃"),
                        position: LatLng(36.082851, 129.384657),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        markerId: const MarkerId("가을흔적"),
                        position: LatLng(36.082832, 129.383084),
                      ),
                    },
            ),
    );
  }
}
