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
          child: ListView.separated(
            controller: widget.panelSc,
            shrinkWrap: true,
            itemCount: widget.cases.length,
            itemBuilder: (context, index) {
              final myCase = widget.cases[index];
              final expiredText = myCase.isExpired ? ' (Expired)' : '';

              return ListTile(
                title: Text('${myCase.venue}$expiredText'),
                subtitle: Text(myCase.formattedDateTimes),
                onTap: () {
                  CaseDialog.show(context, _dialogSc, myCase);
                },
              );
            },
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
