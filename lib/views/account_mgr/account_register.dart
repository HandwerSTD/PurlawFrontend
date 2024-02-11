import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/viewmodels/account_mgr/account_register_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';

import '../../common/utils/misc.dart';
import '../../models/theme_model.dart';

class AccountRegisterPage extends StatelessWidget {
  const AccountRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '', showBack: true).build(context),
      body: const AccountRegisterPageBody(),
    );
  }
}

class AccountRegisterPageBody extends StatelessWidget {
  const AccountRegisterPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    TextTheme textTheme = Theme.of(context).textTheme;
    return ProviderWidget<AccountRegisterViewModel>(
      model: AccountRegisterViewModel(context: context),
      onReady: (model) {},
      builder: (context, model, child) =>
          LayoutBuilder(builder: (_, constraints) {
            bool rBreak = (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
            return Container(
              alignment: Alignment.center,
              // padding: EdgeInsets.only(top: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flex(
                    direction: (rBreak ? Axis.horizontal : Axis.vertical),
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          AppIconImage(
                            margin: EdgeInsets.only(bottom: (rBreak ? 12 : 32), right: (rBreak ? 64 : 0), left: (rBreak ? 64 : 0)),
                          ),
                          Text(
                            '注册',
                            style: textTheme.headlineMedium!.copyWith(
                                color: themeModel.colorModel.loginTextIndicatorColor),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          PurlawLoginTextField(
                            hint: '邮箱',
                            controller: model.mailCtrl,
                            margin:
                            const EdgeInsets.only(left: 32, right: 32, top: 24, bottom: 6),
                          ),
                          PurlawLoginTextField(
                            hint: '用户名',
                            controller: model.nameCtrl,
                            margin:
                            const EdgeInsets.only(left: 32, right: 32, top: 6, bottom: 6),
                          ),
                          PurlawLoginTextField(
                            hint: '密码',
                            controller: model.passwdCtrl,
                            margin:
                            const EdgeInsets.only(left: 32, right: 32, top: 6),
                            secureText: true,
                          ),
                          Text("密码需包含至少6个字符\n"),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(value: model.agreeStatement, onChanged: (val){ model.switchAgree(); },),
                              const Text("我已阅读并同意"),
                              InkWell(
                                child: const Text(
                                  "《用户协议》",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {},
                              ),
                              const Text('和'),
                              InkWell(
                                child: const Text(
                                  "《隐私协议》",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(width: 0, height: 16,),
                          PurlawRRectButton(
                            onClick: () {
                              model.register();
                            },
                            backgroundColor: themeModel.colorModel.generalFillColor,
                            width: 192,
                            height: 54,
                            radius: 12,
                            child: Text(
                              (model.registering ? "注册中" :'一键注册'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            width: 0,
                            height: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                  (rBreak ? Container() : const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('—— 请登录以获得紫藤法道个性化服务。——', style: TextStyle(color: Colors.grey, fontSize: 12),),
                  )),
                ],
              ),
            );
          }),
    );
  }
}
