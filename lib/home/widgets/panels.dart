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
              child: Text(
                'Show list of locations',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Panel extends StatefulWidget {
  final ScrollController panelSc;
  final PanelController panelController;
  final List<Case> cases;

  const Panel({
    Key key,
    @required this.cases,
    @required this.panelController,
    @required this.panelSc,
  })  : assert(cases != null),
        assert(panelController != null),
        assert(panelSc != null),
        super(key: key);

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  final _dialogSc = ScrollController();

  @override
  void dispose() {
    _dialogSc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => widget.panelController.close(),
          child: _SlidingBar(),
        ),
        SizedBox(height: 16),
        Expanded(
          child: _CasesListView(
            panelSc: widget.panelSc,
            dialogSc: _dialogSc,
            cases: widget.cases,
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

class _CasesListView extends StatelessWidget {
  final ScrollController panelSc;
  final ScrollController dialogSc;
  final List<Case> cases;

  const _CasesListView({
    Key key,
    @required this.panelSc,
    @required this.dialogSc,
    @required this.cases,
  })  : assert(panelSc != null),
        assert(dialogSc != null),
        assert(cases != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeCases = <Case>[];
    final expiredCases = <Case>[];

    for (final myCase in cases) {
      if (myCase.isExpired) {
        expiredCases.add(myCase);
      } else {
        activeCases.add(myCase);
      }
    }

    var itemCount = cases.length;
    if (activeCases.isNotEmpty) itemCount++;
    if (expiredCases.isNotEmpty) itemCount++;

    return ListView.separated(
      controller: panelSc,
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0 || index == activeCases.length + 1) {
          var title = 'Expired';
          var topPadding = 16.0;
          var bottomPadding = 16.0;

          if (index == 0 && activeCases.isNotEmpty) {
            title = 'Recent Case Locations';
            topPadding = 0;
          }

          return Padding(
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(fontWeightDelta: 3),
            ),
          );
        } else {
          Case myCase;
          if (index < activeCases.length + 1) {
            myCase = activeCases[index - 1];
          } else {
            var offset = 1;
            if (activeCases.isNotEmpty) offset = 2;
            myCase = expiredCases[index - activeCases.length - offset];
          }

          return ListTile(
            title: Text('${myCase.venue}'),
            subtitle: Text(myCase.formattedDateTimes),
            onTap: () {
              CaseDialog.show(context, dialogSc, myCase);
            },
          );
        }
      },
      separatorBuilder: (context, index) =>
          index == 0 || index == activeCases.length + 1
              ? SizedBox.shrink()
              : Divider(
                  color: Colors.grey,
                  indent: 16,
                  endIndent: 16,
                ),
    );
  }
}
