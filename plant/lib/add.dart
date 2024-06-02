import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPage extends StatefulWidget {
  final String name;
  final String lux;
  final String temp;
  final String humidity;
  final String info;
  final String water;

  const AddPage({
    required this.name,
    required this.lux,
    required this.temp,
    required this.humidity,
    required this.info,
    required this.water,
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
                child: Image.asset(
                  'images/seed.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 24),
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
                        const Icon(Icons.thermostat_outlined, color: Colors.lightGreen,), 
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
                        const Icon(Icons.opacity_outlined, color: Color.fromARGB(255, 127, 203, 238),), 
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
                        const Icon(Icons.format_color_fill, color: Colors.lightBlue,), 
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
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '식물 등록하기',
                    style: TextStyle(color: Colors.white),
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
