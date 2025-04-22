import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/story.dart';

late Isar isar;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<Story> storys = [];

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([StorySchema], directory: dir.path);
    fetchStories();
  }

  Future<void> fetchStories() async {
    final items = await isar.storys.where().findAll();
    setState(() => storys = items);
  }

  /*Future<void> addOrEditStory() async {
    final newItem = Story()
      ..title = _titleController.text
      ..description = _titleController.text
      ..imageURL = _imageController.text;

    if (newItem.title.isEmpty || newItem.imageURL.isEmpty || newItem.description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all the information')),
      );
      return;
    }

    await isar.writeTxn(() async => await isar.storys.put(newItem));
    _titleController.clear();
    _descriptionController.clear();
    _imageController.clear();
    fetchStories();
  }*/

  void _addOrEditStory({
    Story? story,
  }) {
    TextEditingController _descriptionController = TextEditingController(
      text: story?.description ?? "",
    );

    TextEditingController _titleController = TextEditingController(
      text: story?.title ?? "",
    );

    TextEditingController _imageController = TextEditingController(
      text: story?.imageURL ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(story != null ? "Edit Story": "Add Story"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Title'
                ),
              ),
              TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Story'
                ),
              ),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                    labelText: 'Image URL'
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text ('Cancel')
            ),
            TextButton(
              onPressed: () async {
                if (_descriptionController.text.isNotEmpty) {
                  late Story newStory;
                  if(story != null) {
                    newStory = story.copyWith(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      imageURL: _imageController.text,
                    );
                  }else{
                    newStory = Story().copyWith(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      imageURL: _imageController.text,
                    );
                  }
                  await isar.writeTxn(() async => await isar.storys.put(newStory));

                  Navigator.pop(context);
                }
              },
              child: const Text ('Save'),
            ),
          ],
        );
      },
    );
    fetchStories();
  }


  Future<void> deleteStory(int id) async {
    await isar.writeTxn(() async => await isar.storys.delete(id));
    fetchStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text('StoryBase'),
          backgroundColor: Colors.yellow,
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            SizedBox(height: 10),
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("../images/background.jpeg"),
                  fit: BoxFit.cover,),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: storys.length,
                itemBuilder: (context, index) {
                  final item = storys[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(item.imageURL, width: 50),
                      title: Text(item.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed: () {
                              _addOrEditStory(
                                story: item,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => deleteStory(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOrEditStory,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
