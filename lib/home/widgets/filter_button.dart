import 'package:nsw_covid_tracker/home/bloc/home_bloc.dart';
import 'package:nsw_covid_tracker/home/common/consts.dart';
import 'package:nsw_covid_tracker/home/widgets/widgets.dart';
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
  String _sortBy = kAlphabetically;
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = context.bloc<HomeBloc>();
  }

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
        sortBy: _sortBy,
        sortCallbackFunc: _setSortBy,
      ),
      child: FaIcon(FontAwesomeIcons.filter, size: 20),
    );
  }

  void _setIsShowAllCases(bool value) {
    setState(() => _isShowAllCases = value);
    _homeBloc.add(FilterCasesByExpiry(value));
  }

  void _setStartEndDates(DateTimeRange dates) {
    setState(() {
      _startDate = dates.start;
      _endDate = dates.end;
    });
    _homeBloc.add(FilterCasesByDates(dates));
  }

  void _setSortBy(String value) {
    setState(() => _sortBy = value);
    _homeBloc.add(SortCases(value));
  }
}
