import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/themes/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/ui/screens/assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 5),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                ),
                children: [
                  TextSpan(
                    text: 'CAFE',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                  ),
                  TextSpan(
                    text: 'CONECTA',
                    style: TextStyle(color: Color.fromARGB(255, 24, 241, 31)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
