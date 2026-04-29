import 'package:flutter/material.dart';
import '../../core/constants/finder_colors.dart';

class LocationAutocompleteField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Iterable<String> Function(TextEditingValue) optionsBuilder;
  final void Function(String) onSelected;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final String Function(String)? itemPrefixBuilder; // E.g., for flags

  const LocationAutocompleteField({
    super.key,
    required this.hint,
    required this.controller,
    required this.optionsBuilder,
    required this.onSelected,
    this.validator,
    this.prefixIcon,
    this.itemPrefixBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: optionsBuilder,
          onSelected: onSelected,
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
              validator: validator,
              style: const TextStyle(color: FinderColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: FinderColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: prefixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0A3D91)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0A3D91)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0A3D91), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: constraints.maxWidth,
                  margin: const EdgeInsets.only(top: 8.0),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final prefix = itemPrefixBuilder?.call(option) ?? '';
                        
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: index != options.length - 1
                                  ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (prefix.isNotEmpty) ...[
                                  Text(prefix, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: _HighlightText(
                                    text: option,
                                    query: controller.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: FinderColors.textPrimary, fontSize: 16),
      );
    }

    final String lowercaseText = text.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();
    
    if (!lowercaseText.contains(lowercaseQuery)) {
      return Text(
        text,
        style: const TextStyle(color: FinderColors.textPrimary, fontSize: 16),
      );
    }

    final int startIndex = lowercaseText.indexOf(lowercaseQuery);
    final int endIndex = startIndex + lowercaseQuery.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: FinderColors.textPrimary, fontSize: 16),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A3D91), // Highlight color
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
