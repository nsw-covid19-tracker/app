import 'package:flutter/foundation.dart';
import 'package:nsw_covid_tracker/home/common/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef ShowAllCallbackFunc = void Function(bool value);
typedef FilterDateCallbackFunc = void Function(DateTimeRange dates);
typedef SortCallbackFunc = void Function(String value);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required bool isShowAllCases,
    @required ShowAllCallbackFunc showAllCallback,
    @required DateTime startDate,
    @required DateTime endDate,
    @required FilterDateCallbackFunc filterDateCallback,
    @required String sortBy,
    @required SortCallbackFunc sortCallbackFunc,
  }) {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
            Divider(indent: 16, endIndent: 16),
            _SortListTile(sortBy: sortBy, callback: sortCallbackFunc),
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
        final dates = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020, 7, 1),
          lastDate: DateTime.now(),
        );
        if (dates != null) {
          final result = DateTimeRange(
              start: dates.start, end: dates.end.add(Duration(days: 1)));
          callback(result);
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: kLayoutPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dates', style: Theme.of(context).textTheme.subtitle1),
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

class _SortListTile extends StatelessWidget {
  final String sortBy;
  final SortCallbackFunc callback;

  const _SortListTile({Key key, @required this.sortBy, @required this.callback})
      : assert(sortBy != null),
        assert(callback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kLayoutPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sort By', style: Theme.of(context).textTheme.subtitle1),
          DropdownButton<String>(
            value: sortBy,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            onChanged: (value) {
              callback(value);
              Navigator.of(context).pop();
            },
            items: kSortOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FloatingModal extends StatelessWidget {
  final Widget child;

  const _FloatingModal({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bottomPadding = 0.0;
    var horizontal = 24.0;

    if (kIsWeb) {
      bottomPadding = 36;
    } else if (!Device.get().isIphoneX) {
      bottomPadding = 24;
    }

    final width = MediaQuery.of(context).size.width;
    if (width >= kPhoneWidth) {
      horizontal = (width - kDialogWebWidth) / 2;
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottomPadding),
        child: Material(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}
