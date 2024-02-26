import 'package:flutter/material.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/utilities/contract_generation/contract_generation_page.dart';
import 'package:purlaw/views/utilities/document_scan/ai_document_recognition.dart';


class UtilitiesIndexPage extends StatelessWidget {
  const UtilitiesIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    Color getColor = getThemeModel(context).themeData.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilityGridBlock(title: '文档识别', iconAsset: Icon(
                Icons.document_scanner, size: 64, color: getColor,
              ), onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AIDocumentRecognition()));
              }),
              UtilityGridBlock(title: '律师推荐', iconAsset:  Icon(
                Icons.folder_shared_outlined, size: 64,color: getColor,
              ), onTap: (){}),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilityGridBlock(title: '合同生成', iconAsset: Icon(
                Icons.gas_meter , size: 64,color: getColor,
              ), onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractGenerationPage()));
              }),
              UtilityGridBlock(title: '类似案例', iconAsset:  Icon(
                Icons.mark_email_read_rounded, size: 64,color: getColor,
              ), onTap: (){})
            ],
          )
        ],
      )
    );
  }
}

class UtilityGridBlock extends StatelessWidget {
  final String title;
  final Widget iconAsset;
  final void Function() onTap;
  const UtilityGridBlock({super.key, required this.title, required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 144,
        width: 144,
        // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: getThemeModel(context).themeColor.withOpacity(0.8), width: 2)
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconAsset,
            const SizedBox(height: 12,),
            Text(title, style: const TextStyle(fontSize: 20),)
          ],
        ),
      ),
    );
  }
}

