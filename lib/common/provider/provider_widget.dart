import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderWidget<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final T model;
  final Widget? child;
  final Function(T) onReady;
  final Function(T)? onDispose;

  const ProviderWidget({super.key, 
    required this.model,
    this.child,
    required this.onReady,
    this.onDispose,
    required this.builder
  });

  @override
  _ProviderWidgetState<T> createState() => _ProviderWidgetState<T>();
}

class _ProviderWidgetState<T extends ChangeNotifier> extends State<ProviderWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.onReady(widget.model);
  }
  @override
  void dispose() {
    super.dispose();
    if (widget.onDispose != null) {
      widget.onDispose!(widget.model);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (_) => widget.model,
      child: Consumer<T>(
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}