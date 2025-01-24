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
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(238, 238, 238, 238)
            ),
        ),
        title: const Text(
          'Diary',
          style: TextStyle(color: Color.fromARGB(255, 238, 238, 238),
            fontSize: 30
          ),
        ),

        //ini buat appbar color
        backgroundColor: const Color.fromARGB(255, 34, 40, 49),

      ),

      //background color untuk keseluruhan appnya
      backgroundColor: const Color.fromARGB(255, 34, 40, 49),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 238, 238, 238),
              ),
            ),
            const SizedBox(height: 8),

            // Date
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 149, 149, 149),
              ),
            ),
            const SizedBox(height: 16),

            // Boxed Content with Image
            Container(
              height: 650,
              width: 570,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 173, 181),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content Text
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 238, 238, 238),
                    ),
                    maxLines: 6, // Limit text to 6 lines
                    overflow: TextOverflow.ellipsis, // Add ellipses for overflow
                  ),
                  const SizedBox(height: 16),

                  // Image (if URL is provided)
                  if (imageUrl.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 150, // max height
                        maxWidth: double.infinity, // Full width
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}