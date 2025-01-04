import 'dart:convert';
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
  bool loading = false;
  bool error = false;
  bool sudahAbsenPulang = false;

  @override
  void initState() {
    super.initState();
    _riwayatAbsenPulang();
  }

  Future<void> _riwayatAbsenPulang() async {
    setState(() {
      loading = true;
      error = false;
    });

    String urlRiwayatAbsenPulang =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

    try {
      var response = await http.get(Uri.parse(urlRiwayatAbsenPulang));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          riwayatAbsenPulang = responseData.map<Map<String, String>>((item) {
            return {
              'tanggal': item['tanggal'] ?? 'Tidak ada data',
              'masuk': item['jam_masuk'] ?? 'Tidak ada data',
              'pulang': item['jam_keluar'] ?? 'Tidak ada data',
            };
          }).toList();

          
          sudahAbsenPulang = _cekSudahAbsenPulangHariIni();
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

  Future<void> _absenPulang() async {
    if (loading || sudahAbsenPulang) return;

    setState(() {
      loading = true;
    });

    var tanggal = _getHariIni();
    var waktuPulang = '${DateTime.now().hour}:${DateTime.now().minute}';
    var urlAbsenPulang = 'http://10.0.3.2/kepegawaian_dzaky/absen_pulang.php';

    try {
      var response = await http.post(Uri.parse(urlAbsenPulang), body: {
        'karyawan_id': widget.idKaryawan.toString(),
        'tanggal': tanggal,
        'jam_keluar': waktuPulang,
      });
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Absen Berhasil'),
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

  @override
  Widget build(BuildContext context) {
    bool sudahAbsenMasukHariIni = _cekSudahAbsenMasukHariIni();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absen Pulang'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: (loading || sudahAbsenPulang || !sudahAbsenMasukHariIni)
                  ? null
                  : _absenPulang,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: loading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      sudahAbsenPulang
                          ? 'Sudah Absen Pulang Hari Ini'
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
            const SizedBox(height: 10),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (error)
              const Center(
                child: Text(
                  'Gagal memuat data riwayat absen pulang.',
                  style: TextStyle(color: Colors.red),
                ),
              )
            else if (riwayatAbsenPulang.isEmpty)
              const Center(
                child: Text('Tidak ada data riwayat absen pulang.'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: riwayatAbsenPulang.length,
                  itemBuilder: (context, index) {
                    var absen = riwayatAbsenPulang[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text('Tanggal: ${absen['tanggal']}'),
                        subtitle: Text(
                            'Masuk: ${absen['masuk']}\nPulang: ${absen['pulang']}'),
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