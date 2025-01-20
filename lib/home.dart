import 'package:flutter/material.dart';
import 'add_diary_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'edit_diary_page.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final _diaryStream =
  Supabase.instance.client.from('diaries').stream(primaryKey: ['id']);

  //fungsi hapus diary
  Future<void> _deleteDiary(BuildContext context, int id) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah kamu yakin ingin menghapus?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false jika dibatalkan
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true jika hapus
              },
            ),
          ],
        );
      },
    );

    // jika delete di eksekusi
    if (confirmDelete) {
      try {
        final response = await Supabase.instance.client
            .from('diaries')
            .delete()
            .eq('id', id);

        if (context.mounted) {
          if (response == null || response.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diary berhasil di hapus')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diary gagal di hapus')));
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
      appBar: AppBar(
        title: const Text('Diary'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _diaryStream,
        builder: (context, snapshot) {
          //loading...
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //loaded
          final diaries = snapshot.data!;

          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final diary = diaries[index];
              final title = diary['title'];
              final content = diary['content'];
              final tanggal_pembuatan = diary['created_at'];

              final formattedDate = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(tanggal_pembuatan),
              );

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                subtitle: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditDiaryPage(
                              id: diary['id'],
                              initialTitle: title,
                              initialContent: content,
                            ),
                          ),
                        );

                        // Refresh UI if diary is updated
                        if (updated == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Diary updated successfully!')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this diary?'),
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
                          await _deleteDiary(context, diary['id']);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDiaryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}