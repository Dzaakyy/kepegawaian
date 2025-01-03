import 'package:flutter/material.dart';
import 'package:kepegawaian/absenpage.dart';
import 'package:kepegawaian/cutipage.dart';
import 'package:kepegawaian/homepage.dart';

class HomeScreen extends StatefulWidget {
  final int idKaryawan;

  const HomeScreen({super.key, required this.idKaryawan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;
  late List<Widget> widgetList;

  @override
  void initState() {
    super.initState();
    widgetList = [
      HomePage(idKaryawan: widget.idKaryawan),
      AbsenPage(idKaryawan: widget.idKaryawan),
      const CutiPage(), // Kirim idKaryawan ke CutiPage
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetList[myIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Absen'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Cuti'),
        ],
      ),
    );
  }
}