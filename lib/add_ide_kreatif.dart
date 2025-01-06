import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddIdeKreatif extends StatefulWidget {
  final int idKaryawan;
  const AddIdeKreatif({super.key, required this.idKaryawan});

  @override
  State<AddIdeKreatif> createState() => _AddIdeKreatifState();
}

class _AddIdeKreatifState extends State<AddIdeKreatif> {
  final _judulIde = TextEditingController();
  final _deskripsi = TextEditingController();
  final _kategori = TextEditingController();

  Future<void> _addIde() async {
  final now = DateTime.now();
  final tanggal = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  String urlIde = 'http://10.0.3.2/kepegawaian_dzaky/add_ide_kreatif.php';
  try {
    var response = await http.post(Uri.parse(urlIde), body: {
      "karyawan_id": widget.idKaryawan.toString(),
      "judul_ide": _judulIde.text.toString(),
      "deskripsi": _deskripsi.text.toString(),
      "kategori": _kategori.text.toString(),
      "tanggal": tanggal,
    });
    if (kDebugMode) {
      print("Respons dari server: ${response.body}");
    }

    var bodyAddIde = jsonDecode(response.body);
    if (bodyAddIde['message'] == "Ide Kretaif succesfully added") {
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan ide kreatif.")),
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
          'Tambah Ide Kreatif',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Judul Ide
            TextField(
              controller: _judulIde,
              decoration: const InputDecoration(
                labelText: 'Judul Ide',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _deskripsi,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, 
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _addIde,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Tambah Ide',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
