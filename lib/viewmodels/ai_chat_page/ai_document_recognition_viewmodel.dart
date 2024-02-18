import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purlaw/viewmodels/base_viewmodel.dart';
import '../../method_channels/document_recognition.dart';

class AIDocumentRecViewModel extends BaseViewModel {
  PageController controller = PageController();
  List<String> result = [];
  List<AIDocumentRecBodyViewModel> viewModels = [];

  void load() async {
    final files = await CunningDocumentScanner.getPictures(true);
    if (files == null) return;
    for (var file in files) {
      result.add(((file)));
      viewModels.add(AIDocumentRecBodyViewModel(image: File(file)));
    }
    controller.animateToPage(result.length - 1 - (files.length - 1), duration: const Duration(milliseconds: 500), curve: Curves.easeOutExpo);
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

class AIDocumentRecBodyViewModel extends BaseViewModel {
  TextEditingController controller = TextEditingController();
  final File image;
  AIDocumentRecBodyViewModel({required this.image});
  bool ocrCompleted = false;
  String ocrResult = "";

  Future<void> loadOCR() async {
    final res = await DocumentRecognition.getResult(XFile(image.absolute.path));
    ocrResult = "识别结果：\n";
    for (var str in res) {
      ocrResult += "$str\n";
    }
    print(ocrResult);
    controller = TextEditingController(text: ocrResult);
    ocrCompleted = true;
  }
}
