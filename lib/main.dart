import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bike_finder_page.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'package:web_full_alton/utils/providers.dart';

// main 함수: 앱의 시작점
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(const MyApp());

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// MyApp 클래스: 앱의 루트 위젯, 라우팅 정의
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '바이크메트릭스 AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFE8B21), // 메인 오렌지 색상 (Figma 기준)
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1A1A1A)), // 기본 텍스트 색상
          bodyMedium: TextStyle(color: Color(0xFF555555)),
        ),
      ),
      // 라우트(경로) 정의
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/find': (context) => const BikeFinderPage(),
      },
    );
  }
}



// --- 페이지 1: 홈페이지 ---
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final shouldBeScrolled = _scrollController.offset > 0;
    if (ref.read(isScrolledProvider) != shouldBeScrolled) {
      ref
          .read(isScrolledProvider.notifier)
          .state = shouldBeScrolled;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(isDesktop: isDesktop),
        body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildBrandSection(context),
                _buildCoreFunctionsSection(context, isDesktop),
                _buildCollaborationSection(),
                _buildApplicationSection(context, isDesktop),
                AppFooter(isDesktop: isDesktop),
              ],
            ),
        ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft, // 콘텐츠를 왼쪽으로 정렬
      children: [
        // Image.asset('images/Rectangle3407.jpg', height: 730, width: 1280, fit: BoxFit.cover, color: Colors.black.withOpacity(0.3), colorBlendMode: BlendMode.darken),
        const ImageSlider(),
        // 2. 텍스트 및 버튼 콘텐츠
        Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '나에게 꼭 맞는 자전거,\n'),
                    TextSpan(
                      text: '바이크메트릭스 AI',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    const TextSpan(text: ' 가 찾아드립니다!'),
                  ],
                ),
                textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '당신의 라이딩 경험을 혁신적으로 바꿔줄 단 하나의 자전거를 찾으세요.\nAI 맞춤 컨설턴트가 당신의 신체 사이즈, 주행 습관, 선호하는 디자인까지\n고려해 최적의 자전거를 추천합니다.\n세상에 단 하나뿐인 당신을 위한 완벽한 자전거, AI 컨설턴트와 함께 만나보세요.',
                textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400, height: 1.6),
              ),
              const SizedBox(height: 40),
              // 3. 버튼 디자인 변경
              Row(
                children: [
                  _actionButton(context, 'AI 맞춤 자전거 찾기', '/find', primary: true),
                  const SizedBox(width: 20),
                  _actionButton(context, 'AI 시세 조회하기', '/', primary: false),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String text, String routeName, {bool primary = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // primary 값에 따라 배경색과 글자색 변경
        backgroundColor: primary ? Colors.white : const Color(0xFFFE8B21),
        foregroundColor: primary ? const Color(0xFFFE8B21) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 각진 모서리
        elevation: 0,
      ),
      onPressed: () => Navigator.pushNamed(context, routeName),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), letterSpacing: -0.72)),
        const SizedBox(height: 15),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFF868686), fontWeight: FontWeight.w700, letterSpacing: -0.36)),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    // ### 1. 로고 파일 이름 목록으로 변경 ###
    final List<String> logoImages = [
      'images/Group140.png', // alton
      'images/Group151.png', // ealton
      'images/Group150.png', // INFIZA
      'images/Group149.png', // COREX
      'images/Group148.png', // ROADMASTER
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              // ### 2. 부제목 텍스트 스타일 수정 ###
              Column(
                children: [
                  const Text('BRAND', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A), letterSpacing: -0.72)),
                  const SizedBox(height: 15),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 18, color: Color(0xFF868686), fontWeight: FontWeight.w500, letterSpacing: -0.36),
                      children: <TextSpan>[
                        TextSpan(text: '알톤', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700)),
                        const TextSpan(text: '을 비롯한 국내외 '),
                        TextSpan(text: '유명 브랜드', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: '의 자전거를 한곳에서 비교하고 선택할 수 있습니다.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
              // ### 3. 로고를 Text에서 Image.asset으로 변경 ###
              Wrap(
                spacing: 20, // 로고 사이의 가로 간격
                runSpacing: 20, // 로고 사이의 세로 간격
                alignment: WrapAlignment.center,
                children: logoImages.map((logoPath) => Container(
                    width: 240, // 로고 박스 너비
                    height: 100, // 로고 박스 높이
                    padding: const EdgeInsets.all(20), // 내부 여백
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0)
                    ),
                    child: Center(
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit.contain, // 이미지가 박스 안에 맞춰지도록
                      ),
                    )
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CORE FUNCTIONS 섹션 위젯
  Widget _buildCoreFunctionsSection(BuildContext context, bool isDesktop) {
    // ### 1. 데이터 목록에 이미지 경로(imagePath) 추가 ###
    final List<Map<String, dynamic>> functions = [
      {
        'imagePath': 'images/Rectangle3415-1.jpg', // AI 맞춤 추천 이미지
        'title': 'AI 맞춤 자전거 추천',
        'desc': 'AI가 당신의 신체 정보, 예산, \n라이딩 스타일을 분석해 최적의 \n자전거를 추천해 드립니다.'
      },
      {
        'imagePath': 'images/Rectangle3415-2.jpg', // 스펙 비교 리포트 이미지
        'title': '스펙 비교 리포트',
        'desc': 'AI가 여러 모델의 장단점을 비교 \n분석한 스마트 리포트를 제공합니다.'
      },
      {
        'imagePath': 'images/Rectangle3415-3.jpg', // AI 시세 예측 이미지
        'title': 'AI 시세 예측',
        'desc': '방대한 데이터를 \n학습한 AI가 자전거의 현재와 \n미래 가치를 정밀하게 제공합니다.'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFFF6F6F6),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _buildSectionTitle('CORE FUNCTIONS', '사용자의 개인적인 특성과 선호도를 심층적으로 분석하여 가장 적합한 자전거를 추천하는 기능입니다.'),
              isDesktop
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: functions.map((f) {
                  return Expanded(
                    child: _buildFunctionCard(context, f),
                  );
                }).toList(),
              )
                  : Column(children: functions.map((f) => _buildFunctionCard(context, f, isMobile: true)).toList())
            ],
          ),
        ),
      ),
    );
  }

