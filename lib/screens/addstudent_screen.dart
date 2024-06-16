import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studentportfolio_app/database/database_sqflite.dart';
import 'package:studentportfolio_app/database/studentmodel_database.dart';


class AddStudent extends StatefulWidget {
  final Function onStudentAdded;

  const AddStudent({super.key, required this.onStudentAdded});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

final formKey = GlobalKey<FormState>();
File? selectedImage;

final nameEditingController = TextEditingController();
final ageEditingController = TextEditingController();
final placeEditingController = TextEditingController();
final phoneEditingController = TextEditingController();
final idEditingController = TextEditingController();

class _AddStudentState extends State<AddStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: const Text(
          "Add Student",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                  child: Stack(children: [
                    Positioned(
                      left: 50,
                      top: 50,
                      child: selectedImage == null
                          ? const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 245, 245, 245),
                              size: 60,
                            )
                          : const Icon(null),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () async {
                          File? pickedImage = await SelectImageFromGallery(context);
                          setState(() {
                            selectedImage = pickedImage;
                          });
                        },
                        child: const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 193, 193, 194),
                          child: Icon(Icons.camera_alt),
                        ),
                      ),
                    )
                  ]),
                ),
                const SizedBox(height: 40),
                TextformFeildWidget(
                  keyboardtype: TextInputType.number,
                  controller: idEditingController,
                  prefixIcon: const Icon(Icons.person),
                  label: "Student ID",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter the Student ID";
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Please Enter a Valid Student ID (Numbers Only)";
                    }
                    return null;
                  },
                ),
                TextformFeildWidget(
                  controller: nameEditingController,
                  prefixIcon: const Icon(Icons.person),
                  label: "Student Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter the Student Name";
                    }
                    return null;
                  },
                ),
                TextformFeildWidget(
                    controller: ageEditingController,
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    keyboardtype: TextInputType.number,
                    label: "Age",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Student Age";
                      } else if (value.length > 2) {
                        return "Invalid Student Age";
                      }
                      return null;
                    }),
                TextformFeildWidget(
                    controller: placeEditingController,
                    prefixIcon: const Icon(Icons.place),
                    label: "Place",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Student Place";
                      }
                      return null;
                    }),
                TextformFeildWidget(
                    controller: phoneEditingController,
                    prefixIcon: const Icon(Icons.phone),
                    keyboardtype: TextInputType.number,
                    label: "Phone Number",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Phone Number";
                      } else if (value.length == 10) {
                        return null;
                      } else {
                        return "Invalid Phone Number";
                      }
                    }),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedImage != null) {
                              final student = StudentModel(
                                place: placeEditingController.text,
                                id: int.parse(idEditingController.text),
                                age: int.parse(ageEditingController.text),
                                name: nameEditingController.text,
                                phonenumber: phoneEditingController.text,
                                imageurl: selectedImage!.path,
                              );
                              await addStudentToDB(student, context);
                              nameEditingController.clear();
                              ageEditingController.clear();
                              placeEditingController.clear();
                              phoneEditingController.clear();
                              idEditingController.clear();
                              setState(() {
                                selectedImage = null;
                              });
                              widget.onStudentAdded(); // Call the callback function
                            } else {
                              snackBarFunction(
                                  context,
                                  "Please select student image",
                                  const Color.fromARGB(255, 206, 196, 196));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 222, 230, 231),
                          foregroundColor: Colors.blue.shade600,
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color.fromARGB(255, 222, 230, 231), width: 2.5)),
                      onPressed: () {
                        nameEditingController.clear();
                        ageEditingController.clear();
                        placeEditingController.clear();
                        phoneEditingController.clear();
                        idEditingController.clear();
                        setState(() {
                          selectedImage = null;
                        });
                      },
                      child: const Text("Clear",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextformFeildWidget extends StatelessWidget {
  const TextformFeildWidget({
    super.key,
    required this.label,
    required this.validator,
    this.keyboardtype,
    required this.prefixIcon,
    required this.controller,
  });
  final String label;
  final TextInputType? keyboardtype;
  final String? Function(String?)? validator;
  final Icon prefixIcon;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardtype,
          validator: validator,
          decoration: InputDecoration(
              prefixIcon: prefixIcon,
              label: Text(label),
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}

Future<File?> SelectImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    __showSnackBar(context, e.toString());
  }
  return image;
}

void __showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void snackBarFunction(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    backgroundColor: color,
  ));
}
