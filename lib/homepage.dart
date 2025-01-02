import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kepegawaian/accountpage.dart';
import 'package:kepegawaian/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String namaUser = '';
  String jabatanUser = '';
  int idKaryawan = 0; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUser = prefs.getString('namaUser') ?? '';
      jabatanUser = prefs.getString('jabatanUser') ?? '';
      idKaryawan = prefs.getInt('idKaryawan') ?? 0; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountPage(idKaryawan: idKaryawan)
              ),
            );
          },
          icon: const Icon(
            CupertinoIcons.person_alt,
            size: 22,
            color: Colors.black,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              namaUser,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              jabatanUser,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                CupertinoIcons.bell_fill,
                size: 22,
                color: Colors.black,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Flexible(
                            child: Card(
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen()));
                                },
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        './lib/assets/employee.jpg',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Absensi',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Card(
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen()));
                                },
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        './lib/assets/employee.jpg',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Absensi',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Flexible(
                            child: Card(
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen()));
                                },
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        './lib/assets/employee.jpg',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Absensi',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Card(
                              elevation: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen()));
                                },
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        './lib/assets/employee.jpg',
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Absensi',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
