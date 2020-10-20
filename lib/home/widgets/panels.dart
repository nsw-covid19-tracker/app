import 'package:nsw_covid_tracker/home/widgets/cases_list_view.dart';
import 'package:flutter/material.dart';
import 'package:nsw_covid_tracker/home/widgets/loading.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: LoadingWidget());
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

  const Panel({
    Key key,
    @required this.panelSc,
  })  : assert(panelSc != null),
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
        _SlidingBar(),
        SizedBox(height: 16),
        Expanded(
          child: CasesListView(
            panelSc: widget.panelSc,
            dialogSc: _dialogSc,
          ),
        )
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
