import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AbsenPage extends StatefulWidget {
  final int idKaryawan;
  const AbsenPage({super.key, required this.idKaryawan});

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  List<Map<String, String>> riwayatAbsen = [];
  bool isLoading = false;
  bool isError = false;
  bool sudahAbsenHariIni = false; // Tambahkan variabel ini

  @override
  void initState() {
    super.initState();
    _riwayatAbsen();
  }

  Future<void> _riwayatAbsen() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final urlRiwayatAbsen =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

    try {
      final response = await http.get(Uri.parse(urlRiwayatAbsen)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          riwayatAbsen = responseData.map<Map<String, String>>((item) {
            return {
              'tanggal': item['tanggal'] ?? 'Tidak ada data',
              'masuk': item['jam_masuk'] ?? 'Tidak ada data',
            };
          }).toList();

          // Periksa apakah sudah absen hari ini
          final now = DateTime.now();
          final today =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          sudahAbsenHariIni = riwayatAbsen.any((absen) => absen['tanggal'] == today);
        });
      } else {
        setState(() {
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _absenMasuk() async {
    if (isLoading || sudahAbsenHariIni) return; // Jangan izinkan absen jika sudah absen hari ini

    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();
    final tanggal = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final waktuMasuk = '${now.hour}:${now.minute}';
    const urlAbsen = 'http://10.0.3.2/kepegawaian_dzaky/absen.php';

    try {
      final response = await http.post(
        Uri.parse(urlAbsen),
        body: {
          'karyawan_id': widget.idKaryawan.toString(), // Kirim idKaryawan
          'tanggal': tanggal,
          'jam_masuk': waktuMasuk,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Absen berhasil'),
            ),
          );

          // Set status sudahAbsenHariIni ke true
          setState(() {
            sudahAbsenHariIni = true;
          });

          // Perbarui riwayat absen
          await _riwayatAbsen();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal melakukan absen. Silakan coba lagi.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading || sudahAbsenHariIni ? null : _absenMasuk, // Nonaktifkan jika sudah absen
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      sudahAbsenHariIni ? 'Sudah Absen Hari Ini' : 'Absen Masuk', // Ubah teks jika sudah absen
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Absen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isError)
              const Center(
                child: Text(
                  'Gagal memuat data riwayat absen.',
                  style: TextStyle(color: Colors.red),
                ),
              )
            else if (riwayatAbsen.isEmpty)
              const Center(
                child: Text('Tidak ada data riwayat absen.'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: riwayatAbsen.length,
                  itemBuilder: (context, index) {
                    final absen = riwayatAbsen[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text('Tanggal: ${absen['tanggal']}'),
                        subtitle: Text('Masuk: ${absen['masuk']}'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}