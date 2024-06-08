import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add.dart';

class SearchImage extends StatefulWidget {
  const SearchImage({super.key});

  @override
  State<SearchImage> createState() => _SearchImageState();
}

class _SearchImageState extends State<SearchImage> {
  String parsedtext = "";
  bool _textExtracted = false; // 텍스트 추출 완료 여부를 나타내는 플래그

  Future<void> _getFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    var bytes = File(pickedFile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);

    var url = 'https://api.ocr.space/parse/image';
    var payload = {
      "base64Image": "data:image/jpg;base64,${img64.toString()}",
      "language": "kor"
    };
    var header = {"apikey": "K88781771388957"};

    var post = await http.post(Uri.parse(url), body: payload, headers: header);
    var result = jsonDecode(post.body);

    setState(() {
      parsedtext = result['ParsedResults'][0]['ParsedText'];
      _textExtracted = true; // 텍스트 추출 완료로 플래그 설정
    });
  }

  Future<void> _findAndNavigateToPlantDetail(BuildContext context) async {
  if (!_textExtracted) return; // 텍스트 추출이 완료되지 않았으면 함수 종료

  final snapshot = await FirebaseFirestore.instance
      .collection('PlantList')
      .where('name', isEqualTo: parsedtext.trim()) // trim()으로 앞뒤 공백 제거
      .get();

  if (snapshot.docs.isNotEmpty) {
    final plant = snapshot.docs[0];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPage(
          name: plant['name'],
          lux: plant['lux'],
          temp: plant['temp'],
          humidity: plant['humidity'],
          info: plant['info'],
          water: plant['water'],
          special: plant['special'],
        ),
      ),
    );
  } else {
   
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getFromGallery,
              child: const Text('Select Image from Gallery'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _findAndNavigateToPlantDetail(context),
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Text(parsedtext.isNotEmpty ? parsedtext : 'No text extracted'),
          ],
        ),
      ),
    );
  }
}
