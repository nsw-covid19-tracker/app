import 'package:covid_tracing/home/repo/repo.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Fetching locations'),
      ],
    );
  }
}

class CollapsedPanel extends StatelessWidget {
  final PanelController controller;

  const CollapsedPanel({Key key, @required this.controller})
      : assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.open(),
      child: Container(
        color: Colors.white,
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
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  final List<Case> cases;

  const Panel({
    Key key,
    @required this.cases,
    @required this.panelController,
    @required this.scrollController,
  })  : assert(cases != null),
        assert(panelController != null),
        assert(scrollController != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => panelController.close(),
          child: _SlidingBar(),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: cases.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(cases[index].location),
              subtitle: Text(cases[index].dates),
              onTap: () {
                CaseDialog.show(context, scrollController, cases[index]);
              },
            ),
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ),
      ],
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
