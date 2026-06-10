import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../nav.dart';
import '../theme.dart';
import 'home_feed_screen.dart';
import 'theater_screen.dart';
import 'ai_drama_screen.dart';
import 'ai_interactive_screen.dart';
import 'me_screen.dart';
import '../ui/announce_popup.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 进场拉「上新公告」，有未看过的就弹一次炫窗（静默失败，绝不打断用户）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AnnouncePopup.maybeShow(context);
    });
  }

  // 中间 index 2 = 凸起核心按钮「互动剧」(王牌)，不进字标行（mark 为空），单独渲染。
  static const _tabs = [
    _TabDef('H', '首页', Icons.home_rounded),
    _TabDef('T', '剧场', Icons.grid_view_rounded),
    _TabDef('', '互动剧', Icons.auto_awesome_rounded), // 中间核心（凸起）= AI 互动剧
    _TabDef('C', '角色', Icons.groups_rounded), // 角色元宇宙（星云 hub）
    _TabDef('M', '我的', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    // 每次重建传入「首页是否当前 Tab」，离开首页时暂停其视频（避免后台还在出声）
    final pages = <Widget>[
      HomeFeedScreen(active: _index == 0),
      const TheaterScreen(),
      const AiDramaScreen(), // C 位 = AI 互动剧（王牌片单+理念+愿景阶梯）
      const AiInteractiveScreen(), // 角色 = 角色元宇宙（星云 hub）
      const MeScreen(),
    ];
    return Scaffold(
      backgroundColor: FF.bg,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        index: _index,
        onTap: (i) {
          // 先置位：离开首页时让首页视频立刻暂停（不等 IndexedStack 离屏重建）。
          homeTabActive.value = i == 0;
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _TabDef {
  final String mark;
  final String label;
  final IconData icon;
  const _TabDef(this.mark, this.label, this.icon);
}

class _BottomNav extends StatelessWidget {
  final List<_TabDef> tabs;
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav(
      {required this.tabs, required this.index, required this.onTap});

  static const int _coreIndex = 2;

  @override
  Widget build(BuildContext context) {
    // 贴底·全宽：玻璃条铺满到屏幕左右/底部边，仅顶部圆角；内容上抬避开手势条；
    // 凸起核心球横向居中、从条顶露头（用户拍板：导航顶到底+左右顶到头，不留边）。
    final pad = MediaQuery.of(context).padding.bottom; // 手势条高度
    // 在系统手势条之上再抬一截，标签/图标不贴屏幕底边被切（玻璃仍铺到 bottom:0）。
    final bottomGap = pad + 14;
    return SizedBox(
      height: 82 + bottomGap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 贴底·全宽毛玻璃栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 18, // 顶部留给凸起球露头（露头收窄=球更贴条、不太靠上）
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: EdgeInsets.fromLTRB(6, 6, 6, bottomGap),
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF),
                    border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 20,
                          offset: Offset(0, -4)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(tabs.length, (i) {
                      if (i == _coreIndex) return Expanded(child: _coreSlotLabel(context));
                      return Expanded(child: _sideTab(context, i));
                    }),
                  ),
                ),
              ),
            ),
          ),
          // 凸起核心球：横向居中、浮在栏顶上方
          Positioned(top: 0, left: 0, right: 0, child: Center(child: _coreButton())),
        ],
      ),
    );
  }

  // 选中态 = Codex 原设计的「浅粉蓝渐变药丸按钮」(梦幻) + 深色图标文字；
  // 绝不整片变粉。字保持大、图标干净。美术按 Codex 来，别擅改。
  static const Color _idle = Color(0x9E17120F); // 未选中：清晰中灰
  String _tabLabelFor(BuildContext context, int i) {
    final l = AppLocalizations.of(context);
    switch (i) {
      case 0: return l.tabHome;
      case 1: return l.tabTheater;
      case 2: return l.tabInteractive;
      case 3: return l.tabCharacter;
      case 4: return l.tabMe;
      default: return tabs[i].label;
    }
  }

  Widget _sideTab(BuildContext context, int i) {
    final active = i == index;
    final t = tabs[i];
    final color = active ? FF.textDark : _idle;
    final label = _tabLabelFor(context, i);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.fromLTRB(13, 3, 13, 4),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [
                    FF.hot.withValues(alpha: 0.20),
                    FF.blue.withValues(alpha: 0.20),
                  ])
                : null,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(t.icon, size: 26, color: color),
              const SizedBox(height: 3),
              // FittedBox: 中文短字符原尺寸；英文/日文/韩文长字符自动等比缩，
              // 永不换行（修 v2.0.31 真机 bug：英文"Theater"被截成"Theate / r"）。
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1,
                        letterSpacing: 0.3,
                        color: color,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 玻璃条上中间位的标签（球体凸在它上方）——和两侧标签同字号、底部对齐。
  Widget _coreSlotLabel(BuildContext context) {
    final active = index == _coreIndex;
    final l = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(l.tabInteractive,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                  fontSize: 13,
                  height: 1,
                  letterSpacing: 0.3,
                  color: active ? FF.textDark : _idle,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
        ),
      ),
    );
  }

  // 凸起圆形核心按钮：粉紫蓝主渐变 + 柔光，选中时光更亮、轻微缩放。
  Widget _coreButton() {
    final active = index == _coreIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(_coreIndex),
      child: AnimatedScale(
        scale: active ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FF.brandGradient,
            border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
            boxShadow: [
              BoxShadow(
                  color: FF.hot.withValues(alpha: active ? 0.6 : 0.4),
                  blurRadius: active ? 28 : 20,
                  spreadRadius: 1),
              BoxShadow(
                  color: FF.purple.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
