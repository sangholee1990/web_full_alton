import 'package:flutter/material.dart';
import 'widgets/app_header2.dart';
import 'widgets/app_footer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_full_alton/utils/providers.dart';

// --- 페이지 2: AI 맞춤 자전거 찾기 ---
// (이전 코드와 동일, 생략)
class Bike {
  final String name;
  final String brand;
  final int price;
  final String imagePath;
  final double weight;
  final int gears;
  final String brakeType;
  final String frame;
  final String spec;
  final String driveSystem;

  Bike({
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.weight,
    required this.gears,
    required this.brakeType,
    required this.frame,
    required this.spec,
    required this.driveSystem,
  });
}

class BikeFinderPage extends ConsumerStatefulWidget {
  const BikeFinderPage({super.key});

  @override
  ConsumerState<BikeFinderPage> createState() => _BikeFinderPageState();
}

class _BikeFinderPageState extends ConsumerState<BikeFinderPage> {

  late final ScrollController _scrollController;
  int _currentStep = 0;

  // --- 상태 변수 ---
  // Step 1
  String? _selectedUsage = '운동'; // 기본 선택값
  RangeValues _currentRangeValues = const RangeValues(3000000, 9000000);

  // Step 2
  final TextEditingController _heightController = TextEditingController(text: "175");
  final TextEditingController _inseamController = TextEditingController(text: "79.5");

  // Step 3 & 4 (이전 코드와 동일)
  final List<Bike> _recommendedBikes = List.generate(
    12, // 더보기 기능을 테스트하기 위해 12개의 자전거 데이터 생성
        (index) => Bike(
      name: '25알톤 R ONE 로드자전거',
      brand: '알톤',
      price: 1110000,
      imagePath: 'images/25-BOMARC-21D_MATT-BLACK_RGB1.png',
      weight: 12.5,
      gears: 12,
      brakeType: '디스크',
      frame: '알루미늄',
      spec: '시마노, 인피쉰(무한)+Forza휠 용접비드안보이는것',
      driveSystem: 'LTWOO 12단 변속시스템',
    ),
  );

  final Set<Bike> _selectedBikes = {};
  int _visibleBikeCount = 5;

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

