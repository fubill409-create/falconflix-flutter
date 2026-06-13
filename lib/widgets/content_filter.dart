// 内容过滤(苹果 G1.2 四件套之一):发帖/聊天前的客户端违规词拦截。
//
// 这是第一道闸(即时、离线、零成本)。服务端审核(举报→管理端处置)是第二道。
// 词表保守、只拦最硬的违规类别;不做大而全的敏感词,避免误伤正常表达。
import 'package:flutter/material.dart';

class ContentFilter {
  // 硬违规词(色情/辱骂/违法引流等最低限度集合,中英都覆盖)。
  // 全部小写匹配;命中即拦。可后续从后端下发扩充。
  static const _blocked = <String>[
    // 色情
    'porn', 'xxx', '约炮', '裸聊', '性交易', '招嫖', 'av资源',
    // 辱骂/仇恨(示例,保守)
    'fuck you', '操你妈', '傻逼', '去死',
    // 违法引流/诈骗
    '私聊加微信', '加微信', '加qq', '一起赚钱', '稳赚', '色情网站', '黄网',
    // 未成年敏感
    '幼女', '萝莉资源',
  ];

  /// 返回命中的第一个违规词(命中=不可发布);干净返回 null。
  static String? check(String text) {
    final low = text.toLowerCase();
    for (final w in _blocked) {
      if (low.contains(w)) return w;
    }
    return null;
  }

  /// 校验并在命中时弹提示;干净返回 true。
  static bool guard(BuildContext context, String text) {
    if (check(text) == null) return true;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF3A1020),
      content: Text(
        zh ? '内容含违规词,无法发布。请文明发言。'
           : 'Your content violates our community rules and cannot be posted.',
        style: const TextStyle(color: Colors.white),
      ),
    ));
    return false;
  }
}
