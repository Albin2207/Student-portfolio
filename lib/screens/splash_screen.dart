import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentportfolio_app/screens/home_screen.dart';
import 'package:studentportfolio_app/screens/login_screen.dart';
import 'package:video_player/video_player.dart';

const String Savekey = 'loggedIn';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
    checkUserLoggedIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/ATT (4).mp4')
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.play();
        });
      });
  }

  Future<void> checkUserLoggedIn() async {
    final _sharedprefs = await SharedPreferences.getInstance();
    final _userLoggedIn = _sharedprefs.getBool(Savekey);
    if (_userLoggedIn == null || _userLoggedIn == false) {
      await Future.delayed(const Duration(seconds: 5));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ScreenLogin()),
      );
    } else {
      await Future.delayed(const Duration(seconds: 5));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx1) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 41, 71),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
