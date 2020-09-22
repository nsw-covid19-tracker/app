import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatelessWidget {
  final _controller = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is handled by the search bar itself.
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        controller: _controller,
        minHeight: 80,
        panel: Column(
          children: [_SlidingBar()],
        ),
        collapsed: _CollapsedPanel(controller: _controller),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Map(),
            SearchBar(),
          ],
        ),
      ),
    );
  }
}

class _CollapsedPanel extends StatelessWidget {
  final PanelController controller;

  const _CollapsedPanel({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.open(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _SlidingBar(),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list),
                SizedBox(width: 8),
                Text(
                  'Show List',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SlidingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
