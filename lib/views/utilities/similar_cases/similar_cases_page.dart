import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grock/grock.dart';
import 'package:purlaw/common/network/chat_api.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/components/purlaw/search_bar.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/viewmodels/utilities/similar_cases_viewmodel.dart';

import '../../../common/utils/database/database_util.dart';
import '../../../components/purlaw/chat_message_block.dart';

class SimilarCasesPage extends StatelessWidget {
  const SimilarCasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (val){
        ChatNetworkRequest.breakIsolate(getCookie(context, listen: false), DatabaseUtil.getLastAIChatSession());
      },
      child: Scaffold(
        appBar: PurlawAppTitleBar(showBack: true, title: '类案推荐').build(context),
        body: const SimilarCasesPageBody(),
      ),
    );
  }
}

class SimilarCasesPageBody extends StatelessWidget {
  const SimilarCasesPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<SimilarCasesViewModel>(
        model: SimilarCasesViewModel(),
        onReady: (_) {},
        builder: (context, model, child) {
          return Container(
              width: Responsive.assignWidthMedium(Grock.width),
              padding: 12.paddingHorizontal,
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: SearchAppBar(
                    hintLabel: '搜索',
                    onSubmitted: (val) {
                      if (val.isEmpty) return;
                      model.description = val;
                      model.submit(getCookie(context, listen: false));
                    }, onTap: (){},
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: getThemeModel(context)
                                .colorModel
                                .generalFillColorLight),
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(top: 36, bottom: 24),
                    padding: 16.paddingOnlyLeft,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownSearch<String>(
                            onChanged: (val) {
                              model.selectedRegion = val!;
                            },
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        border: InputBorder.none)),
                            popupProps: const PopupProps.modalBottomSheet(
                              title: Text(
                                "\n选择地区",
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              fit: FlexFit.loose,
                              showSelectedItems: true,
                            ),
                            items: const [
                              "全国",
                              "北京",
                              "天津",
                              "山东",
                              "上海",
                              "广东",
                              "江苏",
                              "湖南",
                              "湖北",
                              "四川"
                            ],
                            selectedItem: model.selectedRegion,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: DropdownSearch<String>(
                            onChanged: (val) {
                              model.selectedLevel = val!;
                            },
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        border: InputBorder.none)),
                            popupProps: const PopupProps.modalBottomSheet(
                              title: Text(
                                "\n选择参照级别",
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              fit: FlexFit.loose,
                              showSelectedItems: true,
                            ),
                            items: const [
                              "全部案例",
                              "最高人民法院",
                              "高级人民法院",
                              "中级人民法院",
                              "基层人民法院"
                            ],
                            selectedItem: model.selectedLevel,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: DropdownSearch<String>(
                            onChanged: (val) {
                              model.selectedSort = val!;
                            },
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        border: InputBorder.none)),
                            popupProps: const PopupProps.modalBottomSheet(
                              title: Text(
                                "\n排序方式",
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              fit: FlexFit.loose,
                              showSelectedItems: true,
                            ),
                            items: const ["综合排序", "最新排序"],
                            selectedItem: model.selectedSort,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SliverList.builder(
                //   itemCount: model.cases.length,
                //   itemBuilder: (context, index){
                //     final nowCase = model.cases[index];
                //     return Container(
                //       margin: 24.paddingOnlyBottom,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(24),
                //         boxShadow: TDThemeData.defaultData().shadowsTop
                //       ),
                //       child: Card(
                //         elevation: 0,
                //         child: Container(
                //           height: 200,
                //           child: Column(
                //             children: [
                //               Text(nowCase)
                //             ],
                //           ),
                //         ),
                //       ),
                //     );
                //   },
                // )
                SliverToBoxAdapter(
                  child: (model.genStart || model.genComplete ? Row(
                    children: [
                      Expanded(
                        child: Container(
                            child: (PurlawChatMessageBlockWithAudio(
                                    msg: model.message,
                                    overrideRadius: true,
                              alwaysMarkdown: true,
                                  )
                                )),
                      )
                    ],
                  ) : Container()),
                )
              ]));
        });
  }
}
