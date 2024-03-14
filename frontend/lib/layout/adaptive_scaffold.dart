import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdaptiveScaffold extends StatefulWidget {
  final Widget Function(BuildContext, BoxConstraints, Size) verticalBuilder;
  final Widget Function(BuildContext, BoxConstraints, Size)? horizontalBuilder, horizontalFullBuilder;
  final SystemUiOverlayStyle? systemUiOverlayStyleOverride;
  final bool? resizeToAvoidBottomInset;
  final Widget? drawer;
  final Color? backgroundColor;
  final double? drawerEdgeDragWidth;

  const AdaptiveScaffold(
      {super.key,
      required this.verticalBuilder,
      this.horizontalBuilder,
      this.horizontalFullBuilder,
      this.systemUiOverlayStyleOverride,
      this.resizeToAvoidBottomInset,
      this.drawer,
      this.backgroundColor,
      this.drawerEdgeDragWidth});

  @override
  State<StatefulWidget> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: widget.drawer,
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        body: AnnotatedRegion(
            value: widget.systemUiOverlayStyleOverride ?? context.effectiveSystemUiOverlayStyle,
            child: LayoutBuilder(builder: _buildLayout)));
  }

  void openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void closeDrawer() => _scaffoldKey.currentState?.closeDrawer();

  Widget _buildLayout(BuildContext context, BoxConstraints constraints) {
    Widget Function(BuildContext, BoxConstraints, Size) layout = widget.verticalBuilder;
    if (!context.isMobile && false) {
      layout = widget.horizontalFullBuilder ??
          (context, constraints, size) {
            return Center(
                child: AspectRatio(
                    aspectRatio: 9 / 12,
                    child:
                        widget.verticalBuilder.call(context, constraints, Size(size.height / (12 / 9), size.height))));
          };
    }
    return layout.call(context, constraints, MediaQuery.of(context).size);
  }
}
