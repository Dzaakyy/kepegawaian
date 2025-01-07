import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AbsenPulang extends StatefulWidget {
  final int idKaryawan;
  const AbsenPulang({super.key, required this.idKaryawan});

  @override
  State<AbsenPulang> createState() => _AbsenPulangState();
}

class _AbsenPulangState extends State<AbsenPulang> {
  List<Map<String, String>> riwayatAbsenPulang = [];
  bool sudahAbsenPulang = false;
  bool loading = true;
  bool sudahAbsenMasukHariIni = false;

  @override
  void initState() {
    super.initState();
    _riwayatAbsenPulang();
  }

  Future<void> _riwayatAbsenPulang() async {
    setState(() {
      loading = true;
    });

    String urlRiwayatAbsenPulang =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?pegawai_id=${widget.idKaryawan}';

    try {
      var response = await http.get(Uri.parse(urlRiwayatAbsenPulang));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data dari API: $responseData');
        }
        setState(() {
          riwayatAbsenPulang = responseData.map<Map<String, String>>((item) {
            return {
              'tanggal': item['tanggal'] ?? 'Tidak ada data',
              'masuk': item['jam_masuk'] ?? 'Tidak ada data',
              'pulang': item['jam_keluar'] ?? 'Tidak ada data',
            };
          }).toList();

          sudahAbsenPulang = _cekSudahAbsenPulangHariIni();
          sudahAbsenMasukHariIni = _cekSudahAbsenMasukHariIni();
          loading = false;
        });
      } else {
        if (kDebugMode) {
          print('Status code: ${response.statusCode}');
        }
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        loading = false;
      });
    }
  }

  bool _cekSudahAbsenPulangHariIni() {
    var today = _getHariIni();
    return riwayatAbsenPulang.any((absen) =>
        absen['tanggal'] == today && absen['pulang'] != 'Tidak ada data');
  }

  bool _cekSudahAbsenMasukHariIni() {
    var today = _getHariIni();
    return riwayatAbsenPulang.any((absen) =>
        absen['tanggal'] == today && absen['masuk'] != 'Tidak ada data');
  }

  String _getHariIni() {
    var now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _waktuPulang() {
    final now = DateTime.now();
    final jamPulang = DateTime(now.year, now.month, now.day, 9, 0);
    return now.isAfter(jamPulang);
  }

  Future<void> _absenPulang() async {
    if (sudahAbsenPulang) return;

    var tanggal = _getHariIni();
    var waktuPulang = '${DateTime.now().hour}:${DateTime.now().minute}';
    var urlAbsenPulang = 'http://10.0.3.2/kepegawaian_dzaky/absen_pulang.php';

    try {
      var response = await http.post(Uri.parse(urlAbsenPulang), body: {
        'pegawai_id': widget.idKaryawan.toString(),
        'tanggal': tanggal,
        'jam_keluar': waktuPulang,
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Absen Berhasil'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            sudahAbsenPulang = true;
          });
          await _riwayatAbsenPulang();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal melakukan absen. Silahkan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
        title: const Text(
          'Absen Pulang',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: (sudahAbsenPulang ||
                      !sudahAbsenMasukHariIni ||
                      !_waktuPulang())
                  ? null
                  : _absenPulang,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                sudahAbsenPulang
                    ? 'Sudah Absen Pulang Hari Ini'
                    : !_waktuPulang()
                        ? 'Belum Waktunya Absen Pulang'
                        : sudahAbsenMasukHariIni
                            ? 'Absen Pulang'
                            : 'Belum Absen Masuk',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Absen Pulang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Jam Pulang: 17:00',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : riwayatAbsenPulang.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data riwayat absen pulang.'),
                        )
                      : ListView.builder(
                          itemCount: riwayatAbsenPulang.length,
                          itemBuilder: (context, index) {
                            var absen = riwayatAbsenPulang[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Text('Tanggal: ${absen['tanggal']}'),
                                subtitle: Text(
                                    'Pulang: ${absen['pulang']}'),
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