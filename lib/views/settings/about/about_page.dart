import 'package:flutter/material.dart';
import 'package:purlaw/components/third_party/image_loader.dart';

import '../../../common/constants/eula.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于应用"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              children: [
                AppIconImage(margin: EdgeInsets.only(top: 96, bottom: 24),),
                Text("紫藤法道", style: TextStyle(fontSize: 20),),
                Text("版本 Beta v1.0"),
              ],
            ),
            Padding(padding: EdgeInsets.all(24), child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("我们的"),
                    InkWell(
                      child: Text("用户协议", style: TextStyle(color: Colors.blueAccent),),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EULAPage()));
                      },
                    ),
                    Text("与"),
                    InkWell(
                      child: Text("开放源代码许可", style: TextStyle(color: Colors.blueAccent),),
                      onTap: () {
                        // launchUrl(Uri.parse(privacyStatementAddress), mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                )
              ],
            ),)
          ],
        ),
      ),
    );
  }
}

class EULAPage extends StatelessWidget {
  const EULAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("用户协议"),),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: const [
            Row(
              children: [Expanded(
                child: Text(EULA),
              )],
            )
          ],
        ),
      ),
    );
  }
}