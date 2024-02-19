import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/views/utilities/contract_generation/contract_generation_page.dart';

import '../../viewmodels/theme_viewmodel.dart';

class UtilitiesIndexPage extends StatelessWidget {
  const UtilitiesIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56),
      decoration: const BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [Colors.white, Colors.blue[100]!, Colors.blue[100]!, Colors.white],
        //   begin: Alignment(0, -1),
        //   end: Alignment(0, 0.5)
        // )
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilityGridBlock(title: '合同审查', iconAsset: const Icon(
                Icons.document_scanner, size: 64, color: Colors.indigo,
              ), onTap: (){}),
              UtilityGridBlock(title: '律师推荐', iconAsset: const Icon(
                Icons.folder_shared_outlined, size: 64,color: Colors.indigo,
              ), onTap: (){}),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UtilityGridBlock(title: '合同生成', iconAsset: const Icon(
                Icons.gas_meter , size: 64,color: Colors.indigo,
              ), onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ContractGenerationPage()));
              }),
              UtilityGridBlock(title: '类似案例', iconAsset: const Icon(
                Icons.mark_email_read_rounded, size: 64,color: Colors.indigo,
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
          border: Border.all(color: Colors.indigo[400]!, width: 2)
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

