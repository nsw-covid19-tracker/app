import 'package:covid_tracing/home/bloc/home_bloc.dart';
import 'package:covid_tracing/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterButton extends StatefulWidget {
  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  bool _isShowAllCases = false;
  DateTime _startDate = DateTime(2020, 7, 1);
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => MyBottomSheet.show(
        context: context,
        isShowAllCases: _isShowAllCases,
        showAllCallback: _setIsShowAllCases,
        startDate: _startDate,
        endDate: _endDate,
        filterDateCallback: _setStartEndDates,
      ),
      child: FaIcon(FontAwesomeIcons.filter, size: 20),
    );
  }

  void _setIsShowAllCases(bool value) {
    setState(() => _isShowAllCases = value);
    context.bloc<HomeBloc>().add(FilterCasesByExpiry(value));
  }

  void _setStartEndDates(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }
}
