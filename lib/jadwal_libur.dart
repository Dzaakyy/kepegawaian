import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JadwalLibur extends StatefulWidget {
  const JadwalLibur({super.key});

  @override
  State<JadwalLibur> createState() => _JadwalLiburState();
}

class _JadwalLiburState extends State<JadwalLibur> {
  List<dynamic> listJadwalLibur = [];

  @override
  void initState() {
    super.initState();
    _jadwalLibur();
  }

  Future<void> _jadwalLibur() async {
    const urlLibur = "http://10.0.2.2/kepegawaian_dzaky/jadwal_libur.php";
    try {
      var response = await http.get(Uri.parse(urlLibur));
      listJadwalLibur = jsonDecode(response.body);
      setState(() {
        listJadwalLibur = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jadwal Libur',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: listJadwalLibur.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listJadwalLibur.length,
              itemBuilder: (context, index) {
                final libur = listJadwalLibur[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    title: Text(
                      libur['keterangan'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      libur['tanggal_libur'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
