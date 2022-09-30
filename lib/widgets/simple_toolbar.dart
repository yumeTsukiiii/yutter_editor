import 'package:flutter/material.dart';

class SimpleToolBar extends StatelessWidget {
  const SimpleToolBar({
    Key? key,
    required this.leading,
    this.actions = const [],
    this.color =  Colors.black45,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
  }) : super(key: key);

  final Widget leading;
  final List<Widget> actions;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: color,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          const Spacer(),
          ...actions
        ],
      ),
    );
  }

}