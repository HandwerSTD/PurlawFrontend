import 'package:purlaw/common/utils/log_utils.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';

class ContractGenerationViewModel extends BaseViewModel {
  bool genComplete = false;

  var title = "";
  var desc = "";
  var aName = "";
  var bName = "";
  var type = "";

  Future<void> submit() async {
    Log.i("title: $title, desc: $desc", tag: "ContractGeneration ViewModel");
    genComplete = true;
    notifyListeners();
  }
}