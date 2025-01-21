import 'package:flutter/material.dart';
import 'add_diary_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'edit_diary_page.dart  ';
import 'note_page.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final _diaryStream =
  Supabase.instance.client.from('diaries').stream(primaryKey: ['id']);

  //fungsi hapus diary
  Future<void> _deleteDiary(BuildContext context, int id) async {
    // Dialog konfirmasi pertama
    bool confirmDelete = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Diary akan dihapus permanen?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false jika dibatalkan
              },
            ),
            TextButton(
              child: const Text('Tetap hapus'),
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
      backgroundColor: Color.fromARGB(255, 34, 40, 49),
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Color.fromARGB(255, 34, 40, 49),
        title: Center(
            child: Text('My Diary',
              style: TextStyle(
                color: Color.fromARGB(255, 238, 238, 238),
              ),
            ),
        ),
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

          //Kalo di PHP ini readnya
          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final diary = diaries[index];
              final title = diary['title'];
              final content = diary['content'];
              final tanggalPembuatan = diary['created_at'];

              //Tampil tanggal, menggunakan package intl
              final formattedDate = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(tanggalPembuatan),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 173, 181),
                        Color.fromARGB(255, 0, 222, 232),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 12,
                        spreadRadius: -12,
                        offset: Offset(0, 4),
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
                                  title: const Text('Konfirmasi hapus'),
                                  content: const Text(
                                      'Apakah kamu yakin ingin menghapus?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Tidak'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Ya'),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotePage(
                            title: title,
                            content: content,
                            date: formattedDate,
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

      //button add diary
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 67, 73, 82),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDiaryPage()),
          );
        },
        child: const Icon(Icons.add,
          color: Color.fromARGB(255, 0, 173, 181),
          size: 40,

        ),
      ),
    );
  }
}