import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddLaporan extends StatefulWidget {
  final int idKaryawan;
  const AddLaporan({super.key, required this.idKaryawan});

  @override
  State<AddLaporan> createState() => _AddLaporanState();
}

class _AddLaporanState extends State<AddLaporan> {
  final _aktivitas = TextEditingController();

  Future<void> _addLaporan() async {
    final now = DateTime.now();
    final tanggal =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String urlLaporan = 'http://10.0.2.2/kepegawaian_dzaky/add_laporan.php';
    try {
      var response = await http.post(Uri.parse(urlLaporan), body: {
        "karyawan_id": widget.idKaryawan.toString(),
        "aktivitas": _aktivitas.text.toString(),
        "tanggal": tanggal,
      });
      if (kDebugMode) {
        print("Respons dari server: ${response.body}");
      }

      var bodyAddIde = jsonDecode(response.body);
      if (bodyAddIde['message'] == "Laporan succesfully added") {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menambahkan Laporan.")),
        );
      }
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $exc")),
      );
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
          'Tambah Laporan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aktivitas,
              decoration: const InputDecoration(
                labelText: 'Aktivitas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _addLaporan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Tambah laporan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
