import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_full_alton/utils/providers.dart';
import 'package:web_full_alton/utils/logger.dart';

// 상단 앱 바 위젯
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final bool isDesktop;

  const AppHeader({
    super.key,
    required this.isDesktop,
  });

  Widget _separator({required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(fontSize: 12, color: color)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isScrolled = ref.watch(isScrolledProvider);
    final Color textColor = Colors.black;

    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.75),
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      // actions: const <Widget>[],
      actions: [
        if (!isDesktop)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
      ],
      title: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/'),
                child: Image.asset('logo/logo-def.png', height: isDesktop ? 24 : 16),
              ),
              if (isDesktop)
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    _navButton(context, 'HOME', '/', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/'),
                    _navButton(context, 'AI 맞춤 자전거 찾기', '/find', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/find'),
                    _navButton(context, 'AI 시세 조회하기', '/price', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/price'),
                    const Spacer(),
                    _userMenuButton('로그인', color: textColor),
                    _separator(color: textColor),
                    _userMenuButton('회원가입', color: textColor),
                    _separator(color: textColor),
                    _userMenuButton('알톤몰', color: textColor),
                    const SizedBox(width: 20),
                    Icon(Icons.language, color: textColor, size: 20),
                    const SizedBox(width: 5),
                    Text('KOR', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              if (!isDesktop)
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      _navButton(context, 'HOME', '/', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/'),
                      _navButton(context, 'AI 자전거', '/find', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/find'),
                      _navButton(context, 'AI 시세', '/price', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/price'),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // ### 3. 네비게이션 버튼 텍스트 색상을 흰색으로 변경 ###
  Widget _navButton(BuildContext context, String text, String routeName, {bool isActive = false, required Color color}) {
    final activeColor = const Color(0xFFFE8B21);
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(activeColor.withOpacity(0.1)),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered)) return activeColor;
          return isActive ? activeColor : color;
        }),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    );
  }

  Widget _userMenuButton(String text, {required Color color}) {
    final hoverColor = const Color(0xFFFE8B21);
    return TextButton(
      onPressed: () {},
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
        minimumSize: MaterialStateProperty.all(Size.zero),
        overlayColor: MaterialStateProperty.all(hoverColor.withOpacity(0.1)),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered)) return hoverColor;
          return color;
        }),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

// 모바일용 Drawer 메뉴 위젯
class _NavigationItem {
  const _NavigationItem({required this.title, required this.routeName});
  final String title;
  final String routeName;
}

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  // 2. 관리하기 쉽도록 메뉴 데이터를 리스트로 분리
  static const List<_NavigationItem> _navItems = [
    _NavigationItem(title: 'HOME', routeName: '/'),
    _NavigationItem(title: 'AI 맞춤 자전거 찾기', routeName: '/find'),
    _NavigationItem(title: 'AI 시세 조회하기', routeName: '/price'),
  ];

  // 3. 색상을 상수로 정의하여 중복 제거 및 일관성 유지
  static const Color _activeColor = Color(0xFFFE8B21);

  // Helper method: 내비게이션 리스트 타일 생성
  Widget _buildDrawerItem(
      BuildContext context, {
        required _NavigationItem item,
        required String? currentRoute,
      }) {
    final bool isActive = item.routeName == currentRoute;

    return ListTile(
      title: Text(
        item.title,
        style: TextStyle(
          color: isActive ? _activeColor : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // 드로어 먼저 닫기
        if (!isActive) {
          Navigator.pushNamed(context, item.routeName);
        }
      },
      selected: isActive,
      selectedTileColor: _activeColor.withOpacity(0.1),
    );
  }

  // Helper method: 일반 액션 리스트 타일 생성
  Widget _buildActionItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.black54)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5. 현재 경로를 build 메서드 시작 시 한 번만 가져옴
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.50,
      backgroundColor: Colors.white,

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- 1. Drawer Header ---
          Container(
            // 1. 원하는 높이를 직접 지정합니다 (예: 100).
            height: 100,
            width: double.infinity, // 너비는 꽉 채우도록 설정
            decoration: const BoxDecoration(
              color: _activeColor, // 기존과 동일한 배경색
            ),
            child: SafeArea( // 2. 상태 표시줄 영역을 피하기 위해 SafeArea 추가
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // 드로어 닫기
                  if (currentRoute != '/') {
                    Navigator.pushNamed(context, '/');
                  }
                },
                child: Center( // 3. 로고를 중앙에 배치하기 위해 Center 위젯 사용
                  child: Image.asset(
                    'logo/logo-white.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // --- 2. Main Navigation Items (데이터 기반으로 생성) ---
          // 6. for-in 루프를 사용하여 코드를 더욱 간결하게 만듦
          for (final item in _navItems)
            _buildDrawerItem(context, item: item, currentRoute: currentRoute),

          // --- 3. Divider and Secondary Actions ---
          const Divider(height: 1, thickness: 1),

          _buildActionItem('로그인', () {
            Navigator.pop(context);
            // TODO: 로그인 화면으로 이동하는 로직 구현
          }),
          _buildActionItem('회원가입', () {
            Navigator.pop(context);
            // TODO: 회원가입 화면으로 이동하는 로직 구현
          }),
          _buildActionItem('알톤몰', () {
            Navigator.pop(context);
            // TODO: 외부 링크(알톤몰)를 여는 로직 구현 (url_launcher 등 사용)
          }),
        ],
      ),
    );
  }
}