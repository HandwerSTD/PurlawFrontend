import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/cache_utils.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/views/account_mgr/account_management.dart';
import 'package:purlaw/views/account_mgr/my_account_avatar.dart';
import 'package:purlaw/views/settings/about/about_page.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '设置', showBack: true).build(context),
      body: const SettingsPageBody(),
    );
  }
}

class SettingsPageBody extends StatefulWidget {
  const SettingsPageBody({super.key});

  @override
  State<SettingsPageBody> createState() => _SettingsPageBodyState();
}

class _SettingsPageBodyState extends State<SettingsPageBody> {
  TextEditingController serverAddressController =
      TextEditingController(text: HttpGet.baseUrl);

  bool autoPlayAudio = false;
  bool aiChatFloatingButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    autoPlayAudio = (KVBox.query(DatabaseConst.autoAudioPlay) == DatabaseConst.dbTrue);
    aiChatFloatingButtonEnabled = DatabaseUtil.getAIChatFloatingButtonEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          Visibility(
            visible: getCookie(context).isNotEmpty,
            child: MySettingsGroup(
              settingsGroupTitle: '  帐户设置',
              items: [
                MySettingsItem(
                  icons: Icons.account_circle,
                  title: '头像',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyAccountAvatar()));
                  },
                ).build(context),
                const MySettingsItem(icons: TypIconData(0xE036), title: '昵称')
                    .build(context),
                MySettingsItem(icons: Icons.manage_accounts, title: '帐户管理', onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyAccountManagement(desc: getMainViewModel(context, listen: false).myUserInfoModel.desc)));
                })
                    .build(context),
                MySettingsItem(
                  icons: Icons.logout,
                  title: '注销帐户并退出程序',
                  subtitle: '将会清空本地对话记录与收藏夹',
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return setLogoutConfirm();
                        });
                  },
                ).build(context)
              ],
            ),
          ),
          MySettingsGroup(
            settingsGroupTitle: '  通用设置',
            items: [
              MySettingsItem(
                  icons: Icons.draw_rounded, title: '主题切换', onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsChangeThemePage(current: getThemeModel(context).index)));
              })
                  .build(context),
              SettingsItem(
                  icons: Icons.dark_mode,
                  title: '深色模式',
                  trailing: TDSwitch(
                    enable: true,
                    trackOnColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    isOn:
                        Provider.of<ThemeViewModel>(context).themeModel.dark,
                    onChanged: (bool value) {
                      Provider.of<ThemeViewModel>(context, listen: false)
                          .switchDarkMode();
                    },
                  ),
                  iconStyle: IconStyle(
                    iconsColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    backgroundColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColorBright,
                  ),
                  titleStyle: const TextStyle(fontSize: 16)),
              SettingsItem(
                  icons: Icons.multitrack_audio_rounded,
                  title: '自动语音播报',
                  subtitle: '开启后所有回答将会自动进行语音播报',
                  trailing: TDSwitch(
                    enable: true,
                    trackOnColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    isOn: autoPlayAudio,
                    onChanged: (bool value) {
                      KVBox.insert(DatabaseConst.autoAudioPlay, (autoPlayAudio ? DatabaseConst.dbFalse : DatabaseConst.dbTrue));
                    },
                  ),
                  iconStyle: IconStyle(
                    iconsColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    backgroundColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColorBright,
                  ),
                  titleStyle: const TextStyle(fontSize: 16)),
              SettingsItem(
                  icons: Icons.question_answer_rounded,
                  title: '开启AI对话悬浮窗',
                  subtitle: '开启后可以在部分界面快速调出AI对话窗口进行询问',
                  trailing: TDSwitch(
                    enable: true,
                    trackOnColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    isOn: aiChatFloatingButtonEnabled,
                    onChanged: (bool value) {
                      getMainViewModel(context, listen: false).setChatFloatingButtonEnabled(value);
                      setState(() {
                        aiChatFloatingButtonEnabled = value;
                      });
                    },
                  ),
                  iconStyle: IconStyle(
                    iconsColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    backgroundColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColorBright,
                  ),
                  titleStyle: const TextStyle(fontSize: 16)),
              MySettingsItem(
                  icons: Icons.auto_delete_rounded, title: '清除缓存', onTap: (){
                    CacheUtil.clear();
                    showToast('清除成功', toastType: ToastType.success);
              })
                  .build(context),
            ],
          ),
          MySettingsGroup(
            settingsGroupTitle: '  开发者设置',
            items: [
              MySettingsItem(
                icons: Icons.security_rounded,
                title: '设置服务器地址',
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return setServerAddress();
                      });
                },
              ).build(context),
              if (getCookie(context).isNotEmpty) SettingsItem(
                  icons: Icons.verified_rounded,
                  title: '临时设置本账号为认证账号',
                  subtitle: '本地临时生效，重启应用失效',
                  trailing: TDSwitch(
                    enable: true,
                    trackOnColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    isOn: getMainViewModel(context, listen: false).myUserInfoModel.verified,
                    onChanged: (bool value) {
                      getMainViewModel(context, listen: false).debugSetVerified();
                    },
                  ),
                  iconStyle: IconStyle(
                    iconsColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColor,
                    backgroundColor: Provider.of<ThemeViewModel>(context)
                        .themeModel
                        .colorModel
                        .generalFillColorBright,
                  ),
                  titleStyle: const TextStyle(fontSize: 16)),
              MySettingsItem(icons: Icons.build_circle_outlined, title: '调试信息', onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoggerPage()));
              })
                  .build(context)
            ],
          ),
          MySettingsGroup(
            settingsGroupTitle: '  应用信息',
            items: [
              const MySettingsItem(
                      icons: Icons.contact_support_rounded, title: '联系我们')
                  .build(context),
              MySettingsItem(
                icons: Icons.grid_view_rounded,
                title: '关于紫藤法道',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutPage()));
                },
              ).build(context)
            ],
          )
        ],
      ),
    );
  }

  setServerAddress() {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serverAddressController,
              decoration: const InputDecoration(hintText: "服务器地址"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("取消")),
                TextButton(
                    onPressed: () {
                      DatabaseUtil.storeServerAddress(
                          serverAddressController.text);
                      HttpGet.switchBaseUrl(serverAddressController.text);
                      Navigator.pop(context);
                    },
                    child: const Text("确定"))
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("注销账户会清空本地对话历史记录与收藏夹，是否继续？"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("取消")),
                TextButton(
                    onPressed: () {
                      Provider.of<MainViewModel>(context, listen: false)
                          .logout();
                    },
                    child: const Text("确定"))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MySettingsGroup extends StatelessWidget {
  final List<SettingsItem> items;
  final String? settingsGroupTitle;
  const MySettingsGroup(
      {super.key, required this.items, this.settingsGroupTitle});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      items: items,
      settingsGroupTitle: settingsGroupTitle,
      settingsGroupTitleStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      iconItemSize: 22,
    );
  }
}

