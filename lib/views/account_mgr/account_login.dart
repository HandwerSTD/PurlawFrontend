import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/provider/provider_widget.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/image_loader.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/main.dart';
import 'package:purlaw/viewmodels/account_mgr/account_login_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_register.dart';
import '../../models/theme_model.dart';
import '../settings/settings_page.dart';

class AccountLoginPage extends StatelessWidget {
  final bool showBack;
  const AccountLoginPage({required this.showBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            }, icon: const Icon(Icons.settings))
          ],
        ),
        body: const AccountLoginPageBody(),
    );
  }
}

class AccountLoginPageBody extends StatefulWidget {
  const AccountLoginPageBody({super.key});

  @override
  State<AccountLoginPageBody> createState() => _AccountLoginPageBodyState();
}

class _AccountLoginPageBodyState extends State<AccountLoginPageBody> {
  late StreamSubscription<AccountLoginEventBus> _;

  @override
  void initState() {
    super.initState();
      _  = eventBus.on<AccountLoginEventBus>().listen((event) {
      if (event.needNavigate) {
        showToast("登陆成功", toastType: ToastType.success);
        Navigator.pop(context);
      }
    });
     _.resume();
  }

  @override
  void dispose() {
    _.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    TextTheme textTheme = Theme.of(context).textTheme;
    return ProviderWidget<AccountLoginViewModel>(
      model: AccountLoginViewModel(context: context),
      onReady: (model) {},
      builder: (context, model, child) =>
          LayoutBuilder(builder: (_, constraints) {
            bool rBreak = (Responsive.checkWidth(constraints.maxWidth) == Responsive.lg);
        return Container(
          alignment: Alignment.center,
          height: constraints.maxHeight,
          // padding: EdgeInsets.only(top: 48),
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                        margin: EdgeInsets.only(top: 0,bottom: (rBreak ? 12 : 64), right: (rBreak ? 64 : 0), left: (rBreak ? 64 : 0)),
                      ),
                      Text(
                        '登录',
                        style: textTheme.headlineMedium!.copyWith(
                            color: themeModel.colorModel.loginTextIndicatorColor),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      PurlawLoginTextField(
                        focusNode: model.nameFocus,
                        hint: '用户名',
                        controller: model.nameCtrl,
                        margin:
                            const EdgeInsets.only(left: 32, right: 32, top: 24, bottom: 6),
                        onSubmitted: (val){
                          model.nameFocus.unfocus();
                          model.passwdFocus.requestFocus();
                        },
                      ),
                      PurlawLoginTextField(
                        focusNode: model.passwdFocus,
                        hint: '密码',
                        controller: model.passwdCtrl,
                        margin:
                            const EdgeInsets.only(left: 32, right: 32, top: 6, bottom: 32),
                        secureText: true,
                        onSubmitted: (val) {
                          if (model.loggingIn) return;
                          model.login();
                        },
                      ),
                      PurlawRRectButton(
                        onClick: () async {
                          if (model.loggingIn) return;
                          model.login();
                        },
                        backgroundColor: themeModel.colorModel.generalFillColor,
                        width: 192,
                        height: 54,
                        radius: 12,
                        child:  Text(
                          (model.loggingIn ? '登陆中' : '一键登录'),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("还没有账号？"),
                          InkWell(
                            child: const Text(
                              "注册",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountRegisterPage()));
                            },
                          )
                        ],
                      ),
                    ],
                  )
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
