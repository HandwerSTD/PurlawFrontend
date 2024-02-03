import 'package:flutter/material.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';

/// Out of Box Experience
class OOBE extends StatelessWidget {
  const OOBE({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ElevatedButton(child: const Text("oobe"), onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AccountLoginPage(showBack: false)));
      },),),
    );
  }
}
