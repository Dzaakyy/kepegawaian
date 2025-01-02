import 'package:flutter/material.dart';
import 'package:kepegawaian/homepage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;
  List<Widget> widgetList = const [
    // Text('Home', style: TextStyle(fontSize: 40)),
    HomePage(),
    Text('News', style: TextStyle(fontSize: 40)),
    Text('Account', style: TextStyle(fontSize: 40)),
    // AccountPage(),

  ];

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
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ]),
    );
  }
}
