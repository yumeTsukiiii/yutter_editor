import 'package:flutter/material.dart';
import 'package:yutter_editor/widgets/gesture_resizable.dart';
import 'package:yutter_editor/widgets/side_panel.dart';
import 'package:yutter_editor/widgets/simple_toolbar.dart';

/// UI 编辑器，可视化的 UI 编辑窗口，组合其它 Tool window
class Editor extends StatelessWidget {
  const Editor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        // Container(
        //   width: 200,
        //   color: Colors.red,
        // ),
        SidePanel(),
        _EditorSideWindow(
          indicatorDirection: IndicatorDirection.right,
          children: [
            Container(
              color: Colors.red,
            ),
            Ink(
              color: Colors.blue,
              child: Column(
                children: [
                  SimpleToolBar(
                    leading: const Text('data', style: TextStyle(color: Colors.white60),),
                    actions: [
                      InkWell(
                        onTap: () {},
                        child: const Icon(Icons.remove, color: Colors.white60,),
                      )
                    ],
                  )
                ],
              ),
            ),
            Ink(
              color: Colors.red,
              child: Column(
                children: [
                  SimpleToolBar(
                    leading: const Text('data', style: TextStyle(color: Colors.white60),),
                    actions: [
                      InkWell(
                        onTap: () {},
                        child: const Icon(Icons.remove, color: Colors.white60,),
                      )
                    ],
                  )
                ],
              ),
            ),
            Ink(
              color: Colors.blue,
              child: Column(
                children: [
                  SimpleToolBar(
                    leading: const Text('data', style: TextStyle(color: Colors.white60),),
                    actions: [
                      InkWell(
                        onTap: () {},
                        child: const Icon(Icons.remove, color: Colors.white60,),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        Expanded(child: Container(
          color: Colors.green,
        )),
        const _EditorSideWindow(indicatorDirection: IndicatorDirection.left,),
      ],
    );
  }

}

class _EditorSideWindow extends StatelessWidget {
  const _EditorSideWindow({Key? key, required this.indicatorDirection, this.children = const []}): super(key: key);

  final IndicatorDirection indicatorDirection;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GestureResizable(
      indicatorDirection: indicatorDirection,
      initWidth: 200,
      child: Column(
        children: children.isEmpty ? [] : [
          Expanded(
            child: GestureResizableGroup(
              indicatorDirection: IndicatorDirection.bottom,
              initHeight: 800,
              children: children.sublist(1).map((child) {
                return GestureResizableWidget(
                  alwaysShowIndicator: true,
                  fixedIndicator: false,
                  indicatorWidth: 12,
                  indicator: const DefaultIndicator(
                    opacity: 1,
                    direction: IndicatorDirection.bottom,
                    backgroundColor: Colors.black54,
                    iconSize: 12,
                  ),
                  child: MaterialButton(
                    onPressed: () {  },
                    child: Text('23333'),
                  )
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

}

class _EditorRight extends StatelessWidget {
  const _EditorRight({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }

}

class _EditorCenter extends StatelessWidget {
  const _EditorCenter({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}

class _EditorToolMenu extends StatelessWidget {
  const _EditorToolMenu({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }

}