import 'dart:convert';

import 'package:purlaw/common/network/network_loading_state.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/models/ai_chat/chat_message_model.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

class ChatHistoryViewModel extends BaseViewModel {
  List<(String, ListAIChatMessageModels)> sessionList = [];

  load() async {
    var list = await HistoryDatabaseUtil.listHistory();
    for (var data in list) {
      sessionList.add((
        TimeUtils.formatDateTime((data.$1)),
        ListAIChatMessageModels.fromJson(jsonDecode(data.$2))
      ));
    }
    if (sessionList.isEmpty) {
      changeState(NetworkLoadingState.EMPTY);
    } else {
      changeState(NetworkLoadingState.CONTENT);
    }
    notifyListeners();
  }
}
