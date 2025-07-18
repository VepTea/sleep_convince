# Screen-Gap Sleep Tracker

화면 ON/OFF 이벤트를 감지하여 수면 시간을 자동으로 추적하는 Flutter 앱입니다.

## 📱 기능

- **자동 수면 감지**: 화면이 꺼진 시간을 기반으로 수면 세션 추적
- **수면 부족/과다 계산**: 목표 8시간 대비 실제 수면 시간 비교
- **실시간 UI 업데이트**: 수면 세션 기록 시 즉시 화면 갱신
- **간단한 사용법**: 설정 없이 바로 사용 가능

## 🏗️ 프로젝트 구조

```
sleep_convince/
├── lib/
│   └── main.dart          # 메인 앱 코드 (80줄)
├── android/
│   └── app/
│       └── src/main/
│           └── AndroidManifest.xml  # WAKE_LOCK 권한
├── pubspec.yaml           # 의존성 관리
└── README.md             # 이 파일
```

## 🔧 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  screen_state: ^4.1.1   # 화면 ON/OFF 이벤트 감지
```

## 📊 코드 흐름

### 1. 앱 초기화
```dart
void main() => runApp(const MyApp());
```
- `MyApp`: MaterialApp 설정
- `SleepTrackerPage`: 메인 화면

### 2. 화면 이벤트 리스너 설정
```dart
@override
void initState() {
  super.initState();
  _screen = Screen();
  _sub = _screen.screenStateStream?.listen(_onEvent);
}
```
- `Screen()`: screen_state 패키지의 화면 이벤트 스트림
- `screenStateStream`: SCREEN_OFF/SCREEN_ON 이벤트 수신

### 3. 이벤트 처리 로직
```dart
void _onEvent(ScreenStateEvent e) {
  final now = DateTime.now();
  if (e == ScreenStateEvent.SCREEN_OFF) {
    _candidateStart = now;  // 화면 꺼짐 시점 저장
  } else if (e == ScreenStateEvent.SCREEN_ON && _candidateStart != null) {
    final gap = now.difference(_candidateStart!);
    if (gap >= const Duration(minutes: 2)) {  // 2분 이상이면 수면으로 인정
      setState(() => _lastSleep = gap);
    }
    _candidateStart = null;
  }
}
```

### 4. 수면 부족 계산
```dart
final deficit = _lastSleep == null ? null : _target - _lastSleep!;
```
- `_target`: 목표 수면 시간 (8시간)
- `_lastSleep`: 실제 수면 시간
- `deficit`: 부족/과다 시간 (음수면 과다, 양수면 부족)

### 5. UI 표시
```dart
Text(
  deficit!.inMinutes == 0
      ? '목표 달성! 👍'
      : deficit.isNegative
          ? '오버슬립 ${deficit.abs().inMinutes}분'
          : '수면 부족 ${deficit.inMinutes}분',
  style: const TextStyle(fontSize: 20),
)
```

## 🔄 데이터 흐름

```
화면 OFF → _candidateStart 저장
    ↓
화면 ON → 시간 차이 계산
    ↓
2분 이상? → 수면 세션으로 기록
    ↓
UI 업데이트 → 수면 시간 및 부족/과다 표시
```

## ⚙️ 설정

### Android 권한
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 테스트 설정
- **개발용**: 2분 (빠른 테스트)
- **실제 사용**: 40분 (정확한 수면 감지)

## 🧪 테스트 방법

1. **앱 실행**: `flutter run -d emulator-5554`
2. **화면 끄기**: 에뮬레이터의 전원 아이콘 클릭
3. **2분 대기**: 타이머로 정확히 측정
4. **화면 켜기**: 마우스 클릭
5. **결과 확인**: "실제 수면: Xh Ym" 메시지 확인

## 🚀 확장 가능한 기능

### 1. 목표 시간 사용자 설정
```dart
final time = await showTimePicker(context: context, initialTime: _bedtime);
await PrefsService.setBedtime(time);
```

### 2. 하루 넘는 수면 세션 머지
```dart
if (_candidateStart.day != now.day) {
  // 날짜 변경 시 로직
}
```

### 3. 일주일 그래프
```dart
CustomPaint(
  painter: SleepGraphPainter(weeklyData),
)
```

## 📈 성능 최적화

- **단일 의존성**: screen_state 패키지만 사용
- **최소 코드**: 80줄로 완전한 기능 구현
- **메모리 효율**: StreamSubscription 적절한 해제

## 🔍 디버깅

### 로그 확인
```bash
flutter run -d emulator-5554 --verbose
```

### 핫 리로드
```bash
r  # 터미널에서 입력
```

## 📝 라이센스

MIT License - 자유롭게 사용 및 수정 가능

---

**개발자**: Screen-Gap Sleep Tracker Team  
**버전**: 1.0.0  
**플랫폼**: Android (Flutter 3.x)
