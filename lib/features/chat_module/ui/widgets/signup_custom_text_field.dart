import 'package:flutter/material.dart';

class SignUpCustomTextField extends StatefulWidget {
  const SignUpCustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPasswordField = false,
  });

  final TextEditingController controller;
  final String labelText;
  final bool isPasswordField;

  @override
  State<SignUpCustomTextField> createState() => _SignUpCustomTextFieldState();
}

class _SignUpCustomTextFieldState extends State<SignUpCustomTextField> {
  late bool obscureText = widget.isPasswordField;

  void toggleObsureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.labelText,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                height: 25 / 20,
              ),
            ),
            if (widget.isPasswordField)
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  splashColor: const Color(0x10CCCCCC),
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        height: 25 / 20,
                        color: Color(0XFF0098FF),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: TextField(
            controller: widget.controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 16, height: 20 / 20),
            decoration: InputDecoration(
              suffixIcon: widget.isPasswordField
                  ? GestureDetector(
                      onTap: toggleObsureText,
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: obscureText
                            ? const Color.fromARGB(255, 122, 121, 121)
                            : const Color(0XFF0098FF),
                      ),
                    )
                  : null,
              fillColor: const Color(0xff333333),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusColor: Colors.white54,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
