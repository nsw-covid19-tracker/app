import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/common/common.dart';
import 'package:nsw_covid_tracker/home/repo/repo.dart';
import 'package:nsw_covid_tracker/home/widgets/case_dialog.dart';
import 'package:nsw_covid_tracker/home/widgets/padding.dart';

class CasesListView extends StatelessWidget {
  final ScrollController panelSc;
  final ScrollController dialogSc;

  const CasesListView({
    Key key,
    this.panelSc,
    @required this.dialogSc,
  })  : assert(dialogSc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        return previous is HomeInitial ||
            (previous is HomeSuccess &&
                current is HomeSuccess &&
                previous.casesResult != current.casesResult);
      },
      builder: (context, state) {
        final activeCases = <Case>[];
        final expiredCases = <Case>[];
        var itemCount = 0;

        if (state is HomeSuccess) {
          for (final myCase in state.casesResult) {
            itemCount++;
            if (myCase.isExpired) {
              expiredCases.add(myCase);
            } else {
              activeCases.add(myCase);
            }
          }
        }

        if (activeCases.isNotEmpty) itemCount++;
        if (expiredCases.isNotEmpty) itemCount++;

        return itemCount != 0
            ? ListView.separated(
                controller: panelSc,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index == 0 ||
                      (activeCases.isNotEmpty &&
                          index == activeCases.length + 1)) {
                    return _buildTitle(context, activeCases, index);
                  } else {
                    return _buildTile(
                        context, activeCases, expiredCases, index);
                  }
                },
                separatorBuilder: (context, index) => index == 0 ||
                        (activeCases.isNotEmpty &&
                            index == activeCases.length + 1)
                    ? SizedBox.shrink()
                    : Divider(
                        color: Colors.grey,
                        indent: 16,
                        endIndent: 16,
                        thickness: kIsWeb ? 0.5 : null,
                      ),
              )
            : Center(
                child: Text(
                  'No cases found',
                  style: Theme.of(context).textTheme.headline6,
                ),
              );
      },
    );
  }

  Widget _buildTitle(BuildContext context, List<Case> activeCases, int index) {
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
        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: 3),
      ),
    );
  }

  Widget _buildTile(BuildContext context, List<Case> activeCases,
      List<Case> expiredCases, int index) {
    Case myCase;
    if (index < activeCases.length + 1) {
      myCase = activeCases[index - 1];
    } else {
      var offset = 1;
      if (activeCases.isNotEmpty) offset = 2;
      myCase = expiredCases[index - activeCases.length - offset];
    }

    return InkWell(
      onTap: () => CaseDialog.show(context, dialogSc, myCase),
      child: Padding(
        padding: kLayoutPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${myCase.venue}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .apply(fontWeightDelta: 1),
            ),
            WidgetPaddingSm(),
            Text(myCase.formattedDateTimes),
          ],
        ),
      ),
    );
  }
}
