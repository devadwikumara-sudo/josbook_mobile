import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';

class KotakOtp extends StatefulWidget {
  const KotakOtp({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<KotakOtp> createState() => _KotakOtpState();
}

class _KotakOtpState extends State<KotakOtp> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _ubah(int index, String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      final List<String> digitTempel = digits.split('');
      for (int i = index; i < _controllers.length; i++) {
        final int indexDigit = i - index;
        final String digit = indexDigit < digitTempel.length
            ? digitTempel[indexDigit]
            : '';
        _setDigit(i, digit);
      }

      final int fokusBerikutnya = (index + digitTempel.length).clamp(
        0,
        _focusNodes.length - 1,
      );
      _focusNodes[fokusBerikutnya].requestFocus();
    } else {
      _setDigit(index, digits);
      if (digits.isNotEmpty && index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    widget.onChanged(_controllers.map((controller) => controller.text).join());
    setState(() {});
  }

  void _setDigit(int index, String digit) {
    _controllers[index].value = TextEditingValue(
      text: digit,
      selection: TextSelection.collapsed(offset: digit.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(_controllers.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              autofocus: index == 0,
              keyboardType: TextInputType.number,
              textInputAction: index == _controllers.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: WarnaJosBook.navy,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: WarnaJosBook.navy.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: WarnaJosBook.biru,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) => _ubah(index, value),
            ),
          ),
        );
      }),
    );
  }
}
