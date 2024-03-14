import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/misc.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar(
      {Key? key,
        required this.hintLabel,
        required this.onSubmitted,
        this.height = 56,
        this.readOnly = false,
        required this.onTap})
      : super(key: key);
  final String hintLabel;
  final bool readOnly;
  final double height;
  final Function onTap;
  // 回调函数
  final Function(String) onSubmitted;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // 焦点对象
  final FocusNode _focusNode = FocusNode();
  // 文本的值
  String searchVal = '';
  //用于清空输入框
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    //  获取焦点
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _focusNode.requestFocus();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    MediaQueryData queryData = MediaQuery.of(context);
    bool rBreak = (Responsive.checkWidth(queryData.size.width) == Responsive.lg);
    return Container(
      // width: Responsive.assignWidthSmall(queryData.size.width),
      height: widget.height,
      // 设置padding
      padding: const EdgeInsets.only(left: 20, top: 0),
      margin: (widget.readOnly ? EdgeInsets.only(left: 8, right: 12, top: (rBreak ? 84 : 8)) : const EdgeInsets.only(top: 6)),
      // 设置子级位置
      alignment: Alignment.centerLeft,
      // 设置修饰
      decoration: BoxDecoration(
        border: (widget.readOnly ? null : Border.all(width: 1, color: Colors.grey)),
        boxShadow: (widget.readOnly ? TDTheme.defaultData().shadowsTop : null),
          borderRadius: BorderRadius.circular(10),
          color: getThemeModel(context).dark ? Colors.black : Theme.of(context).scaffoldBackgroundColor),
      child: TextField(
        // style: TextStyle(height: 1),
        textAlignVertical: TextAlignVertical.center,
        controller: _controller,
        // 自动获取焦点
        focusNode: _focusNode,
        autofocus: true,
        readOnly: widget.readOnly,
        onTap: (widget.readOnly ? () {widget.onTap();} : null),
        decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            hintText: widget.hintLabel,
            hintStyle: const TextStyle(color: Colors.grey),
            // 取消掉文本框下面的边框
            border: InputBorder.none,
            icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                )),
            //  关闭按钮，有值时才显示
            suffixIcon: searchVal.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //   清空内容
                setState(() {
                  searchVal = '';
                  _controller.clear();
                });
              },
            )
                : null),
        onChanged: (value) {
          setState(() {
            searchVal = value;
          });
        },
        onSubmitted: (value) {
          widget.onSubmitted(value);
        },
      ),
    );
  }
}
