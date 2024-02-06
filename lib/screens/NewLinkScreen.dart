import 'package:flutter/material.dart';
import 'package:linkwarden/MyApp.dart';
import 'package:linkwarden/api.dart';
import 'package:linkwarden/components/AppDrawer.dart';
import 'package:linkwarden/screens/DashboardScreen.dart';
import 'package:provider/provider.dart';

class NewLinkScreen extends StatefulWidget {
  const NewLinkScreen({Key? key}) : super(key: key);

  @override
  NewLinkScreenState createState() => NewLinkScreenState();
}

class NewLinkScreenState extends State<NewLinkScreen> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String dropdownValueCollection = '';
  String dropdownValueTag = '';
  late Api? api;

  Future<List<List<String>>> fetchData() async {
    // Replace with your actual API calls
    var collections = await api!.get('/collections');
    List<String> collectionNames = collections['response'].map<String>((jsonItem) => jsonItem['name'].toString()).toList();
    var tags = await api!.get('/tags');
    List<String> tagNames = tags['response'].map<String>((jsonItem) => jsonItem['name'].toString()).toList();
    tagNames.insert(0, '');
    tagNames = tagNames.toSet().toList();
    dropdownValueCollection = collectionNames[0];
    return [collectionNames, tagNames];
  }

    @override
  Widget build(BuildContext context) {
    api = Provider.of<MyAppState>(context, listen: false).api;
    var userInfo = Provider.of<MyAppState>(context, listen: false).userInfo;
    var sharedText = Provider.of<MyAppState>(context, listen: false).sharedText;
    if (sharedText != '') {
      urlController.text = sharedText;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Link'),
      ),
      drawer: AppDrawer(userInfo: userInfo),
      body: FutureBuilder<List<List<String>>>(
        future: fetchData(),
        builder: (BuildContext context, AsyncSnapshot<List<List<String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            // Replace 'Collection 1', 'Collection 2', 'Collection 3' with snapshot.data[0]
            // Replace 'Tag 1', 'Tag 2', 'Tag 3' with snapshot.data[1]
            return buildForm(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget buildForm(List<List<String>> data) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL (Required)',
                  fillColor: const Color.fromARGB(255, 52, 52, 52), // Gray background
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded border
                    borderSide: BorderSide(color: Colors.grey[300]!), // Light gray border
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Optional - Leave blank to be auto-generated',
                  fillColor: const Color.fromARGB(255, 52, 52, 52), // Gray background
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded border
                    borderSide: BorderSide(color: Colors.grey[300]!), // Light gray border
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional - Leave blank to be auto-generated',
                  fillColor: const Color.fromARGB(255, 52, 52, 52), // Gray background
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded border
                    borderSide: BorderSide(color: Colors.grey[300]!), // Light gray border
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: double.infinity, // This line
                child: Text(
                  'Collection',
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 16.0, // Adjust the size as needed
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 52, 52, 52), // Gray background
                      borderRadius: BorderRadius.circular(10), // Rounded border
                      border: Border.all(color: Colors.grey[300]!), // Light gray border
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true, // Full-width
                              value: dropdownValueCollection,
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValueCollection = newValue!;
                                });
                              },
                              items: data[0]
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          color: Colors.purple,
                          onPressed: () async {
                            final TextEditingController controller = TextEditingController();
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter new collection name'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(hintText: "Collection name"),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Add'),
                                      onPressed: () {
                                        final String collectionName = controller.text.trim();
                                        if (collectionName.isNotEmpty) {
                                          setState(() {
                                            data[0].add(collectionName);
                                            dropdownValueCollection = collectionName;
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                width: double.infinity, // This line
                child: Text(
                  'Tag',
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 16.0, // Adjust the size as needed
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 52, 52, 52), // Gray background
                      borderRadius: BorderRadius.circular(10), // Rounded border
                      border: Border.all(color: Colors.grey[300]!), // Light gray border
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true, // Full-width
                              value: dropdownValueTag,
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValueTag = newValue!;
                                });
                              },
                              items: data[1]
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          color: Colors.purple,
                          onPressed: () async {
                            final TextEditingController controller = TextEditingController();
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter new tag name'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(hintText: "Tag name"),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Add'),
                                      onPressed: () {
                                        final String tagName = controller.text.trim();
                                        if (tagName.isNotEmpty) {
                                          setState(() {
                                            data[1].add(tagName);
                                            dropdownValueTag = tagName;
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(10.0),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromRGBO(102, 51, 153, 1),
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 20.0),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color.fromRGBO(167, 139, 250, 1)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    addLink(
                      urlController.text,
                      nameController.text,
                      descriptionController.text,
                      dropdownValueCollection,
                      dropdownValueTag,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Create Link'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void addLink(String url, String name, String description, String collection, String tag) {
    var userInfo = Provider.of<MyAppState>(context, listen: false).userInfo;
    var tags = <Map<String, String>>[];
    if (tag != '') {
      tags.add({'name': tag});
    }
    api!.post('/links', {
      'type': 'url',
      'url': url,
      'name': name,
      'description': description,
      'collection': {'name': collection, 'ownerId': userInfo.id},
      'tags': tags,
      'image': '',
      'pdf': '',
      'preview': '',
      'readable': '',
      'textContent': '',
    }).then((Map value) {
      // if the response has an id, then the link was added successfully
      if (value['response']['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link added successfully'),
          ),
        );
        // Navigate back to the dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (Route<dynamic> route) => false, // Never allow back navigation
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error adding link'),
          ),
        );
      }
    });
  }
}
