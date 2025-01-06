import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Karyawan extends StatefulWidget {
  const Karyawan({super.key});

  @override
  State<Karyawan> createState() => _KaryawanState();
}

class _KaryawanState extends State<Karyawan> {
  List<dynamic> listPegawai = [];

  @override
  void initState() {
    super.initState();
    _daftarPegawai();
  }

  Future<void> _daftarPegawai() async {
    String urlPegawai = "http://10.0.3.2/kepegawaian_dzaky/pegawai.php";
    try {
      var response = await http.get(Uri.parse(urlPegawai));
      setState(() {
        listPegawai = jsonDecode(response.body);
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
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
            'Daftar Pegawai',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      body: ListView.builder(
        itemCount: listPegawai.length,
        itemBuilder: (context, index) {
          var pegawai = listPegawai[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              leading: pegawai['images'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(pegawai['images']),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
              title: Text(
                pegawai['nama'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                pegawai['jabatan'],
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPegawai(pegawai: pegawai),
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

class DetailPegawai extends StatelessWidget {
  final Map<String, dynamic> pegawai;

  const DetailPegawai({super.key, required this.pegawai});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pegawai['nama']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: pegawai['images'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(pegawai['images']),
                      radius: 60,
                    )
                  : const CircleAvatar(
                      radius: 60,
                      child: Icon(Icons.person, size: 60),
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nama: ${pegawai['nama']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Jabatan: ${pegawai['jabatan']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Telepon: ${pegawai['telepon']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Tanggal Mulai: ${pegawai['tanggal_mulai']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Departemen: ${pegawai['departemen']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}