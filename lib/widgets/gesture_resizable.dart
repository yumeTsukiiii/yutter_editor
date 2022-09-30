import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum IndicatorDirection {
  top, bottom, left, right
}

/// 可通过手势进行缩放的组件，单个组件进行缩放
/// 当需要多个组件在固定宽高下进行缩放联动时，请使用[GestureResizableGroup]
class GestureResizable extends StatefulWidget {
  const GestureResizable({
    Key? key,
    required this.indicatorDirection,
    required this.child,
    this.initWidth,
    this.initHeight,
    this.indicator,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.indicatorWidth = 14,
    this.fixedIndicator = true,
    this.alwaysShowIndicator = false
  }) : super(key: key);

  final Widget child;
  final IndicatorDirection indicatorDirection;
  final double? initWidth;
  final double? initHeight;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Widget? indicator;
  final double indicatorWidth;
  final bool fixedIndicator;
  final bool alwaysShowIndicator;

  @override
  State<StatefulWidget> createState() => _GestureResizableState();

}

class _GestureResizableState extends State<GestureResizable> {

  double? width = 0;
  double? height = 0;
  bool _showIndicator = false;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    resetSize();
  }

  @override
  void didUpdateWidget(GestureResizable widget) {
    super.didUpdateWidget(widget);
    resetSize();
  }

  void resetSize() {
    width = widget.initWidth;
    height = widget.initHeight;
  }

  bool get showIndicator => _showIndicator || isDragging || widget.alwaysShowIndicator;

  void handleHorizontalDragUpdate(DragUpdateDetails detail) {
    if (widget.indicatorDirection == IndicatorDirection.left || widget.indicatorDirection == IndicatorDirection.right) {
      setState(() {
        width = max(widget.minWidth ?? widget.indicatorWidth, (width ?? 0) + detail.delta.dx * ((widget.indicatorDirection == IndicatorDirection.left) ? -1 : 1));
      });
    }
  }

  void handleVerticalDragUpdate(DragUpdateDetails detail) {
    if (widget.indicatorDirection == IndicatorDirection.top || widget.indicatorDirection == IndicatorDirection.bottom) {
      setState(() {
        height = max(widget.minHeight ?? widget.indicatorWidth, (height ?? 0) + detail.delta.dy * (widget.indicatorDirection == IndicatorDirection.top ? -1 : 1));
      });
    }
  }

  void handleDragStart(DragStartDetails detail) {
    setState(() {
      isDragging = true;
    });
  }

  void handleDragEnd(DragEndDetails detail) {
    setState(() {
      isDragging = false;
    });
  }

  void handleIndicatorHover(PointerHoverEvent event) {
    setState(() {
      _showIndicator = true;
    });
  }

  void handleIndicatorExit(PointerExitEvent event) {
    setState(() {
      _showIndicator = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GestureResizableWidget(
      indicatorDirection: widget.indicatorDirection,
      width: width,
      height: height,
      minWidth: widget.minWidth,
      minHeight: widget.minHeight,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      indicator: widget.indicator,
      indicatorWidth: widget.indicatorWidth,
      showIndicator: showIndicator,
      onDragStart: handleDragStart,
      onDragEnd: handleDragEnd,
      onHorizontalDragUpdate: handleHorizontalDragUpdate,
      onVerticalDragUpdate: handleVerticalDragUpdate,
      onIndicatorHover: handleIndicatorHover,
      onIndicatorExit: handleIndicatorExit,
      fixedIndicator: widget.fixedIndicator,
      child: widget.child,
    );
  }

}

class ResizableItem {

  const ResizableItem({
    this.key,
    required this.child,
    this.flex = 1,
    this.indicator,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.indicatorWidth = 18,
    this.fixedIndicator = true,
    this.alwaysShowIndicator = false
  });

  final Key? key;
  final Widget child;
  final int flex;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Widget? indicator;
  final double indicatorWidth;
  final bool fixedIndicator;
  final bool alwaysShowIndicator;

}

/// 可缩放组件组，可以对配置的 ResizableChildren 进行缩放联动
class GestureResizableGroup extends StatefulWidget {
  const GestureResizableGroup({
    Key? key,
    required this.indicatorDirection,
    this.children = const [],
    this.initWidth,
    this.initHeight,
    this.fixFirstItem = true,
  }) : super(key: key);

  final IndicatorDirection indicatorDirection;
  final double? initWidth;
  final double? initHeight;
  final List<GestureResizableWidget> children;
  final bool fixFirstItem;

  @override
  State<StatefulWidget> createState() => _GestureResizableGroupState();

}

class GroupItemData {

  GroupItemData({
    this.width,
    this.height
  });

  double? width;
  double? height;
  bool isDragging = false;
  bool isHover = false;

  bool get showIndicator => isHover || isDragging;

  @override
  bool operator ==(Object other) {
    if (other is! GroupItemData) {
      return false;
    }

    if (width != other.width || height != other.height || showIndicator != other.showIndicator) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => hashValues(width, height, showIndicator);

  GroupItemData copy({
    double? width,
    double? height,
    bool? isDragging,
    bool? isHover,
    bool overrideNullWidth = false,
    bool overrideNullHeight = false
  }) {
    return GroupItemData(
      width: width ?? (overrideNullWidth ? null : this.width),
      height: height ?? (overrideNullHeight ? null : this.height)
    )..isDragging = isDragging ?? this.isDragging
      ..isHover = isHover ?? this.isHover;
  }

}

class _GestureResizableGroupState extends State<GestureResizableGroup> {

  List<GroupItemData> groupItemData = const [];
  double width = double.infinity;
  double height = double.infinity;

  late double maxWidth;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    resetSize();
  }

  @override
  void didUpdateWidget(GestureResizableGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetSize();
  }

  void resetSize() {
    width = widget.initWidth ?? double.infinity;
    height = widget.initHeight ?? double.infinity;
  }

  void calculateGroupItemData({
    double? defaultWidth,
    double? defaultHeight
  }) {
    groupItemData = [];
    if (widget.children.isEmpty) {
      return;
    }

    final totalFlex = widget.children.map((e) => e.flex).reduce((value, element) => value + element);

    bool isVertical = widget.indicatorDirection == IndicatorDirection.top || widget.indicatorDirection == IndicatorDirection.bottom;
    double? mainAxisLength = isVertical ? (
        widget.initHeight ?? defaultHeight
    ) : widget.initWidth ?? defaultWidth;
    if (mainAxisLength == null) {
      return;
    }

    int remainFlex = totalFlex;

    for (int i = 0; i < widget.children.length; i++) {
      final item = widget.children[i];
      double mainAxisResult = remainFlex.toDouble();
      int originFlex = max(1, item.flex);
      mainAxisResult = (mainAxisLength * (originFlex / totalFlex));
      if (i < widget.children.length - 1) {
        remainFlex = remainFlex - originFlex;
      }

      groupItemData.add(
        GroupItemData(
          width: !isVertical ? mainAxisResult : null,
          height: isVertical ? mainAxisResult : null
        )
      );
    }
  }

  void calculateGroupItemSize({
    required double offset,
    required int index,
    required double oldItemSize,
    required double minSize,
    required int changedSiblingIndex,
    required bool isChangeSibling,
    required double Function(GroupItemData item) onGetSiblingSize,
    required double Function(int index) onGetMinSiblingSize,
    required void Function(double changed) onContainerSizeChanged,
    required double Function(List<GroupItemData> dataExcludeSide) onCalRemainSize,
    required GroupItemData Function(double result) onCreateGroupItemData,
  }) {
    // 1. 重新复制一份 data，供子组件监听变化
    groupItemData = [...groupItemData];
    // 2. 计算当前 index 节点 resize 后的大小
    var result = max(minSize, oldItemSize + offset);
    final changed = oldItemSize - result;
    // 3. 与兄弟节点联动，根据容器大小缩放兄弟节点的大小
    if (isChangeSibling) {
      // 3.1 可以改变顺着主轴的兄弟节点大小
      final oldSibling = groupItemData[changedSiblingIndex];
      groupItemData[changedSiblingIndex] = oldSibling.copy(
        height: max(onGetMinSiblingSize(changedSiblingIndex), onGetSiblingSize(oldSibling) + changed)
      );
    } else {
      // 3.2 不能改变顺着主轴的兄弟节点大小，缩放容器宽高
      onContainerSizeChanged(changed);
    }

    // 4. 兜底，当前节点 size 改变后，总容器高度不能超过原来的最大高度
    List<GroupItemData> dataExcludeSide = [...groupItemData]..removeAt(index);
    final remainHeight = onCalRemainSize(dataExcludeSide);
    groupItemData[index] = onCreateGroupItemData(min(remainHeight, result));
  }

  void handleHorizontalDragUpdate(DragUpdateDetails detail, int index) {
    if (widget.indicatorDirection == IndicatorDirection.left || widget.indicatorDirection == IndicatorDirection.right) {
      setState(() {
        groupItemData = [...groupItemData];
        final changedSiblingIndex = widget.indicatorDirection == IndicatorDirection.left ? index - 1 : index + 1;
        calculateGroupItemSize(
          offset: detail.delta.dx * (widget.indicatorDirection == IndicatorDirection.left ? -1 : 1),
          index: index,
          oldItemSize: groupItemData[index].width ?? 0,
          minSize: widget.children[index].resizeMinWidth,
          changedSiblingIndex: changedSiblingIndex,
          isChangeSibling: widget.indicatorDirection == IndicatorDirection.left ? changedSiblingIndex >= 0 : changedSiblingIndex < groupItemData.length,
          onGetMinSiblingSize: (index) => widget.children[index].resizeMinWidth,
          onGetSiblingSize: (item) => item.width ?? 0,
          onContainerSizeChanged: (changed) => width = min(width - changed, maxWidth),
          onCalRemainSize: (dataExcludeSide) => max(0.0, maxWidth - dataExcludeSide.map((e) => e.width ?? 0.0).reduce((v, e) => v + e)),
          onCreateGroupItemData: (result) => groupItemData[index].copy(width: result)
        );
      });
    }
  }

  void handleVerticalDragUpdate(DragUpdateDetails detail, int index) {
    if (widget.indicatorDirection == IndicatorDirection.top || widget.indicatorDirection == IndicatorDirection.bottom) {
      setState(() {
        groupItemData = [...groupItemData];
        final changedSiblingIndex = widget.indicatorDirection == IndicatorDirection.top ? index - 1 : index + 1;
        calculateGroupItemSize(
          offset: detail.delta.dy * (widget.indicatorDirection == IndicatorDirection.top ? -1 : 1),
          index: index,
          oldItemSize: groupItemData[index].height ?? 0,
          minSize: widget.children[index].resizeMinHeight,
          changedSiblingIndex: changedSiblingIndex,
          isChangeSibling: widget.indicatorDirection == IndicatorDirection.top ? changedSiblingIndex >= 0 : changedSiblingIndex < groupItemData.length,
          onGetMinSiblingSize: (index) => widget.children[index].resizeMinHeight,
          onGetSiblingSize: (item) => item.height ?? 0,
          onContainerSizeChanged: (changed) => height = min(height - changed, maxHeight),
          onCalRemainSize: (dataExcludeSide) => max(0.0, maxHeight - dataExcludeSide.map((e) => e.height ?? 0.0).reduce((v, e) => v + e)),
          onCreateGroupItemData: (result) => groupItemData[index].copy(height: result)
        );
      });
    }
  }

  void handleDragStart(DragStartDetails detail, int index) {
    setState(() {
      groupItemData[index].isDragging = true;
    });
  }

  void handleDragEnd(DragEndDetails detail, int index) {
    setState(() {
      groupItemData[index].isDragging = false;
    });
  }

  void handleIndicatorHover(PointerHoverEvent event, int index) {
    setState(() {
      groupItemData[index].isHover = true;
    });
  }

  void handleIndicatorExit(PointerExitEvent event, int index) {
    setState(() {
      groupItemData[index].isHover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const Center();
    }

    Widget containerBuilder({List<Widget> children = const []}) {
      if (widget.indicatorDirection == IndicatorDirection.top || widget.indicatorDirection == IndicatorDirection.bottom) {
        return SizedBox(
          height: height,
          child: Column(
            children: children,
          ),
        );
      } else {
        return SizedBox(
          width: width,
          child: Row(
            children: children,
          ),
        );
      }
    }

    List<Widget> createChildren(BuildContext context, BoxConstraints constraints) {
      final result = <Widget>[];

      if (groupItemData.isEmpty) {
        calculateGroupItemData(defaultWidth: constraints.maxWidth, defaultHeight: constraints.maxHeight);
      }
      if (groupItemData.isEmpty) {
        return result;
      }

      var startIndex = 0;
      var endIndex = widget.children.length;
      var fixStart = true;
      if (widget.fixFirstItem) {
        if (widget.indicatorDirection == IndicatorDirection.top || widget.indicatorDirection == IndicatorDirection.left) {
          startIndex += 1;
        } else {
          endIndex -= 1;
          fixStart = false;
        }
      }

      void generateFixedItem() {
        if (!widget.fixFirstItem) {
          return;
        }
        final item = widget.children[fixStart ? startIndex : endIndex];
        result.add(
          Expanded(
            flex: item.flex,
            child: SizedBox.expand(
              child: item.child,
            ),
          )
        );
      }

      if (fixStart) {
        generateFixedItem();
      }
      for (int i = startIndex; i < endIndex; i++) {
        result.add(
          _InheritedGestureResizableWidget(
            state: this,
            index: i,
            indicatorDirection: widget.indicatorDirection,
            groupItemData: groupItemData[i],
            child: widget.children[i]
          )
        );
      }
      if (!fixStart) {
        generateFixedItem();
      }

      return result;
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (width == double.infinity) {
        width = constraints.maxWidth;
      }
      if (height == double.infinity) {
        height = constraints.maxHeight;
      }
      maxWidth = min(widget.initWidth ?? constraints.maxWidth, constraints.maxWidth);
      maxHeight = min(widget.initHeight ?? constraints.maxHeight, constraints.maxHeight);
      return containerBuilder(
        children: createChildren(context, constraints)
      );
    });
  }

}

class GestureResizableWidget extends StatelessWidget {

  const GestureResizableWidget({
    Key? key,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.indicator,
    this.indicatorWidth = 18,
    this.fixedIndicator = true,
    this.flex = 1,
    this.alwaysShowIndicator = false
  }): super(key: key);

  final Widget child;
  final int flex;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Widget? indicator;
  final double indicatorWidth;
  final bool fixedIndicator;
  final bool alwaysShowIndicator;

  double get resizeMinHeight => max(minHeight ?? 0, indicatorWidth);
  double get resizeMinWidth => max(minWidth ?? 0, indicatorWidth);

  @override
  Widget build(BuildContext context) {
    final inheritedResizable = context.dependOnInheritedWidgetOfExactType<_InheritedGestureResizableWidget>();
    if (inheritedResizable == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
        'Cannot find _InheritedGestureResizableWidget',
        ),
      ]);
    }
    final groupItem = inheritedResizable.groupItemData;
    final i = inheritedResizable.index;
    final groupState = inheritedResizable.state;

    return _GestureResizableWidget(
      indicatorDirection: inheritedResizable.indicatorDirection,
      width: groupItem.width,
      height: groupItem.height,
      minWidth: minWidth,
      minHeight: minHeight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      indicator: indicator,
      indicatorWidth: indicatorWidth,
      showIndicator: groupItem.showIndicator || alwaysShowIndicator,
      onDragStart: (event) => groupState.handleDragStart(event, i),
      onDragEnd: (event) => groupState.handleDragEnd(event, i),
      onHorizontalDragUpdate: (event) => groupState.handleHorizontalDragUpdate(event, i),
      onVerticalDragUpdate: (event) => groupState.handleVerticalDragUpdate(event, i),
      onIndicatorHover: (event) => groupState.handleIndicatorHover(event, i),
      onIndicatorExit: (event) => groupState.handleIndicatorExit(event, i),
      fixedIndicator: fixedIndicator,
      child: child,
    );
  }

}

