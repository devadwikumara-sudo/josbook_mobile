import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../auth/auth_warna.dart';

/// Kolom input dengan label di atasnya. Bila [sandi] true, teks disembunyikan
/// secara default dan ada ikon mata untuk menampilkan/menyembunyikan.
class FieldAuth extends StatefulWidget {
  const FieldAuth({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.sandi = false,
    this.adaError = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool sandi;
  final bool adaError;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<FieldAuth> createState() => _FieldAuthState();
}

class _FieldAuthState extends State<FieldAuth> {
  late bool _sembunyikan = widget.sandi;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: WarnaJosBook.teks,
            ),
          ),
        ),
        TextField(
          controller: widget.controller,
          obscureText: _sembunyikan,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autocorrect: false,
          enableSuggestions: !widget.sandi,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AuthWarna.teksPudar),
            filled: true,
            fillColor: widget.adaError ? AuthWarna.latarError : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: widget.adaError
                  ? const BorderSide(color: WarnaJosBook.merah, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: widget.adaError ? WarnaJosBook.merah : WarnaJosBook.biru,
                width: 1.5,
              ),
            ),
            suffixIcon: widget.sandi
                ? IconButton(
                    tooltip: _sembunyikan
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    icon: Icon(_sembunyikan
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _sembunyikan = !_sembunyikan),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}