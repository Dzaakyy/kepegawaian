import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kepegawaian/acara_perusahaan.dart';
import 'package:kepegawaian/accountpage.dart';
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
    String urlDepartemen = "http://10.0.2.2/kepegawaian_dzaky/departemen.php";
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
        'http://10.0.2.2/kepegawaian_dzaky/riwayat_absen.php?karyawan_id=${widget.idKaryawan}';

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
              Navigator.push(context, 
              MaterialPageRoute(builder: (context) => const AcaraPerusahaan())
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
           
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.login,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Absen Masuk Hari Ini',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                sudahAbsenHariIni
                                    ? 'Anda sudah absen masuk pada pukul $jamAbsenMasuk'
                                    : 'Anda belum absen masuk hari ini',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

            
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Absen Pulang Hari Ini',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                jamAbsenPulang.isNotEmpty
                                    ? 'Anda sudah absen pulang pada pukul $jamAbsenPulang'
                                    : 'Anda belum absen pulang hari ini',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 20),

              
              // Card(
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [Colors.blue.shade400, Colors.blue.shade700],
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //       ),
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //     child: const Padding(
              //       padding: EdgeInsets.all(16),
              //       child: Row(
              //         children: [
              //           Icon(
              //             Icons.assignment,
              //             size: 40,
              //             color: Colors.white,
              //           ),
              //           SizedBox(width: 16),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   'Sisa Cuti Anda',
              //                   style: TextStyle(
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.bold,
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //                 SizedBox(height: 5),
              //                 Text(
              //                   'Anda memiliki 5 hari cuti tersisa',
              //                   style: TextStyle(
              //                     fontSize: 14,
              //                     color: Colors.white70,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
             
              const SizedBox(height: 20),

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
