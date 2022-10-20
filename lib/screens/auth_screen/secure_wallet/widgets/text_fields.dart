import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';

class TextFields extends StatelessWidget {
  final List<TextEditingController>? controllers;
  final List<FocusNode>? focusNodes;
  final GlobalKey? globalKey;
  final List<int> invalidControllerIndexes;
  final bool enabled;
  final bool isReadOnly;

  const TextFields({
    Key? key,
    this.controllers,
    this.focusNodes,
    this.globalKey,
    this.invalidControllerIndexes = const [],
    this.enabled = true,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int _defaultTextFieldCount = 8;
    const int _rowsCount = 3;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 458,
            minWidth: 328,
            maxHeight: 346,
            minHeight: 248,
          ),
          child: Row(
            children: List.generate(
                _rowsCount,
                (index) => ColumnTextFields(
                      controllers: controllers,
                      focusNodes: focusNodes,
                      globalKey: globalKey,
                      columnsCount: _defaultTextFieldCount,
                      depth: index > 0 ? _defaultTextFieldCount * index : 0,
                      enabled: enabled,
                      isReadOnly: isReadOnly,
                      invalidControllerIndexes: invalidControllerIndexes,
                    )),
          ),
        ),
      ),
    );
  }
}

class ColumnTextFields extends StatefulWidget {
  final List<TextEditingController>? controllers;
  final List<FocusNode>? focusNodes;
  final GlobalKey? globalKey;
  final int? columnsCount;
  final int depth;
  final List<int> invalidControllerIndexes;
  final bool enabled;
  final bool isReadOnly;

  const ColumnTextFields({
    Key? key,
    this.controllers,
    this.focusNodes,
    this.globalKey,
    this.columnsCount,
    this.depth = 0,
    this.invalidControllerIndexes = const [],
    this.enabled = true,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<ColumnTextFields> createState() => _ColumnTextFieldsState();
}

class _ColumnTextFieldsState extends State<ColumnTextFields> {
  static List<String> mnemonic = [];
  var s = 'soul step reunion vendor rather jewel effort tonight pulse salmon drama language aware pen scrub also flag life enhance kidney health mix leader swift'.split(' ');


  @override
  void initState() {
    super.initState();
    mnemonic = List.generate(widget.controllers!.length, (index) => '');
    int i = 0;
    widget.controllers!.forEach((element) {
      element.text = s[i];
      i++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Column(
        children: List.generate(
          widget.columnsCount!,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Text(
                    (index + widget.depth + 1 < 10)
                        ? '  ${index + widget.depth + 1}.'
                        : '${index + widget.depth + 1}.',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Spacer(),
                  Expanded(
                    flex: 10,
                    child: RawKeyboardListener(
                        focusNode:
                            widget.focusNodes![(index + widget.depth).toInt()],
                        onKey: (RawKeyEvent event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
                            if (index + widget.depth ==
                                widget.controllers!.length - 1) {
                              (widget.globalKey!.currentWidget!
                                      as ElevatedButton)
                                  .onPressed!();
                            } else {
                              widget.focusNodes![
                                      (index + widget.depth + 1).toInt()]
                                  .requestFocus();
                            }
                          }
                        },
                        child: TextField(
                          readOnly: widget.isReadOnly,
                          enabled: widget.enabled,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: Theme.of(context).textTheme.headline4,
                          onChanged: (value) async {
                            mnemonic[index + widget.depth] = value;
                            var box = await Hive.openBox(HiveBoxes.client);
                            await box.put(
                                HiveNames.recoveryMnemonic, mnemonic.join(','));
                            await box.close();
                          },
                          onEditingComplete: () => index + widget.depth ==
                                  widget.controllers!.length - 1
                              ? (widget.globalKey!.currentWidget!
                                      as ElevatedButton)
                                  .onPressed!()
                              : null,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: widget.invalidControllerIndexes
                                      .contains(index + widget.depth)
                                  ? OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    )
                                  : null),
                          controller: widget.controllers![index + widget.depth],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
