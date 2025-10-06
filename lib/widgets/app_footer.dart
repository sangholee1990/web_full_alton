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
          color: const Color(0xFFFF7900),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
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
              ),
            ),
          ),
        ),
        // 2. 중간 정보 섹션
        Container(
          color: Colors.white,
          // padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _FooterInfo()),
                    Expanded(flex: 1, child: _FooterQuickLinks()),
                  ],
                )
            ),
          ),
        ),
        // 3. 하단 저작권 섹션
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1))),
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'images/Group2468.png',
                    height: 20,
                  ),
                  const Text(
                    'Copyright © 2025 BikeMetrics. All Rights Reserved.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset( // BIKE METRICS 로고
              'logo/logo-def.png',
              height: 24,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('본사 : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Text('경기도 양주시 칠봉산로120번길 82(봉양동) | 경기도 양주시 봉양동 33-4', style: TextStyle(color: Colors.black, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text('TEL : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Text('(031) 727 - 9100  ', style: TextStyle(color: Colors.black, fontSize: 13)),
                    const Text('A/S : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Text('(031) 859 - 0100  ', style: TextStyle(color: Colors.black, fontSize: 13)),
                    const Text('FAX : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Text('(031) 727 - 9291', style: TextStyle(color: Colors.black, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text('사업자 번호 : ', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    const Text('107-87-33730', style: TextStyle(color: Colors.black, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ],
        ),
        // const SizedBox(height: 20),
      ],
    );
  }
}

class _FooterQuickLinks extends StatelessWidget {
  const _FooterQuickLinks();

  Widget _quickLink(String text) {
    return TextButton(
      onPressed: () {},
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
        _quickLink('HOME'),
        const SizedBox(height: 8),
        _quickLink('AI 맞춤 자전거 찾기'),
        const SizedBox(height: 8),
        _quickLink('AI 시세 조회하기'),
      ],
    );
  }
}
