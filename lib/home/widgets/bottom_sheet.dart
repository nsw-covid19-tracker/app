import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef ShowAllCallbackFunc = void Function(bool value);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required bool isShowAllCases,
    @required ShowAllCallbackFunc showAllCallback,
  }) {
    assert(context != null);
    assert(isShowAllCases != null);
    assert(showAllCallback != null);

    showCustomModalBottomSheet(
      context: context,
      builder: (context, scrollController) => _ModalFit(
        isShowAllCases: isShowAllCases,
        showAllCallback: showAllCallback,
      ),
      containerWidget: (context, animation, child) {
        return _FloatingModal(child: child);
      },
      expand: false,
    );
  }
}

class _ModalFit extends StatelessWidget {
  final bool isShowAllCases;
  final ShowAllCallbackFunc showAllCallback;

  const _ModalFit({
    Key key,
    @required this.isShowAllCases,
    @required this.showAllCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
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
          )
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
