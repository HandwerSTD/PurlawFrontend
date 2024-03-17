import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:grock/grock.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';

import '../../components/purlaw/button.dart';

/// Out of Box Experience
class OutOfBoxExperience extends StatefulWidget {
  const OutOfBoxExperience({super.key});

  @override
  State<OutOfBoxExperience> createState() => _OutOfBoxExperienceState();
}

class _OutOfBoxExperienceState extends State<OutOfBoxExperience> {
  int nowIndex = 0;
  PageController controller = PageController();
  List<Widget> pages = [
    const OOBEPageBody(
      hintText: '欢迎使用紫藤法道\n',
      assetImage: 'assets/rounded_app_icon.png',
      height: 100,
      width: 100,
    ),
    const OOBEPageBody(
      hintText: '与你的 AI 律师交流',
      assetImage: 'assets/oobe/oobe1.png',
      width: 280,
    ),
    const OOBEPageBody(
      hintText: '在社区学习知识、分享经验',
      assetImage: 'assets/oobe/oobe3.png',
      width: 280,
    ),
    const OOBEPageBody(
      hintText: '多种实用工具任你选择',
      assetImage: 'assets/oobe/oobe2.png',
      width: 280,
    ),
    const OOBEPageBody(
      hintText: '创建多个AI律师分身',
      assetImage: 'assets/oobe/oobe4.png',
      width: 280,
    ),
    const OOBEPageBody(
      hintText: '使用语音进行快捷对话',
      assetImage: 'assets/oobe/oobe5.png',
      width: 280,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print(Grock.height);
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: Grock.height > 800 ? 800 : Grock.height - 30,
          child: ExpandablePageView(
            controller: controller,
            alignment: Alignment.center,
            children: List.generate(pages.length, (index) => pages[index])
              ..add(OOBEPageBody(
                hintText: '开始使用紫藤法道\n',
                assetImage: 'assets/rounded_app_icon.png',
                height: 100,
                width: 100,
                additionalWidget: Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: PurlawRRectButton(
                    onClick: () async {
                      Navigator.pop(context);
                    },
                    backgroundColor:
                        ThemeModel.presetModelsLight[0].generalFillColor,
                    width: 192,
                    height: 54,
                    radius: 12,
                    child: const Text(
                      ('开始使用'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
            onPageChanged: (index) {
              setState(() {
                nowIndex = index;
              });
            },
          ),
        ),
        PageViewDotIndicator(
            currentItem: nowIndex,
            count: pages.length + 1,
            unselectedColor: Colors.grey,
            unselectedSize: const Size(6, 6),
            size: const Size(10, 10),
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
      this.width,
      this.additionalWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hintText,
            style: const TextStyle(fontSize: 24),
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
