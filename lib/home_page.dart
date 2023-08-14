import 'package:flutter/material.dart';
import 'package:flutter_sqlflight/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _refreshJournal() async{
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournal();
    debugPrint("...number of items ${_journals.length}");
  }

  Future<void> _addItem()async{
    await SQLHelper.createItem(_titleController.text, _descriptionController.text);
    _refreshJournal();
    debugPrint("...number of items ${_journals.length}");
  }

  Future<void> _updateItem(int id)async{
    await SQLHelper.updateItem(id, _titleController.text, _descriptionController.text);
    _refreshJournal();
    debugPrint("...number of items ${_journals.length}");
  }

  void _deleteItem(int id) async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully deleted a journal')));
    _refreshJournal();
  }

  void _showForm(int? id)async{
    if(id != null){
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: MediaQuery.of(context).viewInsets.bottom +120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async{
                      if(id == null){
                        await _addItem();
                      }
                      if(id != null){
                        await _updateItem(id);
                      }
                      //Clear the textField
                      _titleController.text = '';
                      _descriptionController.text = '';
                      //Close bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null? 'Create new' : 'Update'),
                ),
              ],
            )
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()=> _showForm(null),
      ),
      body: ListView.builder(
        itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: ()=> _showForm(_journals[index]['id']),
                        icon: const Icon(Icons.edit)
                    ),
                    IconButton(
                        onPressed: ()=> _deleteItem(_journals[index]['id']),
                        icon: const Icon(Icons.delete)
                    )
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
