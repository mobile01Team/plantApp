import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // firebase_storage 패키지 추가
import 'add.dart'; // add.dart 파일을 임포트합니다

class AddListPage extends StatelessWidget {
  const AddListPage({super.key});

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
        title: const Text('Add Plant List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('addPlantList').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plants = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 가로로 3개의 아이템을 배치
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75, // 카드의 가로 세로 비율
            ),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPage(
                        id: plant.id, // 문서 ID를 AddPage로 전달
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
                },
                child: FutureBuilder<String>(
                  future: _getImageUrl(plant.id), // 문서 ID와 같은 이름의 이미지 URL 가져오기
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final imageUrl = snapshot.data!;
                    return Card(
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'images/seed.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              plant['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
