import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grock/grock.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_login.dart';

import '../../components/purlaw/button.dart';

/// Out of Box Experience
class OOBE extends StatefulWidget {
  const OOBE({super.key});

  @override
  State<OOBE> createState() => _OOBEState();
}

class _OOBEState extends State<OOBE> {
  int nowIndex = 0;
  PageController controller = PageController();
  List<Widget> pages = [
    OOBEPageBody(
      hintText: '欢迎使用紫藤法道\n',
      assetImage: 'assets/rounded_app_icon.png',
      height: 100,
      width: 100,
    ),
    OOBEPageBody(
      hintText: '与你的AI律师交流(要改',
      assetImage: 'assets/oobe/oobe1.png',
      width: 280,
    ),
    OOBEPageBody(hintText: '开始使用紫藤法道\n', assetImage: 'assets/rounded_app_icon.png',
      height: 100,
      width: 100, additionalWidget: Container(
        margin: EdgeInsets.only(top: 24),
        child: PurlawRRectButton(
          onClick: () async {
          },
          backgroundColor: ThemeModel.presetModelsLight[0].generalFillColor,
          width: 192,
          height: 54,
          radius: 12,
          child:  Text(
            ('开始使用'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),)
  ];

  @override
  Widget build(BuildContext context) {
    print(Grock.height);
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: Grock.height > 800 ? 800 : Grock.height - 30,
          child: ExpandablePageView(
            controller: controller,
            alignment: Alignment.center,
            children: pages,
            onPageChanged: (index) {
              setState(() {
                nowIndex = index;
              });
            },
          ),
        ),
        PageViewDotIndicator(
            currentItem: nowIndex,
            count: pages.length,
            unselectedColor: Colors.grey,
            unselectedSize: Size(6, 6),
            size: Size(10, 10),
            selectedColor: getThemeModel(context).themeColor)
      ],
    ));
  }
}

class OOBEPageBody extends StatelessWidget {
  final String hintText;
  final String assetImage;
  final double? height;
  final double? width;
  final Widget? additionalWidget;
  const OOBEPageBody(
      {super.key,
      required this.hintText,
      required this.assetImage,
      this.height,
      this.width, this.additionalWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hintText,
            style: TextStyle(fontSize: 24),
          ),
          Image.asset(
            assetImage,
            height: height,
            width: width,
          ),
          additionalWidget ?? Container(),
        ],
      ),
    );
  }
}
