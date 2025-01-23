import 'package:flutter/material.dart';
import 'add_diary_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'edit_diary_page.dart';
import 'note_page.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final _diaryStream = Supabase.instance.client.from('diaries').stream(primaryKey: ['id']);

  // Function to delete a diary entry
  Future<void> _deleteDiary(BuildContext context, int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to delete this diary permanently?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      try {
        final response = await Supabase.instance.client
            .from('diaries')
            .delete()
            .eq('id', id);

        if (context.mounted) {
          if (response == null || response.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diary deleted successfully')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete diary')));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 40, 49),
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color.fromARGB(255, 34, 40, 49),
        title: Center(
          child: Text(
            'My Diary',
            style: TextStyle(
              color: const Color.fromARGB(255, 238, 238, 238),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _diaryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final diaries = snapshot.data!;
          final baseUrl = 'https://yrsfburtuqqaufbilgjg.supabase.co/storage/v1/object/public/images/';

          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final diary = diaries[index];
              final title = diary['title'];
              final content = diary['content'];
              final tanggalPembuatan = diary['created_at'];
              final imagePath = diary['image_path'] ?? '';

              final formattedDate = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(tanggalPembuatan),
              );

              final fullImagePath =
              imagePath.isNotEmpty ? '$baseUrl$imagePath' : '';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 0, 173, 181),
                        const Color.fromARGB(255, 0, 222, 232),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 12,
                        spreadRadius: -12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 7),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 238, 238, 238),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 73, 73, 73),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      content,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 238, 238, 238),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.black),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDiaryPage(
                                  id: diary['id'],
                                  initialTitle: title,
                                  initialContent: content,
                                  initialImagePath: imagePath,
                                ),
                              ),
                            );

                            if (updated == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Diary updated successfully!')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm delete'),
                                  content: const Text(
                                      'Are you sure you want to delete this?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete) {
                              await _deleteDiary(context, diary['id']);
                            }
                          },
                        ),
                        imagePath.isNotEmpty
                            ? Image.network(
                          fullImagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image, size: 50),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotePage(
                            title: title,
                            content: content,
                            date: formattedDate,
                            imageUrl: fullImagePath,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 67, 73, 82),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDiaryPage()),
          );
        },
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 0, 173, 181),
          size: 40,
        ),
      ),
    );
  }
}
