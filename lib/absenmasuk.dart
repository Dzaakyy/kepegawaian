import 'dart:convert';
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
  bool loading = false;
  bool error = false;
  bool sudahAbsenHariIni = false;

  @override
  void initState() {
    super.initState();
    _riwayatAbsen();
  }

  Future<void> _riwayatAbsen() async {
    setState(() {
      loading = true;
      error = false;
    });

    String urlRiwayatAbsen =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

    try {
      final response = await http
          .get(Uri.parse(urlRiwayatAbsen))
          .timeout(const Duration(seconds: 10));

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

          sudahAbsenHariIni =
              riwayatAbsen.any((absen) => absen['tanggal'] == today);
        });
      } else {
        setState(() {
          error = true;
        });
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _absenMasuk() async {
    if (loading || sudahAbsenHariIni) return;

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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Absen berhasil'),
            ),
          );

          // Update state
          setState(() {
            sudahAbsenHariIni = true;
          });

          // Refresh riwayat absen
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
        title: const Text('Absen Masuk'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loading || sudahAbsenHariIni ? null : _absenMasuk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
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
                    color: Colors
                        .grey[600], // Warna abu-abu untuk informasi tambahan
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (error)
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
                    final keterlambatan = _hitungKeterlambatan(absen['masuk']!);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
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
