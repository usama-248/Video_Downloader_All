import 'package:flutter/material.dart';

class UrlInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const UrlInput({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter video URL...',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}