import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShowAd extends StatefulWidget {
  @override
  _ShowAdState createState() => _ShowAdState();
}

class _ShowAdState extends State<ShowAd> {
  VideoPlayerController _controller;
  int _life = 5;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );

    _controller.setLooping(true);
    _controller.initialize().then((value) async {
      print("Initialized !");
      await _controller.play();
      setState(() {
        _life = 5;
        _loaded = true;
      });
      Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          _life = _life - 1;
        });
        if (_life <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
              title: Text("Premature Skip"),
              content: Text(
                  "To view the content, please watch the ad for atleast 5 seconds!"),
              actions: [])),
      child: Scaffold(
        backgroundColor: Color(0xffb282a36),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _life <= 0
                  ? RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Color(0xffbbd93f9),
                      child: Text(
                        'Skip Ad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffbf8f8f2),
                        ),
                      ),
                    )
                  : (_loaded
                      ? Text(
                          'Skip Ad in $_life seconds.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xffbf8f8f2),
                          ),
                        )
                      : SizedBox()),
              Container(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      ClosedCaption(text: _controller.value.caption.text),
                      VideoProgressIndicator(_controller,
                          allowScrubbing: false),
                    ],
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {},
                color: Color(0xffbbd93f9),
                child: Text(
                  'Visit Ad',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xffbf8f8f2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
