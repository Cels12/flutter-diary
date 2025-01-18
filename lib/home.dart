import 'package:flutter/material.dart';
import 'add_diary_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Home extends StatelessWidget {
  Home({super.key});

  final _diaryStream =
    Supabase.instance.client.from('diaries').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
      ),
      body: StreamBuilder<List<Map<String,dynamic>>>(
          stream: _diaryStream,
          builder: (context, snapshot){
            //loading...
            if(!snapshot.hasData){
              return const Center(child: CircularProgressIndicator(),);
            }
            //loaded
            final diaries = snapshot.data!;

            return ListView.builder(
              itemCount: diaries.length,
              itemBuilder: (context, index){
                final diary = diaries[index];
                final title = diary['title'];
                final content = diary['content'];

                return ListTile(
                  title: Text(title),
                  subtitle: Text(content),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
