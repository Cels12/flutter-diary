import 'package:flutter/material.dart';

class NotePage extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String imageUrl;

  const NotePage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl, // Added imageUrl as a required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            // Display the image if the URL is not empty
            imageUrl.isNotEmpty
                ? Container(
              constraints: BoxConstraints(
                maxHeight: 300, // Limit the image height
                maxWidth: double.infinity,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Ensure the image fits properly
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            )
                : const Text('No image available'),
          ],
        ),
      ),
    );
  }
}