import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class PurlawWaterfallList extends StatelessWidget {
  final List<Widget> list;
  final ScrollController controller;
  final bool useTopPadding;
  const PurlawWaterfallList({required this.list, required this.controller, this.useTopPadding = true, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:(_, constraints) {
        bool nsmBreak = (Responsive.checkWidth(constraints.maxWidth) != Responsive.sm);
        bool lgBreak = (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
        return Container(
          padding: const EdgeInsets.only(left: 2, right: 2),
          width: Responsive.assignWidthMedium(constraints.maxWidth),
          child: WaterfallFlow.count(
            padding: (useTopPadding ? EdgeInsets.only(top: (lgBreak ? 84 : 64)) : null),
            crossAxisCount: (nsmBreak ? 4 : 2),
            controller: controller,
            children: list,
          ),
        );
      }
    );
  }
}

