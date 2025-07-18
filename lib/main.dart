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
      appBar: AppBar(
        title: const Text('초간단 Sleep MVP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReadmePage()),
              );
            },
            tooltip: 'README 보기',
          ),
        ],
      ),
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

class ReadmePage extends StatelessWidget {
  const ReadmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('README'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screen-Gap Sleep Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '화면 ON/OFF 이벤트를 감지하여 수면 시간을 자동으로 추적하는 Flutter 앱입니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            _buildSection('📱 기능', [
              '자동 수면 감지: 화면이 꺼진 시간을 기반으로 수면 세션 추적',
              '수면 부족/과다 계산: 목표 8시간 대비 실제 수면 시간 비교',
              '실시간 UI 업데이트: 수면 세션 기록 시 즉시 화면 갱신',
              '간단한 사용법: 설정 없이 바로 사용 가능',
            ]),

            _buildSection('🏗️ 프로젝트 구조', [
              'lib/main.dart: 메인 앱 코드 (80줄)',
              'android/app/src/main/AndroidManifest.xml: WAKE_LOCK 권한',
              'pubspec.yaml: 의존성 관리',
              'README.md: 프로젝트 문서',
            ]),

            _buildSection('🔧 의존성', [
              'flutter: Flutter SDK (기본)',
              'screen_state: ^4.1.1 - 화면 ON/OFF 이벤트 감지',
            ]),

            _buildSection('📊 코드 흐름', [
              '1. 앱 초기화: main() → MyApp → SleepTrackerPage',
              '2. 화면 이벤트 리스너 설정: Screen() → screenStateStream',
              '3. 이벤트 처리: SCREEN_OFF/SCREEN_ON 감지',
              '4. 수면 계산: 목표 8시간 대비 실제 수면 시간',
              '5. UI 업데이트: 실시간 화면 갱신',
            ]),

            _buildSection('🔄 데이터 흐름', [
              '화면 OFF → _candidateStart 저장',
              '화면 ON → 시간 차이 계산',
              '2분 이상? → 수면 세션으로 기록',
              'UI 업데이트 → 수면 시간 및 부족/과다 표시',
            ]),

            _buildSection('🧪 테스트 방법', [
              '1. 앱 실행: flutter run -d emulator-5554',
              '2. 화면 끄기: 에뮬레이터의 전원 아이콘 클릭',
              '3. 2분 대기: 타이머로 정확히 측정',
              '4. 화면 켜기: 마우스 클릭',
              '5. 결과 확인: "실제 수면: Xh Ym" 메시지 확인',
            ]),

            _buildSection('🚀 확장 가능한 기능', [
              '목표 시간 사용자 설정: showTimePicker() + SharedPreferences',
              '하루 넘는 수면 세션 머지: 날짜 변경 감지 로직',
              '일주일 그래프: CustomPaint로 간단한 막대 그래프',
            ]),

            _buildSection('📈 성능 최적화', [
              '단일 의존성: screen_state 패키지만 사용',
              '최소 코드: 80줄로 완전한 기능 구현',
              '메모리 효율: StreamSubscription 적절한 해제',
            ]),

            const SizedBox(height: 24),
            const Text(
              '개발자: Screen-Gap Sleep Tracker Team',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('버전: 1.0.0'),
            const Text('플랫폼: Android (Flutter 3.x)'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
