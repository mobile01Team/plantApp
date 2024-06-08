import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // firebase_storage 패키지 추가
import 'package:shimmer/shimmer.dart'; // shimmer 패키지 추가

class AddPage extends StatefulWidget {
  final String id;
  final String name;
  final String lux;
  final String temp;
  final String humidity;
  final String info;
  final String water;
  final String special;

  const AddPage({
    required this.id,
    required this.name,
    required this.lux,
    required this.temp,
    required this.humidity,
    required this.info,
    required this.water,
    required this.special,
    super.key,
  });

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nicknameController = TextEditingController();
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<String> _getImageUrl(String imageName) async {
    // 파이어베이스 스토리지에서 이미지 URL을 가져오는 함수
    try {
      final ref = FirebaseStorage.instance.ref().child('$imageName.png');
      return await ref.getDownloadURL();
    } catch (e) {
      // 오류가 발생할 경우 빈 문자열 반환
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FutureBuilder<String>(
                  future: _getImageUrl(widget.id), // 문서 ID와 같은 이름의 이미지 URL 가져오기
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final imageUrl = snapshot.data!;
                    return imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'images/seed.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
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
                  highlightColor: Color.fromARGB(255, 169, 176, 159),
                  child: Text(
                    widget.special,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
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
                        const Icon(Icons.thermostat_outlined, color: Colors.lightGreen),
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
                        const Icon(Icons.opacity_outlined, color: Color.fromARGB(255, 127, 203, 238)),
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
                        const Icon(Icons.format_color_fill, color: Colors.lightBlue),
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
                    const SizedBox(height: 16),
                    Text(
                      widget.info,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '애칭 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('키우기 시작한 날짜 선택'),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedDate != null)
                      const Icon(Icons.check, color: Colors.lightGreen),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final User? user = _auth.currentUser;
                    if (user != null && _selectedDate != null) {
                      await FirebaseFirestore.instance.collection('PlantList').add({
                        'name': widget.name,
                        'lux': widget.lux,
                        'temp': widget.temp,
                        'humidity': widget.humidity,
                        'info': widget.info,
                        'water': widget.water,
                        'nickname': _nicknameController.text,
                        'userid': user.uid,
                        'date': Timestamp.fromDate(_selectedDate!),
                        'special': widget.special,
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 156, 156, 214),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '식물 등록하기',
                    style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
