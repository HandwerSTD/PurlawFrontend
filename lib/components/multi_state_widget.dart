import 'package:flutter/material.dart';

import '../common/network/network_loading_state.dart';

typedef ContentWidget = Widget Function(BuildContext);

class MultiStateWidget extends StatefulWidget {
  final Widget errorWidget;
  final Widget loadingWidget;
  final Widget? emptyWidget;
  final Widget? readyWaitingWidget;
  final ContentWidget builder;
  final NetworkLoadingState state;
  const MultiStateWidget(
      {required this.state,
      this.errorWidget = const GeneralErrorWidget(),
      this.loadingWidget = const GeneralLoadingWidget(),
      this.emptyWidget = const GeneralEmptyWidget(),
        this.readyWaitingWidget,
      required this.builder,
      super.key});

  @override
  State<MultiStateWidget> createState() => _MultiStateWidgetState();
}

class _MultiStateWidgetState extends State<MultiStateWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.state == NetworkLoadingState.LOADING) {
      return widget.loadingWidget;
    }
    if (widget.state == NetworkLoadingState.ERROR) {
      return widget.errorWidget;
    }
    if (widget.state == NetworkLoadingState.EMPTY) {
      return widget.emptyWidget!;
    }
    if (widget.state == NetworkLoadingState.READY_WAITING) {
      return widget.readyWaitingWidget!;
    }
    return widget.builder(context);
  }
}

class GeneralErrorWidget extends StatelessWidget {
  const GeneralErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("加载错误"));
  }
}

class GeneralEmptyWidget extends StatelessWidget {
  const GeneralEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("列表空"));
  }
}

class GeneralLoadingWidget extends StatelessWidget {
  const GeneralLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("加载中"));
  }
}
