import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  Future<String> _getImageUrl(String imageName) async {
    // Firebase Storage에서 이미지 URL을 가져오는 함수
    try {
      final ref = FirebaseStorage.instance.ref().child('$imageName.png');
      print(ref.getDownloadURL());
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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('addPlantList').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return FutureBuilder<String>(
                future: _getImageUrl(plant.id),
                builder: (context, imageUrlSnapshot) {
                  if (!imageUrlSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final imageUrl = imageUrlSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: ListTile(
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'images/seed.png',
                                fit: BoxFit.contain,
                              ),
                      ),
                      title: Text(plant['name']),
                      subtitle: Text('Type: ${plant['special']}'),
                      onTap: () {
                        // Navigator.push(context
                        //     // MaterialPageRoute(
                        //     //   builder: (context) => DetailPage(plant: plant),
                        //     // ),
                        //     );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
