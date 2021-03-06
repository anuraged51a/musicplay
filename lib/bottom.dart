import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:musicplay/theme.dart';
import 'package:musicplay/songs.dart';
 

class BottomControls extends StatelessWidget {
  const BottomControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: accentColor,
        child: Material(
          color: accentColor,
          shadowColor: Color(0x44000000),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0,bottom: 50.0),
            child: Column(
              children: <Widget>[
                new AudioPlaylistComponent(
                    playlistBuilder: (BuildContext context, Playlist playlist, Widget child){
                      final songTitle = demoPlaylist.songs[playlist.activeIndex].songTitle;
                      final artistName = demoPlaylist.songs[playlist.activeIndex].artist;
                      return new RichText(
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                               text: '${songTitle.toUpperCase()}\n',
                               style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4.0,
                                  height: 1.5,
                                ) 
                              ),
                            TextSpan(
                              text: '${artistName.toUpperCase()}\n',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                                height: 1.5,
                              ) 
                            ),
                          ]
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      new PreviousButton(),
                      Expanded(
                        child: Container(),
                      ),
                      new PlayPauseButton(),
                      Expanded(
                        child: Container(),
                      ),
                      new NextButton(),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayerState,
      ],
      playerBuilder: (BuildContext context, AudioPlayer player,Widget child){
        IconData icon = Icons.music_note;
        Function onPressed;
        Color buttonColor = lightAccentColor;

        if(player.state == AudioPlayerState.playing){
          icon = Icons.pause;
          onPressed = player.pause;
          buttonColor = Colors.white;
        }else if(player.state == AudioPlayerState.paused || player.state == AudioPlayerState.completed){
          icon = Icons.play_arrow;
          onPressed = player.play;
          buttonColor = Colors.white;
        }

        return new RawMaterialButton(
          shape: CircleBorder(),
          splashColor: lightAccentColor,
          fillColor: buttonColor,
          highlightColor: lightAccentColor.withOpacity(0.75),
          elevation: 10.0 ,
          highlightElevation: 5.0,
          onPressed: onPressed, 
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color:darkAccentColor,
              size: 35.0,
            ),
          ),
        );
      },
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioPlaylistComponent(
      playlistBuilder: (BuildContext context, Playlist playlist, Widget child){
        return IconButton(
          splashColor: lightAccentColor,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.skip_previous,
            color:Colors.white,
            size: 35.0,
          ),onPressed: (){
            playlist.previous; 
          },);
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioPlaylistComponent(
      playlistBuilder: (BuildContext context, Playlist playlist, Widget child){
        return IconButton(
          splashColor: lightAccentColor,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.skip_next,
            color:Colors.white,
            size: 35.0,
          ),onPressed: (){
            playlist.next; 
          },);
      },
    );
  }
}

class CircleClipper extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    return Rect.fromCircle(
      center: Offset(
        size.width/2,size.height/2, 
      ),
      radius: min(size.width,size.height)/2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }

}