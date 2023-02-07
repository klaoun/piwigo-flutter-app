import 'package:flutter/material.dart';

class SettingsAppBar extends StatefulWidget {
  const SettingsAppBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  State<SettingsAppBar> createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  final _expandedHeight = kToolbarHeight * 2;

  @override
  initState() {
    widget.scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  double get _horizontalTitlePadding {
    const basePadding = 16.0;
    const delta = (kToolbarHeight - basePadding) / basePadding;

    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset > (_expandedHeight - kToolbarHeight)) {
        // In case 0% of the expanded height is viewed
        return basePadding * delta + basePadding;
      }

      // In case 0%-100% of the expanded height is viewed
      double scrollDelta =
          (_expandedHeight - widget.scrollController.offset) / _expandedHeight;
      double scrollPercent = (scrollDelta * 2 - 1);
      return (1 - scrollPercent) * delta * basePadding + basePadding;
    }

    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      pinned: true,
      expandedHeight: _expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(
          horizontal: _horizontalTitlePadding,
          vertical: 16,
        ),
        title: Text(
          'Settings', // Todo: Use translations
          textScaleFactor: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
