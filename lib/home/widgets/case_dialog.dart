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
      btnOkOnPress: () {},
      btnOkText: 'Close',
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
    final height = MediaQuery.of(context).size.height * 0.3;
    final expiredText = myCase.isExpired ? ' (Expired)' : '';

    return Container(
      height: height,
      padding: kLayoutPadding,
      child: FadingEdgeScrollView.fromScrollView(
        child: ListView(
          controller: controller,
          children: [
            Text(
              '${myCase.location}$expiredText',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(fontWeightDelta: 1),
            ),
            WidgetPaddingSm(),
            Text('Dates', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(myCase.dates),
            WidgetPaddingSm(),
            RichText(
              text: TextSpan(
                text: 'Suggested Action ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '(If you visited this location at the times above)',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            Text(myCase.action),
            WidgetPaddingSm(),
          ],
        ),
      ),
    );
  }
}
