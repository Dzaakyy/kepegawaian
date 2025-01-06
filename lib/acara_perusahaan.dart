import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AcaraPerusahaan extends StatefulWidget {
  const AcaraPerusahaan({super.key});

  @override
  State<AcaraPerusahaan> createState() => _AcaraPerusahaanState();
}

class _AcaraPerusahaanState extends State<AcaraPerusahaan> {
  List<dynamic> listAcara = [];
  final searchAcara = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jadwalAcara();
  }

  Future<void> _jadwalAcara() async {
    const urlLibur = "http://10.0.2.2/kepegawaian_dzaky/acara_perusahaan.php";
    try {
      var response = await http.get(Uri.parse(urlLibur));
      setState(() {
        listAcara = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> _searchAcara() async {
    final search = searchAcara.text;
    _jadwalAcara();
    if (search.isEmpty) {
      return;
    }
    String urlSearch =
        "http://10.0.2.2/kepegawaian_dzaky/search_acara_perusahaan.php?search=$search";
    try {
      var responseSeacrh = await http.get(Uri.parse(urlSearch));
      final List listSearch = jsonDecode(responseSeacrh.body);
      setState(() {
        listAcara = listSearch;
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
            'Acara Perusahaan',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(3, 10, 3, 30),
          child: Column(
            children: [
              TextField(
                controller: searchAcara,
                decoration: InputDecoration(
                  labelText: "Cari Acara Perusahaan",
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
                onChanged: (search) => _searchAcara(),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listAcara.length,
                  itemBuilder: (context, index) {
                    var acara = listAcara[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acara['nama_acara'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  acara['tanggal_acara'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  acara['lokasi'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              acara['deskripsi'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
