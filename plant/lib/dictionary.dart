import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colored_text/colored_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart'; // shimmer 패키지 추가
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  String selectedType = 'All';
  PageController _pageController = PageController();

  Future<String> _getImageUrl(String imageName) async {
    // Firebase Storage에서 이미지 URL을 가져오는 함수
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
        title: const Text('식물 도감',
            style: TextStyle(
              color: Color(0xffFFFCF2),
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Color(0xffFFFCF2)),
      ),
      backgroundColor: const Color(0xffFFFCF2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                style: const TextStyle(
                  color: Colors.black,
                ),
                items: <String>[
                  'All',
                  '키우기 쉬움',
                  '공기정화',
                  '향이 좋음',
                  '진정효과',
                  '가습효과'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                          color: value == selectedType
                              ? Colors.green
                              : Colors.black,
                          fontWeight: value == selectedType
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 17),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('addPlantList')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plants = snapshot.data!.docs.where((plant) {
                  if (selectedType == 'All') return true;
                  return plant['special'] == selectedType;
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          final plant = plants[index];
                          return FutureBuilder<String>(
                            future: _getImageUrl(plant.id),
                            builder: (context, imageUrlSnapshot) {
                              if (!imageUrlSnapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final imageUrl = imageUrlSnapshot.data!;
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: Colors.green,
                                    width: 1.0,
                                  ),
                                ),
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: imageUrl.isNotEmpty
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
                                              ),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // 수직 정렬을 왼쪽 정렬로 설정
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.lightGreen,
                                                  width: 2),
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
                                              highlightColor:
                                                  const Color.fromARGB(
                                                      255, 169, 176, 159),
                                              child: Text(
                                                plant['special'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 15), // 수직 간격 추가
                                          SizedBox(
                                              width: 250.0,
                                              height: 27,
                                              child: ColoredText(
                                                plant['name'],
                                                color: Colors.green,
                                                textStyle:
                                                    GoogleFonts.nanumMyeongjo(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 24,
                                                  color: Colors.black,
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 23),
                                      Container(
                                        height: 320, // 고정된 높이 설정
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xffFFFCF2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.wb_sunny_outlined,
                                                      color: Colors.orange),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      plant['lux'],
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.thermostat_outlined,
                                                      color: Colors.lightGreen),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      plant['temp'],
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.opacity_outlined,
                                                      color: Color.fromARGB(
                                                          255, 127, 203, 238)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      plant['humidity'],
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.format_color_fill,
                                                      color: Colors.lightBlue),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      plant['water'],
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      overflow:
                                                          TextOverflow.clip,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                plant['info'],
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 13.0),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: plants.length,
                      effect: ScrollingDotsEffect(
                        dotWidth: 8.0,
                        dotHeight: 8.0,
                        activeDotColor: Colors.green,
                        dotColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
