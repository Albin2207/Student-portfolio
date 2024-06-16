import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studentportfolio_app/database/studentmodel_database.dart';
import 'package:studentportfolio_app/screens/addstudent_screen.dart';





late Database _database;
Future<void> initializeDatabase() async {
  _database = await openDatabase("student.db", version: 1,
      onCreate: (Database database, int version) async {
    await database.execute(
        'CREATE TABLE student (id INTEGER PRIMARY KEY, studentname TEXT, age INTEGER, place TEXT, number REAL, imagesrc)');
  });
}



Future<void> addStudentToDB(StudentModel value, BuildContext context) async {
  final existingRecord = await _database.query(
    'student',
    where: 'id = ?',
    whereArgs: [value.id],
  );
  if (existingRecord.isEmpty) {
    //await _database.insert(table, values, conflictAlgorithm: Confli);
    await _database.rawInsert(
        "INSERT INTO student(id, studentname, age, place, number, imagesrc) VALUES(?,?,?,?,?,?)",
        [
          value.id,
          value.name,
          value.age,
          value.place,
          value.phonenumber,
          value.imageurl
        ]);
    snackBarFunction(
        context, "The Student Details are upload successfully", Colors.green);
  } else {
    snackBarFunction(
        context, "The Student Id is also present in the database", Colors.red);
  }
}

Future<List<Map<String, dynamic>>> getAllStudentDataFromDB() async {
  final _value = await _database.rawQuery("SELECT * FROM student");
  return _value;
}

Future<void> deleteStudentDetailsFromDB(int id) async {
  await _database.rawDelete('DELETE FROM student WHERE id = ?', [id]);
}

Future<void> updateStudentDetailsFromDB(StudentModel updatedStudent) async {
  await _database.update(
      'student',
      {
        'id': updatedStudent.id,
        'studentname': updatedStudent.name,
        'age': updatedStudent.age,
        'place': updatedStudent.place,
        'number': updatedStudent.phonenumber,
        'imagesrc': updatedStudent.imageurl,
      },
      where: 'id = ?',
      whereArgs: [updatedStudent.id]);
}
