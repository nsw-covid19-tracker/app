import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef ExpiryCallbackFunc = void Function(bool value);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required bool isShowActiveOnly,
    @required ExpiryCallbackFunc expiryCallback,
  }) {
    assert(context != null);
    assert(isShowActiveOnly != null);
    assert(expiryCallback != null);

    showCustomModalBottomSheet(
      context: context,
      builder: (context, scrollController) => _ModalFit(
        isShowActiveOnly: isShowActiveOnly,
        expiryCallback: expiryCallback,
      ),
      containerWidget: (context, animation, child) {
        return _FloatingModal(child: child);
      },
      expand: false,
    );
  }
}

class _ModalFit extends StatelessWidget {
  final bool isShowActiveOnly;
  final ExpiryCallbackFunc expiryCallback;

  const _ModalFit({
    Key key,
    @required this.isShowActiveOnly,
    @required this.expiryCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text('Show Active cases only'),
            value: isShowActiveOnly,
            onChanged: (value) {
              expiryCallback(value);
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