class _InheritedGestureResizableWidget extends InheritedWidget {

  const _InheritedGestureResizableWidget({
    required this.state,
    required this.indicatorDirection,
    required this.groupItemData,
    required this.index,
    required super.child
  });

  final GroupItemData groupItemData;
  final IndicatorDirection indicatorDirection;
  final _GestureResizableGroupState state;
  final int index;

  @override
  bool updateShouldNotify(covariant _InheritedGestureResizableWidget oldWidget) {
    if (oldWidget.state != state) {
      return true;
    }
    if (oldWidget.indicatorDirection != indicatorDirection) {
      return true;
    }
    if (oldWidget.groupItemData != groupItemData) {
      return true;
    }
    return false;
  }

}

class _GestureResizableWidget extends StatelessWidget {

  const _GestureResizableWidget({
    Key? key,
    this.width,
    this.height,
    required this.indicatorDirection,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.indicator,
    this.indicatorWidth = 18,
    this.fixedIndicator = true,
    this.showIndicator = false,
    this.onDragStart,
    this.onDragEnd,
    this.onVerticalDragUpdate,
    this.onHorizontalDragUpdate,
    this.onIndicatorHover,
    this.onIndicatorExit
  }): super(key: key);

  final IndicatorDirection indicatorDirection;
  final double? width;
  final double? height;
  final Widget child;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final Widget? indicator;
  final double indicatorWidth;
  final bool fixedIndicator;
  final bool showIndicator;


