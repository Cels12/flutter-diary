import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditDiaryPage extends StatefulWidget {
  final int id;
  final String initialTitle;
  final String initialContent;

  const EditDiaryPage({
    super.key,
    required this.id,
    required this.initialTitle,
    required this.initialContent,
  });

  @override
  _EditDiaryPageState createState() => _EditDiaryPageState();
}

class _EditDiaryPageState extends State<EditDiaryPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  Future<void> _updateDiary() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Content cannot be empty')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('diaries')
          .update({'title': title, 'content': content})
          .eq('id', widget.id)
          .select();

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary updated successfully')),
        );

        // Tunggu sedikit sebelum pop
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.pop(context, true); // Jika berhasil maka kembali ke halaman sebelumnya
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update diary')),
        );
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
      appBar: AppBar(title: const Text('Edit Diary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
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
