import 'package:flutter/material.dart';
import 'widgets/app_header2.dart';
import 'widgets/app_footer.dart';

// --- 페이지 2: AI 맞춤 자전거 찾기 ---
// (이전 코드와 동일, 생략)
class BikeFinderPage extends StatefulWidget {
  const BikeFinderPage({super.key});

  @override
  State<BikeFinderPage> createState() => _BikeFinderPageState();
}

class _BikeFinderPageState extends State<BikeFinderPage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // 현재 단계에 맞는 위젯을 리스트로 관리
    final List<Widget> stepContents = [
      _buildStep1Budget(),
      _buildStep2BodyInfo(),
      _buildStep3Results(),
      _buildStep4Report(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(isDesktop: isDesktop),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPageHeader(),
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("AI 맞춤 자전거 찾기", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _buildStepper(),
                  const SizedBox(height: 40),
                  // 현재 단계에 맞는 콘텐츠 표시
                  stepContents[_currentStep],
                  const SizedBox(height: 40),
                  _buildNavigationButtons(),
                ],
              ),
            ),
            AppFooter(isDesktop: isDesktop),
          ],
        ),
      ),
    );
  }

  // 페이지 상단 Hero 이미지
  Widget _buildPageHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'images/KSH_0891.png',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(height: 300, color: Colors.black.withOpacity(0.3)),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '나만을 위한 최적의 라이딩 파트너',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AI 맞춤 자전거 찾기는 복잡한 자전거 선택 과정을\n획기적으로 간소화하고, 사용자의 라이프 스타일에 가장 완벽하게\n부합하는 자전거를 추천해주는 혁신적인 서비스입니다.',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: Colors.white, height: 1.6), // Using white70 for better contrast
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 단계 표시기 (Stepper)
  Widget _buildStepper() {
    final List<String> steps = ["용도 및 예산", "신체 정보", "추천 결과", "AI 비교 리포트"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(steps.length, (index) {
        final bool isActive = index == _currentStep;
        return Column(
          children: [
            Text(
              "${index + 1}. ${steps[index]}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? const Color(0xFFFF7900) : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 150,
              color: isActive ? const Color(0xFFFF7900) : Colors.grey[300],
            )
          ],
        );
      }),
    );
  }

  // --- 각 단계별 콘텐츠 위젯 ---
  Widget _buildStep1Budget() {
    return const Center(child: Text("1단계: 용도 및 예산 설정 (구현 예정)", style: TextStyle(fontSize: 20)));
  }

  Widget _buildStep2BodyInfo() {
    return const Center(child: Text("2단계: 신체 정보 입력 (구현 예정)", style: TextStyle(fontSize: 20)));
  }

  Widget _buildStep3Results() {
    return const Center(child: Text("3단계: 추천 결과 보기 (구현 예정)", style: TextStyle(fontSize: 20)));
  }

  Widget _buildStep4Report() {
    return const Center(child: Text("4단계: AI 비교 리포트 (구현 예정)", style: TextStyle(fontSize: 20)));
  }

  // 이전/다음 네비게이션 버튼
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: _previousStep,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
            child: const Text('이전'),
          ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7900), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
          child: Text(_currentStep == 3 ? '완료' : '다음'),
        ),
      ],
    );
  }
}