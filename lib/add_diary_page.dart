import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});

  @override
  _AddDiaryPageState createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  File? _imageFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  //pick image
  Future pickImage() async {
    //picker
    final ImagePicker picker = ImagePicker();

    //pick from gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    //update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  //upload
  Future<String?> uploadImage() async {
    if (_imageFile == null) return null;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    try {
      await Supabase.instance.client.storage.from('images').upload(path, _imageFile!);
      return path; // Return the uploaded image path
    } catch (e) {
      // Handle errors during upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
      return null;
    }
  }


  Future<void> _addDiary(String? imagePath) async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Content cannot be empty')),
      );
      return;
    }

    try {
      // Insert diary data into Supabase
      final response = await Supabase.instance.client
          .from('diaries')
          .insert({
        'title': title,
        'content': content,
        'image_path': imagePath, // Save image path if available
      })
          .select();

      // Feedback to user
      if (context.mounted) {
        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diary added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add diary')),
          );
        }
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  Future<void> _saveDiary() async {
    final imagePath = await uploadImage();
    await _addDiary(imagePath);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Diary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show selected image with size constraints
            _imageFile != null
                ? Container(
              constraints: BoxConstraints(
                maxHeight: 100, // max height
                maxWidth: double.infinity, // Full width
              ),
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              ),
            )
                : const Text('No image selected...'),
            ElevatedButton(
                onPressed: pickImage,
                child: const Text('Pick Image')
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            //button save diary
            ElevatedButton(
              onPressed: _saveDiary,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}