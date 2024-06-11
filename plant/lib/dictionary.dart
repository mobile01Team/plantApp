import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
        actions: [
          DropdownButton<String>(
            value: selectedType,
            items:
                <String>['All', 'Type1', 'Type2', 'Type3'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('addPlantList').snapshots(),
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
                          margin: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 15),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Row(
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor:
                                          const Color.fromARGB(255, 7, 69, 69),
                                      highlightColor: const Color.fromARGB(
                                          255, 140, 188, 96),
                                      child: Text(
                                        plant['name'],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.lightGreen, width: 2),
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
                                        highlightColor: const Color.fromARGB(
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
                                  ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.wb_sunny_outlined,
                                              color: Colors.orange),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              plant['lux'],
                                              style:
                                                  const TextStyle(fontSize: 18),
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
                                              plant['temp'],
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.opacity_outlined,
                                              color: Color.fromARGB(
                                                  255, 127, 203, 238)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              plant['humidity'],
                                              style:
                                                  const TextStyle(fontSize: 18),
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
                                              plant['water'],
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        plant['info'],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
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
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }
}
