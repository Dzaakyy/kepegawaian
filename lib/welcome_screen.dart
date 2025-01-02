import 'package:flutter/material.dart';
import 'package:kepegawaian/signin_screen.dart';
import 'package:kepegawaian/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen(
      {super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            './lib/assets/bg5.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                Flexible(
                    flex: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 40.0,
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Welcome Back!\n',
                                  style: TextStyle(
                                    fontSize: 45.0,
                                    fontWeight: FontWeight.w600,
                                  )),
                              TextSpan(
                                  text:
                                      '\nEnter personal details to your employee account',
                                  style: TextStyle(
                                    fontSize: 20,
                                    // height: 0,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    )),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(30.0),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                 MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(30.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                ),
                              ),
                              child:const Text(
                                'Sign Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
