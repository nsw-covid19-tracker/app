import 'package:covid_tracing/home/common/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef ShowAllCallbackFunc = void Function(bool value);
typedef FilterDateCallbackFunc = void Function(DateTime start, DateTime end);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required bool isShowAllCases,
    @required ShowAllCallbackFunc showAllCallback,
    @required DateTime startDate,
    @required DateTime endDate,
    @required FilterDateCallbackFunc filterDateCallback,
  }) {
    showCustomModalBottomSheet(
      context: context,
      builder: (context, scrollController) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show all cases'),
              value: isShowAllCases,
              onChanged: (value) {
                showAllCallback(value);
                Navigator.of(context).pop();
              },
            ),
            Divider(indent: 16, endIndent: 16),
            _DateListTile(
              start: startDate,
              end: endDate,
              callback: filterDateCallback,
            ),
          ],
        ),
      ),
      containerWidget: (context, animation, child) {
        return _FloatingModal(child: child);
      },
      expand: false,
    );
  }
}

class _DateListTile extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final FilterDateCallbackFunc callback;

  const _DateListTile({
    Key key,
    @required this.start,
    @required this.end,
    @required this.callback,
  })  : assert(start != null),
        assert(end != null),
        assert(callback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('E d MMM, y');

    return InkWell(
      onTap: () async {
        final dateTimeRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020, 7, 1),
          lastDate: DateTime.now(),
        );
        if (dateTimeRange != null) {
          callback(dateTimeRange.start, dateTimeRange.end);
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: kLayoutPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dates'),
            Column(
              children: [
                Text(dateFormat.format(start)),
                Text(dateFormat.format(end)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _FloatingModal extends StatelessWidget {
  final Widget child;

  const _FloatingModal({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = Device.get().isIphoneX ? 0.0 : 20.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, bottomPadding),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}
