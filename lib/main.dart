import 'dart:math';
import 'package:flutter/material.dart';
import 'package:musicplay/bottom.dart';
import 'package:musicplay/theme.dart';
import 'package:musicplay/songs.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new AudioPlaylist(
      playlist: demoPlaylist.songs.map((DemoSong song){
        return song.audioUrl;
      }).toList(growable: false),
      playbackState: PlaybackState.paused,
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios
            ),
            color: const Color(0xFFDDDDDD),
            onPressed: (){},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu
              ),
              color: const Color(0xFFDDDDDD),
              onPressed: (){},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            //Seek Bar
            Expanded(
              child: AudioPlaylistComponent(
                playlistBuilder: (BuildContext context, Playlist playlist, Widget child){
                  String albumArtUrl = demoPlaylist.songs[playlist.activeIndex].albumArtUrl;
                  return new AudioRadialSeekBar(
                    albumArtUrl: albumArtUrl,
                  );
                },
              ),
            ),

            //visualiser
            Container(
              width: double.infinity,
              height: 125.0,
            ),

            //Name, Controls
            new BottomControls()
            ],
        ),
      ),
    );
  }
}

class AudioRadialSeekBar extends StatefulWidget {
  final String albumArtUrl;
  AudioRadialSeekBar({
    this.albumArtUrl,
  });
  @override
  _AudioRadialSeekBarState createState() => _AudioRadialSeekBarState();
}

class _AudioRadialSeekBarState extends State<AudioRadialSeekBar> {
   double _seekPercent;
  @override
  Widget build(BuildContext context) {
    return AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayhead,
        WatchableAudioProperties.audioSeeking,
      ],
      playerBuilder: (BuildContext context,AudioPlayer player, Widget child){
        double playbackProgress = 0.0;
        if(player.audioLength != null&& player.position != null){
          playbackProgress =player.position.inMilliseconds / player.audioLength.inMilliseconds;
        }
        
        _seekPercent = player.isSeeking ? _seekPercent : null;
        return new RadialSeekBar(
          progress: playbackProgress,
          seekPercent: _seekPercent,
          onSeekRequested: (double seekPercent){
            setState(() => _seekPercent = seekPercent);
            final seekMillis = (player.audioLength.inMilliseconds * seekPercent).round();
            player.seek(new Duration(milliseconds: seekMillis));
          },
          child: new Container(
            color: accentColor,
            child: new Image.network(
              widget.albumArtUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

class RadialSeekBar extends StatefulWidget {
  final double seekPercent;
  final double progress;
  final Function (double) onSeekRequested;
  final Widget child;

  const RadialSeekBar({
    this.progress = 0.0,
    this.seekPercent = 0.0,
    this.onSeekRequested,
    this.child,
  });
  
  @override
  _RadialSeekBarState createState() {
    return new _RadialSeekBarState();
  }
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _progress = 0.0;
  double _currentDragPercent;

  @override
  void initState(){
    super.initState();
    _progress = widget.progress;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  void _onDragStart(PolarCoord coord){
    _startDragCoord = coord;
    _startDragPercent = _progress;

  }
  void _onDragUpdate(PolarCoord coord){
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle/(2*pi);
    setState(() => _currentDragPercent = (_startDragPercent + dragPercent) % 1.0 ); 
  }
  void _onDragEnd(){
    if(widget.onSeekRequested !=null){
      widget.onSeekRequested(_currentDragPercent);
    }
    setState(() {
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  } 

  @override
  Widget build(BuildContext context) {
    double thumbPosition =_progress;
    if(_currentDragPercent != null){
      thumbPosition =_currentDragPercent;
    }else if(widget.seekPercent !=  null){
      thumbPosition =widget.seekPercent;
    }
    return new RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: new Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: new Center(
          child: new Container(
            width: 170.0,
            height: 170.0,
            child: new RadialProgressBar(
              progressPercent: _progress,
              thumbPosition: thumbPosition,
              progressColor: accentColor,
              trackColor: Color(0xFFDDDDDD),
              thumbColor: lightAccentColor,
              innerPadding: const EdgeInsets.all(5.0),
              outerPadding: const EdgeInsets.all(5.0),
              child: ClipOval(
                clipper: CircleClipper(),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final double progressWidth;
  final Color trackColor; 
  final Color progressColor;
  final Color thumbColor;
  final double thumbSize;
  final double thumbPosition;
  final double progressPercent;
  final Widget child;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;

  RadialProgressBar({
    this.trackWidth = 3.0,
    this.progressWidth = 5.0,
    this.trackColor = Colors.grey,
    this.progressColor  = Colors.black,
    this.thumbColor = Colors.black,
    this.thumbSize = 10.0,
    this.thumbPosition = 0.0,
    this.progressPercent = 0.0,
    this.child,
    this.innerPadding = const EdgeInsets.all(0.0),
    this.outerPadding = const EdgeInsets.all(0.0),
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsforPainter(){
    final outerThickness = max(widget.trackWidth, max(widget.progressWidth,widget.thumbSize))/2.0;
    return new EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          progressWidth: widget.progressWidth,
          trackColor: widget.trackColor,
          progressColor: widget.progressColor,
          thumbColor: widget.thumbColor,
          thumbSize: widget.thumbSize,
          thumbPosition: widget.thumbPosition,
          progressPercent: widget.progressPercent  
        ),
        child: Padding(
          padding: _insetsforPainter() + widget.innerPadding,
          child: widget.child,
        ), 
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter{

  final double trackWidth;
  final double progressWidth; 
  final double thumbSize;
  final double thumbPosition;
  final double progressPercent;
  final Paint trackPaint;
  final Paint progressPaint;
  final Paint thumbPaint;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required this.progressWidth,
    @required trackColor,
    @required progressColor,
    @required thumbColor,
    @required this.thumbSize,
    @required this.thumbPosition,
    @required this.progressPercent, 
  }):trackPaint = new Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth,
      progressPaint = new Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressWidth
      ..strokeCap = StrokeCap.round,
      thumbPaint = new Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill
      ..strokeWidth = trackWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth,thumbSize));
    Size constrainedSize = new Size(
      size.width - outerThickness,
      size.height - outerThickness,
    ); 
    final center = Offset(size.width/2, size.height/2);
    final radius = min(constrainedSize.width,constrainedSize.height)/2;
    canvas.drawCircle(
      center, 
      radius, 
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ), 
      -pi/2, 
      2*pi*progressPercent, 
      false, 
      progressPaint);

      final thumbRadius =  thumbSize/2.0;
      final thumbAngle = 2*pi*thumbPosition -(pi/2);
      final thumbX = cos(thumbAngle)*radius;
      final thumbY = sin(thumbAngle)*radius;
      final thumbCenter = Offset(thumbX,thumbY) + center;
      canvas.drawCircle(
        thumbCenter, 
        thumbRadius, 
        thumbPaint
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

} 