// ### 2. Function Card 위젯 디자인 전체 수정 ###
  Widget _buildFunctionCard(BuildContext context, Map<String, dynamic> data, {bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카드 상단 이미지
            Image.asset(
              data['imagePath'],
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // ### 1. SizedBox로 최소 높이를 지정하여 카드 전체 높이를 통일 ###
            SizedBox(
              width: double.infinity, // 너비를 최대로 채움
              height: 200, // 카드의 텍스트 영역 최소 높이 지정
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16)
                        ),
                        const SizedBox(width: 10),
                        Text(
                            data['title'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    // ### 2. 설명 텍스트가 남은 공간을 차지하도록 설정 ###
                    // (Spacer와 함께 사용하여 아래 콘텐츠를 밀어낼 수도 있지만,
                    //  설명 텍스트 자체가 유연하게 공간을 차지하는 것이 더 간단합니다.)
                    Text(
                        data['desc'],
                        style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.w500, height: 1.6)
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborationSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('images/batch_CR6_5393.jpg', height: 800, width: double.infinity, fit: BoxFit.cover),
        Container(height: 800, color: Colors.black.withOpacity(0.0)),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Alton x Bike Metrics', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 80, fontFamily: 'NotoSansKr', fontWeight: FontWeight.w700, height: 0.7, letterSpacing: -1.6,)),
            SizedBox(height: 40),
            Text('당신이 꿈꾸는 모든 길,\nAI가 안내하는 최고의 자전거와 함께', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'NotoSansKr', fontWeight: FontWeight.w500, height: 1.58, letterSpacing: -0.48,)),
          ],
        )
      ],
    );
  }

  Widget _buildApplicationSection(BuildContext context, bool isDesktop) {
    // ### 1. 데이터 목록에서 SVG 경로를 IconData로 변경 ###
    final List<Map<String, dynamic>> apps = [
      {
        'imagePath': 'images/Rectangle3415-1.png',
        'iconData': Icons.search,
        'title': '자전거 입문자',
        'desc': '어디서부터 시작해야 할지 모르는 초보자에게 최적의 모델을 추천'
      },
      {
        'imagePath': 'images/Rectangle3415-2.png',
        'iconData': Icons.article_outlined,
        'title': '경험있는 라이더',
        'desc': '업그레이드와 교체 시점을 스마트하게 결정하도록 지원'
      },
      {
        'imagePath': 'images/Rectangle3415-3.png',
        'iconData': Icons.calendar_today_outlined,
        'title': '미래 가치를 중시하는 분',
        'desc': '단순 구매가 아닌, 향후 중고가치까지 고려한 스마트한 소비 지원'
      },
      {
        'imagePath': 'images/Rectangle3415-4.png',
        'iconData': Icons.schedule_outlined,
        'title': '시간을 절약하고 싶은 분',
        'desc': '일일이 비교할 필요 없이, AI로 맞춤형 리포트로 빠르고 정확하게 비교'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFFF6F6F6),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              _buildSectionTitle('Application', '바이크 메트릭스 이렇게 활용해 보세요!'),

              // ### 해결: GridView를 Wrap 위젯으로 교체 ###
              Wrap(
                spacing: 20, // 카드 사이의 가로 간격
                runSpacing: 20, // 카드 사이의 세로 간격
                alignment: WrapAlignment.center, // 가운데 정렬
                children: apps.map((app) {
                  // ### 각 카드의 너비를 지정하여 한 줄에 표시될 개수 제어 ###
                  return SizedBox(
                    width: isDesktop ? 295 : (MediaQuery.of(context).size.width / 2) - 30,
                    child: _buildApplicationCard(app),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Application Card 위젯 (세로 스크롤 제거 버전)
  Widget _buildApplicationCard(Map<String, dynamic> data) {
    // ### 중요: Card를 IntrinsicHeight로 감싸서 내부 높이를 콘텐츠에 맞춤 ###
    return IntrinsicHeight(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              data['imagePath'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFE8B21),
                              borderRadius: BorderRadius.circular(7)
                          ),
                          child: Icon(
                            data['iconData'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              data['title'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['desc'],
                      style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.w500, height: 1.6),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _current = 0; // 현재 배너 인덱스를 위한 변수
  final CarouselSliderController _controller = CarouselSliderController();

  // 슬라이드에 표시할 이미지 목록
  final List<String> _imagePaths = [
    'images/Rectangle3407.jpg',
    'images/MainB_kor_1920_2025.jpg',
    'images/MainD_kor_1920_2025.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter, // 인디케이터를 하단 중앙에 배치
      children: [
        // CarouselSlider 위젯
        CarouselSlider.builder(
          itemCount: _imagePaths.length,
          itemBuilder: (context, index, realIndex) {
            return Image.asset(
              _imagePaths[index],
              height: 730,
              width: double.infinity, // 너비를 최대로 설정
              fit: BoxFit.cover,
              // color: Colors.black.withOpacity(0.3),
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            );
          },
          options: CarouselOptions(
            height: 730, // 슬라이더 높이
            viewportFraction: 1.0, // 화면에 하나의 이미지만 보이도록 설정
            autoPlay: true, // 자동 슬라이드 활성화
            autoPlayInterval: const Duration(seconds: 5), // 전환 간격 5초
            autoPlayAnimationDuration: const Duration(milliseconds: 800), // 애니메이션 속도
            autoPlayCurve: Curves.fastOutSlowIn, // 애니메이션 커브
            enlargeCenterPage: false, // 중앙 페이지 확대 비활성화
            onPageChanged: (index, reason) {
              // 페이지가 변경될 때마다 _current 변수 업데이트
              setState(() {
                _current = index;
              });
            },
          ),
        ),

        // 인디케이터(점) 위젯
        Positioned(
          bottom: 20.0, // 하단에서 20px 띄움
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _imagePaths.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
