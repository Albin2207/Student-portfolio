import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studentportfolio_app/database/database_sqflite.dart';
import 'package:studentportfolio_app/database/studentmodel_database.dart';
import 'package:studentportfolio_app/screens/addstudent_screen.dart';
import 'package:studentportfolio_app/screens/home_screen.dart';


class UpdateStudentDetails extends StatefulWidget {
  const UpdateStudentDetails({
    Key? key,
    required this.id,
    required this.name,
    required this.age,
    required this.place,
    required this.number,
    required this.imageSrc,
  }) : super(key: key);

  final int id;
  final String name;
  final int age;
  final String place;
  final double number;
  final dynamic imageSrc;

  @override
  State<UpdateStudentDetails> createState() => _UpdateStudentDetailsState();
}

class _UpdateStudentDetailsState extends State<UpdateStudentDetails> {
  final formKey = GlobalKey<FormState>();
  File? selectedImage;

  late TextEditingController nameEditingController;
  late TextEditingController ageEditingController;
  late TextEditingController placeEditingController;
  late TextEditingController phoneEditingController;
  late TextEditingController idEditingController;

  @override
  void initState() {
    int phone = widget.number.toInt();
    nameEditingController = TextEditingController(text: widget.name);
    ageEditingController = TextEditingController(text: widget.age.toString());
    placeEditingController = TextEditingController(text: widget.place);
    phoneEditingController = TextEditingController(text: phone.toString());
    idEditingController = TextEditingController(text: widget.id.toString());
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        centerTitle: true,
        title:  const Text(
            "Update Student Details", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : FileImage(File(widget.imageSrc)),
                  child: Stack(children: [
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            File? pickedImage =
                                await SelectImageFromGallery(context);
                            setState(() {
                              selectedImage = pickedImage;
                            });
                          },
                          child: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 186, 186, 185),
                            child: Icon(Icons.edit),
                          ),
                        ))
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
                    } else {}
                  },
                ),
                TextformFeildWidget(
                  controller: nameEditingController,
                  prefixIcon: const Icon(Icons.person),
                  label: "Student Name",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter the Student Name";
                    } else {}
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
                    }),
                TextformFeildWidget(
                    controller: placeEditingController,
                    prefixIcon: const Icon(Icons.place),
                    label: "Place",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Student Place";
                      }
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
                        return "Invalid the Phone Number";
                      }
                    }),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedImage != null ||
                                widget.imageSrc != null) {
                              final student = StudentModel(
                                place: placeEditingController.text,
                                id: int.parse(idEditingController.text),
                                age: int.parse(ageEditingController.text),
                                name: nameEditingController.text,
                                phonenumber: phoneEditingController.text,
                                imageurl: selectedImage == null
                                    ? widget.imageSrc
                                    : selectedImage!.path,
                              );
                              await updateStudentDetailsFromDB(student);
                              nameEditingController.clear();
                              ageEditingController.clear();
                              placeEditingController.clear();
                              phoneEditingController.clear();
                              idEditingController.clear();
                              setState(() {
                                selectedImage = null;
                              });
                              snackBarFunction(
                                  context, "Upload Successfully", Colors.green);
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ));
                            } else {
                              snackBarFunction(
                                  context,
                                  "Please select student image",
                                  Colors.redAccent);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 222, 230, 231),
                          foregroundColor: Colors.blue.shade600,
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameEditingController.dispose();
    ageEditingController.dispose();
    placeEditingController.dispose();
    phoneEditingController.dispose();
    idEditingController.dispose(); // Dispose of idEditingController
    super.dispose();
  }
}
