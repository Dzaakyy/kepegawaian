import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final int idKaryawan;
  const EditProfile({
    super.key,
    required this.profileData,
    required this.idKaryawan,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _idController = TextEditingController();
  final _teleponController = TextEditingController();
  final _imagesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.text = widget.idKaryawan.toString();
    _teleponController.text = widget.profileData['telepon'].toString();
    _imagesController.text = widget.profileData['images'].toString();
  }

  Future<void> _submitForm() async {
    const url = 'http://10.0.3.2/kepegawaian_dzaky/edit_profile.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id_pegawai': _idController.text,
          'telepon': _teleponController.text,
          'images': _imagesController.text,
        },
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['Success'] == true) {
        if (kDebugMode) {
          print("Profil berhasil diperbarui");
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        if (kDebugMode) {
          print("Gagal memperbarui profil");
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil')),
        );
      }
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $exc')),
      );
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
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.profileData['images'] != null &&
                        widget.profileData['images'].isNotEmpty
                    ? NetworkImage(widget.profileData['images'])
                    : null,
                child: widget.profileData['images'] == null ||
                        widget.profileData['images'].isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imagesController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar Profil',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL gambar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
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
      ),
    );
  }
}
