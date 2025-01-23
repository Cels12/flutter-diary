import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditDiaryPage extends StatefulWidget {
  final int id;
  final String initialTitle;
  final String initialContent;
  final String initialImagePath;

  const EditDiaryPage({
    Key? key,
    required this.id,
    required this.initialTitle,
    required this.initialContent,
    required this.initialImagePath,
  }) : super(key: key);

  @override
  _EditDiaryPageState createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _contentController.text = widget.initialContent;

    // Resolve the full URL for the image
    _imagePath = widget.initialImagePath.isNotEmpty
        ? Supabase.instance.client.storage
        .from('images') // Replace 'images' with your bucket name
        .getPublicUrl(widget.initialImagePath)
        : null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadResponse = await Supabase.instance.client.storage
          .from('images') // Replace 'images' with your bucket name
          .upload('uploads/$fileName', _imageFile!);

      // Ensure the upload response contains a valid key
      if (uploadResponse.isEmpty) {
        throw Exception('Image upload failed: No response received.');
      }

      // Get the public URL of the uploaded image
      final newImagePath = 'uploads/$fileName';
      _imagePath = Supabase.instance.client.storage
          .from('images') // Replace 'images' with your bucket name
          .getPublicUrl(newImagePath);

      // Update the database with the new image path
      await Supabase.instance.client.from('diaries').update({
        'image_path': newImagePath,
      }).eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateDiary() async {
    try {
      await Supabase.instance.client.from('diaries').update({
        'title': _titleController.text,
        'content': _contentController.text,
      }).eq('id', widget.id);

      if (_imageFile != null) {
        await _uploadImage(); // Upload image if a new one is selected
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 16),
            _imageFile != null
                ? Image.file(
              _imageFile!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : (_imagePath != null
                ? Image.network(
              _imagePath!,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : const Text('No image selected')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateDiary,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

