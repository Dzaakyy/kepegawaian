import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AbsenMasuk extends StatefulWidget {
  final int idKaryawan;
  const AbsenMasuk({super.key, required this.idKaryawan});

  @override
  State<AbsenMasuk> createState() => _AbsenMasukState();
}

class _AbsenMasukState extends State<AbsenMasuk> {
  List<Map<String, String>> riwayatAbsen = [];
  bool sudahAbsenHariIni = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _riwayatAbsen();
  }

  Future<void> _riwayatAbsen() async {
    setState(() {
      loading = true;
    });

    String urlRiwayatAbsen =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

    try {
      final response = await http.get(Uri.parse(urlRiwayatAbsen));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          riwayatAbsen = responseData.map<Map<String, String>>((item) {
            return {
              'tanggal': item['tanggal'] ?? 'Tidak ada data',
              'masuk': item['jam_masuk'] ?? 'Tidak ada data',
            };
          }).toList();

          final now = DateTime.now();
          final today =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          sudahAbsenHariIni =
              riwayatAbsen.any((absen) => absen['tanggal'] == today);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _absenMasuk() async {
    if (sudahAbsenHariIni || loading) return;

    setState(() {
      loading = true;
    });

    final now = DateTime.now();
    final tanggal =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final waktuMasuk = '${now.hour}:${now.minute}';
    const urlAbsen = 'http://10.0.3.2/kepegawaian_dzaky/absen_masuk.php';

    try {
      final response = await http.post(
        Uri.parse(urlAbsen),
        body: {
          'karyawan_id': widget.idKaryawan.toString(),
          'tanggal': tanggal,
          'jam_masuk': waktuMasuk,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Absen berhasil'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            sudahAbsenHariIni = true;
          });

          await _riwayatAbsen();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal melakukan absen. Silakan coba lagi.'),
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
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _hitungKeterlambatan(String jamMasuk) {
    final waktuMasuk = jamMasuk.split(':');
    final jam = int.parse(waktuMasuk[0]);
    final menit = int.parse(waktuMasuk[1]);

    final waktuAbsen = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, jam, menit);
    final batasWaktuMasuk = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0);

    final durasiKeterlambatan = waktuAbsen.difference(batasWaktuMasuk);

    if (durasiKeterlambatan.inMinutes > 0) {
      return 'Telat ${durasiKeterlambatan.inMinutes} menit';
    } else {
      return '';
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
        title: const Text(
          'Absen Masuk',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: (sudahAbsenHariIni || loading) ? null : _absenMasuk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: loading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      sudahAbsenHariIni
                          ? 'Sudah Absen Masuk Hari Ini'
                          : 'Absen Masuk',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  'Riwayat Absen Masuk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Jam Masuk: 09:00',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : riwayatAbsen.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data riwayat absen.'),
                        )
                      : ListView.builder(
                          itemCount: riwayatAbsen.length,
                          itemBuilder: (context, index) {
                            final absen = riwayatAbsen[index];
                            final keterlambatan =
                                _hitungKeterlambatan(absen['masuk']!);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Text('Tanggal: ${absen['tanggal']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Masuk: ${absen['masuk']}'),
                                    if (keterlambatan.isNotEmpty)
                                      Text(
                                        keterlambatan,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
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
