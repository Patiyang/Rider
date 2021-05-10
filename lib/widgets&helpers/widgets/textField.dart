import 'package:flutter/material.dart';

class CustomRegisterTextField extends StatelessWidget {
  final String text;
  final bool obscure;
  final validator;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Color fillColor;
  final bool readOnly;
  final prefixIcon;
  final suffixIcon;
 
  CustomRegisterTextField(
      {this.text, this.obscure, this.validator, this.controller, this.textInputType, this.fillColor, this.readOnly, this.prefixIcon, this.suffixIcon});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: height * 0.06,
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            keyboardType: textInputType,
            readOnly: readOnly ?? false,
            controller: controller,
            validator: validator,
            obscureText: obscure ?? false,
            autofocus: false,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: false,
              fillColor: fillColor ?? Color(0xffF6F6F6),
              labelText: text,
              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final String hint;
  final iconOne;
  final iconTwo;
  final Color containerColor;
  final Color hintColor;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType textInputType;
  final TextAlign align;
  final double radius;
  final InputBorder inputBorder;
  final int maxLines;
  final validator;

  const LoginTextField(
      {Key key,
      this.hint,
      this.iconOne,
      this.iconTwo,
      this.containerColor,
      this.hintColor,
      this.controller,
      this.obscure,
      this.textInputType,
      this.align,
      this.radius,
      this.inputBorder,
      this.validator,
      this.maxLines})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
        child: TextFormField(
          maxLines: maxLines ?? 1,
          textAlign: align ?? TextAlign.start,
          keyboardType: textInputType,
          obscureText: obscure ?? false,
          validator: validator,
          controller: controller,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(radius ?? 15))),
              suffixIcon: iconTwo,
              prefixIcon: iconOne,
              labelText: hint,
              hintStyle: TextStyle(color: hintColor ?? Colors.black),
              contentPadding: EdgeInsets.only(left: 9, top: 19)),
        ),
      ),
    );
  }
}
