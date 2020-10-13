import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:covid_tracing/home/common/common.dart';
import 'package:covid_tracing/home/repo/repo.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';

class CaseDialog {
  static void show(
      BuildContext context, ScrollController controller, Case myCase) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: myCase.isExpired ? DialogType.INFO : DialogType.WARNING,
      body: _CaseInfo(myCase: myCase, controller: controller),
    )..show();
  }
}

class _CaseInfo extends StatelessWidget {
  final Case myCase;
  final ScrollController controller;

  const _CaseInfo({Key key, @required this.myCase, @required this.controller})
      : assert(myCase != null),
        assert(controller != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: kLayoutPadding,
      child: FadingEdgeScrollView.fromScrollView(
        child: ListView(
          controller: controller,
          children: [
            Text(
              myCase.isExpired ? 'Expired' : 'Recent Case Location',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(fontWeightDelta: 3),
            ),
            WidgetPaddingSm(),
            Text(
              myCase.venue,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(fontWeightDelta: 1),
            ),
            WidgetPaddingSm(),
            Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(myCase.address),
            WidgetPaddingSm(),
            Text(
              'Date and Time',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(myCase.formattedDateTimes),
          ],
        ),
      ),
    );
  }
}
