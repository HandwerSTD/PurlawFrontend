import 'package:flutter/material.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/utilities/contract_generation_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../../components/purlaw/text_field.dart';
import '../../../viewmodels/theme_viewmodel.dart';

class ContractGenerationPage extends StatelessWidget {
  const ContractGenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(
        title: '合同生成',
        showBack: true
      ).build(context),
      body: const ContractGenerationPageBody(),
    );
  }
}

class ContractGenerationPageBody extends StatefulWidget {
  const ContractGenerationPageBody({super.key});

  @override
  State<ContractGenerationPageBody> createState() => _ContractGenerationPageBodyState();
}

class _ContractGenerationPageBodyState extends State<ContractGenerationPageBody> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<ContractGenerationViewModel>(
      model: ContractGenerationViewModel(context: context),
      onReady: (v){},
      builder: (context, model, child) => SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FastForm(
                formKey: formKey,
                onChanged: (val) {
                  model.title = val["field_title"].toString();
                  model.desc = val["field_desc"].toString();
                  model.aName = val["field_name_a"].toString();
                  model.bName = val["field_name_b"].toString();
                  model.type = val["field_type"].toString();
                },
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("请填写下列信息", style: TextStyle(fontSize: 16),),
                      ),
                    ],
                  ),
                  FastTextField(name: 'field_title', decoration: outlineBorderedInputDecoration('合同标题', 12, context, filled: true),),
                  const SizedBox(height: 12,),
                  FastTextField(name: 'field_type', decoration: outlineBorderedInputDecoration('合同类型', 12, context, filled: true),),
                  const SizedBox(height: 12,),
                  FastTextField(name: 'field_name_a', decoration: outlineBorderedInputDecoration('甲方名称', 12, context, filled: true),),
                  const SizedBox(height: 12,),
                  FastTextField(name: 'field_name_b', decoration: outlineBorderedInputDecoration('乙方名称', 12, context, filled: true),),
                  const SizedBox(height: 12,),
                  FastTextField(name: 'field_desc', decoration: outlineBorderedInputDecoration('描述', 12, context, filled: true),maxLines: 12, minLines: 6,),
                  const SizedBox(height: 24,),
                  TDButton(
                    size: TDButtonSize.large,
                    type: TDButtonType.fill,
                    isBlock: true,
                    disabled: model.genStart,
                    text: '提交',
                    onTap: (){
                      if (model.title.isEmpty || model.desc.isEmpty || model.aName.isEmpty || model.bName.isEmpty || model.type.isEmpty) {
                        TDToast.showText('请填写完整项', context: context);
                        return;
                      }
                      model.submit(getCookie(context, listen: false));
                    },
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(child: Container(
                    margin: const EdgeInsets.only( top: 24, bottom: 48),
                    child: (model.genComplete ? TextField(
                      decoration: PurlawChatTextField.chatInputDeco('', getThemeModel(context).colorModel.loginTextFieldColor, 24),
                      controller: model.controller,
                      maxLines: null,
                    ) : Text(model.text, style: const TextStyle(fontSize: 16),)),
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration outlineBorderedInputDecoration(String hint, double rad, BuildContext context,
      {bool dense = false, bool filled = false, fillColor}) =>
      InputDecoration(
        isDense: dense,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 12),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(rad))),
        filled: filled,
        fillColor: fillColor ??
            Provider.of<ThemeViewModel>(context)
                .themeModel
                .colorModel
                .loginTextFieldColor,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
      );
}
