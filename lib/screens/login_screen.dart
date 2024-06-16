import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentportfolio_app/main.dart';
import 'package:studentportfolio_app/screens/home_screen.dart';


class ScreenLogin  extends StatefulWidget {
   ScreenLogin ({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
 final _usernameController = TextEditingController();

 final _passwordController = TextEditingController();

// bool _isDataMatched = true;

 final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Username'
                    ),
                     validator: (value){
                  if(value==null||value.isEmpty)
                  {
                      return 'Enter Username';
                  }else{
                    return null;
                  }
                }),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password'
                  ),
                 validator: (value){
                   if(value==null||value.isEmpty)
                  {
                      return 'Enter Password';
                  }else{
                    return null;
                  }
                 }, 
                ),
                const SizedBox(
                  height: 20,
                  ),
                  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Visibility(
                      child: Text("Enter Both Same",
                       style: TextStyle(color: Colors.blue),),
                    ),
                    ElevatedButton.icon(
                    
                    onPressed: (){
                      if(_formkey.currentState!.validate())
                      {
                         checkLogin(context);
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Login'
                    ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void checkLogin(BuildContext ctx)async{
  final _username = _usernameController.text;
  final _password = _passwordController.text;
  if(_username !=_password)
  {
    final _errorMessage= "Username Password Dosen't Match";
   showDialog(context: ctx, builder: (ctx1){
    return AlertDialog(
      title: const Text('Error'),
    content: Text(_errorMessage),
    actions: [
      TextButton(
      onPressed: (){
        Navigator.of(ctx1).pop();
      }, child: const Text('Close'),
      )
    ],
    ); 
   });
  }
  else{
  final _sharedprefs = await SharedPreferences.getInstance();
  await _sharedprefs.setBool(Savekey, true);

   Navigator.of(ctx).pushReplacement(
     MaterialPageRoute(builder: (ctx1)=>const HomeScreen())
    );
  }
 
}
}