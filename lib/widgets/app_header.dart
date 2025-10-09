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
    // isScrolled 값에 따라 텍스트/아이콘 색상 결정
    final bool isScrolled = ref.watch(isScrolledProvider);
    logger.i('AppHeader built with isScrolled: $isScrolled');
    final Color textColor = Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        // AppBar 자체는 항상 투명하게 유지
        // backgroundColor: Colors.transparent,
        backgroundColor: Colors.white.withOpacity(0.75),
        // backgroundColor: isScrolled ? Colors.white.withOpacity(1.0) : Colors.white.withOpacity(0.75),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Image.asset('logo/logo-def.png', height: 24),
                ),
                // if (isDesktop)
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 50),
                      _navButton(context, 'HOME', '/', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/'),
                      _navButton(context, 'AI 맞춤 자전거 찾기', '/find', color: textColor, isActive: ModalRoute.of(context)?.settings.name == '/find'),
                      _navButton(context, 'AI 시세 조회하기', '/', color: textColor),
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
                // if (!isDesktop)
                //   IconButton(
                //     icon: Icon(Icons.menu, color: textColor),
                //     onPressed: () { /* TODO: Drawer 구현 */ },
                //   ),
              ],
            ),
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

  // ### 4. 유저 메뉴 버튼 텍스트 색상을 흰색으로 변경 ###
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