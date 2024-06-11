import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'add.dart';

class AddListPage extends StatelessWidget {
  const AddListPage({super.key});

  Future<String> _getImageUrl(String imageName) async {
    // 파이어베이스 스토리지에서 이미지 URL을 가져오는 함수
    try {
      final ref = FirebaseStorage.instance.ref().child('$imageName.png');
      return await ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('키우는 식물을 선택해주세요!',
              style: TextStyle(
                  color: Color(0xffFFFCF2),
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
          iconTheme: const IconThemeData(color: Color(0xffFFFCF2))),
      backgroundColor: const Color(0xffFFFCF2),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('addPlantList').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plants = snapshot.data!.docs;

          return AnimationLimiter(
            // 애니메이션을 위한 AnimationLimiter 추가
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return AnimationConfiguration.staggeredGrid(
                  // AnimationConfiguration.staggeredGrid로 애니메이션 설정
                  position: index,
                  duration: const Duration(milliseconds: 1575),
                  columnCount: 3, // GridView의 열 수와 동일하게 설정
                  child: SlideAnimation(
                    // SlideAnimation으로 아이템이 슬라이드되는 애니메이션
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      // FadeInAnimation으로 아이템이 페이드되는 애니메이션
                      child: GestureDetector(
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
                          future: _getImageUrl(
                              plant.id), // 문서 ID와 같은 이름의 이미지 URL 가져오기
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
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
                                  Container(
                                    color: Colors.green,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      plant['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}