class MySettingsItem {
  final IconData icons;
  final String title;
  final String? subtitle;
  final Function()? onTap;
  const MySettingsItem(
      {required this.icons, required this.title, this.subtitle, this.onTap});

  SettingsItem build(BuildContext context) {
    return settingsItem(context);
  }

  SettingsItem settingsItem(context) {
    return SettingsItem(
      icons: icons,
      title: title,
      subtitle: subtitle,
      iconStyle: IconStyle(
        iconsColor: Provider.of<ThemeViewModel>(context)
          .themeModel
          .colorModel
          .generalFillColor,
        backgroundColor: Provider.of<ThemeViewModel>(context)
            .themeModel
            .colorModel
            .generalFillColorBright,
      ),
      titleStyle: const TextStyle(fontSize: 16),
      onTap: onTap,
    );
  }
}

class SettingsChangeThemePage extends StatefulWidget {
  final int current;
  const SettingsChangeThemePage({super.key, required this.current});

  @override
  State<SettingsChangeThemePage> createState() => _SettingsChangeThemePageState();
}

class _SettingsChangeThemePageState extends State<SettingsChangeThemePage> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    value = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '主题更换', showBack: true).build(context),
      body: MySettingsGroup(
        items: List.generate(ThemeModel.presetThemes.length, (index) {
          return SettingsItem(
            icons: Icons.circle,
            title: ThemeModel.presetNames[index],
            iconStyle: IconStyle(
                withBackground: true,
                backgroundColor: Colors.transparent,
                iconsColor: ThemeModel.presetThemes[index]),
            onTap: (){
              setState(() {
                value = index;
              });
              Provider.of<ThemeViewModel>(context, listen: false).setThemeColor(index);
            },
            trailing: Radio<int>(value: index, groupValue: value, onChanged: (_) {
              setState(() {
                value = index;
              });
              Provider.of<ThemeViewModel>(context, listen: false).setThemeColor(index);
            },),
          );
        }),
      ),
    );
  }
}
