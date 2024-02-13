import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import '../../method_channels/document_recognition.dart';

class AIDocumentRecViewModel extends BaseViewModel {
  PageController controller = PageController();
  List<String> results = [];
  List<XFile?> images = [];

  void loadNew() {
    results.add("加载中");
    images.add(null);
    notifyListeners();
  }

  load(int index) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      results.removeLast();
      images.removeLast();
      notifyListeners();
      return;
    }
    final ext = p.extension(image.path).toLowerCase();
    // if (!(ext.isEmpty || ext == ".jpg" || ext == ".png" || ext == ".jpeg")) {
    //   results[index] = "图片格式不支持";
    //   notifyListeners();
    //   return;
    // }

    images.last = image; notifyListeners();
    var res = await DocumentRecognition.getResult(image);
    results[index] = "识别结果：\n";
    for (var str in res) {
      results[index] += "$str\n";
    }
    notifyListeners();

    if (results.length > 1) {
      controller.animateToPage(results.length, duration: Duration(milliseconds: 400), curve: Curves.easeOutQuad);
    }
  }
}
