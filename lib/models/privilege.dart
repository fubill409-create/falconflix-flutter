/// V 级别特权：哪些功能要到哪个 V 级别才解锁（功能按等级解锁）。
///
/// 设计见 docs/PRICING_SYSTEM_IMPLEMENTATION_PLAN.md §5.5（用户 2026-06-05 批准）。
/// 原则：
///  ① 接入门槛压低位（V2–V10），防「猫阿狗」白嫖、催首充；
///  ② **门 ≠ 油**：级别只决定「能不能用」，用一次照样扣鹰币能量（两层叠加）；
///  ③ 普通追剧**不受** V 级别限制（走 per-剧鹰币四档解锁）；本表只圈 AI互动/数字人/社交/面子；
///  ④ 高敏感（真脸客串/联系本尊）另叠 KYC，不在此表。
///
/// 注意：级别来自「累计付费」(auth.level)，免费票不计。
enum Feature {
  voiceChat, // 语音聊天
  videoCall, // 视频通话（数字人开口）——防猫阿狗的头牌门槛
  secondCharacter, // 多角色聊天位
  postCommunity, // 发社区动态
  priorityQueue, // 并发满员优先插通话
}

class FeatureSpec {
  final int level; // 解锁所需 V 级别
  final String name; // 功能名（升级弹层标题用）
  final String blurb; // 一句卖点/说明
  const FeatureSpec(this.level, this.name, this.blurb);
}

/// 解锁阶梯（与清单 §5.5 一致）。后续加功能只加这一张表。
const Map<Feature, FeatureSpec> kFeatureSpec = {
  Feature.voiceChat: FeatureSpec(2, '语音聊天', '用声音和 TA 更亲密地聊'),
  Feature.videoCall: FeatureSpec(3, '视频通话', '和数字人面对面、声音对声音'),
  Feature.secondCharacter: FeatureSpec(5, '多角色畅聊', '同时和更多角色建立关系'),
  Feature.postCommunity: FeatureSpec(10, '发布动态', '在社区发动态、晒你的追剧'),
  Feature.priorityQueue: FeatureSpec(30, '优先接通', '高峰也不排队，TA 第一时间接你'),
};

class Privilege {
  static int requiredLevel(Feature f) => kFeatureSpec[f]?.level ?? 1;

  static FeatureSpec spec(Feature f) =>
      kFeatureSpec[f] ?? const FeatureSpec(1, '', '');

  /// 够级别用该功能吗？level = 用户当前 V 级别（auth.level）。
  static bool canUse(Feature f, int level) => level >= requiredLevel(f);
}
