import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kepegawaian/acara_perusahaan.dart';
import 'package:kepegawaian/accountpage.dart';
import 'package:kepegawaian/ide_kreatif.dart';
import 'package:kepegawaian/laporan.dart';
import 'package:kepegawaian/karyawan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final int idKaryawan;
  const HomePage({super.key, required this.idKaryawan});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String namaUser = '';
  String jabatanUser = '';
  int idKaryawan = 0;
  List listDepartemen = [];
  bool sudahAbsenHariIni = false;
  String jamAbsenMasuk = '';
  String jamAbsenPulang = '';

  @override
  void initState() {
    super.initState();
    _dataUserLogin();
    _departemen();
    _cekAbsenHariIni();
  }

  Future<void> _dataUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUser = prefs.getString('namaUser') ?? '';
      jabatanUser = prefs.getString('jabatanUser') ?? '';
      idKaryawan = prefs.getInt('idKaryawan') ?? 0;
    });
  }

  Future<void> _departemen() async {
    String urlDepartemen = "http://10.0.3.2/kepegawaian_dzaky/departemen.php";
    try {
      var response = await http.get(Uri.parse(urlDepartemen));
      setState(() {
        listDepartemen = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> _cekAbsenHariIni() async {
    String today = _getHariIni();
    String urlRiwayatAbsen =
        'http://10.0.3.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

    try {
      var response = await http.get(Uri.parse(urlRiwayatAbsen));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final absenHariIni = responseData.firstWhere(
          (absen) => absen['tanggal'] == today,
          orElse: () => null,
        );

        setState(() {
          sudahAbsenHariIni = (absenHariIni?['jam_masuk'] ?? '') != '';
          jamAbsenMasuk = absenHariIni?['jam_masuk'] ?? '';
          jamAbsenPulang = absenHariIni?['jam_keluar'] ?? '';
        });
      }
    } catch (exc) {
      if (kDebugMode) {
        print('Error: $exc');
      }
    }
  }

  String _getHariIni() {
    var now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountPage(idKaryawan: idKaryawan),
            ),
          );
        },
        icon: const Icon(
          CupertinoIcons.person_alt,
          size: 22,
          color: Colors.white,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            namaUser,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            jabatanUser,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AcaraPerusahaan(),
              ),
            );
          },
          icon: const Icon(
            CupertinoIcons.calendar,
            size: 22,
            color: Colors.white,
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Baris pertama: Absen Masuk dan Absen Pulang
            GridView.count(
              crossAxisCount: 2, // 2 card per baris
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2, // Sesuaikan aspek rasio
              children: [
                // Card Absen Masuk
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Logika absen masuk
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.login,
                              size: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Absen Masuk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sudahAbsenHariIni
                                  ? 'Sudah absen pada $jamAbsenMasuk'
                                  : 'Belum absen hari ini',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Card Absen Pulang
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Logika absen pulang
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Absen Pulang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              jamAbsenPulang.isNotEmpty
                                  ? 'Sudah absen pada $jamAbsenPulang'
                                  : 'Belum absen pulang',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Baris kedua: Ide Kreatif, Laporan Harian, dan Pegawai
            GridView.count(
              crossAxisCount: 3, // 3 card per baris
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9, // Sesuaikan aspek rasio
              children: [
                // Card Ide Kreatif
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IdeKreatif(idKaryawan: idKaryawan),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 30,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ide Kreatif',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Card Laporan Harian
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Laporan(idKaryawan: idKaryawan),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book,
                              size: 30,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Laporan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Card Pegawai
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Karyawan(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              size: 30,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pegawai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // List Departemen
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Departemen dan Lokasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 325,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: listDepartemen.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.business,
                                color: Colors.blue,
                              ),
                              title: Text(
                                listDepartemen[index]['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                listDepartemen[index]['lokasi'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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