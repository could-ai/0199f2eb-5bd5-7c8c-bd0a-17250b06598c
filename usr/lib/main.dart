import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const _initialDuration = Duration(minutes: 5);
  Duration _duration = _initialDuration;
  Timer? _timer;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_duration.inSeconds == 0) {
      _resetTimer();
    }
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _duration = _initialDuration;
    });
  }

  void _updateTimer() {
    if (_duration.inSeconds > 0) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds - 1);
      });
    } else {
      _playSound();
      _pauseTimer();
    }
  }

  Future<void> _playSound() async {
    try {
      // Using a remote URL for the sound to avoid needing local assets.
      // This is a simple beep sound.
      await _audioPlayer.play(UrlSource('https://www.soundjay.com/buttons/beep-07a.wav'));
    } catch (e) {
      // Handle potential errors, e.g., network issues
      print("Error playing sound: $e");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Timer'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTimerDisplay(),
            const SizedBox(height: 80),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _duration.inSeconds / _initialDuration.inSeconds,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isRunning ? Colors.blueAccent : Colors.grey,
            ),
          ),
          Center(
            child: Text(
              _formatDuration(_duration),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _resetTimer,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.refresh, size: 35),
        ),
        const SizedBox(width: 40),
        ElevatedButton(
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(30),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Icon(
            _isRunning ? Icons.pause : Icons.play_arrow,
            size: 50,
          ),
        ),
      ],
    );
  }
}
