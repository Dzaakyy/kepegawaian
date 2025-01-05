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
  List<dynamic> listIde = [];
  int get idKaryawan => widget.idKaryawan;

  @override
  void initState() {
    super.initState();
    _ideKreatif();
  }

  Future<void> _ideKreatif() async {
    String urlIde = 'http://10.0.2.2/kepegawaian_dzaky/ide_kreatif.php';
    try {
      var response = await http.get(Uri.parse(urlIde));
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        if (responsedata is List) {
          setState(() {
            listIde = responsedata;
          });
        } else {
          if (kDebugMode) {
            print("Respons dari server bukan berupa list.");
          }
        }
      } else {
        if (kDebugMode) {
          print("Gagal mengambil data: ${response.statusCode}");
        }
      }
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    String urlDelete = "http://10.0.2.2/kepegawaian_dzaky/delete_ide_kreatif.php";
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
          'Ide Kreatif',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        key: Key(listIde.length.toString()), // Key unik untuk ListView
        padding: const EdgeInsets.all(16.0),
        itemCount: listIde.length,
        itemBuilder: (context, index) {
          var ide = listIde[index];
          Color cardColor = index % 2 == 0 ? Colors.blue[50]! : Colors.lightBlue[50]!;

          return Card(
            key: Key(ide['id_ide'].toString()), // Key unik untuk setiap Card
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: cardColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Anda memilih: ${ide['judul_ide']}"),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Ide
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
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteProduct(ide['id_ide'].toString());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    Text(
                      ide['deskripsi'] ?? 'Deskripsi tidak tersedia',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kategori
                    Text(
                      "Kategori: ${ide['kategori'] ?? 'Kategori tidak tersedia'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nama Karyawan
                    Text(
                      "Dibuat oleh: ${ide['nama'] ?? 'Nama tidak tersedia'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Lihat Detail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Detail: ${ide['judul_ide']}"),
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
            ),
          );
        },
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () async {
    // Gunakan await untuk menunggu nilai kembalian
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIdeKreatif(idKaryawan: idKaryawan),
      ),
    );

    // Jika result adalah true, perbarui data
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