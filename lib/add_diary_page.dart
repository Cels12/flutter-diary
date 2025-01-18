import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddDiaryPage extends StatefulWidget {
  @override
  _AddDiaryPageState createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _addDiary() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Content cannot be empty')),
      );
      return;
    }

    try {
      // Kirim data ke Supabase
      final response = await Supabase.instance.client
          .from('diaries')
          .insert({'title': title, 'content': content})
          .select();

      // Cek jika data berhasil ditambahkan
      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diary added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Tangani error jika ada masalah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Diary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ElevatedButton(
              onPressed: _addDiary,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
