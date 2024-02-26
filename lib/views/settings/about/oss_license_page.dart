import 'package:flutter/material.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/oss_licenses.dart';

class OSSLicensePage extends StatelessWidget {
  const OSSLicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
        title: '开放源代码许可',
        showBack: true
      ).build(context),
      body: ListView.builder(
        itemCount: ossLicenses.length,
        itemBuilder: (context, index) {
          var license = ossLicenses[index];
          return ListTile(
            title: Text(license.name),
            subtitle: Text(license.description, maxLines: 2,),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => OSSLicenseSingleDetailPage(package: license)));
            },
          );
        },
      ),
    );
  }
}

class OSSLicenseSingleDetailPage extends StatelessWidget {
  final Package package;
  const OSSLicenseSingleDetailPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: package.name, showBack: true).build(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("${package.name} ${package.version}"),
              Text(package.description),
              Text(package.license ?? "")
            ],
          ),
        ),
      ),
    );
  }
}