  void _resetStep1() {
    setState(() {
      // 기본값으로 재설정
      _selectedUsage = '운동';
      _currentRangeValues = const RangeValues(3000000, 9000000);
    });
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final shouldBeScrolled = _scrollController.offset > 0;
    if (ref.read(isScrolledProvider) != shouldBeScrolled) {
      ref.read(isScrolledProvider.notifier).state = shouldBeScrolled;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heightController.dispose();
    _inseamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final List<Widget> stepContents = [
      _buildStep1Budget(),
      _buildStep2BodyInfo(), // 이전 단계에서 구현한 위젯
      _buildStep3Results(),  // 이전 단계에서 구현한 위젯
      _buildStep4Report(),   // 이전 단계에서 구현한 위젯
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(isDesktop: isDesktop),
      body: SingleChildScrollView(
        // controller: ref.watch(scrollControllerProvider),
        controller: _scrollController,
        child: Column(
          children: [
            _buildPageHeader(), // 이전 단계에서 구현한 위젯
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("AI 맞춤 자전거 찾기", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _buildStepper(), // 이전 단계에서 구현한 위젯
                  const SizedBox(height: 40),
                  stepContents[_currentStep],
                  const SizedBox(height: 40),
                  _buildNavigationButtons(), // 이전 단계에서 구현한 위젯
                ],
              ),
            ),
            AppFooter(isDesktop: isDesktop),
          ],
        ),
      ),
    );
  }

  // --- 1단계: 용도 및 예산 (새롭게 구현된 위젯) ---
  Widget _buildStep1Budget() {
    final List<Map<String, dynamic>> usages = [
      {'icon': Icons.location_city, 'label': '출퇴근'},
      {'icon': Icons.fitness_center, 'label': '운동'},
      {'icon': Icons.luggage, 'label': '여행'},
      {'icon': Icons.terrain, 'label': '산악'},
      {'icon': Icons.directions_bike, 'label': '로드'},
    ];

    return Column(
      children: [
        // 상단 타이틀 박스
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF424242),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "라이딩 목적과 예산 설정",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "최적의 자전거 추천을 위한 첫 단계입니다.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        // 메인 콘텐츠 영역
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주요 용도 선택
              const Text("주요 용도(1개 선택)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: usages.map((usage) {
                  final bool isSelected = _selectedUsage == usage['label'];
                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedUsage = usage['label'];
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFFFE8B21) : Colors.white,
                      side: BorderSide(color: isSelected ? const Color(0xFFFE8B21) : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFFE8B21),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(usage['icon'], color: isSelected ? const Color(0xFFFE8B21) : Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          usage['label'],
                          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),
              // 예산 설정
              const Text("예산", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              Column(
                children: [
                  // 슬라이더 값 표시 라벨
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(_currentRangeValues.start / 10000).round()} - ${(_currentRangeValues.end / 10000).round()}만원',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // 레인지 슬라이더
                  RangeSlider(
                    values: _currentRangeValues,
                    min: 0,
                    max: 15000000,
                    divisions: 150,
                    activeColor: const Color(0xFFFE8B21),
                    inactiveColor: Colors.grey[300],
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                      });
                    },
                  ),
                  // 최소/최대 라벨
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("최소", style: TextStyle(color: Colors.grey)),
                        Text("최대", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("300만", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("600만", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("900만", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("1200만", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("1500만", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 이하 위젯들은 이전 코드와 동일 ---

  Widget _buildPageHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'images/KSH_0891.png',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(height: 300, color: Colors.grey),
        ),
        Container(height: 300, color: Colors.black.withOpacity(0.3)),
        const Center(
          child: SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('나만을 위한 최적의 라이딩 파트너', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 10),
                Text('AI 맞춤 자전거 찾기는 복잡한 자전거 선택 과정을\n획기적으로 간소화하고, 사용자의 라이프 스타일에 가장 완벽하게\n부합하는 자전거를 추천해주는 혁신적인 서비스입니다.', textAlign: TextAlign.left, style: TextStyle(fontSize: 16, color: Colors.white, height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    final List<String> steps = ["용도 및 예산", "신체 정보", "추천 결과", "AI 비교 리포트"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(steps.length, (index) {
        final bool isActive = index == _currentStep;
        return Expanded(
          child: Column(
            children: [
              Text(
                "${index + 1}. ${steps[index]}",
                style: TextStyle(fontSize: 16, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFFFE8B21) : Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                color: isActive ? const Color(0xFFFE8B21) : Colors.grey[300],
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep2BodyInfo() {
    return Column(
      children: [
        // 상단 타이틀 박스
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF424242),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("신체 정보 입력", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("입력한 신체 정보를 기반으로 AI가 최적화된 자전거를 찾아드립니다.", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        // 메인 콘텐츠 영역
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 키 입력 필드
              _buildNumberInputField(
                label: "키 (cm)",
                controller: _heightController,
                hintText: "175",
              ),
              const SizedBox(height: 30),
              _buildNumberInputField(
                label: "다리 안쪽 길이 (cm)",
                controller: _inseamController,
                hintText: "79.5",
                description: "발을 어깨너비로 벌리고 선 상태에서 허벅지 안쪽부터 바닥까지의 줄자로 재면 인심 길이를 잴 수 있습니다.",
              ),
              const SizedBox(height: 40),
              // 인심 측정 안내 이미지
              Center(
                child: Image.asset(
                  'images/Frame.png',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: Text('인심 측정 안내 이미지')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 숫자 입력 필드를 만드는 재사용 위젯
  Widget _buildNumberInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String? description,
  }) {
    void changeValue(int amount) {
      int currentValue = int.tryParse(controller.text) ?? 0;
      int newValue = currentValue + amount;
      if (newValue >= 0) {
        controller.text = newValue.toString();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            // [수정] Expanded를 제거하고 명확한 높이를 가진 Container로 감싸 오류를 해결합니다.
            suffixIcon: Container(
              height: 50, // 고정 높이 부여
              margin: const EdgeInsets.only(right: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => changeValue(1),
                    child: const Icon(Icons.arrow_drop_up, size: 24),
                  ),
                  InkWell(
                    onTap: () => changeValue(-1),
                    child: const Icon(Icons.arrow_drop_down, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Results() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀 박스
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF424242),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("AI 맞춤 추천 결과!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("입력된 기본 데이터를 분석하여 최적화된 자전거를 제안합니다.", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        // 추천 개수 텍스트
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            // 텍스트의 세로 정렬을 베이스라인에 맞춥니다.
            // crossAxisAlignment: CrossAxisAlignment.baseline,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // 왼쪽 텍스트
              Text(
                "${_recommendedBikes.length}개의 자전거가 추천되었습니다.",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // 위젯 사이의 공간을 최대로 확보합니다.
              const Spacer(),
              // 오른쪽 텍스트
              const Text(
                "2~4개의 자전거를 선택하여 비교해보세요.",
                style: TextStyle(fontSize: 14, color: Colors.grey), // 스타일 추가
              ),
            ],
          ),
        ),
        // const SizedBox(height: 20),
        // 자전거 목록
        Column(
          children: _recommendedBikes.take(_visibleBikeCount).map((bike) {
            return _buildBikeListItem(bike);
          }).toList(),
        ),
        // 더보기 버튼
        if (_visibleBikeCount < _recommendedBikes.length)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleBikeCount = _recommendedBikes.length; // 모든 항목 표시
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text(
                  "더보기",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 각 자전거 항목을 구성하는 위젯
  Widget _buildBikeListItem(Bike bike) {
    final bool isSelected = _selectedBikes.contains(bike);
    // 1. Card 스타일을 적용하기 위해 Container를 새로 추가하고 꾸며줍니다.
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // 각 항목 아래에 여백 추가
      padding: const EdgeInsets.all(20.0), // 내부 여백
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!), // 회색 테두리
        borderRadius: BorderRadius.circular(8.0),   // 둥근 모서리
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image.asset(bike.imagePath, width: 120, height: 120, fit: BoxFit.cover),
          Image.asset(bike.imagePath, height: 120, fit: BoxFit.cover),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bike.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(formatPrice(bike.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFE8B21))),
                const SizedBox(height: 8),
                _buildSpecText("자전거 설명: ", bike.spec ?? '정보 없음'),
                _buildSpecText("프레임: ", bike.frame ?? '정보 없음'),
                _buildSpecText("변속시스템: ", bike.driveSystem ?? '정보 없음'),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedBikes.add(bike);
                    } else {
                      _selectedBikes.remove(bike);
                    }
                  });
                },
                activeColor: const Color(0xFFFE8B21),
              ),
              const Text("선택"),
            ],
          ),
        ],
      ),
    );
  }

  // 자전거 스펙 텍스트 위젯
  Widget _buildSpecText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87, fontFamily: 'Pretendard'),
          children: [
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Report() { return const Center(child: Text("4단계: AI 비교 리포트 (구현 예정)")); }

  Widget _buildNavigationButtons() {
    // 버튼 스타일 정의
    final ButtonStyle greyButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[600],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    final ButtonStyle orangeButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFE8B21),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    // 1단계일 경우 '초기화', '다음' 버튼 표시
    if (_currentStep == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _resetStep1, // 초기화 함수 연결
            style: greyButtonStyle,
            child: const Text('초기화'),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _nextStep,
            style: orangeButtonStyle,
            child: const Text('다음'),
          ),
        ],
      );
    }
    // 그 외 단계에서는 '이전', '다음' 버튼 표시
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _previousStep,
            style: greyButtonStyle,
            child: const Text('이전'),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: _nextStep,
            style: orangeButtonStyle,
            child: Text(_currentStep == 3 ? '완료' : '다음'),
          ),
        ],
      );
    }
  }
}