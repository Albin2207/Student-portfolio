import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studentportfolio_app/database/database_sqflite.dart';
import 'package:studentportfolio_app/screens/addstudent_screen.dart';
import 'package:studentportfolio_app/screens/login_screen.dart';
import 'package:studentportfolio_app/screens/updatestudent_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final searchController = TextEditingController();
late List<Map<String, dynamic>> _studentsData = [];
bool _isListView = true;

class _HomeScreenState extends State<HomeScreen> {
  Future<void> fetchStudentData() async {
    List<Map<String, dynamic>> students = await getAllStudentDataFromDB();

    if (searchController.text.isNotEmpty) {
      students = students
          .where((student) => student['studentname']
              .toString()
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }
    setState(() {
      _studentsData = students;
    });
  }

  @override
  void initState() {
    fetchStudentData();
    super.initState();
  }

  void updateSearchResults(String query) {
    if (query.isEmpty) {
      fetchStudentData();
    } else {
      List<Map<String, dynamic>> filteredList = _studentsData
          .where((student) => student['studentname']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      setState(() {
        _studentsData = filteredList;
      });
    }
  }

  void toggleView() {
    setState(() {
      _isListView = !_isListView;
    });
  }

  void signOut(BuildContext context) async {
    final _sharedPrefs = await SharedPreferences.getInstance();
    await _sharedPrefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => ScreenLogin()),
      (route) => false,
    );
  }

  void signOutBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx1) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Do you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx1).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                signOut(context);
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text("List of Students", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
        centerTitle: true,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: toggleView,
            icon: Icon(_isListView ? Icons.grid_view : Icons.list),
          ),
          IconButton(
            onPressed: () {
              signOutBar(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _isListView ? _buildListView() : _buildGridView(),
      backgroundColor: Color.fromARGB(255, 147, 212, 149),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        shape: const StadiumBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddStudent(
                onStudentAdded: fetchStudentData,
              ),
            ),
          ).then((data) {
            if (data != null) {
              fetchStudentData();
              snackBarFunction(
                context,
                'Student Detail Added Successfully',
                Colors.green,
              );
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              updateSearchResults(value);
            },
          ),
          const SizedBox(height: 20),
          _studentsData.isEmpty
              ? const Center(child: Text("No students available."))
              : Expanded(
                  child: ListView.separated(
                    itemCount: _studentsData.length,
                    itemBuilder: (context, index) {
                      final student = _studentsData[index];
                      final id = student['id'];
                      final imageurl = student['imagesrc'];
                      final name = student['studentname'];
                      return ListTile(
                        title: Text(name),
                        leading: CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(File(imageurl)),
                        ),
                        subtitle: Text(id.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 207, 205, 205),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateStudentDetails(
                                        id: id,
                                        age: student['age'],
                                        name: name,
                                        place: student['place'],
                                        imageSrc: imageurl,
                                        number: student['number'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            const SizedBox(width: 15),
                            CircleAvatar(
                              backgroundColor:
                                  Color.fromARGB(255, 207, 205, 205),
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            "Delete The Student Information"),
                                        content: const Text(
                                            "Are you sure you want to delete?"),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await deleteStudentDetailsFromDB(
                                                  id);
                                              fetchStudentData();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Ok"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(color: Colors.black);
                    
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              updateSearchResults(value);
            },
          ),
          const SizedBox(height: 20),
          _studentsData.isEmpty
              ? const Center(child: Text("No students available."))
              : Expanded(
                  child: GridView.builder(
                    itemCount: _studentsData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final student = _studentsData[index];
                      final id = student['id'];
                      final imageurl = student['imagesrc'];
                      final name = student['studentname'];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GridTile(
                          footer: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: FileImage(File(imageurl)),
                              ),
                              const SizedBox(height: 10),
                              Text(id.toString()),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateStudentDetails(
                                            id: id,
                                            age: student['age'],
                                            name: name,
                                            place: student['place'],
                                            imageSrc: imageurl,
                                            number: student['number'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  const SizedBox(width: 15),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Delete The Student Information"),
                                            content: const Text(
                                                "Are you sure you want to delete?"),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await deleteStudentDetailsFromDB(
                                                      id);
                                                  fetchStudentData();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Ok"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
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
    );
  }
}
