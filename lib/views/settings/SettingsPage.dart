import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/account_mgr/my_account_avatar.dart';
import 'package:purlaw/views/settings/about/about_page.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '设置', showBack: true).build(context),
      body: SettingsPageBody(),
    );
  }
}

class SettingsPageBody extends StatefulWidget {
  const SettingsPageBody({super.key});

  @override
  State<SettingsPageBody> createState() => _SettingsPageBodyState();
}

class _SettingsPageBodyState extends State<SettingsPageBody> {
  TextEditingController serverAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Visibility(
            visible: getCookie(context).isNotEmpty,
            child: SettingsGroup(
              settingsGroupTitle: '  帐户设置',
              items: [
                SettingsItem(icons: Icons.account_circle, title: '头像', onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyAccountAvatar()));
                },),
                SettingsItem(icons: const TypIconData(0xE036), title: '昵称'),
                SettingsItem(icons: Icons.manage_accounts, title: '账户管理'),
                SettingsItem(icons: Icons.logout, title: '注销账户并退出程序', onTap: (){
                  showDialog(context: context, builder: (context) {
                    return setLogoutConfirm();
                  });
                },)
              ],
            ),
          ),
          SettingsGroup(
            settingsGroupTitle: '  开发者设置',
            items: [
              SettingsItem(icons: Icons.security_rounded, title: '设置服务器地址', onTap: () {
                showDialog(context: context, builder: (context) {
                  return setServerAddress();
                });
              },),
              SettingsItem(icons: Icons.build_circle_outlined, title: '调试信息')
            ],
          ),
          SettingsGroup(
            settingsGroupTitle: '  应用信息',
            items: [
              SettingsItem(icons: Icons.contact_support_rounded, title: '联系我们'),
              SettingsItem(icons: Icons.grid_view_rounded, title: '关于紫藤法道', onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
              },)
            ],
          )
        ],
      ),
    );
  }

  setServerAddress() {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serverAddressController,
              decoration: InputDecoration(hintText: "服务器地址"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消")),
                TextButton(
                    onPressed: () {
                      DatabaseUtil.storeServerAddress(serverAddressController.text);
                      HttpGet.switchBaseUrl(serverAddressController.text);
                      Navigator.pop(context);
                    },
                    child: Text("确定"))
              ],
            )
          ],
        ),
      ),
    );
  }
  setLogoutConfirm() {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("注销账户会清空本地对话历史记录，是否继续？"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消")),
                TextButton(
                    onPressed: () {
                      Provider.of<MainViewModel>(context, listen: false).logout();
                    },
                    child: Text("确定"))
              ],
            )
          ],
        ),
      ),
    );
  }
}

