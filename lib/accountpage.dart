import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kepegawaian/signin_screen.dart';
import 'dart:convert';

class AccountPage extends StatefulWidget {
  final int idKaryawan;
  const AccountPage({super.key, required this.idKaryawan});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String nama = 'Loading...';
  String telepon = 'Loading...';
  String tanggalMulai = 'Loading...';
  String departemen = 'Loading...';
  String jabatan = 'Loading...';
  String images = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final url = Uri.parse(
        'http://10.0.3.2/kepegawaian_dzaky/profile.php?id_karyawan=${widget.idKaryawan}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            nama = data['data']['nama'];
            telepon = data['data']['telepon'] ?? 'Tidak ada data';
            tanggalMulai = data['data']['tanggal_mulai'];
            departemen = data['data']['departemen'] ?? 'Tidak ada data';
            jabatan = data['data']['jabatan'] ?? 'Tidak ada data';
            images = data['data']['images'] ?? 'Tidak ada data';
            isLoading = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.arrow_left,
            size: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: images.isNotEmpty &&
                            images != 'Tidak ada data'
                        ? NetworkImage(
                            images) 
                        : null, 
                    child: images.isEmpty || images == 'Tidak ada data'
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            size: 50,
                            color: Colors.white,
                          )
                        : null, 
                  ),
                  const SizedBox(height: 16),

                  // Nama Karyawan
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Jabatan Karyawan
                  Text(
                    jabatan,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informasi Profil
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.work, 'Departemen', departemen),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.phone, 'Telepon', telepon),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.calendar_today, 'Tanggal Masuk',
                              tanggalMulai),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget untuk menampilkan baris informasi
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
