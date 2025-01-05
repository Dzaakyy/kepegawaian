import 'package:flutter/material.dart';
import 'package:kepegawaian/absenmasuk.dart';
import 'package:kepegawaian/absenpulang.dart';
import 'package:kepegawaian/homepage.dart';

class HomeScreen extends StatefulWidget {
  final int idKaryawan;
  const HomeScreen({super.key, required this.idKaryawan});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 1; 
  late List<Widget> widgetList;

  @override
  void initState() {
    super.initState();
    widgetList = [
      AbsenMasuk(idKaryawan: widget.idKaryawan),
      HomePage(idKaryawan: widget.idKaryawan),  
      AbsenPulang(idKaryawan: widget.idKaryawan) 
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
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Absen Masuk'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Absen Pulang'),
        ],
      ),
    );
  }
}