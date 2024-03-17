import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/common/network/network_request.dart';
import 'package:purlaw/components/purlaw/purlaw_components.dart';
import 'package:purlaw/components/third_party/prompt.dart';
import 'package:purlaw/viewmodels/main_viewmodel.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:purlaw/common/utils/log_utils.dart';


class MyAccountManagement extends StatefulWidget {
  final String desc;
  const MyAccountManagement({super.key, required this.desc});

  @override
  State<MyAccountManagement> createState() => _MyAccountManagementState();
}

class _MyAccountManagementState extends State<MyAccountManagement> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  int count = 0;
  
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.desc);
    count = widget.desc.length;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PurlawAppTitleBar(title: '帐户管理', showBack: true).build(context),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: controller, focusNode: focusNode, readOnly: false,
              maxLines: null,
              decoration: PurlawChatTextField.chatInputDeco('个人简介', getThemeModel(context).colorModel.loginTextFieldColor, 24),
              onChanged: (val){
                setState(() {
                  count = val.length;
                });
              },
            ),
            Text("$count / 50", style: TextStyle(color: (count > 50 ? Colors.red : null)),),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      child: const Text("更新简介"),
                      onPressed: () async {
                        focusNode.unfocus();
                        var desc = controller.text;
                        if (desc.length > 50) {
                          showToast("字数不能超过50", toastType: ToastType.warning);
                          return;
                        }
                        try {
                          var response = jsonDecode(await HttpGet.post(API.userUpdateDesc.api, HttpGet.jsonHeadersCookie(getCookie(context, listen: false)), {
                            "user_info": controller.text
                          }));
                          if (response["status"] != "success") throw Exception(response["message"]);
                          getMainViewModel(context, listen: false).changeDesc(desc);
                          showToast("更新简介成功", toastType: ToastType.success);
                        } on Exception catch (e) {
                          Log.e("", error: e, tag: "Account Mgr Update Desc");
                          showToast("更新简介失败", toastType: ToastType.error);
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
