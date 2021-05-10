import 'package:delivery_boy/constant/constant.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final leading;
  final title;
  final subtitle;
  final trailing;
  final double radius;
  final Color color;
  final VoidCallback callback;

  const CustomListTile({Key key, this.leading, this.title, this.subtitle, this.trailing, this.radius, this.color, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(onTap: callback,
      tileColor: color ?? whiteColor,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 13))),
    );
  }
}
