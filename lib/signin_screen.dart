import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kepegawaian/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

    class SignInScreen extends StatefulWidget {
      const SignInScreen({super.key});

      @override
      State<SignInScreen> createState() => _SignInScreenState();
    }

    class _SignInScreenState extends State<SignInScreen> {
      final TextEditingController _usernameController = TextEditingController();
      final TextEditingController _passwordController = TextEditingController();

      Future<void> login() async {
        String urlLogin = "http://10.0.2.2/kepegawaian_dzaky/login.php";
        try {
          var response = await http.post(Uri.parse(urlLogin), body: {
            "username": _usernameController.text,
            "password": _passwordController.text,
          });
          if (kDebugMode) {
            print("Response: ${response.body}");
          }
          var dataLogin = jsonDecode(response.body);
          if (dataLogin['status'] == 'success') {
            if (kDebugMode) {
              print("Login Berhasil");
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('namaUser', dataLogin['data']['nama']);
            prefs.setString('jabatanUser', dataLogin['data']['jabatan']);
            prefs.setInt('idKaryawan', dataLogin['data']['id_pegawai']);

          // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Login Berhasil!"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          
          // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    idKaryawan: dataLogin['data']['id_pegawai'], 
                  ),
                ),
              );
          
          } else {
            if (kDebugMode) {
              print("Login gagal: ${dataLogin['message']}");
            }
             // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Login Gagal: ${dataLogin['message']}"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            
          }
        } catch (exc) {
          if (kDebugMode) {
            print(exc);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Terjadi kesalahan. Coba lagi nanti."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Image.asset(
                './lib/assets/signin.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              SafeArea(
                child: Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blue.shade300,
                                  ),
                                ),
                                const SizedBox(
                                  height: 40.0,
                                ),
                                TextFormField(
                                  controller: _usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Username';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    label: const Text('Username'),
                                    hintText: 'Enter Username',
                                    hintStyle: const TextStyle(
                                      color: Colors.black26,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 25.0,
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    label: const Text('Password'),
                                    hintText: 'Enter Password',
                                    hintStyle: const TextStyle(
                                      color: Colors.black26,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 25.0,
                                ),
                                const SizedBox(
                                  height: 25.0,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_usernameController.text.isEmpty ||
                                          _passwordController.text.isEmpty) {
                                        if (kDebugMode) {
                                          print(
                                              "Username dan password tidak boleh kosong");
                                        }
                                        return;
                                      }
                                      login();
                                    },
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }