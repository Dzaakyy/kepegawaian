import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pegawai extends StatefulWidget {
  const Pegawai({super.key});

  @override
  State<Pegawai> createState() => _PegawaiState();
}

class _PegawaiState extends State<Pegawai> {
  List<dynamic> listPegawai = [];
  final searchPegawai = TextEditingController();

  @override
  void initState() {
    super.initState();
    _daftarPegawai();
  }

  Future<void> _daftarPegawai() async {
    String urlPegawai = "http://10.0.2.2/kepegawaian_dzaky/pegawai.php";
    try {
      var response = await http.get(Uri.parse(urlPegawai));
      setState(() {
        listPegawai = jsonDecode(response.body);
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> _searchPegawai() async {
    final search = searchPegawai.text;
    _daftarPegawai();
    if (search.isEmpty) {
      return;
    }
    String urlSearch =
        "http://10.0.2.2/kepegawaian_dzaky/search_pegawai.php?search=$search";
    try {
      var responseSearch = await http.get(Uri.parse(urlSearch));
      final List listSearch = jsonDecode(responseSearch.body);
      setState(() {
        listPegawai = listSearch;
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
            'Daftar Pegawai',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(3, 10, 3, 30),
          child: Column(
            children: <Widget>[
              TextField(
                controller: searchPegawai,
                decoration: InputDecoration(
                  labelText: "Cari Pegawai",
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
                onChanged: (search) => _searchPegawai(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listPegawai.length,
                  itemBuilder: (context, index) {
                    var pegawai = listPegawai[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      child: ListTile(
                        leading: pegawai['images'] != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(pegawai['images']),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                          pegawai['nama'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          pegawai['jabatan'],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailPegawai(pegawai: pegawai),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class DetailPegawai extends StatelessWidget {
  final Map<String, dynamic> pegawai;

  const DetailPegawai({super.key, required this.pegawai});

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
          "Detail Pegawai",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Profil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: pegawai['images'] != null && pegawai['images'].isNotEmpty
                    ? NetworkImage(pegawai['images'])
                    : null,
                child: pegawai['images'] == null || pegawai['images'].isEmpty
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            // Nama dan Jabatan
            Center(
              child: Text(
                pegawai['nama'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                pegawai['jabatan'] ?? 'Tidak ada data',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.apartment, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Departemen',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pegawai['departemen'] ?? 'Tidak ada data',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.phone, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Telepon',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pegawai['telepon'] ?? 'Tidak ada data',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanggal Mulai',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pegawai['tanggal_mulai'] ?? 'Tidak ada data',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
