import 'dart:convert';

import '../models/community/short_video_info_model.dart';

final testVideo = VideoInfoModel.fromJson(jsonDecode(
  """
  {"uid":"65f66eab14ecaf804c931c31","title":"【法听】法聚两会: 全国两会特别版","description":"全国两会特别版","author":"Handwer","author_id":"65f162e9313d77bd491971ae","like":2,"tags":"资讯","comments_id":"65f66eab14ecaf804c931c30","sha1":"d5d7ac7c4a640036bd8add88a7a29c0e42d56dd8","cover_sha1":"4ce04cfa197b2ae77c795e3179fcd63d53382fef","timestamp":1710649003.4797893,"avatar":"21e80200213ce694aa31acab3e982874fe44f1ae","cover_ratio":0.4443359375}
  """
));

List<List<VideoInfoModel>> videoList = [
  [VideoInfoModel.fromJson(jsonDecode(
      """
  {"uid":"65f66eab14ecaf804c931c31","title":"【法听】法聚两会: 全国两会特别版","description":"全国两会特别版","author":"Handwer","author_id":"65f162e9313d77bd491971ae","like":2,"tags":"资讯","comments_id":"65f66eab14ecaf804c931c30","sha1":"d5d7ac7c4a640036bd8add88a7a29c0e42d56dd8","cover_sha1":"4ce04cfa197b2ae77c795e3179fcd63d53382fef","timestamp":1710649003.4797893,"avatar":"21e80200213ce694aa31acab3e982874fe44f1ae","cover_ratio":0.4443359375}
  """
  )),VideoInfoModel.fromJson(jsonDecode(
      """
      {"uid":"65f6754e14ecaf804c931c3a","title":"315","description":"666","author":"miaoiaoaoa","author_id":"65f455674cd9061b8818ee8f","like":0,"tags":"时讯","comments_id":"65f6754e14ecaf804c931c39","sha1":"2f35c3a10f3dcbb7ddce9d9f72de71fd0347e414","cover_sha1":"17df4de0cdc016363d8676855fb82fa2067c517d","timestamp":1710650702.8367836,"avatar":"284d3c78cbb798891844ffe752e12d17b9b6a88f","cover_ratio":0.4453125}
  """
  )),VideoInfoModel.fromJson(jsonDecode(
      """
      {"uid":"65f5afae14ecaf804c931c2d","title":"罗翔谈邯郸未成年人杀人埋尸案","description":"罗翔谈邯郸未成年人杀人埋尸案 人性从来都是弯曲的曲木 而非虚无的白纸 只有惩罚 才能带来改造的效果","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":1,"tags":"罗翔,法律,刑法,未成年","comments_id":"65f5afae14ecaf804c931c2c","sha1":"062ada11db8f25b07b83fae5b0535aeeefef4438","cover_sha1":"cf7980d26797898c99511a282d55571f81c6d47e","timestamp":1710600110.9467862,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":1.7777777777777777}
  """
  )),VideoInfoModel.fromJson(jsonDecode(
      """
      {"uid":"65f6a02414ecaf804c931c4e","title":"曝光天价麻辣烫","description":"kk","author":"miaoiaoaoa","author_id":"65f455674cd9061b8818ee8f","like":0,"tags":"时讯","comments_id":"65f6a02414ecaf804c931c4d","sha1":"60f5f45596747891a13c8122b276d35f037dbd27","cover_sha1":"cda685a581b8d760eaa6ade4508e64fa6bfe6fe4","timestamp":1710661668.927789,"avatar":"284d3c78cbb798891844ffe752e12d17b9b6a88f","cover_ratio":0.4453125}
  """
  )),VideoInfoModel.fromJson(jsonDecode(
      """
      {"uid":"65f51ef34cd9061b8818ee93","title":"听花酒骗局","description":"6666","author":"miaoiaoaoa","author_id":"65f455674cd9061b8818ee8f","like":0,"tags":"时世","comments_id":"65f51ef34cd9061b8818ee92","sha1":"d96668cf5d8f5773d79b0497fe984e3706a804e0","cover_sha1":"622beefa98c1dab9d8a72c858fe9825422204698","timestamp":1710563059.5269418,"avatar":"284d3c78cbb798891844ffe752e12d17b9b6a88f","cover_ratio":0.4462890625}
  """
  )),],
  [
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f69fbf14ecaf804c931c4b","title":"【海南原创系列动画普法小剧场】司法保护","description":"【海南原创系列动画普法小剧场 | 司法保护】《未成年人保护法》施行一周年之际，海南省未成年人保护工作领导小组办公室、海南省民政厅、海南广播电视总台新闻频道携手精心制作推出海南原创系列动画普法小剧场，今天让我们一起来看看——司法保护！以法之名，保护“少年的你”。","author":"Handwer","author_id":"65f162e9313d77bd491971ae","like":0,"tags":"科普,未成年人保护法","comments_id":"65f69fbf14ecaf804c931c4a","sha1":"7647578ecd70124708bdb3eeacea599e5011e84e","cover_sha1":"2e1e5147c0a4583a93ec3ee9a8ac9efd26a3d730","timestamp":1710661567.6738052,"avatar":"21e80200213ce694aa31acab3e982874fe44f1ae","cover_ratio":0.5625}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f69b3f14ecaf804c931c48","title":"120秒读懂民法典①","description":"民法典如何影响我们的生活？","author":"Handwer","author_id":"65f162e9313d77bd491971ae","like":0,"tags":"科普,民法典","comments_id":"65f69b3f14ecaf804c931c47","sha1":"baee791a1a843af6af66398e6a530ab1ae51a7c4","cover_sha1":"ae329e6784ab17a85059b74baaf14e227b768da1","timestamp":1710660415.3628147,"avatar":"21e80200213ce694aa31acab3e982874fe44f1ae","cover_ratio":0.5859375}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f66eab14ecaf804c931c31","title":"【法听】法聚两会: 全国两会特别版","description":"全国两会特别版","author":"Handwer","author_id":"65f162e9313d77bd491971ae","like":2,"tags":"资讯","comments_id":"65f66eab14ecaf804c931c30","sha1":"d5d7ac7c4a640036bd8add88a7a29c0e42d56dd8","cover_sha1":"4ce04cfa197b2ae77c795e3179fcd63d53382fef","timestamp":1710649003.4797893,"avatar":"21e80200213ce694aa31acab3e982874fe44f1ae","cover_ratio":0.4443359375}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f5740514ecaf804c931c1f","title":"刑事年龄责任","description":"近日，不满14岁的未成年人杀人事件再次让刑事责任成了焦点话题。","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":3,"tags":"罗翔,普法,法律,刑法,未成年,刑事责任","comments_id":"65f5740514ecaf804c931c1e","sha1":"84a2f5723abcebeeb27ed366965bb4c21eddb057","cover_sha1":"0cd5179057aeaa2e9c84604a511c3e559a902045","timestamp":1710584837.1732953,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":0.5625}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f5989a14ecaf804c931c22","title":"如何证明你是正当防卫？","description":"电影《第二十条》中如果刀没有找到，还是正当防卫吗？与电影类似的一个现实案件是多年前的田仁信故意杀人案，该类案件的关键涉及的都是正当防卫的证明责任的问题。事实上，在大部分有关正当防卫的疑难案件中，当辩护人提出正当防卫的抗辩，都会产生证明责任应由谁承担的问题。","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":2,"tags":"罗翔,刑法,正当防卫,刑事责任,第二十条,举证责任","comments_id":"65f5989a14ecaf804c931c21","sha1":"7c1e43a8ad52d32b7912a5da019976c075166feb","cover_sha1":"0cac8ee2f380713c7eb78ff638aa1b630ca143ab","timestamp":1710594202.452787,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":0.5625}
  """
    )),
  ],
  [

    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f5afae14ecaf804c931c2d","title":"罗翔谈邯郸未成年人杀人埋尸案","description":"罗翔谈邯郸未成年人杀人埋尸案 人性从来都是弯曲的曲木 而非虚无的白纸 只有惩罚 才能带来改造的效果","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":1,"tags":"罗翔,法律,刑法,未成年","comments_id":"65f5afae14ecaf804c931c2c","sha1":"062ada11db8f25b07b83fae5b0535aeeefef4438","cover_sha1":"cf7980d26797898c99511a282d55571f81c6d47e","timestamp":1710600110.9467862,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":1.7777777777777777}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f6773c14ecaf804c931c40","title":"法治之光","description":"罗翔老师","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":2,"tags":"罗翔,普法,刑法","comments_id":"65f6773c14ecaf804c931c3f","sha1":"80200a5ae6106189cbdd736d700982dc02aa9c52","cover_sha1":"e1b475d96e7012dca60365700943e338aa7ddf9c","timestamp":1710651196.2027857,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":1.7777777777777777}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f6777f14ecaf804c931c43","title":"罗老师接的第一个案件","description":"罗老师","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":2,"tags":"罗翔,普法,案件,刑法","comments_id":"65f6777f14ecaf804c931c42","sha1":"91afab35cd1181196a0eeadad621888a835f6efc","cover_sha1":"3b9f983061206f8e8d506782480462ddc00064d2","timestamp":1710651263.2467859,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":1.7777777777777777}
  """
    )),
    VideoInfoModel.fromJson(jsonDecode(
        """
        {"uid":"65f6771114ecaf804c931c3d","title":"著名的锡箔案","description":"罗翔谈著名锡箔案","author":"pieck","author_id":"65f4ed854cd9061b8818ee91","like":1,"tags":"罗翔,法律,刑法","comments_id":"65f6771114ecaf804c931c3c","sha1":"6d618dd99e595056919cd42921706221d492c747","cover_sha1":"1286b977e326688956ae27192d860b57d5a03ce4","timestamp":1710651153.1397867,"avatar":"0434f4e8c89df3a5f5cc56b823cf2b031b56dd84","cover_ratio":1.7777777777777777}
  """
    )),
  ]
];
