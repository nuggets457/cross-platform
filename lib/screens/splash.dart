import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../utils/design_size.dart';
import '../widgets/logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AETHERION Logo
              SizedBox(
                width: DesignSize.w(context, 260),
                height: DesignSize.w(context, 260),
                child: AetherionLogo(
                  size: DesignSize.w(context, 260),
                ),
              ),
              SizedBox(height: DesignSize.h(context, 22)),
              Text(
                'AETHERION',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: DesignSize.h(context, 8)),
              Text(
                'Exploring the Heart of Mars',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              SizedBox(height: DesignSize.h(context, 34)),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: DesignSize.h(context, 34)),
              Text(
                'Curiosity data, gallery, and mission insights are loading.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
