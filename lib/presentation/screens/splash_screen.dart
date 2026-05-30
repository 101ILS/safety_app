import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
 State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          LoginScreen.routeName,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              padding:
                  const EdgeInsets.all(
                22,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: const Icon(
                Icons.health_and_safety,
                size: 90,
                color: Color(
                  0xFF1565C0,
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            const Text(
              'Safety AI',

              style: TextStyle(
                fontSize: 34,
                color: Colors.white,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Интеллектуальная система\nконтроля допуска сотрудников',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.white70,

                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 36,
            ),

            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}