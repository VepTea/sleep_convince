import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: SleepTrackerPage());
}

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});
  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  DateTime? _candidateStart; // 화면 OFF 시점
  Duration? _lastSleep; // OFF→ON 간격
  late final Screen _screen;
  StreamSubscription<ScreenStateEvent>? _sub;

  // 사용자가 정한 목표 (23:00~07:00 예시)
  final _target = const Duration(hours: 8);

  @override
  void initState() {
    super.initState();
    _screen = Screen();
    _sub = _screen.screenStateStream?.listen(_onEvent);
  }

  void _onEvent(ScreenStateEvent e) {
    final now = DateTime.now();
    if (e == ScreenStateEvent.SCREEN_OFF) {
      _candidateStart = now;
    } else if (e == ScreenStateEvent.SCREEN_ON && _candidateStart != null) {
      final gap = now.difference(_candidateStart!);
      // 2 분 이상 OFF였으면 "잠"으로 인정 (테스트용)
      if (gap >= const Duration(minutes: 2)) {
        setState(() => _lastSleep = gap);
      }
      _candidateStart = null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deficit = _lastSleep == null ? null : _target - _lastSleep!;
    return Scaffold(
      appBar: AppBar(title: const Text('초간단 Sleep MVP')),
      body: Center(
        child: _lastSleep == null
            ? const Text('아직 수면 기록 없음')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '실제 수면: '
                    '${_lastSleep!.inHours}h ${_lastSleep!.inMinutes % 60}m',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deficit!.inMinutes == 0
                        ? '목표 달성! 👍'
                        : deficit.isNegative
                        ? '오버슬립 ${deficit.abs().inMinutes}분'
                        : '수면 부족 ${deficit.inMinutes}분',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
      ),
    );
  }
}
