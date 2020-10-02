import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef ExpiryCallbackFunc = void Function(bool value);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required bool isShowNotExpiredOnly,
    @required ExpiryCallbackFunc expiryCallback,
  }) {
    assert(context != null);
    assert(isShowNotExpiredOnly != null);
    assert(expiryCallback != null);

    showCustomModalBottomSheet(
      context: context,
      builder: (context, scrollController) => _ModalFit(
        isShowNotExpiredOnly: isShowNotExpiredOnly,
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
  final bool isShowNotExpiredOnly;
  final ExpiryCallbackFunc expiryCallback;

  const _ModalFit({
    Key key,
    @required this.isShowNotExpiredOnly,
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
            title: const Text('Show not expired cases only'),
            value: isShowNotExpiredOnly,
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
