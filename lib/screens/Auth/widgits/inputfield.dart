import 'package:flutter/material.dart';

class Inputfield extends StatefulWidget {
  final String lable;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  const Inputfield({
    required this.lable,
    required this.obscureText,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    super.key,
  });

  @override
  State<Inputfield> createState() => _InputfieldState();
}

class _InputfieldState extends State<Inputfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: TextFormField(
        textInputAction: widget.textInputAction,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        cursorColor: Color(0xFFFFFFFF),
        obscureText: _obscureText,
        style: TextStyle(
          color: Color(0xFFFFFFFF),
        ),
        decoration: InputDecoration(
          labelText: widget.lable,
          labelStyle: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFFFFFFF),
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFFFFFFF),
            ),
          ),
          // Add suffix icon only for password fields
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}