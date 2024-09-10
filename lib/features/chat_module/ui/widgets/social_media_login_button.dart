import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialMediaLoginButton extends StatelessWidget {
  const SocialMediaLoginButton(
      {super.key, required this.labelText, required this.labelLogo});

  final String labelText;
  final String labelLogo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          height: 52,
          width: 196,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(labelLogo),
                const SizedBox(width: 10),
                Text(
                  labelText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    height: 27 / 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
