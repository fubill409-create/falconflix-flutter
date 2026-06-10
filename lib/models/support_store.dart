import 'package:flutter/foundation.dart';

import 'ai_character.dart';
import 'level_curve.dart';

/// 运行时应援层（v0 = 本地体验，不接计费后端）。
/// kCharacters 是 const、不可变；这个单例把「我」的打投叠加上去：
/// 累计鹰币 + 出道进度增量 + 把「我」插进应援榜。
/// 详情 / 应援榜 / 角色机会榜都监听它，投完一笔立刻全链路刷新。
class SupportStore extends ChangeNotifier {
  // 角色 id -> 我对 TA 累计投入的鹰币
  final Map<String, int> _myCoins = {};
  // 角色 id -> 我的打投带来的出道进度增量
  final Map<String, double> _bonus = {};

  String myName = '我';

  /// 登录后把昵称带进来当榜单名（没登录就用「我」）。
  void setMyName(String? name) {
    final n = (name ?? '').trim();
    myName = n.isEmpty ? '我' : n;
  }

  int myCoins(String id) => _myCoins[id] ?? 0;
  bool hasSupported(String id) => (_myCoins[id] ?? 0) > 0;

  /// 投一笔。叠加后通知所有监听者，并返回这次的「成果」给庆祝弹层。
  SupportResult support(AiCharacter c, int coins) {
    final newTotal = (_myCoins[c.id] ?? 0) + coins;
    _myCoins[c.id] = newTotal;
    final delta = (coins / 80000.0).clamp(0.004, 0.12);
    _bonus[c.id] = (_bonus[c.id] ?? 0) + delta;
    notifyListeners();

    final rank = rankFor(c);
    return SupportResult(
      coins: coins,
      myTotal: newTotal,
      myLevel: levelForCoins(newTotal),
      progressDelta: delta,
      newProgress: progressFor(c),
      myRank: rank,
      isKing: rank == 1,
    );
  }

  /// 合并后的应援榜（const 榜 + 我），按鹰币降序。
  List<Supporter> boardFor(AiCharacter c) {
    final mine = _myCoins[c.id] ?? 0;
    if (mine <= 0) return c.board;
    final me = Supporter(myName, mine);
    return [...c.board, me]..sort((a, b) => b.coins.compareTo(a.coins));
  }

  /// 合并后的出道进度（const + 我的增量），上限 1.0。
  double progressFor(AiCharacter c) =>
      (c.voteProgress + (_bonus[c.id] ?? 0)).clamp(0.0, 1.0);

  /// 合并后的累计应援鹰币。
  int totalCoinsFor(AiCharacter c) => c.totalCoins + (_myCoins[c.id] ?? 0);

  /// 我在该角色榜单的名次（1-based）；没投过 = 0。
  int rankFor(AiCharacter c) {
    final mine = _myCoins[c.id] ?? 0;
    if (mine <= 0) return 0;
    var ahead = 0;
    for (final s in c.board) {
      if (s.coins > mine) ahead++;
    }
    return ahead + 1;
  }
}

/// 一次应援的成果（喂给庆祝弹层）。
class SupportResult {
  final int coins; // 这次投的
  final int myTotal; // 我累计
  final int myLevel; // 我现在的 V 级别
  final double progressDelta; // 进度增量
  final double newProgress; // 新进度
  final int myRank; // 我在榜单名次
  final bool isKing; // 我是不是登顶榜一
  const SupportResult({
    required this.coins,
    required this.myTotal,
    required this.myLevel,
    required this.progressDelta,
    required this.newProgress,
    required this.myRank,
    required this.isKing,
  });
}

final supportStore = SupportStore();
