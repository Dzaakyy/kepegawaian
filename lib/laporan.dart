import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kepegawaian/add_laporan.dart';

class Laporan extends StatefulWidget {
  final int idKaryawan;
  const Laporan({super.key, required this.idKaryawan});

  @override
  State<Laporan> createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  final searchlaporanHarian = TextEditingController();
  List<dynamic> listLaporan = [];
  int get idKaryawan => widget.idKaryawan;

  @override
  void initState() {
    super.initState();
    _laporanHarian();
  }

  Future<void> _laporanHarian() async {
    String urlLaporan = 'http://10.0.2.2/kepegawaian_dzaky/laporan.php';
    try {
      var response = await http.get(Uri.parse(urlLaporan));
      if (kDebugMode) {
        print("Response: ${response.body}");
      }
      setState(() {
        listLaporan = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print("Error: $exc");
      }
    }
  }

  Future<void> deletelaporan(String id) async {
    String urlDelete = "http://10.0.2.2/kepegawaian_dzaky/delete_laporan.php";
    try {
      var respponseDelete =
          await http.post(Uri.parse(urlDelete), body: {"id_laporan": id});
      var bodyDelete = jsonDecode(respponseDelete.body);
      if (bodyDelete['Success'] == true) {
        if (kDebugMode) {
          print("Laporan Succesfully Deleted");
        }
        setState(() {
          listLaporan
              .removeWhere((laporan) => laporan['id_laporan'].toString() == id);
        });
      } else {
        if (kDebugMode) {
          print("Laporan failed to deleted");
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> searchLaporan() async {
    final search = searchlaporanHarian.text;
    if (search.isEmpty) {
      _laporanHarian();
      return;
    }

    String urlSearch =
        "http://10.0.2.2/kepegawaian_dzaky/search_laporan.php?search=$search";
    try {
      var responseSearch = await http.get(Uri.parse(urlSearch));
      final List listSearch = jsonDecode(responseSearch.body);
      setState(() {
        listLaporan = listSearch;
      });
    } catch (exc) {
      if (kDebugMode) {
        print("Failed to load Laporan: $exc");
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
          'Laporan Harian',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(3, 10, 3, 30),
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchlaporanHarian,
              decoration: InputDecoration(
                labelText: "Cari Laporan",
                hintText: "Cari : ",
                labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                hintStyle: const TextStyle(color: Colors.blue, fontSize: 15),
                suffixIcon: const Align(
                  widthFactor: 1.0,
                  child: Icon(Icons.search,
                      color: Colors.deepPurpleAccent, size: 20),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 3.0,
                      color: Colors.deepPurple.shade400,
                      style: BorderStyle.solid),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
              onChanged: (search) => searchLaporan(),
            ),
            Expanded(
              child: ListView.builder(
                key: Key(listLaporan.length.toString()),
                padding: const EdgeInsets.all(16.0),
                itemCount: listLaporan.length,
                itemBuilder: (context, index) {
                  var laporan = listLaporan[index];
                  return Card(
                    key: Key(laporan['id_laporan'].toString()),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue[50], 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 30,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            laporan['aktivitas'] ?? 'Aktivitas tidak tersedia',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Dibuat oleh: ${laporan['nama'] ?? 'Nama tidak tersedia'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Tanggal: ${laporan['tanggal'] ?? 'Tanggal tidak tersedia'}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailLaporan(laporan: laporan),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Lihat Detail',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              if (int.parse(
                                      laporan['karyawan_id'].toString()) ==
                                  widget.idKaryawan)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deletelaporan(
                                        laporan['id_laporan'].toString());
                                  },
                                ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLaporan(idKaryawan: idKaryawan),
            ),
          );

          if (result == true) {
            _laporanHarian();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DetailLaporan extends StatelessWidget {
  final Map<String, dynamic> laporan;

  const DetailLaporan({super.key, required this.laporan});

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
          'Detail Laporan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              laporan['aktivitas'] ?? 'Aktivitas tidak tersedia',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Dibuat oleh: ${laporan['nama'] ?? 'Nama tidak tersedia'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tanggal: ${laporan['tanggal'] ?? 'Tanggal tidak tersedia'}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}