
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class SettingsColor extends StatefulWidget {
  const SettingsColor({
    super.key,
    required this.title,
    required this.pref,
    this.afterChange,
  });

  final String title;
  final IPref<int, dynamic> pref;
  final ValueChanged<Color?>? afterChange;

  @override
  State<SettingsColor> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsColor> {
  Color? get color => widget.pref.value == 0 ? null : Color(widget.pref.value);
  static Color defaultColor = Colors.yellow;

  @override
  void initState() {
    widget.pref.addListener(onChanged);
    super.initState();
  }

  void onChanged() {
    Color? color = this.color;
    if (color != null) {
      defaultColor = color;
    }
    widget.afterChange?.call(color);
    setState(() { });
  }

  get colorPickerDialog => AlertDialog(
    title: Text(t.settings.accentColorPicker.pickAColor),
    content: SingleChildScrollView(
      child: ColorPicker(
        pickerColor: color ?? defaultColor,
        onColorChanged: (Color color) {
          Prefs.accentColor.value = color.value;
        },
      ),
    ),
    actions: <Widget>[
      ElevatedButton(
        child: Text(t.settings.accentColorPicker.confirm),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title, style: const TextStyle(fontSize: 14)),
      subtitle: kDebugMode ? Text(widget.pref.key) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: color != null,
            onChanged: (bool? value) {
              if (value == null) return;
              widget.pref.value = value ? defaultColor.value : 0;
            },
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color ?? defaultColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => colorPickerDialog,
        );
      },
    );
  }

  @override
  void dispose() {
    widget.pref.removeListener(onChanged);
    super.dispose();
  }
}
