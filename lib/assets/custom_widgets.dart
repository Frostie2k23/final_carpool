import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String? hintText;
  final bool? readOnly;
  final PopupMenuButton<String>? popUpMenuButton;

  const MyTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    this.hintText,
    this.readOnly,
    this.popUpMenuButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent),
        ),
        child: TextField(
          cursorColor: Colors.black,
          readOnly: readOnly ?? false,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText ?? '',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            hintStyle: GoogleFonts.robotoSlab(),
            suffixIcon: popUpMenuButton,
          ),
          inputFormatters: [
            // prevents spacing
            NoLeadingOrTrailingSpacesFormatter(),
            RemoveMiddleSpacesFormatter(),
          ],
          obscureText: obscureText,
          obscuringCharacter: '*',
          controller: controller,
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  const MyButton({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red,
      ),
      child: Center(
          child: Text(
        text,
        style: GoogleFonts.robotoSlab(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      )),
    );
  }
}

class MyText extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;

  const MyText({
    super.key,
    required this.text,
    required this.color,
    required this.fontWeight,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.robotoSlab(
          color: color, fontWeight: fontWeight, fontSize: fontSize),
    );
  }
}

class MyImage extends StatelessWidget {
  final String filepath;
  final double height;
  const MyImage({super.key, required this.filepath, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
      ),
      child: Image.asset(
        filepath,
        height: height,
      ),
    );
  }
}

// was giving strange issue with Global<key?
class MyTextFormField extends StatelessWidget {
  final String? hintText;
  final bool? readOnly;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final String? label;

  final bool? isNumber;

  final TextEditingController? controller;
  final AutovalidateMode? autoValidateMode;
  final Function(String?)? onSave;
  final IconButton? iconButton;
  final PopupMenuButton<String>? popUpMenuButton;

  const MyTextFormField({
    super.key,
    required this.validator,
    required this.obscureText,
    this.label,
    this.hintText,
    this.controller,
    this.autoValidateMode,
    this.onSave,
    this.iconButton,
    this.readOnly,
    this.isNumber,
    this.popUpMenuButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
              : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent),
            ),
            child: TextFormField(
              keyboardType:
                  isNumber == true ? TextInputType.number : TextInputType.text,
              readOnly: readOnly ?? false,
              controller: controller,
              style: GoogleFonts.robotoSlab(),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText ?? '',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                hintStyle: GoogleFonts.robotoSlab(),
                suffixIcon: iconButton,
              ),
              inputFormatters: [
                //NoLeadingSpacesFormatter(), // prevents spacing
                NoLeadingOrTrailingSpacesFormatter(),
                RemoveMiddleSpacesFormatter(),
                //NoSpacesFormatter(),
              ],
              validator: validator,
              obscureText: obscureText,
              obscuringCharacter: '*',
              autovalidateMode: autoValidateMode,
            ),
          ),
        ],
      ),
    );
  }
}


class MyTextFormFieldPopMenu extends StatelessWidget {
  final String? hintText;
  final bool? readOnly;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final String? label;

  final bool? isNumber;

  final TextEditingController? controller;
  final AutovalidateMode? autoValidateMode;
  final Function(String?)? onSave;
  final IconButton? iconButton;
  final PopupMenuButton<String>? popUpMenuButton;


  const MyTextFormFieldPopMenu({
    super.key,
    required this.validator,
    required this.obscureText,
    this.label,
    this.hintText,
    this.controller,
    this.autoValidateMode,
    this.onSave,
    this.iconButton,
    this.readOnly,
    this.isNumber,
    this.popUpMenuButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label != null
              ? Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent),
            ),
            child: TextFormField(
              keyboardType:
              isNumber == true ? TextInputType.number : TextInputType.text,
              readOnly: readOnly ?? false,
              controller: controller,
              style: GoogleFonts.robotoSlab(),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText ?? '',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                hintStyle: GoogleFonts.robotoSlab(),
                suffixIcon: popUpMenuButton,
              ),
              inputFormatters: [
                //NoLeadingSpacesFormatter(), // prevents spacing
                NoLeadingOrTrailingSpacesFormatter(),
                RemoveMiddleSpacesFormatter(),
                //NoSpacesFormatter(),
              ],
              validator: validator,
              obscureText: obscureText,
              obscuringCharacter: '*',
              autovalidateMode: autoValidateMode,
            ),
          ),
        ],
      ),
    );
  }
}











class NoLeadingOrTrailingSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Check and remove leading spaces.
    final trimmedText = newValue.text.trimLeft();

    // Check and remove trailing spaces.
    final trimmedTextWithoutTrailingSpaces = trimmedText.trimRight();

    if (newValue.text != trimmedTextWithoutTrailingSpaces) {
      // If leading or trailing spaces were removed, update the text value.
      return TextEditingValue(
        text: trimmedTextWithoutTrailingSpaces,
        selection: TextSelection.collapsed(
            offset: trimmedTextWithoutTrailingSpaces.length),
      );
    }
    return newValue;
  }
}

class RemoveMiddleSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(' ', ''); // Remove all spaces
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
