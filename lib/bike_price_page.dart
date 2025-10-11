import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:web_full_alton/widgets/app_header2.dart';
import 'package:web_full_alton/widgets/app_footer.dart';
import 'package:web_full_alton/utils/providers.dart';
import 'package:web_full_alton/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:high_chart/high_chart.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

// 다른 페이지와 일관성을 유지하기 위한 스타일 상수
const Color kPrimaryColor = Color(0xFFFE8B21);
const Color kHeaderColor = Color(0xFF424242);
const Color kGreyTextColor = Color(0xFF868686);
const Color kBorderColor = Color(0xFFD2D2D2);

// [신규] 트리 뷰를 위한 데이터 모델
class Brand {
  final String name;
  final List<String> models;

  Brand({required this.name, required this.models});
}

// Color 객체를 Hex 코드로 변환하기 위한 확장 기능
extension ColorExtension on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

class BikePricePage extends ConsumerStatefulWidget {
  const BikePricePage({super.key});

  @override
  ConsumerState<BikePricePage> createState() => _BikePricePageState();
}

class _BikePricePageState extends ConsumerState<BikePricePage> {
  late final ScrollController _scrollController;
  int _currentStep = 0;

  // final TextEditingController _bikeDisplayController = TextEditingController();
  late final TextEditingController _bikeDisplayController;

  String _selectedBrand = '';
  String _selectedModel = '';
  String _selectedCondition = '중';
  int _endYear = DateTime.now().year;
  int _srtYear = DateTime.now().year - 10;

