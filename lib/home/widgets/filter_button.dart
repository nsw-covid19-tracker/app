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
  bool _isShowActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => MyBottomSheet.show(
        context: context,
        isShowActiveOnly: _isShowActiveOnly,
        expiryCallback: _expiryCallback,
      ),
      child: FaIcon(FontAwesomeIcons.filter, size: 20),
    );
  }

  void _expiryCallback(bool value) {
    setState(() => _isShowActiveOnly = value);
    context.bloc<HomeBloc>().add(FilterCasesByExpiry(value));
  }
}
