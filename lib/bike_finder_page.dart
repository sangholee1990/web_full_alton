import 'dart:js_interop';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_full_alton/widgets/app_header2.dart';
import 'package:web_full_alton/widgets/app_footer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_full_alton/utils/providers.dart';
import 'package:high_chart/high_chart.dart';
import 'dart:convert';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:web_full_alton/utils/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:html' as html;
import 'package:web/web.dart' as web;

const Color kPrimaryColor = Color(0xFFFE8B21);
const Color kHeaderColor = Color(0xFF424242);
const TextStyle kSectionTitleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const TextStyle kCardTitleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

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

  final String tag; // 예: 추천, 가성비
  final Color tagColor; // 태그 배경색
  final Map<String, int> performanceStats; // 레이더 차트 데이터
  final List<String> pros; // 장점
  final List<String> cons; // 단점
  final String summary; // AI 총평 요약

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

    required this.tag,
    required this.tagColor,
    required this.performanceStats,
    required this.pros,
    required this.cons,
    required this.summary,
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
  final GlobalKey _chartKey = GlobalKey();
  // pw.Font? _pdfFont;
  bool _isGeneratingPdf = false;

  // --- 상태 변수 ---
  // Step 1
  String? _selectedUsage = '운동'; // 기본 선택값
  RangeValues _currentRangeValues = const RangeValues(3000000, 9000000);

  // Step 2
  final TextEditingController _heightController = TextEditingController(text: "175.0");
  final TextEditingController _inseamController = TextEditingController(text: "79.5");

  // Step 3 & 4 (이전 코드와 동일)
  final List<Bike> _recommendedBikes = [
    Bike(name: '25알원 R ONE 로드자전거', brand: '알톤', price: 1110000, imagePath: 'images/25-BOMARC-21D_MATT-BLACK_RGB1.png', frame: '알루미늄', weight: 10.5, gears: 22, brakeType: '디스크', spec: '시마노 105', driveSystem: '시마노 105', tag: '추천', tagColor: Colors.orange, performanceStats: {'가성비': 4, '성능': 5, '편의성': 3, '디자인': 4, '유지보수': 4}, pros: ['경량 프레임', '안정적인 제동력'], cons: ['다소 높은 가격'], summary: '입문용 로드자전거로 가장 균형 잡힌 성능을 제공하며, 특히 안정적인 주행 성능이 돋보입니다.'),
    Bike(name: '25자비스16 로드자전거', brand: '알톤', price: 780000, imagePath: 'images/25-BOMARC-21D_MATT-BLACK_RGB1.png', frame: '알루미늄', weight: 11.2, gears: 16, brakeType: '캘리퍼', spec: '시마노 클라리스', driveSystem: '시마노 클라리스', tag: '가성비', tagColor: Colors.green, performanceStats: {'가성비': 5, '성능': 3, '편의성': 4, '디자인': 3, '유지보수': 5}, pros: ['저렴한 가격', '유지보수 용이'], cons: ['다소 무거운 무게'], summary: '가격 대비 성능이 매우 우수하여, 출퇴근이나 가벼운 운동 용도로 자전거를 시작하는 분들에게 최적입니다.'),
    Bike(name: '23인피자 이노사이클 9', brand: '인피자', price: 930000, imagePath: 'images/25-BOMARC-21D_MATT-BLACK_RGB1.png', frame: '알루미늄', weight: 10.8, gears: 18, brakeType: '디스크', spec: '시마노 소라', driveSystem: '시마노 소라', tag: '', tagColor: Colors.transparent, performanceStats: {'가성비': 4, '성능': 4, '편의성': 4, '디자인': 4, '유지보수': 4}, pros: ['유압식 디스크 브레이크'], cons: ['연식이 조금 지남'], summary: '유압식 디스크 브레이크를 채택하여 다양한 도로 환경에서 안정적인 제동력을 보여주는 모델입니다.'),
    Bike(name: '23엘리우스-D 105', brand: '알톤', price: 2200000, imagePath: 'images/25-BOMARC-21D_MATT-BLACK_RGB1.png', frame: '카본', weight: 8.9, gears: 22, brakeType: '디스크', spec: '시마노 105', driveSystem: '시마노 105', tag: '성능', tagColor: Colors.blue, performanceStats: {'가성비': 3, '성능': 5, '편의성': 3, '디자인': 5, '유지보수': 3}, pros: ['초경량 카본 프레임', '최상급 구동계'], cons: ['높은 가격대', '전문가 수준의 관리 필요'], summary: '카본 프레임과 시마노 105 구동계를 장착하여, 전문적인 라이딩이나 대회 참가를 목표로 하는 분들께 추천합니다.'),
  ];
  final Set<Bike> _selectedBikes = {};
  int _visibleBikeCount = 5;

  static const List<String> kChartColors = [
    '#7B4B19',
    '#BE6201',
    '#FF4E0F',
    '#F6A10F',
  ];

  // 헥사 코드(#)를 Flutter Color 객체로 변환하는 헬퍼 함수
  Color _hexToColor(String hexCode) {
    final hexString = hexCode.replaceAll('#', '');
    return Color(int.parse('FF$hexString', radix: 16));
  }


  void _nextStep() {
    if (_currentStep == 2 && _selectedBikes.length < 2) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: '최소 2개 이상 자전거를 선택해주세요.',
      );

      return;
    }

    if (_currentStep == 2 && _selectedBikes.length > 4) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: '최대 4개 이하 자전거를 선택해주세요.',
      );

      return;
    }


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
    // _loadPdfAssets();
  }

  // Future<void> _loadPdfAssets() async {
  //   final fontData = await rootBundle.load("assets/fonts/NotoSansKR-Regular.ttf");
  //   final boldFontData = await rootBundle.load("assets/fonts/NotoSansKR-Bold.ttf");
  //   _pdfFont = pw.Font.ttf(fontData);
  //   _pdfBoldFont = pw.Font.ttf(boldFontData);
  // }

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
      _buildStep1Budget(isDesktop),
      _buildStep2BodyInfo(), // 이전 단계에서 구현한 위젯
      _buildStep3Results(isDesktop: isDesktop),  // 이전 단계에서 구현한 위젯
      _buildStep4Report(isDesktop: isDesktop),   // 이전 단계에서 구현한 위젯
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(isDesktop: isDesktop),
      endDrawer: isDesktop ? null : const MobileDrawer(), // 모바일에서만 Drawer 추가
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
                  _buildStepper(isDesktop: isDesktop), // 이전 단계에서 구현한 위젯
                  const SizedBox(height: 40),
                  stepContents[_currentStep],
                  const SizedBox(height: 40),
                  _buildNavigationButtons(isDesktop: isDesktop), // 이전 단계에서 구현한 위젯
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
  Widget _buildStep1Budget(isDesktop) {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주요 용도 선택
              const Text("주요 용도 (1개 선택)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              GridView.count(
                // 1. 한 줄에 2개의 열을 생성하여 2열 레이아웃을 만듭니다.
                crossAxisCount: isDesktop ? 5 : 2,
                padding: EdgeInsets.zero,
                // 2. Column 내에서 GridView가 필요한 만큼의 공간만 차지하도록 설정합니다.
                shrinkWrap: true,

                // 3. 부모 스크롤(SingleChildScrollView)과의 충돌을 방지합니다.
                physics: const NeverScrollableScrollPhysics(),

                // 4. 아이템 사이의 간격을 설정합니다.
                crossAxisSpacing: 12, // 가로 간격
                mainAxisSpacing: 12,  // 세로 간격

                // 5. 버튼의 가로:세로 비율을 조절합니다. (숫자를 조절해 모양 변경)
                childAspectRatio: 2.8,

                // 6. 그리드에 표시될 위젯 리스트입니다.
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 버튼 내부 콘텐츠 중앙 정렬
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
              const SizedBox(height: 20),
              const Text("예산", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
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
    final isDesktop = MediaQuery.of(context).size.width > 900;
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
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('나만을 위한 최적의 라이딩 파트너', style: TextStyle(fontSize: isDesktop ? 36 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text('AI 맞춤 자전거 찾기는 복잡한 자전거 선택 과정을\n획기적으로 간소화하고, 사용자의 라이프 스타일에 가장 완벽하게\n부합하는 자전거를 추천해주는 혁신적인 서비스입니다.', textAlign: TextAlign.left, style: TextStyle(fontSize: isDesktop ? 16 : 13, color: Colors.white, height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper({required bool isDesktop}) {
    final List<String> desktopSteps = ["용도 및 예산", "신체 정보", "추천 결과", "AI 비교 리포트"];
    final List<String> mobileSteps = ["용도예산", "신체정보", "추천결과", "리포트"];
    final List<String> steps = isDesktop ? desktopSteps : mobileSteps;

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
                hintText: "175.0",
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
    void changeValue(double amount) {
      // 버튼으로 값을 변경하는 로직은 이미 소수점을 잘 처리하고 있습니다.
      double currentValue = double.tryParse(controller.text) ?? 0.0;
      double newValue = currentValue + amount;
      // 소수점 첫째 자리까지 표시
      String formattedValue = newValue.toStringAsFixed(1);
      controller.text = formattedValue;
      // 커서를 텍스트 끝으로 이동시켜 사용자 경험을 개선합니다.
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
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
          // [수정 1] 소수점 입력이 가능한 숫자 키보드를 사용하도록 변경
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // [수정 2] 숫자와 소수점 첫째 자리까지만 허용하도록 입력 포매터 변경
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            suffixIcon: SizedBox(
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => changeValue(1.0),
                    child: const Icon(Icons.arrow_drop_up, size: 24),
                  ),
                  InkWell(
                    onTap: () => changeValue(-1.0),
                    child: const Icon(Icons.arrow_drop_down, size: 24),
                  ),
                ],
              ),
            ),
          ),
          // textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStep3Results({required bool isDesktop}) {
    // isDesktop 값에 따라 다른 UI를 적용합니다.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 상단 타이틀 박스 (변경 없음)
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

        // 2. 추천 개수 텍스트
        Padding(
          // PC와 모바일에서 다른 좌우 여백을 줍니다.
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: isDesktop ? 0 : 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${_recommendedBikes.length}개의 자전거가 추천되었습니다.",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                // isDesktop 값에 따라 다른 텍스트를 보여줍니다.
                isDesktop ? "2~4개의 자전거를 선택하여 비교해보세요." : "2~4개 선택 비교",
                style: TextStyle(fontSize: isDesktop ? 14 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),

        // 3. 자전거 목록
        Column(
          children: _recommendedBikes.take(_visibleBikeCount).map((bike) {
            // 모바일에서만 리스트 아이템에 좌우 여백을 추가합니다.
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16.0),
              child: _buildBikeListItem(bike, isDesktop: isDesktop),
            );
          }).toList(),
        ),

        // 4. 더보기 버튼
        if (_visibleBikeCount < _recommendedBikes.length)
          Padding(
            // 모바일에서만 좌우 여백을 줍니다.
            padding: EdgeInsets.fromLTRB(isDesktop ? 0 : 16.0, 20.0, isDesktop ? 0 : 16.0, 0),
            child: isDesktop
            // --- PC용 버튼 ---
                ? Center(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleBikeCount = _recommendedBikes.length;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text("더보기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
            // --- 모바일용 버튼 ---
                : SizedBox(
              width: double.infinity, // [핵심] 버튼을 화면 전체 너비로 확장
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleBikeCount = _recommendedBikes.length;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), // 세로 높이 증가
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text("더보기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  // 각 자전거 항목을 구성하는 위젯
  // 각 자전거 항목을 구성하는 위젯 (PC/모바일 분기 처리)
  Widget _buildBikeListItem(Bike bike, {required bool isDesktop}) {
    final bool isSelected = _selectedBikes.contains(bike);

    // --- 재사용을 위해 위젯 조각들을 변수로 정의 ---

    // 1. 텍스트 정보 위젯
    final Widget textDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(bike.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(formatPrice(bike.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFE8B21))),
        const SizedBox(height: 8),
        _buildSpecText("자전거 설명: ", bike.spec),
        _buildSpecText("프레임: ", bike.frame),
        _buildSpecText("변속시스템: ", bike.driveSystem),
      ],
    );

    // 2. 선택 상자 위젯
    final Widget checkboxArea = Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );

    // 3. 이미지 위젯
    final Widget bikeImage = Image.asset(bike.imagePath, width: 200, fit: BoxFit.contain);

    // --- 최종 레이아웃 반환 ---
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      // ✅ isDesktop 값에 따라 다른 레이아웃을 반환
      child: isDesktop
          ?
      // --- 🖥️ PC용 레이아웃 ---
      Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          bikeImage,
          const SizedBox(width: 16),
          Expanded(child: textDetails), // 텍스트가 남는 공간 차지
          const SizedBox(width: 8),
          checkboxArea,
        ],
      )
          :
      // --- 📱 모바일용 레이아웃 ---
      Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측: 이미지와 텍스트를 세로로 묶고 남는 공간 모두 차지
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bikeImage,
                const SizedBox(height: 16),
                textDetails,
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 우측: 선택 상자
          checkboxArea,
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

  Widget _buildStep4Report({required bool isDesktop}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedBikesOverview(isDesktop: isDesktop),
        const SizedBox(height: 40),
        _buildSectionTitle("종합 성능 비교"),
        _buildRadarChart(isDesktop: isDesktop),
        const SizedBox(height: 40),
        _buildSectionTitle("상세 스펙 비교"),
        _buildSpecTable(),
        const SizedBox(height: 40),
        _buildSectionTitle("AI 종합 분석"),
        _buildAiAnalysis(isDesktop: isDesktop),
      ],
    );
  }

  // 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  // 선택된 자전거 개요 위젯
  Widget _buildSelectedBikesOverview({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀 헤더 (기존과 동일)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: kHeaderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("AI 분석 자전거 비교 리포트", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("여러 모델의 장단점을 AI가 분석하여 한눈에 비교할 수 있습니다.", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // ✅ LayoutBuilder를 사용하여 부모의 너비를 기준으로 아이템 너비 계산
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16.0, // 가로 간격
              mainAxisSpacing: 16.0,  // 세로 간격
              childAspectRatio: 0.75, // 아이템의 가로:세로 비율
              children: _selectedBikes.toList().asMap().entries.map((entry) {
                return _buildBikeCard(entry.value, entry.key, isDesktop);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBikeCard(Bike bike, int index, isDesktop) {

    final hexCode = kChartColors[index % kChartColors.length];
    final nameColor = Color(int.parse('FF${hexCode.replaceAll('#', '')}', radix: 16));

    return Column(
      children: [
        // 1. 자전거 이미지
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Image.asset(
            bike.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const AspectRatio(
              aspectRatio: 1,
              child: Center(child: Icon(Icons.photo, color: Colors.grey)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 2. 브랜드 태그
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            bike.brand,
            style: const TextStyle(color: Color(0xFF4D4D53), fontSize: 12, fontFamily: 'NotoSansKr', fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 8),
        // 3. 자전거 이름
        // _buildBikeName(bike),
        Text(
          bike.name,
          textAlign: TextAlign.center,
          maxLines: isDesktop ? null : 1,
          overflow: isDesktop ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(color: nameColor, fontSize: isDesktop ? 18 : 15, fontWeight: FontWeight.w700, fontFamily: 'NotoSansKr'),
        ),
        const SizedBox(height: 6),
        // 4. 가격
        Text(
          '${bike.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
          style: TextStyle(fontSize: 15, fontFamily: 'NotoSansKr', color: Color(0xFF4D4D53), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // 레이더 차트 위젯
  Widget _buildRadarChart({required bool isDesktop}) {
    final List<Bike> bikes = _selectedBikes.toList();
    final List<String> titles = ['가성비', '성능', '편의성', '디자인', '유지보수'];

    // HighCharts 위젯에 전달할 데이터 Map 생성
    final Map<String, dynamic> chartData = {
      'chart': {
        'polar': true, // পোলার (레이더) 차트 활성화
        'type': 'line', // 라인 타입으로 지정
      },
      'exporting': {
        'enabled': false,
      },
      'title': {'text': ''},
      'pane': {'size': '80%'},
      'xAxis': {
        'categories': titles,
        'tickmarkPlacement': 'on',
        'lineWidth': 0
      },
      'yAxis': {
        'gridLineInterpolation': 'polygon',
        'lineWidth': 0,
        'min': 0,
        'max': 5,
        'tickInterval': 1,
      },
      'tooltip': {
        'shared': true,
        'pointFormat': '<span style="color:{series.color}">{series.name}: <b>{point.y}</b><br/>'
      },
      // [수정] 범례 설정을 하단으로 변경
      'legend': {
        // 'align': 'center',
        // 'verticalAlign': 'bottom',
        // 'layout': 'horizontal'
        'align': isDesktop ? 'right' : 'center',
        'verticalAlign': isDesktop ? 'middle' : 'bottom',
        'layout': isDesktop ? 'vertical' : 'horizontal',
      },
      'plotOptions': {
        'line': {
          'marker': {
            'enabled': true,
            'radius': 5,
            'lineWidth': 2,
            'symbol': 'circle',
          }
        }
      },
      'series': List.generate(bikes.length, (i) {
        final bike = bikes[i];
        final color = kChartColors[i];
        // logger.i('color value: ${color}');

        return {
          'name': bike.name,
          'data': titles
              .map((title) => bike.performanceStats?[title] ?? 0)
              .toList(),
          'pointPlacement': 'on',
          'color': color,
        };
      }),
      'credits': {'enabled': false},
      'accessibility': {'enabled': false},
    };

    return SizedBox(
      height: 400,
      child: HighCharts(
        data: jsonEncode(chartData),
        size: Size(MediaQuery.of(context).size.width, 400),
      ),
    );
  }

  // 상세 스펙 비교 테이블 위젯
  Widget _buildSpecTable() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return isDesktop ? _buildDesktopSpecTable() : _buildMobileSpecTable();
  }

  Widget _buildDesktopSpecTable() {
    // _selectedBikes는 사용자가 선택한 순서를 유지하는 List입니다.
    final List<Bike> bikes = _selectedBikes.toList();


    // 셀에 일관된 패딩을 적용하기 위한 변수
    const cellPadding = EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0);

    // 1. 자전거 이름 헤더 셀 (색상 있는 텍스트)
    Widget buildBikeHeaderCell(String text, int index) {
      // kChartColors 리스트에서 순서에 맞는 색상을 가져와 적용
      final hexCode = kChartColors[index % kChartColors.length].replaceAll('#', '');
      final color = Color(int.parse('FF$hexCode', radix: 16));

      return Padding(
        padding: cellPadding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
      );
    }

    // 2. 항목 헤더 셀 (첫 번째 열, 굵은 텍스트)
    Widget buildRowHeaderCell(String text) {
      return Padding(
        padding: cellPadding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'NotoSansKr'),
        ),
      );
    }

    // 3. 일반 데이터 셀
    Widget buildCell(String text) {
      return Padding(
        padding: cellPadding,
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontFamily: 'NotoSansKr')),
      );
    }

    return Table(
      // [수정] 세로선 없이 가로선만 표시
      border: TableBorder(
        horizontalInside: BorderSide(width: 1, color: Colors.grey[300]!),
      ),
      // 첫 번째 열의 너비는 내용에 맞게 자동 조절
      columnWidths: const { 0: IntrinsicColumnWidth() },
      // 모든 셀의 내용을 세로 중앙 정렬
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // 헤더 행
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            buildRowHeaderCell("항목"),
            ...bikes.asMap().entries.map((entry) {
              int index = entry.key;
              Bike bike = entry.value;
              return buildBikeHeaderCell(bike.name, index);
            }).toList(),
          ],
        ),

        // 데이터 행
        TableRow(children: [
          buildRowHeaderCell("가격"),
          ...bikes.map((b) => buildCell(formatPrice(b.price))),
        ]),
        TableRow(children: [
          buildRowHeaderCell("프레임"),
          ...bikes.map((b) => buildCell(b.frame)),
        ]),
        TableRow(children: [
          buildRowHeaderCell("무게"),
          ...bikes.map((b) => buildCell('${b.weight}kg')),
        ]),
        TableRow(children: [
          buildRowHeaderCell("기어"),
          ...bikes.map((b) => buildCell('${b.gears}단')),
        ]),
        TableRow(children: [
          buildRowHeaderCell("브레이크"),
          ...bikes.map((b) => buildCell(b.brakeType)),
        ]),
      ],
    );
  }

  // 모바일용 스펙 목록
  Widget _buildMobileSpecTable() {
    final List<Bike> bikes = _selectedBikes.toList();
    final List<String> specTitles = ["가격", "프레임", "무게", "기어", "브레이크"];

    // 각 스펙에 대한 데이터를 가져오는 헬퍼 함수
    String getSpecData(Bike bike, String title) {
      switch (title) {
        case "가격": return formatPrice(bike.price);
        case "프레임": return bike.frame;
        case "무게": return '${bike.weight}kg';
        case "기어": return '${bike.gears}단';
        case "브레이크": return bike.brakeType;
        default: return '';
      }
    }

    return Column(
      children: specTitles.map((title) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              // 각 자전거의 스펙을 세로로 나열
              ...bikes.asMap().entries.map((entry) {
                int index = entry.key;
                Bike bike = entry.value;
                final color = _hexToColor(kChartColors[index % kChartColors.length]);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(bike.name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                      Text(getSpecData(bike, title)),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- [개선] AI 종합 분석 위젯 ---
  Widget _buildAiAnalysis({required bool isDesktop}) {
    final bikes = _selectedBikes.toList();

    // 'AI 총평' 섹션의 개별 요약 라인을 만드는 헬퍼 함수
    Widget buildSummaryRow(Bike bike, int index) {
      final color = _hexToColor(kChartColors[index % kChartColors.length]);

      // ✅ isDesktop 값에 따라 PC와 모바일 레이아웃을 다르게 반환
      if (isDesktop) {
        // --- 🖥️ PC용 가로 레이아웃 ---
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: Text(bike.name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'NotoSansKr')),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(bike.summary, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87, fontFamily: 'NotoSansKr'))),
            ],
          ),
        );
      } else {
        // --- 📱 모바일용 세로 레이아웃 ---
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 자전거 이름
              Text(
                bike.name,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'NotoSansKr'),
              ),
              const SizedBox(height: 8),
              // 요약 내용
              Text(
                bike.summary,
                style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87, fontFamily: 'NotoSansKr'),
              ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. AI 총평 섹션 ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("AI 총평", style: kSectionTitleStyle),
              const SizedBox(height: 20),
              const Text("네 모델은 각기 다른 라이딩 스타일에 최적화되어 있습니다.", style: TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 20),
              Column(
                children: bikes.asMap().entries.map((entry) {
                  return buildSummaryRow(entry.value, entry.key);
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),

        // --- 2. 개별 분석 카드 섹션 (기존과 동일) ---
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: bikes.asMap().entries.map((entry) {
                return SizedBox(
                  width: constraints.maxWidth > 600 ? (constraints.maxWidth / 2 - 10) : double.infinity,
                  child: _buildAnalysisCard(entry.value, entry.key),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

// --- [개선] 개별 분석 카드 위젯 ---
  Widget _buildAnalysisCard(Bike bike, int index) {
    // 카드 테두리 및 버튼에 적용할 고유 색상
    final color = _hexToColor(kChartColors[index % kChartColors.length]);

    // "장점: (분석 내용)" 형태의 텍스트 라인을 만드는 헬퍼
    Widget buildDetailRow(String label, String content) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'Pretendard', height: 1.7),
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: content),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.8)), // 테두리 색상 적용
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 타이틀 (자전거 이름)
          Text(
            bike.name,
            style: TextStyle(
              color: color, // 이름에 고유 색상 적용
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          // 분석 내용
          buildDetailRow("장점", bike.pros.join(', ')), // pros 리스트를 문자열로 변환
          buildDetailRow("단점", bike.cons.join(', ')), // cons 리스트를 문자열로 변환
          buildDetailRow("최적 고객", bike.summary), // summary를 최적 고객 내용으로 활용

          const SizedBox(height: 30),

          // 구매처 보기 버튼
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color, // 버튼 배경색 적용
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("구매처 보기"),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({required bool isDesktop}) {
    final ButtonStyle greyButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[600],
      foregroundColor: Colors.white,
      // PC에서는 가로 패딩을 늘려 좀 더 보기 좋게 만듭니다.
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 40, vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    final ButtonStyle orangeButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFE8B21),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 40, vertical: 18),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    final bool isFirstStep = _currentStep == 0;
    final bool isLastStep = _currentStep == 3;

    // 버튼 위젯 생성 로직
    Widget resetButton = ElevatedButton(
      onPressed: _isGeneratingPdf ? null : (isFirstStep ? _resetStep1 : _previousStep),
      style: greyButtonStyle,
      child: Text(isFirstStep ? '초기화' : '이전'),
    );

    Widget nextButton = ElevatedButton(
      onPressed: _isGeneratingPdf ? null : (isLastStep ? _generateAndSavePdf : _nextStep),
      style: orangeButtonStyle,
      child: _isGeneratingPdf && isLastStep
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      )
          : Text(isLastStep ? '저장' : '다음'),
    );

    // isDesktop 값에 따라 다른 레이아웃 반환
    if (isDesktop) {
      // --- PC용 레이아웃 (Expanded 없음) ---
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          resetButton,
          const SizedBox(width: 20),
          nextButton,
        ],
      );
    } else {
      // --- 모바일용 레이아웃 (Expanded 사용) ---
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: resetButton),
          const SizedBox(width: 20),
          Expanded(child: nextButton),
        ],
      );
    }
  }

  // --- [개선] 모든 리포트 정보를 포함하는 PDF 생성 함수 ---
  Future<void> _generateAndSavePdf() async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);

    try {
      final bikes = _selectedBikes.toList();
      if (bikes.isEmpty) {
        logger.e('PDF 보고서 실패, bikes : ${bikes}');
        IconSnackBar.show(context, snackBarType: SnackBarType.alert, label: 'PDF 보고서 실패');
        setState(() => _isGeneratingPdf = false);
        return;
      }

      // if (_pdfFont == null) {
      //   logger.e('PDF 보고서 저장 실패, _pdfFont : ${_pdfFont}');
      //   IconSnackBar.show(context, snackBarType: SnackBarType.alert, label: 'PDF 보고서 저장 실패');
      //   setState(() => _isGeneratingPdf = false);
      //   return;
      // }

      final fontData = await rootBundle.load("assets/fonts/NotoSansKR-Regular.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/NotoSansKR-Bold.ttf");
      final font = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(boldFontData);

      // --- 2. 테마 정의 시 fontFallback 추가 ---
      final myTheme = pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ).copyWith(
        // 문서 전체에 적용될 기본 스타일 정의
        defaultTextStyle: pw.TextStyle(fontSize: 10),

        // 헤더 레벨별 스타일 정의
        header1: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        header2: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),

        // 테이블 스타일 정의
        tableHeader: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        tableCell: pw.TextStyle(),
      );

      final doc = pw.Document(theme: myTheme);
      IconSnackBar.show(context, snackBarType: SnackBarType.alert, label: 'PDF 보고서 진행 중');

      final List<String> titles = ['가성비', '성능', '편의성', '디자인', '유지보수'];
      final headers = <String>['항목', ...bikes.map((b) => b.name)];
      final data = titles.map((title) {
        final row = <String>[
          title,
          ...bikes.map((bike) => bike.performanceStats[title]?.toString() ?? '0')
        ];
        return row;
      }).toList();


      final List<pw.ImageProvider> bikeImages = [];
      for (final bike in bikes) {
        final imageBytes = await rootBundle.load(bike.imagePath);
        bikeImages.add(pw.MemoryImage(imageBytes.buffer.asUint8List()));
      }

      // --- 2. PDF 스타일 정의 ---
      final baseStyle = pw.TextStyle(font: font, fontSize: 10);
      final titleStyle = pw.TextStyle(font: font, fontSize: 20, fontWeight: pw.FontWeight.bold);
      final sectionTitleStyle = pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800);
      final bikeNameStyle = pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold);

      // --- 3. PDF 페이지 및 콘텐츠 구성 ---
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) =>
          [
            // -- 문서 제목 --
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  // 기존 제목
                  pw.Text('AI 자전거 비교 리포트', style: titleStyle),
                  // [추가] 오늘 날짜를 표시하는 Text 위젯
                  pw.Text(
                    DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                    style: baseStyle.copyWith(color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
            // pw.Divider(thickness: 1.5),
            pw.SizedBox(height: 10),

            // -- [추가] 선택된 자전거 개요 --
            pw.Text('자전거 비교', style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(bikes.length, (i) {
                return pw.SizedBox(
                    width: 120,
                    child: pw.Column(
                        children: [
                          pw.Image(bikeImages[i], height: 80,
                              fit: pw.BoxFit.contain),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            bikes[i].brand,
                            style: baseStyle.copyWith(color: PdfColors.grey600, fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 4), // 브랜드명과 제품명 사이의 작은 간격

                          pw.Text(
                            bikes[i].name,
                            style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            formatPrice(bikes[i].price),
                            style: baseStyle,
                            textAlign: pw.TextAlign.center,
                          ),
                        ]
                    )
                );
              }),
            ),
            pw.SizedBox(height: 30),

            // -- [추가] 종합 성능 비교 --
            pw.Text('종합 성능 비교', style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellHeight: 30,
              cellAlignments: { for (var i = 1; i < headers.length; i++) i: pw.Alignment.center },
              cellStyle: pw.TextStyle(font: font),
            ),
            pw.SizedBox(height: 30),

            // -- 상세 스펙 테이블 --
            pw.Text('상세 스펙 비교', style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headerStyle: bikeNameStyle.copyWith(fontSize: 10),
              cellStyle: baseStyle,
              headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200),
              headers: <String>['항목', ...bikes.map((b) => b.name)],
              data: <List<String>>[
                ['가격', ...bikes.map((b) => formatPrice(b.price))],
                ['프레임', ...bikes.map((b) => b.frame)],
                ['무게', ...bikes.map((b) => '${b.weight}kg')],
                ['기어', ...bikes.map((b) => '${b.gears}단')],
                ['브레이크', ...bikes.map((b) => b.brakeType)],
              ],
            ),
            pw.SizedBox(height: 30),

            // -- [개선] AI 종합 분석 --
            pw.NewPage(),
            pw.Text('AI 종합 분석', style: sectionTitleStyle),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              // 선택된 자전거들의 summary를 순서대로 보여줍니다.
              child: pw.Column(
                children: bikes.map((bike) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12.0),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // 글머리 기호
                        pw.SizedBox(width: 15, child: pw.Text('• ')),
                        // 자전거 이름과 요약 내용
                        pw.Expanded(
                          // pw.Text.rich를 사용해 한 문장 안에서 다른 스타일을 적용합니다.
                            child: pw.RichText(
                              text: pw.TextSpan(
                                  style: baseStyle,
                                  children: [
                                    pw.TextSpan(
                                      text: '${bike.name}: ',
                                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                    ),
                                    pw.TextSpan(text: bike.summary),
                                  ]
                              ),
                            )
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            pw.SizedBox(height: 30),

           // 'AI 개별 분석' 섹션 (기존과 동일)
           //  pw.Text('AI 개별 분석', style: sectionTitleStyle),
           //  pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 20,
              runSpacing: 20,
              children: bikes.map((bike) {
                return pw.Container(
                    width: 240, // A4 너비에 맞춰 2열 배치
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400)),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(bike.name, style: bikeNameStyle),
                          pw.SizedBox(height: 10),
                          pw.Text('장점: ${bike.pros.join(', ')}',
                              style: baseStyle),
                          pw.Text('단점: ${bike.cons.join(', ')}',
                              style: baseStyle),
                          pw.SizedBox(height: 5),
                          pw.Text('최적 고객: ${bike.summary}', style: baseStyle),
                        ]
                    )
                );
              }).toList(),
            ),
          ],
        ),
      );

      // 4. PDF 미리보기 및 저장/인쇄 화면 표시
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name:'AI 분석 자전거 비교 리포트_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf'
      );

      IconSnackBar.show(context, snackBarType: SnackBarType.success, label: 'PDF 보고서 완료');
    } catch (e) {
      logger.e('PDF 보고서 실패 : $e');
      IconSnackBar.show(context, snackBarType: SnackBarType.fail, label: 'PDF 보고서 실패');
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }
}