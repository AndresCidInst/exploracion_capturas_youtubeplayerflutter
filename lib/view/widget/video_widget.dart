import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late YoutubePlayerController _controller;
  final List _capturas = [];
  bool _inReduction = false;
  Map data = {};

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId:
          'SnXkhkEvNIM', // Reemplaza con la ID de tu video de YouTube
      flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: true,
          hideControls: false,
          controlsVisibleAtStart: true),
    );

    Map pastValues = {'status': '', 'volumen': 100, 'position': 0};
    // Escucha cambios en el estado del reproductor de YouTube
    _controller.addListener(() {
      //Si empezó la reproducción del video y hay cambios en uno de los valores a capturar
      if (_controller.value.hasPlayed && _inReduction) {
        if (pastValues['status'] != _controller.value.playerState) {
          captureVideoStatus();
        } else if (pastValues['volume'] != _controller.value.volume) {
          volumeChange();
        }

        /*

          if (pastValues['position'] + 1 < _controller.value.position.inSeconds ||
            pastValues['position'] > _controller.value.position.inSeconds) {
          print('Entre acá');
          if (pastValues['position'] > _controller.value.position.inSeconds) {
            _capturas.add('Se atrasó');
          } else {
            _capturas.add('Se Adealntó');
          }
        }

        */
        pastValues = {
          'status': _controller.value.playerState,
          'volumen': _controller.value.volume,
          'position': _controller.value.position.inSeconds
        };
      } else {
        if (_controller.value.hasPlayed != _inReduction) {
          _capturas.add('Se reprodujo');
          pastValues = pastValues = {
            'status': _controller.value.playerState,
            'volumen': _controller.value.volume,
            'position': _controller.value.position.inSeconds
          };
          _inReduction = true;
        }
      }
    });
  }

  void captureVideoStatus() {
    //Comprueba el estado del video
    switch (_controller.value.playerState) {
      case PlayerState.playing:
        _capturas.add('Video reanudó');
        break;
      case PlayerState.paused:
        _capturas.add('Video pausado');
        break;
      case PlayerState.ended:
        _capturas.add('Video finalizado');
        break;
      default:
        break;
    }
  }

  void volumeChange() {
    bool isMuted = false;

    if (isMuted != (_controller.value.volume == 0)) {
      if (_controller.value.volume == 0) {
        _capturas.add("Se muteo");
        isMuted = _controller.value.volume == 0;
      } else {
        _capturas.add("De desmuteo");
        isMuted = _controller.value.volume != 0;
      }
    }
  }

  dataRecord() {
    //Dentro del YoutubePlayerController, no hay nada que retorne un 'Future', también con YoutubePlayerMetaData
    //De los datos requeridos para la captura
    //La calidad está entregada como string
    //velocidad de reproducción como double
    //Volumen en int
    //La Pantalla completa en bool, true: Sí está en pantalla completa, false: No está en pantalla completa
    //El largo está entregado en una variable tipo 'duration'
    return {
      'quality': _controller.value.playbackQuality,
      'reproductionSpeed': _controller.value.playbackRate,
      'volume': _controller.value.volume,
      'fullScreen': _controller.value.isFullScreen,
      'large': _controller.metadata.duration,
      'title': _controller.metadata.title,
      'currentPosition': _controller.value.position
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder(
        child: Column(
      children: [
        YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.cyan,
        ),
        IconButton(
            onPressed: () {
              data = dataRecord();
              print("$_capturas \n$data");
              print('\n\n${_controller.value}');
            },
            icon: const Icon(Icons.add))
      ],
    ));
  }
}
