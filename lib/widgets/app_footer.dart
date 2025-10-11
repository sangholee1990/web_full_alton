import 'package:flutter/material.dart';

// 새로운 푸터 위젯
class AppFooter extends StatelessWidget {
  final bool isDesktop;
  const AppFooter({super.key, required this.isDesktop});

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text('|', style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 상단 주황색 바
        Container(
          color: const Color(0xFFFE8B21),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: isDesktop
                  ? Row( // 데스크톱 레이아웃
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      _footerLinkButton('개인정보처리방침'),
                      _separator(),
                      _footerLinkButton('법적고지'),
                      _separator(),
                      _footerLinkButton('회사소개'),
                    ],
                  ),
                  _footerLinkButton('FAMILY SITE +'),
                ],
              )
                  : Column( // 모바일 레이아웃
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      _footerLinkButton('개인정보처리방침'),
                      _separator(),
                      _footerLinkButton('법적고지'),
                      _separator(),
                      _footerLinkButton('회사소개'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _footerLinkButton('FAMILY SITE +'),
                ],
              ),
            ),
          ),
        ),
        // 2. 중간 정보 섹션
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: isDesktop
                    ? const Row( // 데스크톱 레이아웃
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _FooterInfo()),
                    Expanded(flex: 1, child: _FooterQuickLinks()),
                  ],
                )
                    : const Column( // 모바일 레이아웃
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterInfo(),
                    // SizedBox(height: 30),
                    // _FooterQuickLinks(),
                  ],
                )),
          ),
        ),
        // 3. 하단 저작권 섹션
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1))),
              padding: const EdgeInsets.only(top: 20),
              child: isDesktop
                  ? Row( // 데스크톱 레이아웃
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('images/Group2468.png', height: 20),
                  const Text(
                    'Copyright © 2025 BikeMetrics. All Rights Reserved.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
                  : Column( // 모바일 레이아웃
                children: [
                  Image.asset('images/Group2468.png', height: 20),
                  const SizedBox(height: 10),
                  const Text(
                    'Copyright © 2025 BikeMetrics. All Rights Reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _footerLinkButton(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();
  @override
  Widget build(BuildContext context) {
    // 모바일 대응을 위해 isDesktop 플래그를 가져옵니다.
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Image.asset('logo/logo-def.png', height: 24),
            ],
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 주소
                  const Wrap( // 긴 텍스트 줄바꿈을 위해 Wrap 사용
                    children: [
                      Text('본사 : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('경기도 양주시 칠봉산로120번길 82(봉양동) | 경기도 양주시 봉양동 33-4', style: TextStyle(color: Colors.black, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // 전화/팩스 번호
                  Wrap( // 화면이 좁을 때 줄바꿈을 위해 Wrap 사용
                    runSpacing: 5,
                    children: [
                      const Text('TEL : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      const Text('(031) 727 - 9100  ', style: TextStyle(color: Colors.black, fontSize: 13)),
                      const Text('A/S : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      const Text('(031) 859 - 0100  ', style: TextStyle(color: Colors.black, fontSize: 13)),
                      if (isDesktop) const SizedBox(width: 5), // 데스크톱에서만 간격 추가
                      const Text('FAX : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      const Text('(031) 727 - 9291', style: TextStyle(color: Colors.black, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // 사업자 번호
                  const Row(
                    children: [
                      Text('사업자 번호 : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('107-87-33730', style: TextStyle(color: Colors.black, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterQuickLinks extends StatelessWidget {
  const _FooterQuickLinks();

  Widget _quickLink(BuildContext context, String text, String routeName) {
    return TextButton(
      // 버튼 클릭 시 지정된 경로로 페이지를 이동시킵니다.
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        alignment: Alignment.centerLeft,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _quickLink(context, 'HOME', '/'),
        const SizedBox(height: 8),
        _quickLink(context, 'AI 맞춤 자전거 찾기', '/find'),
        const SizedBox(height: 8),
        _quickLink(context, 'AI 시세 조회하기', '/price'),
      ],
    );
  }
}
