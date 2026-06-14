// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => '首页';

  @override
  String get tabTheater => '剧场';

  @override
  String get tabInteractive => '互动剧';

  @override
  String get tabCharacter => '角色';

  @override
  String get tabMe => '我的';

  @override
  String get common_cancel => '取消';

  @override
  String get common_confirm => '确认';

  @override
  String get common_save => '保存';

  @override
  String get common_back => '返回';

  @override
  String get common_close => '关闭';

  @override
  String get common_retry => '重试';

  @override
  String get common_loading => '加载中…';

  @override
  String get common_more => '更多';

  @override
  String get common_yes => '是';

  @override
  String get common_no => '否';

  @override
  String get common_free => '免费';

  @override
  String get common_login => '登录';

  @override
  String get common_logout => '退出登录';

  @override
  String get common_loadFailed => '加载失败';

  @override
  String get common_pleaseLogin => '请先登录';

  @override
  String get common_done => '完成';

  @override
  String get common_edit => '编辑';

  @override
  String get common_delete => '删除';

  @override
  String get common_send => '发送';

  @override
  String get me_title => '个人中心';

  @override
  String get me_loginPrompt => '登录 / 注册';

  @override
  String get me_loginSubtitle => '登录后解锁追剧、鹰币钱包与互动剧';

  @override
  String get me_membershipNormal => '普通会员';

  @override
  String get me_membershipVip => 'VIP 会员';

  @override
  String get me_inviteCode => '邀请码';

  @override
  String get me_statEagleCoins => '鹰币';

  @override
  String get me_statBoughtEpisodes => '已购剧集';

  @override
  String get me_statCollections => '收藏';

  @override
  String get me_sectionMyContent => '我的内容';

  @override
  String get me_sectionWallet => '钱包';

  @override
  String get me_sectionCommunity => '社区';

  @override
  String get me_sectionCreator => '创作者';

  @override
  String get me_sectionSettings => '设置';

  @override
  String get me_sectionHelpAbout => '帮助与关于';

  @override
  String get me_rowCollections => '我的收藏';

  @override
  String get me_rowHistory => '观看历史';

  @override
  String get me_rowCommunity => '社区动态';

  @override
  String get me_rowWallet => '充值和会员';

  @override
  String get me_rowOrders => '我的订单';

  @override
  String get me_rowInvite => '邀请好友';

  @override
  String get me_rowPartner => '剧集伙伴';

  @override
  String get me_rowNotifications => '消息通知';

  @override
  String get me_rowSettings => '设置';

  @override
  String get me_rowHelpAbout => '帮助与关于';

  @override
  String get me_rowAbout => '关于 FalconFlix';

  @override
  String get me_logoutConfirm => '确认退出登录？';

  @override
  String get history_title => '观看历史';

  @override
  String get history_emptyTitle => '还没有观看记录';

  @override
  String get history_emptyBody => '看过一集，这里就会出现，方便你随时回来追到最后看的那一集。';

  @override
  String get history_loginBody => '登录后可以查看你看过的剧集。';

  @override
  String get history_actionDelSelected => '删除所选';

  @override
  String get history_actionClearAll => '清空全部';

  @override
  String get history_episodeFallback => '整剧';

  @override
  String get history_unknown => '（未知剧目）';

  @override
  String history_selectedCount(int n) {
    return '已选 $n';
  }

  @override
  String history_delConfirmTitle(int n) {
    return '删除 $n 条记录？';
  }

  @override
  String get history_delConfirmBody => '删除后无法恢复；剧集本身不受影响，下次播放会重新生成记录。';

  @override
  String get history_clearConfirmTitle => '清空所有观看历史？';

  @override
  String get history_clearConfirmBody => '清空后无法恢复。下次播放会重新生成记录。';

  @override
  String history_toastDeleted(int n) {
    return '已删除 $n 条';
  }

  @override
  String get history_toastCleared => '已清空';

  @override
  String get orders_title => '我的订单';

  @override
  String get orders_tabFull => '整剧';

  @override
  String get orders_tabEpisode => '单集';

  @override
  String get orders_tabRecharge => '充值流水';

  @override
  String get orders_emptyFull => '还没有整剧订单';

  @override
  String get orders_emptyEpisode => '还没有单集订单';

  @override
  String get orders_emptyBody => '解锁的剧目会出现在这里，方便对账与售后。';

  @override
  String get orders_emptyRecharge => '还没有充值记录';

  @override
  String get orders_emptyRechargeBody => '完成第一次充值后这里会显示流水。';

  @override
  String get orders_loginBodyOrders => '登录后可以查看你的订单记录。';

  @override
  String get orders_loginBodyRecharge => '登录后可以查看充值流水。';

  @override
  String get orders_kvAmount => '金额';

  @override
  String get orders_kvPayMethod => '支付方式';

  @override
  String get orders_kvTime => '时间';

  @override
  String orders_orderCopied(String orderNo) {
    return '订单号已复制 · $orderNo';
  }

  @override
  String get orders_paid => '已到账';

  @override
  String get orders_pending => '待支付';

  @override
  String get orders_payEagle => '鹰币';

  @override
  String get orders_unknownTitle => '（未知剧目）';

  @override
  String get orders_rechargeFallback => '鹰币充值';

  @override
  String get inbox_title => '消息通知';

  @override
  String get inbox_tabAll => '全部';

  @override
  String get inbox_tabRecharge => '充值';

  @override
  String get inbox_tabInvite => '邀请';

  @override
  String get inbox_tabSystem => '系统';

  @override
  String get inbox_tabActivity => '活动';

  @override
  String get inbox_tabInteractive => '互动剧';

  @override
  String get inbox_emptyTitle => '一条消息也没有';

  @override
  String get inbox_emptyBody => '充值到账、邀请奖励、活动公告、系统通知都会出现在这里。';

  @override
  String get inbox_loginBody => '登录后可以查看充值到账 / 邀请奖励 / 系统通知。';

  @override
  String get settings_title => '设置';

  @override
  String get settings_sectionNotificationPlayback => '通知与播放';

  @override
  String get settings_sectionAccount => '账号';

  @override
  String get settings_sectionUIStorage => '界面与存储';

  @override
  String get settings_rowNotifyPrefs => '通知偏好';

  @override
  String get settings_rowPlayPrefs => '播放与下载偏好';

  @override
  String get settings_rowAccountSecurity => '账号与安全';

  @override
  String get settings_rowPrivacy => '隐私';

  @override
  String get settings_rowLanguage => '界面语言';

  @override
  String get settings_rowClearCache => '清理缓存';

  @override
  String get settings_clearCacheTitle => '清理缓存？';

  @override
  String get settings_clearCacheBody => '会清掉互动剧已下视频 + 网络图片缓存。已购剧目、登录态、设置都不会丢。';

  @override
  String get settings_clearCacheAction => '立即清理';

  @override
  String settings_clearCacheDone(String size) {
    return '已清理 $size 缓存';
  }

  @override
  String get notifyPrefs_title => '通知偏好';

  @override
  String get notifyPrefs_pushMaster => '推送总开关';

  @override
  String get notifyPrefs_pushMasterDesc => '关闭后所有手机推送暂停，但站内信仍会到达';

  @override
  String get notifyPrefs_recharge => '充值到账';

  @override
  String get notifyPrefs_rechargeDesc => '充值成功 / 鹰币入账';

  @override
  String get notifyPrefs_invite => '邀请成功';

  @override
  String get notifyPrefs_inviteDesc => '邀请的朋友注册 / 奖励到账';

  @override
  String get notifyPrefs_system => '系统公告';

  @override
  String get notifyPrefs_systemDesc => '账号安全 / 重要变更';

  @override
  String get notifyPrefs_activity => '活动促销';

  @override
  String get notifyPrefs_activityDesc => '新剧上线 / 充值大促';

  @override
  String get notifyPrefs_interactive => '互动剧进度';

  @override
  String get notifyPrefs_interactiveDesc => '在追的互动剧上新 / 新结局解锁';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return '保存失败：$msg';
  }

  @override
  String get playPrefs_title => '播放与下载偏好';

  @override
  String get playPrefs_autoplay => '首页自动连播';

  @override
  String get playPrefs_autoplayDesc => '看完一条自动播放下一条';

  @override
  String get playPrefs_wifiOnlyAutoplay => '仅 Wi-Fi 自动播放';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc => '4G/5G 下不自动播，节省流量';

  @override
  String get playPrefs_quality => '默认画质';

  @override
  String get playPrefs_qualityAuto => '自动（根据网络）';

  @override
  String get playPrefs_quality480 => '标清 480p';

  @override
  String get playPrefs_quality720 => '高清 720p';

  @override
  String get playPrefs_quality1080 => '超清 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => '仅 Wi-Fi 下载';

  @override
  String get playPrefs_wifiOnlyDownloadDesc => '互动剧 / 离线缓存只在 Wi-Fi 下进行';

  @override
  String get accountSec_title => '账号与安全';

  @override
  String get accountSec_sectionLogin => '登录';

  @override
  String get accountSec_sectionDeletion => '账号注销';

  @override
  String get accountSec_rowChangePwd => '修改登录密码';

  @override
  String get accountSec_rowChangePwdDesc => '需要先输入原密码';

  @override
  String get accountSec_rowDelete => '注销账号';

  @override
  String get accountSec_rowDeleteDesc => '7 天冷静期，期间登录可撤销';

  @override
  String get accountSec_oldPwHint => '原密码';

  @override
  String get accountSec_newPwHint => '新密码（至少 8 位）';

  @override
  String get accountSec_confirmPwHint => '再次输入新密码';

  @override
  String get accountSec_errMinLen => '新密码至少 8 位';

  @override
  String get accountSec_errMismatch => '两次输入不一致';

  @override
  String get accountSec_saveNewPw => '保存新密码';

  @override
  String get accountSec_saving => '保存中…';

  @override
  String get accountSec_pwUpdated => '密码已更新';

  @override
  String get privacyPrefs_title => '隐私';

  @override
  String get privacyPrefs_sectionData => '我的数据';

  @override
  String get privacyPrefs_sectionLegal => '协议与政策';

  @override
  String get privacyPrefs_rowExport => '下载我的数据';

  @override
  String get privacyPrefs_rowExportDesc => 'GDPR / CCPA 合规：申请打包下载你的全部数据';

  @override
  String get privacyPrefs_rowPolicy => '隐私政策';

  @override
  String get deleteAcc_title => '注销账号';

  @override
  String get deleteAcc_inProgress => '注销申请进行中';

  @override
  String deleteAcc_scheduledAt(String time) {
    return '执行时间：$time';
  }

  @override
  String get deleteAcc_pendingHint =>
      '7 天冷静期内任何时候登录此账号都可以撤销注销。撤销后账号与所有数据立刻恢复正常使用。';

  @override
  String get deleteAcc_cancelBtn => '撤销注销，继续使用';

  @override
  String get deleteAcc_willDelete => '注销账号会删除以下数据';

  @override
  String get deleteAcc_bullet1 => '账号资料、昵称、头像、邮箱、手机号绑定';

  @override
  String get deleteAcc_bullet2 => '钱包余额（鹰币不可退款）、VIP / 等级';

  @override
  String get deleteAcc_bullet3 => '已购买的剧集与互动剧解锁记录';

  @override
  String get deleteAcc_bullet4 => '观看历史、收藏、社区动态、互动剧存档';

  @override
  String get deleteAcc_bullet5 => '邀请关系（被邀请人侧记录保留）';

  @override
  String get deleteAcc_coolingHint =>
      '提交后进入 7 天冷静期，期间登录此账号可撤销。过期后账号将被永久删除，且无法恢复。';

  @override
  String get deleteAcc_reasonLabel => '注销原因（可选，用于改进产品）';

  @override
  String get deleteAcc_reasonHint => '说说你的想法（可不填）';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return '请输入「$phrase」以确认';
  }

  @override
  String get deleteAcc_confirmPhrase => '删除我的账号';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return '请准确输入「$phrase」以确认';
  }

  @override
  String get deleteAcc_submit => '提交注销申请';

  @override
  String get deleteAcc_finalTitle => '最后一次确认';

  @override
  String get deleteAcc_finalBody =>
      '提交后将进入 7 天冷静期。期间任何时候登录都可以撤销。\n\n到期后，账号数据将被永久删除且无法恢复。';

  @override
  String get deleteAcc_finalSubmit => '提交注销';

  @override
  String get deleteAcc_submitted => '注销申请已提交，7 天后执行';

  @override
  String get deleteAcc_cancelled => '已撤销注销申请';

  @override
  String get deleteAcc_thinkAgain => '再想想，先不注销';

  @override
  String get dataExport_title => '下载我的数据';

  @override
  String get dataExport_introTitle => '下载你的全部数据';

  @override
  String get dataExport_introBody =>
      '依据 GDPR Article 15（欧盟）与 CCPA（加州），你有权获取我们持有的关于你的全部个人数据。\n\n提交申请后，我们会异步生成一个 zip 包，包含：\n  · 账号资料 / 邮箱 / 手机号\n  · 鹰币余额与变更流水\n  · 已购订单、观看历史、收藏\n  · 社区动态、互动剧解锁记录\n\n准备完成后会通过站内信通知你，下载链接有效期 7 天。';

  @override
  String get dataExport_statusQueued => '待处理 · 排队中';

  @override
  String get dataExport_statusProcessing => '处理中 · 正在打包';

  @override
  String get dataExport_statusReady => '已完成 · 可下载';

  @override
  String get dataExport_statusExpired => '已过期 · 请重新申请';

  @override
  String get dataExport_statusFailed => '生成失败 · 请重新申请';

  @override
  String dataExport_expiresAt(String time) {
    return '链接有效至 $time';
  }

  @override
  String get dataExport_downloadBtn => '下载';

  @override
  String get dataExport_submitBtn => '申请下载';

  @override
  String get dataExport_submitting => '提交中…';

  @override
  String get dataExport_submitted => '已提交申请，准备好后会通知你下载';

  @override
  String get helpAbout_title => '帮助与关于';

  @override
  String get helpAbout_sectionHelp => '帮助';

  @override
  String get helpAbout_sectionAbout => '关于';

  @override
  String get helpAbout_rowFaq => '帮助中心';

  @override
  String get helpAbout_rowFaqDesc => '常见问题解答';

  @override
  String get helpAbout_rowSupport => '联系客服';

  @override
  String get helpAbout_rowSupportDesc => '一对一工单对话';

  @override
  String get helpAbout_rowFeedback => '意见反馈';

  @override
  String get helpAbout_rowFeedbackDesc => '产品建议 / Bug 上报';

  @override
  String get faq_title => '帮助中心';

  @override
  String get faq_catAll => '全部';

  @override
  String get faq_catAccount => '账号';

  @override
  String get faq_catRecharge => '充值';

  @override
  String get faq_catPlayback => '播放';

  @override
  String get faq_catInteractive => '互动剧';

  @override
  String get faq_catOther => '其他';

  @override
  String get faq_emptyTitle => '暂无 FAQ';

  @override
  String get faq_emptyBody => '如果你遇到了问题，可以直接「联系客服」开工单。';

  @override
  String get tickets_title => '联系客服';

  @override
  String get tickets_newBtn => '新建工单';

  @override
  String get tickets_emptyTitle => '还没有工单';

  @override
  String get tickets_emptyBody => '遇到问题点右下角「新建工单」，客服会一对一回复你。';

  @override
  String get tickets_threadTitle => '工单详情';

  @override
  String get tickets_initial => '初始问题';

  @override
  String get tickets_speakerStaff => '客服';

  @override
  String get tickets_speakerSelf => '我';

  @override
  String get tickets_replyHint => '回复客服…';

  @override
  String tickets_sendFailed(String msg) {
    return '发送失败：$msg';
  }

  @override
  String get tickets_statusPending => '待处理';

  @override
  String get tickets_statusReplied => '已回复';

  @override
  String get tickets_statusResolved => '已解决';

  @override
  String get tickets_statusClosed => '已关闭';

  @override
  String get feedback_titleTicket => '新建工单';

  @override
  String get feedback_titleFeedback => '意见反馈';

  @override
  String get feedback_typeBug => 'Bug 上报';

  @override
  String get feedback_typeSuggestion => '产品建议';

  @override
  String get feedback_typeComplaint => '投诉';

  @override
  String get feedback_typeRecharge => '充值问题';

  @override
  String get feedback_typeOther => '其他';

  @override
  String get feedback_typeLabel => '问题类型';

  @override
  String get feedback_contentLabel => '详细描述';

  @override
  String get feedback_contentHintTicket => '说说你遇到的问题，越详细越快定位…';

  @override
  String get feedback_contentHintFeedback => '说说你的建议 / 遇到的问题…';

  @override
  String get feedback_contactLabel => '回访邮箱 / 手机（可选）';

  @override
  String get feedback_contactHint => '填了我们会优先联系你；不填也行';

  @override
  String get feedback_submit => '提交';

  @override
  String get feedback_submitting => '提交中…';

  @override
  String get feedback_submitted => '已提交，客服会一对一回复';

  @override
  String get feedback_minLength => '请描述至少 5 个字';

  @override
  String feedback_tip(String version) {
    return '小提示：上报 Bug 时附上重现步骤 + 截图（截图功能即将上线）会更快定位。\n版本号：$version';
  }

  @override
  String get lang_zh => '中文';

  @override
  String get lang_en => 'English';

  @override
  String get lang_ja => '日本語';

  @override
  String get lang_ko => '한국어';

  @override
  String get lang_ar => 'العربية';

  @override
  String get lang_fr => 'Français';

  @override
  String get home_noDramaData => '暂无短剧数据';

  @override
  String get home_localOnlyLike => '本地片源不支持点赞';

  @override
  String get home_localOnlyCollect => '本地片源不支持收藏';

  @override
  String get home_addedToMy => '已收藏到「我的」';

  @override
  String get home_actionLike => '点赞';

  @override
  String get home_actionCollected => '已收藏';

  @override
  String get home_actionCollect => '收藏';

  @override
  String get home_actionShare => '分享';

  @override
  String get home_shopComingSoon => '剧中同款 · AI 识别（商品页开发中）';

  @override
  String get home_chipAiTheater => 'AI 剧场';

  @override
  String get home_bannerPremiere => 'AI 短剧首映';

  @override
  String get home_btnWatch => '观看';

  @override
  String get home_btnDetails => '详情';

  @override
  String home_loadFailedFmt(String message) {
    return '加载失败\n$message';
  }

  @override
  String get theater_genreAll => '全部';

  @override
  String get theater_genreRomance => '爱情';

  @override
  String get theater_genreUrban => '都市';

  @override
  String get theater_genreInteractive => '互动';

  @override
  String get theater_genreFinished => '完结';

  @override
  String get theater_sectionHot => '正在热播';

  @override
  String get theater_seeAll => '查看全部';

  @override
  String get theater_sectionAll => '全部剧集';

  @override
  String get theater_ranking => '热度榜';

  @override
  String get theater_today => '今日推荐';

  @override
  String get theater_labelShort => '短剧';

  @override
  String theater_continueWatch(String name) {
    return '继续观看 · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '$heat 热度';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · $heat 热度';
  }

  @override
  String get cast_sectionPlaying => '在播 & 候选剧';

  @override
  String get cast_oppRanking => '角色机会榜 ›';

  @override
  String get cast_universeTitle => '角色元宇宙';

  @override
  String get cast_universeSub => '遇见会回应你的人 · 了解这个世界';

  @override
  String get cast_demoBadge => '互动样板 · 可玩';

  @override
  String get cast_demoTitle => '互动样板剧';

  @override
  String get cast_demoSub => '你来选——一句台词点燃一部剧';

  @override
  String get cast_inPlay => '在播';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '热度 $heat · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '热度 $heat';
  }

  @override
  String get cb_sectionSupport => '助推榜 · 谁在为 TA 助推';

  @override
  String get cb_goSupport => '去助推 · 助 TA 出道';

  @override
  String get cb_seeBio => '看 TA 简介 ›';

  @override
  String cb_pollHeatPct(String pct) {
    return '助推热度 $pct%';
  }

  @override
  String get cb_debuted => '已出道开机';

  @override
  String cb_toDebutPct(String pct) {
    return '距开机差 $pct%';
  }

  @override
  String get cb_totalSupport => '累计助推';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins 鹰币';
  }

  @override
  String get cb_topBacker => '本剧榜一大哥';

  @override
  String get cb_emptyBackers => '还没有人助推 · 快来当 TA 的第一位榜一大哥';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · 助推榜';
  }

  @override
  String get aid_titleHeader => 'AI 互动剧';

  @override
  String get aid_aceBadge => '王牌';

  @override
  String get aid_tagline => '你的选择，改写结局。';

  @override
  String get aid_demoBadge => '样板剧 · demo · 免费试玩';

  @override
  String get aid_lastcallSub => '5 层抉择 · 7 种结局 · 你的选择改写结局';

  @override
  String get aid_pipelineTitle => '星光片场';

  @override
  String get aid_pipelineSub => '王牌片单 · 陆续开机';

  @override
  String get aid_cameoTitle => '客串自己';

  @override
  String get aid_cameoSub => '上传一张照片，把你写进这部剧';

  @override
  String get aid_castingBadge => '选角中';

  @override
  String get aid_producingBadge => '制作中';

  @override
  String aid_castVoteFmt(String pct) {
    return '为 TA 选角 · $pct%';
  }

  @override
  String get aid_manifesto1 => '你不再只是看故事。';

  @override
  String get aid_manifesto2 => '你替主角做选择，故事就替你改写结局。';

  @override
  String get aid_manifesto3 => '每一次抉择，都是你和这个世界的一次对话。';

  @override
  String get aid_manifestoHeader => '我们为什么做互动剧';

  @override
  String get aid_metaversePre => '我们把它叫做「互动剧」——\n但它其实是 ';

  @override
  String get aid_metaverseEmph => '「决策元宇宙」的第一幕';

  @override
  String get aid_metaversePost => '：\n一个你说了算的世界，从这里开始。';

  @override
  String get aid_step1Title => '看剧';

  @override
  String get aid_step1Sub => '坐下来，先被一个故事抓住。';

  @override
  String get aid_step2Title => '互动选择';

  @override
  String get aid_step2Sub => '在岔路口替角色做决定，剧情就此分叉。';

  @override
  String get aid_step3Title => '客串自己';

  @override
  String get aid_step3Sub => '把你的脸、你的名字写进这部剧。';

  @override
  String get aid_step4Title => '助推出道';

  @override
  String get aid_step4Sub => '为心动的角色助推，把 TA 推上舞台。';

  @override
  String get aid_step5Title => '决策元宇宙';

  @override
  String get aid_step5Sub => '终点，是一个你说了算的世界。';

  @override
  String get aid_ladderHeader => '从一次选择，到一个世界';

  @override
  String get aid_liveTitle => '已上线 · 可玩';

  @override
  String get aid_liveSub => '真互动剧 · 你的选择改写结局';

  @override
  String get aid_fallbackHook => '你的选择，改写她的故事';

  @override
  String get aid_aceCardBadge => '王牌互动剧 · 可玩';

  @override
  String get player_btnLiked => '已赞';

  @override
  String get player_btnEpisodes => '选集';

  @override
  String get player_btnAiCast => 'AI入戏';

  @override
  String player_episodeNumFmt(int n) {
    return '第 $n 集';
  }

  @override
  String player_switchEpFmt(int n) {
    return '切到第 $n 集（接后端中）';
  }

  @override
  String get player_unlockHint => '请在剧目详情页解锁鹰币';

  @override
  String player_comingSoonFmt(String label) {
    return '$label（开发中）';
  }

  @override
  String get player_sceneSame => '场景同款';

  @override
  String get detail_unlockThis => '本集';

  @override
  String get detail_unlockNext5 => '后续 5 集';

  @override
  String get detail_unlockNext10 => '后续 10 集';

  @override
  String get detail_unlockAll => '全集';

  @override
  String detail_episodeCountFmt(int n) {
    return '共 $n 集';
  }

  @override
  String get detail_drawerEpisodes => '抽屉选集';

  @override
  String get detail_unlockSuccess => '解锁成功';

  @override
  String detail_coinBalanceFmt(String coins) {
    return '鹰币余额 $coins';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n 次播放';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return '$coins 鹰币解锁';
  }

  @override
  String get detail_playNow => '立即播放';

  @override
  String get detail_playThis => '播放本剧';

  @override
  String get detail_noEpisodes => '暂无可播放剧集';

  @override
  String get login_welcome => '欢迎来到 FalconFlix';

  @override
  String get login_subtitle => '登录解锁追剧 · 鹰币钱包 · 专属互动剧';

  @override
  String get login_emailLabel => '邮箱';

  @override
  String get login_passwordLabel => '密码';

  @override
  String get login_codeLabel => '验证码';

  @override
  String get login_codeHint => '6 位验证码';

  @override
  String get login_pwInputHint => '请输入密码';

  @override
  String get login_modeOtp => '验证码登录';

  @override
  String get login_modePassword => '密码登录';

  @override
  String get login_getCode => '获取验证码';

  @override
  String get login_sending => '发送中';

  @override
  String get login_loggingIn => '登录中…';

  @override
  String get login_loginOrRegister => '登录 / 注册';

  @override
  String get login_pwHint => '首次用密码登录将自动注册并设置该密码';

  @override
  String get login_quickLogin => '快捷登录';

  @override
  String get login_recommended => '推荐';

  @override
  String get login_success => '登录成功';

  @override
  String get login_agreement => '登录即代表同意《用户协议》与《隐私政策》';

  @override
  String get login_emailInvalid => '请先填写正确的邮箱';

  @override
  String get login_emailRequired => '请填写正确的邮箱';

  @override
  String get login_passwordRequired => '请填写密码';

  @override
  String get login_codeRequired => '请填写验证码';

  @override
  String get login_codeSent => '验证码已发送，请查收邮箱';

  @override
  String get login_emailNotConfigured => '邮件通道暂时不可用，请稍后重试';

  @override
  String get login_networkError => '登录失败，请检查网络后重试';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return '$provider 登录失败：$code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return '$provider 登录失败，请稍后重试';
  }

  @override
  String login_oauthComingFmt(String name) {
    return '$name 登录正在接入中';
  }

  @override
  String get login_oauthComingBody => '马上就好～现在可以先用邮箱验证码或密码登录。';

  @override
  String get login_gotIt => '我知道了';

  @override
  String get login_googleNoToken => 'Google 未返回 idToken，请检查凭证配置';

  @override
  String get about_tagline => '鹰眼短剧 · 看得见的好戏';

  @override
  String get about_body =>
      'FalconFlix 是面向全球的精品短剧平台——在这里追剧、与 AI 角色互动、边看边带货。我们用电影级的制作与 AI 创意，让每一帧都值得停留。';

  @override
  String get about_userAgreement => '用户协议';

  @override
  String get about_privacyPolicy => '隐私政策';

  @override
  String about_legalUpdatedFmt(String date) {
    return '最近更新：$date';
  }

  @override
  String get about_operatingEntity => '运营主体';

  @override
  String about_contactEmailFmt(String email) {
    return '联系邮箱：$email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return '关于 $appName';
  }

  @override
  String get wallet_title => '充值鹰币';

  @override
  String get wallet_chooseRecharge => '选择充值包';

  @override
  String get wallet_introNote => '鹰币用于解锁剧集、互动玩法与助推';

  @override
  String get wallet_menuAutoUnlock => '自动解锁设置';

  @override
  String get wallet_menuHistory => '充值记录';

  @override
  String get wallet_menuReceipt => '发票邮箱';

  @override
  String get wallet_stripeNotice => '支付由 Stripe 安全处理 · 美金结算';

  @override
  String get wallet_appStoreNotice => '通过 App Store 安全支付';

  @override
  String get wallet_loadFailed => '加载失败，请稍后再试';

  @override
  String get wallet_packsComing => '充值套餐即将上线';

  @override
  String get wallet_packsComingBody => '我们正在为你准备最划算的鹰币礼包';

  @override
  String get wallet_coins => '鹰币';

  @override
  String wallet_giftFmt(String coins) {
    return '送 $coins';
  }

  @override
  String get wallet_bestDeal => '最划算';

  @override
  String wallet_payNowFmt(String price) {
    return '立即充值 · $price';
  }

  @override
  String get wallet_payNow => '立即充值';

  @override
  String get wallet_loginFirst => '请先登录再充值';

  @override
  String get wallet_openPayFail => '无法打开支付页面，请稍后再试';

  @override
  String get wallet_payFail => '支付失败，请稍后再试';

  @override
  String get wallet_iapUnavailable => '无法连接 App Store，请稍后再试';

  @override
  String get wallet_iapVerifyFail => '支付确认失败，下次启动将自动重试';

  @override
  String get wallet_balanceLabel => '鹰币余额';

  @override
  String get wallet_loginToView => '登录后查看';

  @override
  String get wallet_legendPeak => '传奇巅峰 · 已封顶';

  @override
  String wallet_toLevelFmt(String level) {
    return '距 V$level';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return '累计充值 $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return '再充 $amount 升至 V$level';
  }

  @override
  String get wallet_successTitle => '鹰币充值成功 · 已到账';

  @override
  String get wallet_tapAnywhere => '轻触任意处继续';

  @override
  String get wallet_successBarrier => '充值成功';

  @override
  String get creator_title => '伙伴中心';

  @override
  String get creator_statSeries => '部短剧';

  @override
  String get creator_statPlays => '播放';

  @override
  String get creator_statShare => '分成';

  @override
  String get creator_applyLabel => '申请成为剧集伙伴';

  @override
  String get creator_applyToast => '申请提交（开发中）';

  @override
  String get creator_menuRequirement => '上传要求';

  @override
  String get creator_menuRevenue => '分成规则';

  @override
  String get creator_menuLangPriv => '语言与隐私';

  @override
  String get invite_title => '邀请好友';

  @override
  String get invite_stepsTitle => '邀请步骤';

  @override
  String get invite_step1Title => '分享邀请码';

  @override
  String get invite_step1Sub => '把你的专属邀请码发给好友';

  @override
  String get invite_step2Title => '好友填码注册';

  @override
  String get invite_step2Sub => '好友注册时填入你的邀请码';

  @override
  String get invite_step3Title => '双方领鹰币';

  @override
  String get invite_step3Sub => '注册成功后你和好友都能拿鹰币';

  @override
  String get invite_copyMessage => '复制邀请文案分享';

  @override
  String get invite_loginToGet => '登录后获取邀请码';

  @override
  String get invite_loginToGen => '登录后才能生成你的专属邀请码';

  @override
  String get invite_messageCopied => '邀请文案已复制，去粘贴给好友吧';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 我在用 FalconFlix 追短剧，超好看！注册时填我的邀请码 $code，咱俩都能领鹰币～';
  }

  @override
  String get invite_bigTitle => '邀请好友 一起追剧';

  @override
  String get invite_bigSub => '好友用你的邀请码注册，双方都能领鹰币奖励';

  @override
  String get invite_myCode => '我的专属邀请码';

  @override
  String get invite_copyBtn => '复制';

  @override
  String invite_codeCopiedFmt(String code) {
    return '邀请码已复制：$code';
  }

  @override
  String get collect_emptyTitle => '还没有收藏的剧';

  @override
  String get collect_emptyBody => '在剧里点「收藏」，就会出现在这里，方便随时回来追。';

  @override
  String get au_title => '自动解锁';

  @override
  String get au_introTitle => '追剧不被打断';

  @override
  String get au_introBody => '开启后看到下一集自动用鹰币解锁，一口气追到爽';

  @override
  String get au_toggleLabel => '自动解锁下一集';

  @override
  String get au_on => '已开启';

  @override
  String get au_off => '已关闭';

  @override
  String get au_toggleOnToast => '已开启自动解锁';

  @override
  String get au_toggleOffToast => '已关闭自动解锁';

  @override
  String get au_rule1 => '点已锁剧集会直接扣鹰币解锁，不再每次弹窗确认';

  @override
  String get au_rule2 => '鹰币余额不足时仍会提示你去充值，不会乱扣';

  @override
  String get au_rule3 => '仅对「单集解锁」生效；整部解锁因金额较大仍需手动确认';

  @override
  String get rh_title => '充值记录';

  @override
  String get rh_loginToView => '登录后可查看充值记录';

  @override
  String get rh_emptyBody => '还没有充值记录\n去充值鹰币解锁更多剧集吧';

  @override
  String get rh_fallback => '充值鹰币';

  @override
  String get re_title => '发票邮箱';

  @override
  String get re_invalidEmail => '请输入有效的邮箱地址';

  @override
  String get re_saved => '发票邮箱已保存';

  @override
  String get re_label => '收据邮箱';

  @override
  String get re_body => '充值成功后，Stripe 会把付款收据发到这个邮箱；下次充值收银台也会自动预填它。';

  @override
  String re_useAccountEmailFmt(String email) {
    return '使用登录邮箱 $email';
  }

  @override
  String get re_save => '保存';

  @override
  String common_comingSoonFmt(String name) {
    return '$name（开发中）';
  }

  @override
  String get sheets_episodeTitle => '选集';

  @override
  String get sheets_unlockAllBtn => '全部解锁';

  @override
  String get sheets_unlockTitle => '解锁';

  @override
  String get sheets_unlockChooseCount => '选择解锁集数';

  @override
  String get sheets_unlockFailed => '解锁失败，请稍后重试';

  @override
  String get sheets_networkErr => '网络异常，请稍后重试';

  @override
  String get sheets_walletBalance => '鹰币余额';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins 鹰币';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return '还差 $coins 鹰币，充值后即可解锁';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return '立即解锁 · $coins 鹰币';
  }

  @override
  String get sheets_coinsNotEnough => '鹰币不足 · 去充值';

  @override
  String sheets_tierForeverFmt(String count) {
    return '共 $count 集 · 永久可看';
  }

  @override
  String get sheets_unlockAllSub => '解锁全集';

  @override
  String get sheets_unlockThisSub => '解锁本集';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return '解锁全部 $count 集 · 永久可看';
  }

  @override
  String get sheets_unlockThisForever => '解锁本集 · 永久可看';

  @override
  String get sheets_coinsShort => '鹰币';

  @override
  String get sheets_vipDiscount => 'VIP 结算更低';

  @override
  String get sheets_shareTitle => '分享';

  @override
  String get sheets_shareSub => '分享这部好剧';

  @override
  String get sheets_copyLink => '复制链接';

  @override
  String get sheets_linkCopiedShort => '链接已复制';

  @override
  String get sheets_linkCopiedLong => '链接已复制，去粘贴给好友吧';

  @override
  String get sheets_shareTargetMessage => '消息';

  @override
  String get sheets_shareTargetPoster => '海报';

  @override
  String get sheets_shareTargetCommunity => '动态';

  @override
  String get sheets_shareTargetRemix => '混剪';

  @override
  String get sheets_remixComingShort => '智能混剪 · 即将上线';

  @override
  String get sheets_remixComingFooter => '混剪 即将上线，敬请期待';

  @override
  String get sheets_fallbackTitle => 'FalconFlix 精彩短剧';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title太好看了，来 FalconFlix 一起追！$url';
  }

  @override
  String get sheets_posterTitle => '海报';

  @override
  String get sheets_posterMakeSub => '生成专属海报';

  @override
  String get sheets_posterReady => '分享海报';

  @override
  String get sheets_posterGenerating => '海报生成中…';

  @override
  String get sheets_posterGenFail => '海报生成失败';

  @override
  String get sheets_posterExportFail => '海报导出失败';

  @override
  String get sheets_posterTagline => '扫码一起追这部好剧';

  @override
  String get ixp_resumeTitle => '上次看到一半';

  @override
  String get ixp_resumeBody => '要从上次的位置继续看，还是从头来一遍？';

  @override
  String get ixp_resumeFromStart => '从头看';

  @override
  String get ixp_resumeContinue => '继续上次';

  @override
  String ixp_fetchFailedFmt(String code) {
    return '拉取剧情失败（$code）';
  }

  @override
  String get ixp_dataAnomaly => '剧情数据异常（无起点节点）';

  @override
  String ixp_loadErrorFmt(String msg) {
    return '加载出错：$msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return '节点「$id」不存在';
  }

  @override
  String get ixp_nodeJumpTitle => '节点跳转 · owner 测试';

  @override
  String get ixp_nodeJumpBody => '普通用户看不到这个。点任一节点直接跳过去（不会改 flag 状态）。';

  @override
  String ixp_segCountFmt(String n) {
    return '$n 段';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return '付费分支（上线后 $price 鹰币）· 本期免费体验';
  }

  @override
  String get ixp_fallbackTitle => '互动剧';

  @override
  String get ixp_btnSkip => '跳过';

  @override
  String get ixp_btnBack => '返回';

  @override
  String get ixp_segGenerating => '这段还在生成中…';

  @override
  String get ixp_btnContinue => '继续';

  @override
  String ixp_prepFmt(String done, String total) {
    return '准备中 $done / $total';
  }

  @override
  String get ixp_prep => '准备中…';

  @override
  String get ixp_yourChoice => '该你选了';

  @override
  String get ixp_endingFallback => '结局';

  @override
  String get ixp_btnReplay => '重看';

  @override
  String get ixp_endingGood => '好结局';

  @override
  String get ixp_endingBad => '坏结局';

  @override
  String get ixp_endingHidden => '隐藏结局';

  @override
  String get ixp_endingOpen => '开放结局';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n 选项';
  }

  @override
  String get ip_busyAiCreatingTitle => '已交给 AI 为你创作';

  @override
  String get ip_busyAiCreatingSub =>
      '你的专属结局正在逐帧生成中…\n这通常要几分钟，好了会通知你 —— 你也可以先去逛逛';

  @override
  String get ip_busyDirectorTitle => '导演重坐监视器 · 演员为你进场';

  @override
  String get ip_busyDirectorSub => '正在把你走过的每一个选择、你的脸，写进只属于你的收场';

  @override
  String get ip_busyDoneTitle => '✦ 你的专属结局已生成';

  @override
  String get ip_busyDoneSub => '已永久收进「我的专属结局」';

  @override
  String ip_titleChipFmt(String n) {
    return '互动剧 · $n 种结局';
  }

  @override
  String get ip_titleSub => '你的每一次选择，都会改写结局';

  @override
  String get ip_titleStart => '进入故事';

  @override
  String get ip_btnContinue => '继续';

  @override
  String ip_voteFmt(String n) {
    return '$n% 人这么选';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return '已解锁结局 $got / $total';
  }

  @override
  String get ip_btnDex => '结局图鉴';

  @override
  String get ip_btnReplay => '换个选择再玩';

  @override
  String get ip_dexTitle => '结局图鉴';

  @override
  String get ip_dexLocked => '？？？';

  @override
  String ip_errorTitleFmt(String err) {
    return '剧情校验未通过\n$err';
  }

  @override
  String get ip_unlockTitleAi => '定制只属于你的结局';

  @override
  String get ip_unlockTitle => '解锁这条剧情分支';

  @override
  String get ip_demoFree => '样板剧 · 免费体验';

  @override
  String get ip_unlockBtnAi => '开始为我定制';

  @override
  String get ip_unlockBtn => '解锁分支';

  @override
  String get ip_unlockCancel => '再想想';

  @override
  String com_sceneSameFmt(String n) {
    return '本场景 $n 件同款';
  }

  @override
  String get com_sameInDrama => '剧中同款';

  @override
  String get com_buyNow => '立即购买';

  @override
  String get com_inStock => '现货 · 包邮';

  @override
  String get com_outOfStock => '暂时缺货';

  @override
  String get com_infoMerchant => '商家';

  @override
  String get com_infoEpisode => '关联剧集';

  @override
  String get com_infoScene => '出现场景';

  @override
  String com_sceneTimeFmt(String sec) {
    return '${sec}s 起';
  }

  @override
  String get com_descTitle => '商品介绍';

  @override
  String get com_descBody =>
      '剧中同款精选好物，由 FalconFlix 严选合作商家提供。下单后由平台统一发货，支持七天无理由退换。（示例文案，接入真实商品后替换。）';

  @override
  String get com_addCart => '加入购物车';

  @override
  String get com_addCartToast => '已加入购物车（开发中）';

  @override
  String get com_methodCoin => '金币余额';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return '余 $n';
  }

  @override
  String get com_methodWechat => '微信支付';

  @override
  String get com_methodAlipay => '支付宝';

  @override
  String get com_confirmOrder => '确认订单';

  @override
  String get com_qtyOne => '数量 1';

  @override
  String get com_payMethod => '支付方式';

  @override
  String get com_lineAmount => '商品金额';

  @override
  String get com_lineCoupon => '优惠码';

  @override
  String get com_lineCouponUnused => '未使用';

  @override
  String get com_lineShipping => '运费';

  @override
  String get com_lineShippingFree => '包邮';

  @override
  String get com_total => '合计';

  @override
  String get com_submitOrder => '提交订单';

  @override
  String get com_submitToast => '下单成功（支付功能开发中）';

  @override
  String get ss_tier66_label => '点亮 TA';

  @override
  String get ss_tier66_meaning => '六六大顺';

  @override
  String get ss_tier188_label => '送一捧花';

  @override
  String get ss_tier188_meaning => '心意满满';

  @override
  String get ss_tier520_label => '我爱 TA';

  @override
  String get ss_tier520_meaning => '小鹿乱撞';

  @override
  String get ss_tier1314_label => '一生一世';

  @override
  String get ss_tier1314_meaning => '非你不可';

  @override
  String get ss_tier3344_label => '生生世世';

  @override
  String get ss_tier3344_meaning => '宠 TA 到底';

  @override
  String get ss_tier9999_label => '封神助攻';

  @override
  String get ss_tier9999_meaning => '榜一就是你';

  @override
  String ss_callForFmt(String name) {
    return '助推 $name';
  }

  @override
  String get ss_subtitle => '砸的鹰币越多 · TA 出道越快 · 你的榜位越高';

  @override
  String ss_balanceFmt(String n) {
    return '我的鹰币余额 $n';
  }

  @override
  String get ss_localNote => '内测体验 · 助推先本地记录，正式上线后从鹰币结算';

  @override
  String get ss_celebTitle => '助推成功';

  @override
  String get ss_backFailed => '助推失败，请稍后再试';

  @override
  String ss_forFmt(String name, String label) {
    return '为 $name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins 鹰币';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return '出道进度 +$delta% · 现 $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 你登顶 TA 的榜一大哥！V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return '你是 TA 的第 $rank 位守护者 · V$level $tier';
  }

  @override
  String get ss_tapToContinue => '轻触任意处继续';

  @override
  String get air_title => '角色机会榜';

  @override
  String get air_sub => '热度攒满就开机出道 · 助推越猛排名越靠前';

  @override
  String get air_segCharRank => '角色榜';

  @override
  String get air_segKingRank => '榜一大哥';

  @override
  String get air_chipAll => '全部';

  @override
  String get air_chipFemale => '女宝';

  @override
  String get air_chipMale => '男宝';

  @override
  String get air_chipTycoon => '巨鳄';

  @override
  String get air_chipDeity => '封神';

  @override
  String get air_chipLegend => '传奇';

  @override
  String get air_emptyChar => '这个分类暂时没有角色';

  @override
  String get air_emptyKing => '这个段位暂时虚位以待';

  @override
  String get air_debuted => '已开机出道';

  @override
  String get air_leading => '出道领跑';

  @override
  String air_heatFmt(String pct) {
    return '助推热度 $pct%';
  }

  @override
  String get air_doneShoot => '已出道开机';

  @override
  String air_toGoFmt(String n) {
    return '距开机还差 $n%';
  }

  @override
  String air_supportKingFmt(String name) {
    return '本剧头号助推 $name';
  }

  @override
  String get air_emptyKingPlaceholder => '虚位以待';

  @override
  String get air_globalKing => '全站榜一大哥';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · 力挺 $name';
  }

  @override
  String air_guardFmt(String name) {
    return '守护 $name';
  }

  @override
  String get cd_secVideos => 'TA 的视频';

  @override
  String get cd_secMoments => '深入沟通的时刻';

  @override
  String get cd_actUnlock => '鹰币解锁';

  @override
  String get cd_secCredits => 'TA 参演的剧';

  @override
  String cd_secBoardFmt(String n) {
    return '助推榜 · $n 位支持者';
  }

  @override
  String get cd_actImInToo => '我也要上榜 ›';

  @override
  String get cd_swipeHint => '下滑了解 TA · 助推 · 解锁';

  @override
  String get cd_introBadge => 'TA 的自我介绍';

  @override
  String get cd_debutProgress => '出道助推进度';

  @override
  String get cd_debutHint => '攒满即触发开机 · 真人＋AI 结合的精品互动剧';

  @override
  String cd_clipToastFmt(String name) {
    return '播放片段「$name」· 开发中';
  }

  @override
  String cd_momentToastFmt(String title) {
    return '解锁「$title」· 鹰币功能开发中';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '《$name》· 欣赏功能开发中';
  }

  @override
  String get cd_kingBadge => '本剧头号助推';

  @override
  String get cd_btnSupport => '助推';

  @override
  String get cd_btnChat => '聊天 · 解锁';

  @override
  String get sp_toolPosterName => '剧照海报生成';

  @override
  String get sp_toolPosterDesc => '上传人脸，生成你在这部剧里的竖版海报。';

  @override
  String get sp_toolPosterCost => '约 5-25 金币';

  @override
  String get sp_toolVideoNameShort => '3秒 AI 片段';

  @override
  String get sp_toolVideoName => '3秒 AI 短剧片段';

  @override
  String get sp_toolVideoDesc => '用图片或一句话生成轻量竖版短剧片段。';

  @override
  String get sp_toolVideoCost => '约 40 金币';

  @override
  String get sp_toolMakeoverName => 'AI 变装';

  @override
  String get sp_toolMakeoverDesc => '一张照片尝试古装、职业装、动漫、复古和写真。';

  @override
  String get sp_toolMakeoverCost => '约 25 金币';

  @override
  String get sp_toolAvatarName => 'AI 专属头像';

  @override
  String get sp_toolAvatarDesc => '用人脸参考生成个人头像，可直接更新资料页。';

  @override
  String get sp_toolAvatarCost => '约 5-25 金币';

  @override
  String get sp_sectionHeader => 'AI 玩法';

  @override
  String get sp_subtitle => '和短剧观看连接的轻量 AI 玩法。';

  @override
  String sp_creatingFmt(String title) {
    return '正在为《$title》创作';
  }

  @override
  String get sp_chipLinked => '剧情联动';

  @override
  String get sp_chipMall => '短剧商城';

  @override
  String get sp_putInDramaTitle => '把自己放进短剧';

  @override
  String get sp_putInDramaBody => '拍照或上传照片，生成当前短剧的海报或小片段。';

  @override
  String get sp_btnTryRoleplay => '试试 AI 入戏';

  @override
  String get sp_sceneMallTitle => '场景商城';

  @override
  String get sp_sceneMallBody => '查看短剧同款、场景商品和创作者联名商品。';

  @override
  String get spf_settingsTitle => '工具设置';

  @override
  String spf_linkedToFmt(String title) {
    return '关联《$title》';
  }

  @override
  String get spf_chooseTool => '选择玩法';

  @override
  String spf_genBtnFmt(String cost) {
    return '生成 · $cost';
  }

  @override
  String get spf_noPhotoBtn => '请先上传照片';

  @override
  String get spf_photoReady => '照片已就绪';

  @override
  String get spf_uploadPhoto => '上传你的照片';

  @override
  String get spf_photoTapToReplace => '可点击重新选择';

  @override
  String get spf_photoHint => '正面或全身，确保人脸清晰';

  @override
  String get spf_photoSourceTitle => '添加照片';

  @override
  String get spf_takePhoto => '拍照';

  @override
  String get spf_chooseFromAlbum => '从相册选择';

  @override
  String get spf_generating => 'AI 正在生成…';

  @override
  String get spf_generatingSub => '正在把你放进短剧，请稍候';

  @override
  String get spf_genDoneTag => '生成完成';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · 成片';
  }

  @override
  String get spf_genDoneBody => '保存到作品、分享，或重新生成。';

  @override
  String get spf_btnSave => '保存到相册';

  @override
  String get spf_savedToast => '已保存到相册';

  @override
  String get spf_saveFail => '保存失败，请重试';

  @override
  String get spf_saveNoPerm => '请在系统设置里允许访问相册后再保存';

  @override
  String get spf_shareLabel => 'AI 成片';

  @override
  String get cui_chipAI => 'AI 互动';

  @override
  String get cui_chipMetaverse => '元宇宙世界观';

  @override
  String get cui_title => '角色元宇宙';

  @override
  String get cui_lead => '在这里，你遇见的不是演员，是会回应你的人。';

  @override
  String get cui_body =>
      '每一个角色，都有自己的性格、声音和故事。你可以陪 TA 聊天，为 TA 助推，把心动的那一个亲手推上舞台——从一句台词，到一部属于你们的精品互动剧。';

  @override
  String get cui_step1Title => '遇见 & 私聊';

  @override
  String get cui_step1Desc => '长按角色听 TA 说话，进去与 TA 一对一聊天。能量陪伴，越聊越懂你。';

  @override
  String get cui_step2Title => '助推 & 投票';

  @override
  String get cui_step2Desc => '为心动的 TA 投出鹰币，实名登上助推榜，成为 TA 的「头号助推」。';

  @override
  String get cui_step3Title => '开机 & 出道';

  @override
  String get cui_step3Desc => '助推进度攒满，TA 正式出道——真人＋AI 打造的精品互动剧，由你点燃。';

  @override
  String get cui_step4Title => '客串 & 深入';

  @override
  String get cui_step4Desc => '解锁与 TA 专属的剧情和「深入沟通的时刻」，甚至把自己写进这部剧里。';

  @override
  String get cui_footer => '你投出的每一票，都在改写谁会成为下一个主角。';

  @override
  String get com2_title => '社区动态';

  @override
  String get com2_chipPlaza => '追剧广场';

  @override
  String get com2_emptyHint => '还没有动态，来发第一条吧';

  @override
  String get com2_btnPost => '发动态';

  @override
  String get com2_watching => '正在追这部';

  @override
  String get com2_fallbackDrama => 'FalconFlix 短剧';

  @override
  String get com2_publishedToast => '已发布到社区动态';

  @override
  String get com2_postHint => '说说你对这部剧的感受，安利给大家…';

  @override
  String get com2_publish => '发布';

  @override
  String get com2_attachDrama => '附带这部剧';

  @override
  String get dhc_connected => '已接通';

  @override
  String get dhc_connecting => '接通中';

  @override
  String get dhc_ended => '已结束';

  @override
  String get dhc_error => '出错';

  @override
  String get dhc_connectingHint => '正在接通…请稍等';

  @override
  String dhc_talkingFmt(String name) {
    return '$name 正在说…';
  }

  @override
  String get dhc_listening => '在聆听你说…';

  @override
  String get dhc_backLabel => '返回';

  @override
  String get dhc_actorsReady => '演员正在就位…';

  @override
  String get ss2_searchHint => '搜短剧 / 演员 / 标签';

  @override
  String get ss2_history => '搜索历史';

  @override
  String get ss2_clear => '清空';

  @override
  String get ss2_hot => '热门搜索';

  @override
  String get ss2_hotBadge => '热';

  @override
  String ss2_noResultFmt(String q) {
    return '没有找到「$q」相关短剧';
  }

  @override
  String ss2_foundFmt(String n) {
    return '找到 $n 部';
  }

  @override
  String get ss2_chipCEO => '霸总';

  @override
  String get ss2_chipTimeTravel => '穿越';

  @override
  String get ss2_chipMystery => '悬疑';

  @override
  String get ss2_chipModern => '现言';

  @override
  String get ss2_chipSweetPet => '甜宠';

  @override
  String get rk_emptyCat => '该分类暂无榜单';

  @override
  String get rk_hotTitle => '热播榜单';

  @override
  String get rk_hotSub => '按今日热度实时排序';

  @override
  String get rk_top1Today => '# 1  今日最热';

  @override
  String rk_heatFmt(String plays) {
    return '$plays 热度 · 持续上升';
  }

  @override
  String get rk_chipUrban => '都市';

  @override
  String get rk_chipFinished => '完结';

  @override
  String get rk_chipRomance => '爱情';

  @override
  String get aic_lowEnergyNag => '呜…人家有点没力气了，给我充点能量好不好~';

  @override
  String get aic_chargedReply => '谢谢你！满血复活，我们继续聊~';

  @override
  String get aic_chargeToast => '充能 · 鹰币计费功能开发中（已 mock 充满）';

  @override
  String aic_energyFmt(String pct) {
    return '能量 $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return '给 $name 充能';
  }

  @override
  String aic_hintFmt(String name) {
    return '对 $name 说点什么…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · 需 V$level 解锁';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return '再充 $amount 升到 V$level 即可解锁';
  }

  @override
  String get lg_btnTopUp => '去充值升级';

  @override
  String get lg_btnLater => '以后再说';

  @override
  String get me_defaultName => '鹰眼用户';

  @override
  String get me_avatarUpdated => '头像已更新';

  @override
  String get me_avatarUpdateFailed => '头像更新失败，请重试';

  @override
  String get me_tapAvatarToChange => '点头像可更换自己的图片';

  @override
  String get me_myLevel => '我的等级';

  @override
  String get me_loginEmail => '登录邮箱';

  @override
  String get me_membership => '会员';

  @override
  String get me_uploading => '上传中…';

  @override
  String get me_changeAvatar => '更换头像';

  @override
  String me_copiedFmt(String value) {
    return '已复制：$value';
  }

  @override
  String get tier_commoner => '平民';

  @override
  String get tier_rookie => '入门';

  @override
  String get tier_advanced => '进阶';

  @override
  String get tier_lord => '大佬';

  @override
  String get tier_tycoon => '巨鳄';

  @override
  String get tier_deity => '封神';

  @override
  String get tier_legend => '传奇';

  @override
  String get rch_statusPaid => '已到账';

  @override
  String get rch_statusPending => '待支付';

  @override
  String get rch_statusCanceled => '已取消';

  @override
  String get rch_statusProcessing => '处理中';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n 鹰币';
  }

  @override
  String get time_justNow => '刚刚';

  @override
  String time_minutesAgoFmt(String n) {
    return '$n 分钟前';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return '$n 小时前';
  }

  @override
  String time_daysAgoFmt(String n) {
    return '$n 天前';
  }

  @override
  String get notify_typeRecharge => '充值';

  @override
  String get notify_typeInvite => '邀请';

  @override
  String get notify_typeSystem => '系统';

  @override
  String get notify_typeActivity => '活动';

  @override
  String get notify_typeInteractive => '互动剧';
}
