import 'package:flutter/material.dart';
import 'package:kelanaapp/theme.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final ButtonStyle style; // Add ButtonStyle parameter

  const PrimaryButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.style,
    // Require ButtonStyle parameter
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style, // Apply the provided style to the button
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: Text(
          buttonText,
          style: textButton.copyWith(color: kWhiteColor),
        ),
      ),
    );
  }
}
