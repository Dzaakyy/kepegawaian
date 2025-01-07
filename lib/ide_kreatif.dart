import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kepegawaian/add_ide_kreatif.dart';

class IdeKreatif extends StatefulWidget {
  final int idKaryawan;
  const IdeKreatif({super.key, required this.idKaryawan});

  @override
  State<IdeKreatif> createState() => _IdeKaretifState();
}

class _IdeKaretifState extends State<IdeKreatif> {
  final searchIde = TextEditingController();
  List<dynamic> listIde = [];
  int get idKaryawan => widget.idKaryawan;

  @override
  void initState() {
    super.initState();
    _ideKreatif();
  }

  Future<void> _ideKreatif() async {
    String urlIde = 'http://10.0.3.2/kepegawaian_dzaky/ide_kreatif.php';
    try {
      var response = await http.get(Uri.parse(urlIde));
      listIde = jsonDecode(response.body);
      setState(() {
        listIde = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> deleteide(String id) async {
    String urlDelete =
        "http://10.0.3.2/kepegawaian_dzaky/delete_ide_kreatif.php";
    try {
      var respponseDelete =
          await http.post(Uri.parse(urlDelete), body: {"id_ide": id});
      var bodyDelete = jsonDecode(respponseDelete.body);
      if (bodyDelete['Success'] == true) {
        if (kDebugMode) {
          print("Ide Succesfully Deleted");
        }
        setState(() {
          listIde.removeWhere((ide) => ide['id_ide'].toString() == id);
        });
      } else {
        if (kDebugMode) {
          print("Ide failed to deleted");
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> searchIdeKreatif() async {
    final search = searchIde.text;
    _ideKreatif();
    if (search.isEmpty) {
      return;
    }
    String urlSearch =
        "http://10.0.3.2/kepegawaian_dzaky/search_ide_kreatif.php?search=$search";
    try {
      var responseSearch = await http.get(Uri.parse(urlSearch));
      final List listSearch = jsonDecode(responseSearch.body);
      setState(() {
        listIde = listSearch;
      });
    } catch (exc) {
      if (kDebugMode) {
        print("Failed to load Ide");
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
            colors: [Colors.blue.shade900, Colors.blue.shade600],
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
          'Ide Kreatif',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(3, 10, 3, 30),
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchIde,
              decoration: InputDecoration(
                labelText: "Cari Ide Kreatif",
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
              onChanged: (search) => searchIdeKreatif(),
            ),
            Expanded(
              child: ListView.builder(
                key: Key(listIde.length.toString()),
                padding: const EdgeInsets.all(16.0),
                itemCount: listIde.length,
                itemBuilder: (context, index) {
                  var ide = listIde[index];
                  return Card(
                    key: Key(ide['id_ide'].toString()),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                size: 30,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ide['judul_ide'] ?? 'Judul tidak tersedia',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (int.parse(ide['pegawai_id'].toString()) ==
                                  widget.idKaryawan)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deleteide(ide['id_ide'].toString());
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ide['deskripsi'] ?? 'Deskripsi tidak tersedia',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Kategori: ${ide['kategori'] ?? 'Kategori tidak tersedia'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Dibuat oleh: ${ide['nama'] ?? 'Nama tidak tersedia'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
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
                                          DetailIdeKreatif(ide: ide),
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
              builder: (context) => AddIdeKreatif(idKaryawan: idKaryawan),
            ),
          );

          if (result == true) {
            _ideKreatif();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DetailIdeKreatif extends StatelessWidget {
  final Map<String, dynamic> ide;

  const DetailIdeKreatif({super.key, required this.ide});

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
          'Detail Ide Kreatif',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ide['judul_ide'] ?? 'Judul tidak tersedia',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ide['deskripsi'] ?? 'Deskripsi tidak tersedia',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Kategori: ${ide['kategori'] ?? 'Kategori tidak tersedia'}",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Dibuat oleh: ${ide['nama'] ?? 'Nama tidak tersedia'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tanggal: ${ide['tanggal'] ?? 'Tanggal tidak tersedia'}",
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