  static final List<Brand> _brandTree = [
    Brand(name: '알톤 자전거', models: [
      '25알원 R ONE',
      '25자비스16',
      '23인피자 이노사이클 9',
      '23엘리우스-D 105',
    ]),
    Brand(name: '삼천리 자전거', models: [
      '팬텀 Q SF',
      '칼라스 20',
      '레스포 GS',
      '아팔란치아 칼라스',
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bikeDisplayController = TextEditingController();
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
    _bikeDisplayController.dispose();
    super.dispose();
  }

  String formatPrice(int price) {
    return '${NumberFormat('#,###').format(price)}원';
  }

  void _nextStep() {

    if (_selectedBrand.isEmpty && _selectedModel.isEmpty) {
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.alert,
        label: '브랜드 및 모델명을 선택해주세요.',
      );

      return;
    }

    if (_currentStep < 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedBrand = '';
      _selectedModel = '';
      _bikeDisplayController.clear();
      _selectedCondition = '중';
      _endYear = DateTime.now().year;
      _srtYear = DateTime.now().year - 10;
      _currentStep = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final List<Widget> stepContents = [
      _buildStep1Input(),
      _buildStep2Result(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(isDesktop: isDesktop),
      endDrawer: isDesktop ? null : const MobileDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildPageHeader(),
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("AI 시세 조회하기", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _buildStepper(),
                  const SizedBox(height: 40),
                  stepContents[_currentStep],
                ],
              ),
            ),
            AppFooter(isDesktop: isDesktop),
          ],
        ),
      ),
    );
  }

  void _showBikeTreePicker() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: _BikeTreePicker(
            brandTree: _brandTree,
          ),
        );
      },
    );

    // logger.i('Page: 피커로부터 결과 받음 -> $result');

    if (result != null) {
      setState(() {
        _selectedBrand = result['brand']!;
        _selectedModel = result['model']!;
        // logger.i('_selectedBrand : $_selectedBrand');
        // logger.i('_selectedModel.text  : $_selectedModel');
        _bikeDisplayController.text = '${_selectedBrand}/${_selectedModel}';
      });
    }
  }

  Widget _buildPageHeader() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'images/KSH_08911.png',
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
                Text('단 한 번의 조회로 정확한 시세 분석', style: TextStyle(fontSize: isDesktop ? 36 : 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text('방대한 데이터를 학습한 AI가 데이터를 종합 분석하여,\n자전거의 현재 시세부터 미래 가치까지 정밀하게 제공합니다.\n복잡한 데이터 해석 없이도, 누구나 손쉽게 신뢰할 수 있는 가격 정보를 확인할 수 있습니다.', textAlign: TextAlign.left, style: TextStyle(fontSize: isDesktop ? 16 : 13, color: Colors.white, height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    final List<String> steps = ["1. 정보 입력", "2. 결과 확인"];
    final double stepperWidth = MediaQuery.of(context).size.width > 900 ? 900-40 : MediaQuery.of(context).size.width-40;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(steps.length, (index) {
            final bool isActive = index == _currentStep;
            return Expanded(
              child: Column(
                children: [
                  Text(
                    "${steps[index]}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? kPrimaryColor : kGreyTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: isActive ? kPrimaryColor : Colors.grey[300],
                  )
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStep1Input() {
    return Column(
      children: [
        Container(
          // decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4D4D53))),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                // padding: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF4D4D53),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("자전거 정보 입력", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("모델명, 연식, 상태를 입력하면 AI가 정확한 시세를 분석해 드립니다.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),

              Padding(
                // padding: const EdgeInsets.all(24.0),
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("브랜드/모델명", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _bikeDisplayController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: "브랜드/모델명을 선택해주세요.",
                        filled: true,
                        fillColor: Color(0xFFF6F6F6),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onTap: _showBikeTreePicker,
                    ),
                    const SizedBox(height: 30),
                    _buildYearSlider(),
                    const SizedBox(height: 30),
                    _buildConditionSelector(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildYearSlider() {
    final maxYear = DateTime.now().year;
    final minYear = maxYear - 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("연식", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              border: Border.all(color: kBorderColor),
              color: const Color(0xFFF6F6F6)
          ),
          child: Column(
            children: [
              RangeSlider(
                values: RangeValues(_srtYear.toDouble(), _endYear.toDouble()),
                min: minYear.toDouble(),
                max: maxYear.toDouble(),
                divisions: maxYear - minYear,
                labels: RangeLabels(
                  '${_srtYear}년',
                  '${_endYear}년',
                ),
                activeColor: kPrimaryColor,
                inactiveColor: Colors.grey[300],
                onChanged: (RangeValues values) {
                  setState(() {
                    _srtYear = values.start.round();
                    _endYear = values.end.round();
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$minYear년", style: const TextStyle(color: Colors.grey)),
                    Text("$maxYear년", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSelector() {
    final conditions = [
      {'label': '상', 'icon': Icons.sentiment_very_satisfied},
      {'label': '중', 'icon': Icons.sentiment_satisfied},
      {'label': '하', 'icon': Icons.sentiment_dissatisfied},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("자전거 상태", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: conditions.map((condition) {
            final isSelected = _selectedCondition == condition['label'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCondition = condition['label'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : Colors.white,
                    border: Border.all(color: isSelected ? kPrimaryColor : kBorderColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Icon(condition['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey[600]),
                      const SizedBox(height: 4),
                      Text(condition['label'] as String, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Result() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final brand = _selectedBrand;
    final model = _selectedModel;

    final estimatedPrice = 1100000;
    final maxPrice = 1500000;
    final minPrice = 500000;

    final now = DateTime.now();
    final random = math.Random();

    // 4개의 데이터 시리즈를 담을 리스트 초기화
    final List<List<dynamic?>> lowestPriceData = [];
    final List<List<dynamic?>> mlPriceData = [];
    final List<List<dynamic?>> dlPriceData = [];

    // --- 데이터 생성 ---

    // 1. 과거 90일 데이터 생성 (최저가만 실제 값, 나머지는 null)
    for (int i = 90; i > 0; i--) {
      final date = now.subtract(Duration(days: i));
      final timestamp = date.millisecondsSinceEpoch;

      double baseValue = estimatedPrice * (1 - (i / 90) * 0.15);
      double lowestValue = baseValue * (0.9 + random.nextDouble() * 0.1);
      lowestPriceData.add([timestamp, lowestValue.round()]);

      // 과거 시점에는 예측 데이터가 없으므로 null 추가
      mlPriceData.add([timestamp, null]);
      dlPriceData.add([timestamp, null]);
    }

    // 2. '현재' 데이터 생성 (과거와 미래를 잇는 연결점)
    final todayTimestamp = now.millisecondsSinceEpoch;
    double todayLowestValue = estimatedPrice * 0.9 * (0.98 + random.nextDouble() * 0.04);

    // '현재' 시점의 데이터는 모든 시리즈에 동일하게 추가하여 선을 연결
    lowestPriceData.add([todayTimestamp, todayLowestValue.round()]);
    mlPriceData.add([todayTimestamp, todayLowestValue.round()]);
    dlPriceData.add([todayTimestamp, todayLowestValue.round()]);

    // 3. 미래 180일(6개월) 데이터 생성 (3가지 예측 모델)
    for (int i = 1; i <= 180; i++) {
      final date = now.add(Duration(days: i));
      final timestamp = date.millisecondsSinceEpoch;

      // 미래의 최저가는 알 수 없으므로 null
      lowestPriceData.add([timestamp, null]);

      // 3가지 AI 모델에 대한 예측 값 생성
      double baseFutureValue = todayLowestValue * (1 + (i / 180) * 0.18);

      // 머신러닝 예상 시세 (기본보다 약간 낙관적)
      double mlValue = baseFutureValue * 1.05 * (1 + (random.nextDouble() - 0.5) * 0.04);
      mlPriceData.add([timestamp, mlValue.round()]);

      // 딥러닝 예상 시세 (기본보다 약간 더 낙관적)
      double dlValue = baseFutureValue * 1.08 * (1 + (random.nextDouble() - 0.5) * 0.05);
      dlPriceData.add([timestamp, dlValue.round()]);
    }


    final chartData = {
      'chart': {
        'zoomType': 'x',
        'type': 'line',
        if (!isDesktop) 'spacingLeft': 0,
        if (!isDesktop) 'spacingRight': 5,
      },
      'title': {'text': ''},
      'xAxis': {
        'type': 'datetime',
        'dateTimeLabelFormats': {
          'month': '%Y년 %m월',
          'day': '%m월 %d일',
        },
        'startOnTick': true,
        'endOnTick': true,
      },
      'yAxis': {
        'title': {'text': isDesktop ? '가격 (원)' : ''},
      },
      'tooltip': {
        'xDateFormat': '%Y-%m-%d',
        'pointFormat': '{series.name}: <b>{point.y:,.0f}원</b><br/>',
        'shared': true,
      },
      'series': [
        // 시리즈 1: 일별 최저가 (과거 데이터)
        {
          'name': '최저가',
          'data': lowestPriceData,
          'color': kGreyTextColor.toHex(),
          'marker': {'symbol': 'circle', 'radius': 1},
          'zIndex': 1,
        },
        {
          'name': 'AI 시세 (머신러닝)',
          'data': mlPriceData,
          'color': const Color(0xFF7B4B19).toHex(),
          'marker': {'symbol': 'circle', 'radius': 1},
          'zIndex': 2,
        },
        {
          'name': 'AI 시세 (딥러닝)',
          'data': dlPriceData,
          'color': const Color(0xFFBE6201).toHex(),
          'marker': {'symbol': 'circle', 'radius': 1},
          'zIndex': 3,
        },
      ],
      'credits': {'enabled': false},
      'legend': {
        'enabled': true,
        if (!isDesktop) 'itemStyle': {'fontSize': '10px'},
      },
      'exporting': {'enabled': false},
    };

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                // padding: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF4D4D53),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("AI 시세 분석 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text("실시간 데이터를 기반으로 분석된 예상 시세입니다.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('시세 요약', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(24),
                      color: const Color(0xFFF6F6F6),
                      child: Column(
                        children: [
                          Container(
                            color: kPrimaryColor,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${brand}/${model} (연식 ${_srtYear} ~ ${_endYear}년 / 상태: $_selectedCondition)',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          isDesktop
                          ? Row( crossAxisAlignment: CrossAxisAlignment.center, children: _buildSummaryContents(isDesktop))
                          : Column( children: _buildSummaryContents(isDesktop))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('시세 그래프', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: isDesktop ? 1.75 : 0.75,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double chartWidth = constraints.maxWidth;
                          final double chartHeight = constraints.maxHeight;

                          return HighCharts(
                            data: jsonEncode(chartData),
                            size: Size(chartWidth, chartHeight),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildNavigationButtons(),
      ],
    );
  }

  // 시세 요약 콘텐츠를 만드는 헬퍼 메서드
  List<Widget> _buildSummaryContents(bool isDesktop) {
    final estimatedPrice = 1100000;
    final maxPrice = 1500000;
    final minPrice = 500000;

    // ✅ 1. '평균 거래가' 부분을 별도의 위젯 변수로 분리합니다.
    final Widget priceSection = Column(
      mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬 추가
      children: [
        const Text('평균 거래가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(formatPrice(estimatedPrice), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFBE6201))),
      ],
    );

    return [
      Container(
        width: isDesktop ? 250 : double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            'images/25-BOMARC-21D_MATT-BLACK_RGB1.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('이미지 없음', style: TextStyle(color: Colors.grey)));
            },
          ),
        ),
      ),
      SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 24),

      // ✅ 2. isDesktop 값에 따라 Expanded를 조건부로 적용합니다.
      // PC일 때는 Expanded로 감싸고, 모바일일 때는 그냥 위젯을 사용합니다.
      isDesktop ? Expanded(child: priceSection) : priceSection,

      SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 24),
      IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(4)),
              child: Center(child: Text('상한가: ${formatPrice(maxPrice)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: kBorderColor)),
              child: Center(child: Text('하한가: ${formatPrice(minPrice)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildNavigationButtons() {
    final isFirstStep = _currentStep == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          // flex: isFirstStep ? 1 : 1,
          flex: 1,
          child: ElevatedButton(
            onPressed: isFirstStep ? _resetForm : _previousStep,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF868686),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
            ),
            child: Text(isFirstStep ? '초기화' : '다시 조회하기'),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          // flex: isFirstStep ? 2 : 2,
          flex: 1,
          child: ElevatedButton(
            onPressed: isFirstStep ? _nextStep : _resetForm,
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
            ),
            child: Text(isFirstStep ? '결과 확인하기' : '맞춤 자전거 찾기'),
          ),
        ),
      ],
    );
  }
}

class _BikeTreePicker extends StatefulWidget {
  final List<Brand> brandTree;
  final ScrollController? scrollController;

  const _BikeTreePicker({
    required this.brandTree,
    this.scrollController,
  });

  @override
  State<_BikeTreePicker> createState() => _BikeTreePickerState();
}

class _BikeTreePickerState extends State<_BikeTreePicker> {
  late final TextEditingController _searchController;
  List<Brand> _filteredBrandTree = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredBrandTree = widget.brandTree;
    _searchController.addListener(_filterTree);
  }

  void _filterTree() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredBrandTree = widget.brandTree;
    } else {
      _filteredBrandTree = widget.brandTree.map((brand) {
        if (brand.name.toLowerCase().contains(query)) {
          return brand;
        }
        final matchingModels = brand.models.where((model) => model.toLowerCase().contains(query)).toList();
        if (matchingModels.isNotEmpty) {
          return Brand(name: brand.name, models: matchingModels);
        }
        return null;
      }).whereType<Brand>().toList();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTree);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          const Text('브랜드/모델명', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '브랜드/모델명 검색',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _filteredBrandTree.length,
              itemBuilder: (context, index) {
                final brand = _filteredBrandTree[index];
                return ExpansionTile(
                  title: Text(brand.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: _searchController.text.isNotEmpty,
                  children: brand.models.map((model) {
                    return ListTile(
                      title: Text(model),
                      onTap: () {
                        final selection = {'brand': brand.name, 'model': model};
                        // logger.i('Picker: 항목 선택됨 -> $selection');
                        Navigator.of(context).pop(selection);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}