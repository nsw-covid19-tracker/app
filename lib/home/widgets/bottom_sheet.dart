import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

typedef CallbackFunc = void Function(String string);

class MyBottomSheet {
  static void show({
    @required BuildContext context,
    @required List<String> options,
    @required CallbackFunc callback,
    String selected,
  }) {
    assert(context != null);
    assert(options != null);
    assert(callback != null);

    showCustomModalBottomSheet(
      context: context,
      builder: (context, scrollController) => _ModalFit(
        selected: selected,
        options: options,
        callback: callback,
      ),
      containerWidget: (context, animation, child) {
        return FloatingModal(child: child);
      },
      expand: false,
    );
  }
}

class _ModalFit extends StatelessWidget {
  final String selected;
  final List<String> options;
  final CallbackFunc callback;

  const _ModalFit({
    Key key,
    @required this.options,
    @required this.callback,
    this.selected,
  })  : assert(options != null),
        assert(callback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: ListView(
            shrinkWrap: true,
            children: options.map<Widget>((String option) {
              final isSelected = option == selected;

              return _OptionTile(
                option: option,
                isSelected: isSelected,
                callback: callback,
              );
            }).toList()),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final Function callback;

  const _OptionTile({
    Key key,
    @required this.option,
    @required this.isSelected,
    @required this.callback,
  })  : assert(option != null),
        assert(isSelected != null),
        assert(callback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.w300;

    return ListTile(
      title: Text(option, style: TextStyle(fontWeight: fontWeight)),
      onTap: () {
        callback(option);
        Navigator.of(context).pop();
      },
    );
  }
}

class FloatingModal extends StatelessWidget {
  final Widget child;

  const FloatingModal({Key key, this.child}) : super(key: key);

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
