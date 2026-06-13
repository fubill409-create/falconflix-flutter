import 'package:flutter/foundation.dart';

import '../api/api.dart';
import 'ai_character.dart';
import 'level_curve.dart';

/// 运行时应援层（已接真后端：真扣鹰币 + 真落榜）。
/// 投一笔 → 调 Api.sendGift → 缓存服务端返回的 myCharTotal / charProgress / myCharRank，
/// 详情 / 应援榜 / 角色机会榜都监听它，投完一笔立刻全链路刷新。
///
/// 读方法（progressFor/boardFor/totalCoinsFor/rankFor/myCoins）签名保持不变，
/// 仅把数据源从 const mock 换成服务端缓存：没拉到时回退到包内 mock（c.voteProgress/c.board），
/// 拉到后以服务端为准。
class SupportStore extends ChangeNotifier {
  // 角色 id -> 我对 TA 累计投入的鹰币（服务端 myCharTotal）
  final Map<String, int> _myCoins = {};
  // 角色 id -> 服务端出道进度（0..1）
  final Map<String, double> _progress = {};
  // 角色 id -> 我在该角色应援榜名次（1-based；服务端 myCharRank）
  final Map<String, int> _myRank = {};
  // 角色 id -> 该角色应援榜（服务端 backers），降序
  final Map<String, List<Supporter>> _board = {};

  String myName = '我';

  /// 登录后把昵称带进来当榜单名（没登录就用「我」）。
  void setMyName(String? name) {
    final n = (name ?? '').trim();
    myName = n.isEmpty ? '我' : n;
  }

  int myCoins(String id) => _myCoins[id] ?? 0;
  bool hasSupported(String id) => (_myCoins[id] ?? 0) > 0;

  /// 鹰币档位 → 礼物 code（与后端 6 档礼物一一对应）。
  static String giftCodeForCoins(int coins) {
    switch (coins) {
      case 66:
        return 'rose';
      case 188:
        return 'lollipop';
      case 520:
        return 'crown';
      case 1314:
        return 'sportscar';
      case 3344:
        return 'rocket';
      case 9999:
        return 'carnival';
      default:
        // 兜底：挑就近不超过的一档（理论上不会走到，档位由 UI 固定）。
        if (coins >= 9999) return 'carnival';
        if (coins >= 3344) return 'rocket';
        if (coins >= 1314) return 'sportscar';
        if (coins >= 520) return 'crown';
        if (coins >= 188) return 'lollipop';
        return 'rose';
    }
  }

  /// 投一笔（真扣鹰币 + 真落榜）。成功后缓存服务端结果并通知监听者，
  /// 返回这次的「成果」给庆祝弹层。鹰币不足 / 网络等错误向上抛 ApiException。
  Future<SupportResult> support(AiCharacter c, int coins) async {
    final giftCode = giftCodeForCoins(coins);
    final requestId =
        '${DateTime.now().microsecondsSinceEpoch}_${c.id}';
    final res = await Api.sendGift(
      characterId: c.id,
      giftCode: giftCode,
      requestId: requestId,
    );

    final myCharTotal = (res['myCharTotal'] as num?)?.toInt() ?? coins;
    final charProgress = (res['charProgress'] as num?)?.toDouble() ?? 0.0;
    final myCharRank = (res['myCharRank'] as num?)?.toInt() ?? 0;
    final isKing = res['isKing'] == true;

    _myCoins[c.id] = myCharTotal;
    _progress[c.id] = charProgress.clamp(0.0, 1.0);
    if (myCharRank > 0) _myRank[c.id] = myCharRank;
    notifyListeners();

    return SupportResult(
      coins: coins,
      myTotal: myCharTotal,
      myLevel: levelForCoins(myCharTotal),
      progressDelta: 0,
      newProgress: charProgress.clamp(0.0, 1.0),
      myRank: myCharRank,
      isKing: isKing,
    );
  }

  /// 拉某角色的应援榜 + 我的累计/名次（screen 进页时调）。失败静默（保留旧值/回退 mock）。
  Future<void> refreshChar(String charId) async {
    try {
      final m = await Api.giftCharBoard(charId);
      final data = (m['data'] as List?) ?? const [];
      final backers = <Supporter>[
        for (final r in data.whereType<Map>())
          Supporter(
            _displayName(r['name']),
            (r['total'] as num?)?.toInt() ?? 0,
          ),
      ];
      _board[charId] = backers;
      final myTotal = (m['myTotal'] as num?)?.toInt() ?? 0;
      if (myTotal > 0) _myCoins[charId] = myTotal;
      final myRank = (m['myRank'] as num?)?.toInt() ?? 0;
      if (myRank > 0) _myRank[charId] = myRank;
      notifyListeners();
    } catch (_) {
      // 失败：保留已有缓存 / 回退 mock，不抛。
    }
  }

  /// 该角色应援榜：拉到服务端数据则用之，否则回退包内 mock（c.board）。
  List<Supporter> boardFor(AiCharacter c) => _board[c.id] ?? c.board;

  /// 出道进度：拉到服务端值则用之，否则回退包内 mock（c.voteProgress）。
  double progressFor(AiCharacter c) =>
      (_progress[c.id] ?? c.voteProgress).clamp(0.0, 1.0);

  /// 累计应援鹰币：有榜单则求和，否则回退包内 mock（c.totalCoins）。
  int totalCoinsFor(AiCharacter c) {
    final b = _board[c.id];
    if (b != null) return b.fold(0, (s, e) => s + e.coins);
    return c.totalCoins;
  }

  /// 我在该角色榜单的名次（1-based）；没投过 / 未知 = 0。
  int rankFor(AiCharacter c) => _myRank[c.id] ?? 0;

  /// 榜单名兜底：服务端用户名可能为空/UUID，空则用「鹰眼用户」。
  static String _displayName(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    return s.isEmpty ? '鹰眼用户' : s;
  }
}

/// 一次应援的成果（喂给庆祝弹层）。
class SupportResult {
  final int coins; // 这次投的
  final int myTotal; // 我累计
  final int myLevel; // 我现在的 V 级别
  final double progressDelta; // 进度增量（真后端只给绝对进度，这里恒 0）
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
