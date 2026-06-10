import 'dart:math' as math;

/// 面子系统 V1–V99 等级曲线（唯一来源）。
///
/// 设计（2026-06-05 用户拍板，见 docs/PRICING_SYSTEM_IMPLEMENTATION_PLAN.md §1）：
/// 基准 $1 = 100 鹰币。按「累计**付费**鹰币」定级，曲线要**陡峭**——
/// 普通用户充到头也就 V10–V20，破 V50 才算大客户，V90+ 超指数几乎不可达，
/// 这样大佬才有尊贵感（旧 log 公式太平：$1万→V35、$100万→才 V52，人人破 V50）。
///
/// 锚点（累计付费鹰币 → ≈USD）：
///   V1=0($0) · V2=500($5) · V10=4,500($45) · V20≈4万($400 普通到头)
///   V50=100万($1万) · V90≈4000万($40万) · V99≈7.6亿($760万 几乎不可达)
///
/// 分段：V1–V10 线性($5/级) · V10–V20 / V20–V50 / V50–V90 几何插值 ·
/// V90–V99 超指数（每加一档 = 之前加 10 档的钱，增量 = 1600万×档差）。

/// 每个等级的「门槛累计鹰币」(index = 等级 1..99；index 0 占位)。一次性构建。
final List<int> _kLevelFloor = _buildLevelFloors();

List<int> _buildLevelFloors() {
  final f = List<double>.filled(100, 0);

  // V1..V10：线性 $5/级（500 鹰币/级）。V1=0、V10=4,500。
  for (var v = 1; v <= 10; v++) {
    f[v] = 500.0 * (v - 1);
  }

  // 在两个锚点之间几何（等比）插值，保证单调平滑递增。
  void geo(int lo, double loVal, int hi, double hiVal) {
    final r = math.pow(hiVal / loVal, 1 / (hi - lo)).toDouble();
    for (var v = lo + 1; v <= hi; v++) {
      f[v] = loVal * math.pow(r, v - lo).toDouble();
    }
  }

  geo(10, 4500, 20, 40000); // 普通用户到头 V20≈$400
  geo(20, 40000, 50, 1000000); // V50=100 万鹰币=$1 万（巨鳄锚点）
  geo(50, 1000000, 90, 40000000); // V90≈4000 万=$40 万（超指数起点）

  // V90..V99：超指数。增量(V90+k) = 1,600 万 × k（= $16,000×10k 折算鹰币）。
  // 累计 V90→V99 增量 = 1600万×(1+..+9)=7.2 亿 → V99≈7.6 亿（≈$760 万）。
  for (var k = 1; k <= 9; k++) {
    f[90 + k] = f[90 + k - 1] + 16000000.0 * k;
  }

  return [for (var v = 0; v < 100; v++) f[v].round()];
}

/// 累计付费鹰币 → V 级别（1..99）。0 或负 = V1（注册默认）。
int levelForCoins(int coins) {
  if (coins <= 0) return 1;
  var lvl = 1;
  for (var v = 1; v <= 99; v++) {
    if (coins >= _kLevelFloor[v]) {
      lvl = v;
    } else {
      break;
    }
  }
  return lvl;
}

/// 某等级的门槛累计鹰币（升到该级所需）。
int levelFloorCoins(int level) => _kLevelFloor[level.clamp(1, 99)];

/// 升到下一级还差多少鹰币；已 V99 返回 0。
int coinsToNextLevel(int coins) {
  final lvl = levelForCoins(coins);
  if (lvl >= 99) return 0;
  final gap = _kLevelFloor[lvl + 1] - (coins < 0 ? 0 : coins);
  return gap < 0 ? 0 : gap;
}

/// 当前等级内到下一级的进度 0..1（催充进度条用）。已 V99 返回 1。
double levelProgress(int coins) {
  final lvl = levelForCoins(coins);
  if (lvl >= 99) return 1.0;
  final lo = _kLevelFloor[lvl];
  final hi = _kLevelFloor[lvl + 1];
  if (hi <= lo) return 0.0;
  final p = (coins - lo) / (hi - lo);
  return p < 0 ? 0.0 : (p > 1 ? 1.0 : p);
}
