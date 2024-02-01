import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/components/purlaw/appbar.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/views/account_mgr/my_account_detail.dart';

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
  TextEditingController changeServerAddressController = TextEditingController(text: HttpGet.baseUrl);
  @override
  Widget build(BuildContext context) {
    bool logged = DatabaseUtil.getCookie().isNotEmpty;
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: changeServerAddressController,
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
                                        DatabaseUtil.storeServerAddress(changeServerAddressController.text);
                                        HttpGet.switchBaseUrl(changeServerAddressController.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text("确定"))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Text("设置服务器地址")),
          Visibility(
            visible: logged,
            child: Column(
              children: [
                ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetails()));}, child: Text("编辑账户信息")),
                ElevatedButton(onPressed: (){
                  Provider.of<MainViewModel>(context, listen: false).logout();
                }, child: Text("退出账户并退出程序")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