  final GestureDragStartCallback? onDragStart;
  final GestureDragEndCallback? onDragEnd;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final PointerHoverEventListener? onIndicatorHover;
  final PointerExitEventListener? onIndicatorExit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (fixedIndicator)
            child
          else
            Positioned(
                top: indicatorDirection == IndicatorDirection.top ? indicatorWidth : 0,
                bottom: indicatorDirection == IndicatorDirection.bottom ? indicatorWidth : 0,
                left: indicatorDirection == IndicatorDirection.left ? indicatorWidth : 0,
                right: indicatorDirection == IndicatorDirection.right ? indicatorWidth : 0,
                child: child
            ),
          Positioned(
            top: indicatorDirection == IndicatorDirection.bottom ? null : 0,
            bottom: indicatorDirection == IndicatorDirection.top ? null : 0,
            left: indicatorDirection == IndicatorDirection.right ? null : 0,
            right: indicatorDirection == IndicatorDirection.left ? null : 0,
            child: MouseRegion(
              onHover: onIndicatorHover,
              onExit: onIndicatorExit,
              child: GestureDetector(
                onHorizontalDragStart: onDragStart,
                onHorizontalDragEnd: onDragEnd,
                onVerticalDragStart: onDragStart,
                onVerticalDragEnd: onDragEnd,
                onHorizontalDragUpdate: onHorizontalDragUpdate,
                onVerticalDragUpdate: onVerticalDragUpdate,
                child: AnimatedOpacity(
                  opacity: showIndicator ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: (indicatorDirection == IndicatorDirection.left || indicatorDirection == IndicatorDirection.right) ? indicatorWidth : null,
                    height: (indicatorDirection == IndicatorDirection.top || indicatorDirection == IndicatorDirection.bottom) ? indicatorWidth : null,
                    child: indicator ?? DefaultIndicator(direction: indicatorDirection, iconSize: indicatorWidth,),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}

class DefaultIndicator extends StatelessWidget {

  const DefaultIndicator({
    Key? key,
    required this.direction,
    this.iconSize = 14.0,
    this.backgroundColor = Colors.black,
    this.iconColor = Colors.white,
    this.opacity = 0.2,
    this.icon = Icons.menu
  }): super(key: key);

  final IndicatorDirection direction;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final double opacity;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        color: backgroundColor,
        child: Center(
          child: Transform.rotate(
            angle: (direction == IndicatorDirection.left || direction == IndicatorDirection.right) ? (pi / 2) : 0,
            child: Icon(icon, color: Colors.white, size: iconSize,),
          ),
        ),
      ),
    );
  }

}