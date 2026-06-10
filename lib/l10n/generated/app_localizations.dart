import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// 应用名
  ///
  /// In zh, this message translates to:
  /// **'FalconFlix'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabTheater.
  ///
  /// In zh, this message translates to:
  /// **'剧场'**
  String get tabTheater;

  /// No description provided for @tabInteractive.
  ///
  /// In zh, this message translates to:
  /// **'互动剧'**
  String get tabInteractive;

  /// No description provided for @tabCharacter.
  ///
  /// In zh, this message translates to:
  /// **'角色'**
  String get tabCharacter;

  /// No description provided for @tabMe.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabMe;

  /// No description provided for @common_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get common_confirm;

  /// No description provided for @common_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get common_save;

  /// No description provided for @common_back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get common_back;

  /// No description provided for @common_close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get common_close;

  /// No description provided for @common_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get common_loading;

  /// No description provided for @common_more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get common_more;

  /// No description provided for @common_yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get common_no;

  /// No description provided for @common_free.
  ///
  /// In zh, this message translates to:
  /// **'免费'**
  String get common_free;

  /// No description provided for @common_login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get common_login;

  /// No description provided for @common_logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get common_logout;

  /// No description provided for @common_loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get common_loadFailed;

  /// No description provided for @common_pleaseLogin.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get common_pleaseLogin;

  /// No description provided for @common_done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get common_done;

  /// No description provided for @common_edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get common_edit;

  /// No description provided for @common_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get common_delete;

  /// No description provided for @common_send.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get common_send;

  /// No description provided for @me_title.
  ///
  /// In zh, this message translates to:
  /// **'个人中心'**
  String get me_title;

  /// No description provided for @me_loginPrompt.
  ///
  /// In zh, this message translates to:
  /// **'登录 / 注册'**
  String get me_loginPrompt;

  /// No description provided for @me_loginSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'登录后解锁追剧、鹰币钱包与互动剧'**
  String get me_loginSubtitle;

  /// No description provided for @me_membershipNormal.
  ///
  /// In zh, this message translates to:
  /// **'普通会员'**
  String get me_membershipNormal;

  /// No description provided for @me_membershipVip.
  ///
  /// In zh, this message translates to:
  /// **'VIP 会员'**
  String get me_membershipVip;

  /// No description provided for @me_inviteCode.
  ///
  /// In zh, this message translates to:
  /// **'邀请码'**
  String get me_inviteCode;

  /// No description provided for @me_statEagleCoins.
  ///
  /// In zh, this message translates to:
  /// **'鹰币'**
  String get me_statEagleCoins;

  /// No description provided for @me_statBoughtEpisodes.
  ///
  /// In zh, this message translates to:
  /// **'已购剧集'**
  String get me_statBoughtEpisodes;

  /// No description provided for @me_statCollections.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get me_statCollections;

  /// No description provided for @me_sectionMyContent.
  ///
  /// In zh, this message translates to:
  /// **'我的内容'**
  String get me_sectionMyContent;

  /// No description provided for @me_sectionWallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包'**
  String get me_sectionWallet;

  /// No description provided for @me_sectionCommunity.
  ///
  /// In zh, this message translates to:
  /// **'社区'**
  String get me_sectionCommunity;

  /// No description provided for @me_sectionCreator.
  ///
  /// In zh, this message translates to:
  /// **'创作者'**
  String get me_sectionCreator;

  /// No description provided for @me_sectionSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get me_sectionSettings;

  /// No description provided for @me_sectionHelpAbout.
  ///
  /// In zh, this message translates to:
  /// **'帮助与关于'**
  String get me_sectionHelpAbout;

  /// No description provided for @me_rowCollections.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get me_rowCollections;

  /// No description provided for @me_rowHistory.
  ///
  /// In zh, this message translates to:
  /// **'观看历史'**
  String get me_rowHistory;

  /// No description provided for @me_rowCommunity.
  ///
  /// In zh, this message translates to:
  /// **'社区动态'**
  String get me_rowCommunity;

  /// No description provided for @me_rowWallet.
  ///
  /// In zh, this message translates to:
  /// **'充值和会员'**
  String get me_rowWallet;

  /// No description provided for @me_rowOrders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get me_rowOrders;

  /// No description provided for @me_rowInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请好友'**
  String get me_rowInvite;

  /// No description provided for @me_rowPartner.
  ///
  /// In zh, this message translates to:
  /// **'剧集伙伴'**
  String get me_rowPartner;

  /// No description provided for @me_rowNotifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get me_rowNotifications;

  /// No description provided for @me_rowSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get me_rowSettings;

  /// No description provided for @me_rowHelpAbout.
  ///
  /// In zh, this message translates to:
  /// **'帮助与关于'**
  String get me_rowHelpAbout;

  /// No description provided for @me_rowAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于 FalconFlix'**
  String get me_rowAbout;

  /// No description provided for @me_logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认退出登录？'**
  String get me_logoutConfirm;

  /// No description provided for @history_title.
  ///
  /// In zh, this message translates to:
  /// **'观看历史'**
  String get history_title;

  /// No description provided for @history_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有观看记录'**
  String get history_emptyTitle;

  /// No description provided for @history_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'看过一集，这里就会出现，方便你随时回来追到最后看的那一集。'**
  String get history_emptyBody;

  /// No description provided for @history_loginBody.
  ///
  /// In zh, this message translates to:
  /// **'登录后可以查看你看过的剧集。'**
  String get history_loginBody;

  /// No description provided for @history_actionDelSelected.
  ///
  /// In zh, this message translates to:
  /// **'删除所选'**
  String get history_actionDelSelected;

  /// No description provided for @history_actionClearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空全部'**
  String get history_actionClearAll;

  /// No description provided for @history_episodeFallback.
  ///
  /// In zh, this message translates to:
  /// **'整剧'**
  String get history_episodeFallback;

  /// No description provided for @history_unknown.
  ///
  /// In zh, this message translates to:
  /// **'（未知剧目）'**
  String get history_unknown;

  /// No description provided for @history_selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {n}'**
  String history_selectedCount(int n);

  /// No description provided for @history_delConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除 {n} 条记录？'**
  String history_delConfirmTitle(int n);

  /// No description provided for @history_delConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'删除后无法恢复；剧集本身不受影响，下次播放会重新生成记录。'**
  String get history_delConfirmBody;

  /// No description provided for @history_clearConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空所有观看历史？'**
  String get history_clearConfirmTitle;

  /// No description provided for @history_clearConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'清空后无法恢复。下次播放会重新生成记录。'**
  String get history_clearConfirmBody;

  /// No description provided for @history_toastDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {n} 条'**
  String history_toastDeleted(int n);

  /// No description provided for @history_toastCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清空'**
  String get history_toastCleared;

  /// No description provided for @orders_title.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get orders_title;

  /// No description provided for @orders_tabFull.
  ///
  /// In zh, this message translates to:
  /// **'整剧'**
  String get orders_tabFull;

  /// No description provided for @orders_tabEpisode.
  ///
  /// In zh, this message translates to:
  /// **'单集'**
  String get orders_tabEpisode;

  /// No description provided for @orders_tabRecharge.
  ///
  /// In zh, this message translates to:
  /// **'充值流水'**
  String get orders_tabRecharge;

  /// No description provided for @orders_emptyFull.
  ///
  /// In zh, this message translates to:
  /// **'还没有整剧订单'**
  String get orders_emptyFull;

  /// No description provided for @orders_emptyEpisode.
  ///
  /// In zh, this message translates to:
  /// **'还没有单集订单'**
  String get orders_emptyEpisode;

  /// No description provided for @orders_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'解锁的剧目会出现在这里，方便对账与售后。'**
  String get orders_emptyBody;

  /// No description provided for @orders_emptyRecharge.
  ///
  /// In zh, this message translates to:
  /// **'还没有充值记录'**
  String get orders_emptyRecharge;

  /// No description provided for @orders_emptyRechargeBody.
  ///
  /// In zh, this message translates to:
  /// **'完成第一次充值后这里会显示流水。'**
  String get orders_emptyRechargeBody;

  /// No description provided for @orders_loginBodyOrders.
  ///
  /// In zh, this message translates to:
  /// **'登录后可以查看你的订单记录。'**
  String get orders_loginBodyOrders;

  /// No description provided for @orders_loginBodyRecharge.
  ///
  /// In zh, this message translates to:
  /// **'登录后可以查看充值流水。'**
  String get orders_loginBodyRecharge;

  /// No description provided for @orders_kvAmount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get orders_kvAmount;

  /// No description provided for @orders_kvPayMethod.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get orders_kvPayMethod;

  /// No description provided for @orders_kvTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get orders_kvTime;

  /// No description provided for @orders_orderCopied.
  ///
  /// In zh, this message translates to:
  /// **'订单号已复制 · {orderNo}'**
  String orders_orderCopied(String orderNo);

  /// No description provided for @orders_paid.
  ///
  /// In zh, this message translates to:
  /// **'已到账'**
  String get orders_paid;

  /// No description provided for @orders_pending.
  ///
  /// In zh, this message translates to:
  /// **'待支付'**
  String get orders_pending;

  /// No description provided for @orders_payEagle.
  ///
  /// In zh, this message translates to:
  /// **'鹰币'**
  String get orders_payEagle;

  /// No description provided for @orders_unknownTitle.
  ///
  /// In zh, this message translates to:
  /// **'（未知剧目）'**
  String get orders_unknownTitle;

  /// No description provided for @orders_rechargeFallback.
  ///
  /// In zh, this message translates to:
  /// **'鹰币充值'**
  String get orders_rechargeFallback;

  /// No description provided for @inbox_title.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get inbox_title;

  /// No description provided for @inbox_tabAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get inbox_tabAll;

  /// No description provided for @inbox_tabRecharge.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get inbox_tabRecharge;

  /// No description provided for @inbox_tabInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请'**
  String get inbox_tabInvite;

  /// No description provided for @inbox_tabSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get inbox_tabSystem;

  /// No description provided for @inbox_tabActivity.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get inbox_tabActivity;

  /// No description provided for @inbox_tabInteractive.
  ///
  /// In zh, this message translates to:
  /// **'互动剧'**
  String get inbox_tabInteractive;

  /// No description provided for @inbox_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'一条消息也没有'**
  String get inbox_emptyTitle;

  /// No description provided for @inbox_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'充值到账、邀请奖励、活动公告、系统通知都会出现在这里。'**
  String get inbox_emptyBody;

  /// No description provided for @inbox_loginBody.
  ///
  /// In zh, this message translates to:
  /// **'登录后可以查看充值到账 / 邀请奖励 / 系统通知。'**
  String get inbox_loginBody;

  /// No description provided for @settings_title.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_title;

  /// No description provided for @settings_sectionNotificationPlayback.
  ///
  /// In zh, this message translates to:
  /// **'通知与播放'**
  String get settings_sectionNotificationPlayback;

  /// No description provided for @settings_sectionAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get settings_sectionAccount;

  /// No description provided for @settings_sectionUIStorage.
  ///
  /// In zh, this message translates to:
  /// **'界面与存储'**
  String get settings_sectionUIStorage;

  /// No description provided for @settings_rowNotifyPrefs.
  ///
  /// In zh, this message translates to:
  /// **'通知偏好'**
  String get settings_rowNotifyPrefs;

  /// No description provided for @settings_rowPlayPrefs.
  ///
  /// In zh, this message translates to:
  /// **'播放与下载偏好'**
  String get settings_rowPlayPrefs;

  /// No description provided for @settings_rowAccountSecurity.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get settings_rowAccountSecurity;

  /// No description provided for @settings_rowPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私'**
  String get settings_rowPrivacy;

  /// No description provided for @settings_rowLanguage.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get settings_rowLanguage;

  /// No description provided for @settings_rowClearCache.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存'**
  String get settings_rowClearCache;

  /// No description provided for @settings_clearCacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存？'**
  String get settings_clearCacheTitle;

  /// No description provided for @settings_clearCacheBody.
  ///
  /// In zh, this message translates to:
  /// **'会清掉互动剧已下视频 + 网络图片缓存。已购剧目、登录态、设置都不会丢。'**
  String get settings_clearCacheBody;

  /// No description provided for @settings_clearCacheAction.
  ///
  /// In zh, this message translates to:
  /// **'立即清理'**
  String get settings_clearCacheAction;

  /// No description provided for @settings_clearCacheDone.
  ///
  /// In zh, this message translates to:
  /// **'已清理 {size} 缓存'**
  String settings_clearCacheDone(String size);

  /// No description provided for @notifyPrefs_title.
  ///
  /// In zh, this message translates to:
  /// **'通知偏好'**
  String get notifyPrefs_title;

  /// No description provided for @notifyPrefs_pushMaster.
  ///
  /// In zh, this message translates to:
  /// **'推送总开关'**
  String get notifyPrefs_pushMaster;

  /// No description provided for @notifyPrefs_pushMasterDesc.
  ///
  /// In zh, this message translates to:
  /// **'关闭后所有手机推送暂停，但站内信仍会到达'**
  String get notifyPrefs_pushMasterDesc;

  /// No description provided for @notifyPrefs_recharge.
  ///
  /// In zh, this message translates to:
  /// **'充值到账'**
  String get notifyPrefs_recharge;

  /// No description provided for @notifyPrefs_rechargeDesc.
  ///
  /// In zh, this message translates to:
  /// **'充值成功 / 鹰币入账'**
  String get notifyPrefs_rechargeDesc;

  /// No description provided for @notifyPrefs_invite.
  ///
  /// In zh, this message translates to:
  /// **'邀请成功'**
  String get notifyPrefs_invite;

  /// No description provided for @notifyPrefs_inviteDesc.
  ///
  /// In zh, this message translates to:
  /// **'邀请的朋友注册 / 奖励到账'**
  String get notifyPrefs_inviteDesc;

  /// No description provided for @notifyPrefs_system.
  ///
  /// In zh, this message translates to:
  /// **'系统公告'**
  String get notifyPrefs_system;

  /// No description provided for @notifyPrefs_systemDesc.
  ///
  /// In zh, this message translates to:
  /// **'账号安全 / 重要变更'**
  String get notifyPrefs_systemDesc;

  /// No description provided for @notifyPrefs_activity.
  ///
  /// In zh, this message translates to:
  /// **'活动促销'**
  String get notifyPrefs_activity;

  /// No description provided for @notifyPrefs_activityDesc.
  ///
  /// In zh, this message translates to:
  /// **'新剧上线 / 充值大促'**
  String get notifyPrefs_activityDesc;

  /// No description provided for @notifyPrefs_interactive.
  ///
  /// In zh, this message translates to:
  /// **'互动剧进度'**
  String get notifyPrefs_interactive;

  /// No description provided for @notifyPrefs_interactiveDesc.
  ///
  /// In zh, this message translates to:
  /// **'在追的互动剧上新 / 新结局解锁'**
  String get notifyPrefs_interactiveDesc;

  /// No description provided for @notifyPrefs_saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{msg}'**
  String notifyPrefs_saveFailed(String msg);

  /// No description provided for @playPrefs_title.
  ///
  /// In zh, this message translates to:
  /// **'播放与下载偏好'**
  String get playPrefs_title;

  /// No description provided for @playPrefs_autoplay.
  ///
  /// In zh, this message translates to:
  /// **'首页自动连播'**
  String get playPrefs_autoplay;

  /// No description provided for @playPrefs_autoplayDesc.
  ///
  /// In zh, this message translates to:
  /// **'看完一条自动播放下一条'**
  String get playPrefs_autoplayDesc;

  /// No description provided for @playPrefs_wifiOnlyAutoplay.
  ///
  /// In zh, this message translates to:
  /// **'仅 Wi-Fi 自动播放'**
  String get playPrefs_wifiOnlyAutoplay;

  /// No description provided for @playPrefs_wifiOnlyAutoplayDesc.
  ///
  /// In zh, this message translates to:
  /// **'4G/5G 下不自动播，节省流量'**
  String get playPrefs_wifiOnlyAutoplayDesc;

  /// No description provided for @playPrefs_quality.
  ///
  /// In zh, this message translates to:
  /// **'默认画质'**
  String get playPrefs_quality;

  /// No description provided for @playPrefs_qualityAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动（根据网络）'**
  String get playPrefs_qualityAuto;

  /// No description provided for @playPrefs_quality480.
  ///
  /// In zh, this message translates to:
  /// **'标清 480p'**
  String get playPrefs_quality480;

  /// No description provided for @playPrefs_quality720.
  ///
  /// In zh, this message translates to:
  /// **'高清 720p'**
  String get playPrefs_quality720;

  /// No description provided for @playPrefs_quality1080.
  ///
  /// In zh, this message translates to:
  /// **'超清 1080p'**
  String get playPrefs_quality1080;

  /// No description provided for @playPrefs_wifiOnlyDownload.
  ///
  /// In zh, this message translates to:
  /// **'仅 Wi-Fi 下载'**
  String get playPrefs_wifiOnlyDownload;

  /// No description provided for @playPrefs_wifiOnlyDownloadDesc.
  ///
  /// In zh, this message translates to:
  /// **'互动剧 / 离线缓存只在 Wi-Fi 下进行'**
  String get playPrefs_wifiOnlyDownloadDesc;

  /// No description provided for @accountSec_title.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get accountSec_title;

  /// No description provided for @accountSec_sectionLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get accountSec_sectionLogin;

  /// No description provided for @accountSec_sectionDeletion.
  ///
  /// In zh, this message translates to:
  /// **'账号注销'**
  String get accountSec_sectionDeletion;

  /// No description provided for @accountSec_rowChangePwd.
  ///
  /// In zh, this message translates to:
  /// **'修改登录密码'**
  String get accountSec_rowChangePwd;

  /// No description provided for @accountSec_rowChangePwdDesc.
  ///
  /// In zh, this message translates to:
  /// **'需要先输入原密码'**
  String get accountSec_rowChangePwdDesc;

  /// No description provided for @accountSec_rowDelete.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get accountSec_rowDelete;

  /// No description provided for @accountSec_rowDeleteDesc.
  ///
  /// In zh, this message translates to:
  /// **'7 天冷静期，期间登录可撤销'**
  String get accountSec_rowDeleteDesc;

  /// No description provided for @accountSec_oldPwHint.
  ///
  /// In zh, this message translates to:
  /// **'原密码'**
  String get accountSec_oldPwHint;

  /// No description provided for @accountSec_newPwHint.
  ///
  /// In zh, this message translates to:
  /// **'新密码（至少 8 位）'**
  String get accountSec_newPwHint;

  /// No description provided for @accountSec_confirmPwHint.
  ///
  /// In zh, this message translates to:
  /// **'再次输入新密码'**
  String get accountSec_confirmPwHint;

  /// No description provided for @accountSec_errMinLen.
  ///
  /// In zh, this message translates to:
  /// **'新密码至少 8 位'**
  String get accountSec_errMinLen;

  /// No description provided for @accountSec_errMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入不一致'**
  String get accountSec_errMismatch;

  /// No description provided for @accountSec_saveNewPw.
  ///
  /// In zh, this message translates to:
  /// **'保存新密码'**
  String get accountSec_saveNewPw;

  /// No description provided for @accountSec_saving.
  ///
  /// In zh, this message translates to:
  /// **'保存中…'**
  String get accountSec_saving;

  /// No description provided for @accountSec_pwUpdated.
  ///
  /// In zh, this message translates to:
  /// **'密码已更新'**
  String get accountSec_pwUpdated;

  /// No description provided for @privacyPrefs_title.
  ///
  /// In zh, this message translates to:
  /// **'隐私'**
  String get privacyPrefs_title;

  /// No description provided for @privacyPrefs_sectionData.
  ///
  /// In zh, this message translates to:
  /// **'我的数据'**
  String get privacyPrefs_sectionData;

  /// No description provided for @privacyPrefs_sectionLegal.
  ///
  /// In zh, this message translates to:
  /// **'协议与政策'**
  String get privacyPrefs_sectionLegal;

  /// No description provided for @privacyPrefs_rowExport.
  ///
  /// In zh, this message translates to:
  /// **'下载我的数据'**
  String get privacyPrefs_rowExport;

  /// No description provided for @privacyPrefs_rowExportDesc.
  ///
  /// In zh, this message translates to:
  /// **'GDPR / CCPA 合规：申请打包下载你的全部数据'**
  String get privacyPrefs_rowExportDesc;

  /// No description provided for @privacyPrefs_rowPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPrefs_rowPolicy;

  /// No description provided for @deleteAcc_title.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get deleteAcc_title;

  /// No description provided for @deleteAcc_inProgress.
  ///
  /// In zh, this message translates to:
  /// **'注销申请进行中'**
  String get deleteAcc_inProgress;

  /// No description provided for @deleteAcc_scheduledAt.
  ///
  /// In zh, this message translates to:
  /// **'执行时间：{time}'**
  String deleteAcc_scheduledAt(String time);

  /// No description provided for @deleteAcc_pendingHint.
  ///
  /// In zh, this message translates to:
  /// **'7 天冷静期内任何时候登录此账号都可以撤销注销。撤销后账号与所有数据立刻恢复正常使用。'**
  String get deleteAcc_pendingHint;

  /// No description provided for @deleteAcc_cancelBtn.
  ///
  /// In zh, this message translates to:
  /// **'撤销注销，继续使用'**
  String get deleteAcc_cancelBtn;

  /// No description provided for @deleteAcc_willDelete.
  ///
  /// In zh, this message translates to:
  /// **'注销账号会删除以下数据'**
  String get deleteAcc_willDelete;

  /// No description provided for @deleteAcc_bullet1.
  ///
  /// In zh, this message translates to:
  /// **'账号资料、昵称、头像、邮箱、手机号绑定'**
  String get deleteAcc_bullet1;

  /// No description provided for @deleteAcc_bullet2.
  ///
  /// In zh, this message translates to:
  /// **'钱包余额（鹰币不可退款）、VIP / 等级'**
  String get deleteAcc_bullet2;

  /// No description provided for @deleteAcc_bullet3.
  ///
  /// In zh, this message translates to:
  /// **'已购买的剧集与互动剧解锁记录'**
  String get deleteAcc_bullet3;

  /// No description provided for @deleteAcc_bullet4.
  ///
  /// In zh, this message translates to:
  /// **'观看历史、收藏、社区动态、互动剧存档'**
  String get deleteAcc_bullet4;

  /// No description provided for @deleteAcc_bullet5.
  ///
  /// In zh, this message translates to:
  /// **'邀请关系（被邀请人侧记录保留）'**
  String get deleteAcc_bullet5;

  /// No description provided for @deleteAcc_coolingHint.
  ///
  /// In zh, this message translates to:
  /// **'提交后进入 7 天冷静期，期间登录此账号可撤销。过期后账号将被永久删除，且无法恢复。'**
  String get deleteAcc_coolingHint;

  /// No description provided for @deleteAcc_reasonLabel.
  ///
  /// In zh, this message translates to:
  /// **'注销原因（可选，用于改进产品）'**
  String get deleteAcc_reasonLabel;

  /// No description provided for @deleteAcc_reasonHint.
  ///
  /// In zh, this message translates to:
  /// **'说说你的想法（可不填）'**
  String get deleteAcc_reasonHint;

  /// No description provided for @deleteAcc_typeToConfirm.
  ///
  /// In zh, this message translates to:
  /// **'请输入「{phrase}」以确认'**
  String deleteAcc_typeToConfirm(String phrase);

  /// No description provided for @deleteAcc_confirmPhrase.
  ///
  /// In zh, this message translates to:
  /// **'删除我的账号'**
  String get deleteAcc_confirmPhrase;

  /// No description provided for @deleteAcc_typeMismatch.
  ///
  /// In zh, this message translates to:
  /// **'请准确输入「{phrase}」以确认'**
  String deleteAcc_typeMismatch(String phrase);

  /// No description provided for @deleteAcc_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交注销申请'**
  String get deleteAcc_submit;

  /// No description provided for @deleteAcc_finalTitle.
  ///
  /// In zh, this message translates to:
  /// **'最后一次确认'**
  String get deleteAcc_finalTitle;

  /// No description provided for @deleteAcc_finalBody.
  ///
  /// In zh, this message translates to:
  /// **'提交后将进入 7 天冷静期。期间任何时候登录都可以撤销。\n\n到期后，账号数据将被永久删除且无法恢复。'**
  String get deleteAcc_finalBody;

  /// No description provided for @deleteAcc_finalSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交注销'**
  String get deleteAcc_finalSubmit;

  /// No description provided for @deleteAcc_submitted.
  ///
  /// In zh, this message translates to:
  /// **'注销申请已提交，7 天后执行'**
  String get deleteAcc_submitted;

  /// No description provided for @deleteAcc_cancelled.
  ///
  /// In zh, this message translates to:
  /// **'已撤销注销申请'**
  String get deleteAcc_cancelled;

  /// No description provided for @deleteAcc_thinkAgain.
  ///
  /// In zh, this message translates to:
  /// **'再想想，先不注销'**
  String get deleteAcc_thinkAgain;

  /// No description provided for @dataExport_title.
  ///
  /// In zh, this message translates to:
  /// **'下载我的数据'**
  String get dataExport_title;

  /// No description provided for @dataExport_introTitle.
  ///
  /// In zh, this message translates to:
  /// **'下载你的全部数据'**
  String get dataExport_introTitle;

  /// No description provided for @dataExport_introBody.
  ///
  /// In zh, this message translates to:
  /// **'依据 GDPR Article 15（欧盟）与 CCPA（加州），你有权获取我们持有的关于你的全部个人数据。\n\n提交申请后，我们会异步生成一个 zip 包，包含：\n  · 账号资料 / 邮箱 / 手机号\n  · 鹰币余额与变更流水\n  · 已购订单、观看历史、收藏\n  · 社区动态、互动剧解锁记录\n\n准备完成后会通过站内信通知你，下载链接有效期 7 天。'**
  String get dataExport_introBody;

  /// No description provided for @dataExport_statusQueued.
  ///
  /// In zh, this message translates to:
  /// **'待处理 · 排队中'**
  String get dataExport_statusQueued;

  /// No description provided for @dataExport_statusProcessing.
  ///
  /// In zh, this message translates to:
  /// **'处理中 · 正在打包'**
  String get dataExport_statusProcessing;

  /// No description provided for @dataExport_statusReady.
  ///
  /// In zh, this message translates to:
  /// **'已完成 · 可下载'**
  String get dataExport_statusReady;

  /// No description provided for @dataExport_statusExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期 · 请重新申请'**
  String get dataExport_statusExpired;

  /// No description provided for @dataExport_statusFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成失败 · 请重新申请'**
  String get dataExport_statusFailed;

  /// No description provided for @dataExport_expiresAt.
  ///
  /// In zh, this message translates to:
  /// **'链接有效至 {time}'**
  String dataExport_expiresAt(String time);

  /// No description provided for @dataExport_downloadBtn.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get dataExport_downloadBtn;

  /// No description provided for @dataExport_submitBtn.
  ///
  /// In zh, this message translates to:
  /// **'申请下载'**
  String get dataExport_submitBtn;

  /// No description provided for @dataExport_submitting.
  ///
  /// In zh, this message translates to:
  /// **'提交中…'**
  String get dataExport_submitting;

  /// No description provided for @dataExport_submitted.
  ///
  /// In zh, this message translates to:
  /// **'已提交申请，准备好后会通知你下载'**
  String get dataExport_submitted;

  /// No description provided for @helpAbout_title.
  ///
  /// In zh, this message translates to:
  /// **'帮助与关于'**
  String get helpAbout_title;

  /// No description provided for @helpAbout_sectionHelp.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get helpAbout_sectionHelp;

  /// No description provided for @helpAbout_sectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get helpAbout_sectionAbout;

  /// No description provided for @helpAbout_rowFaq.
  ///
  /// In zh, this message translates to:
  /// **'帮助中心'**
  String get helpAbout_rowFaq;

  /// No description provided for @helpAbout_rowFaqDesc.
  ///
  /// In zh, this message translates to:
  /// **'常见问题解答'**
  String get helpAbout_rowFaqDesc;

  /// No description provided for @helpAbout_rowSupport.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get helpAbout_rowSupport;

  /// No description provided for @helpAbout_rowSupportDesc.
  ///
  /// In zh, this message translates to:
  /// **'一对一工单对话'**
  String get helpAbout_rowSupportDesc;

  /// No description provided for @helpAbout_rowFeedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get helpAbout_rowFeedback;

  /// No description provided for @helpAbout_rowFeedbackDesc.
  ///
  /// In zh, this message translates to:
  /// **'产品建议 / Bug 上报'**
  String get helpAbout_rowFeedbackDesc;

  /// No description provided for @faq_title.
  ///
  /// In zh, this message translates to:
  /// **'帮助中心'**
  String get faq_title;

  /// No description provided for @faq_catAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get faq_catAll;

  /// No description provided for @faq_catAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get faq_catAccount;

  /// No description provided for @faq_catRecharge.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get faq_catRecharge;

  /// No description provided for @faq_catPlayback.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get faq_catPlayback;

  /// No description provided for @faq_catInteractive.
  ///
  /// In zh, this message translates to:
  /// **'互动剧'**
  String get faq_catInteractive;

  /// No description provided for @faq_catOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get faq_catOther;

  /// No description provided for @faq_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无 FAQ'**
  String get faq_emptyTitle;

  /// No description provided for @faq_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'如果你遇到了问题，可以直接「联系客服」开工单。'**
  String get faq_emptyBody;

  /// No description provided for @tickets_title.
  ///
  /// In zh, this message translates to:
  /// **'联系客服'**
  String get tickets_title;

  /// No description provided for @tickets_newBtn.
  ///
  /// In zh, this message translates to:
  /// **'新建工单'**
  String get tickets_newBtn;

  /// No description provided for @tickets_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有工单'**
  String get tickets_emptyTitle;

  /// No description provided for @tickets_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'遇到问题点右下角「新建工单」，客服会一对一回复你。'**
  String get tickets_emptyBody;

  /// No description provided for @tickets_threadTitle.
  ///
  /// In zh, this message translates to:
  /// **'工单详情'**
  String get tickets_threadTitle;

  /// No description provided for @tickets_initial.
  ///
  /// In zh, this message translates to:
  /// **'初始问题'**
  String get tickets_initial;

  /// No description provided for @tickets_speakerStaff.
  ///
  /// In zh, this message translates to:
  /// **'客服'**
  String get tickets_speakerStaff;

  /// No description provided for @tickets_speakerSelf.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get tickets_speakerSelf;

  /// No description provided for @tickets_replyHint.
  ///
  /// In zh, this message translates to:
  /// **'回复客服…'**
  String get tickets_replyHint;

  /// No description provided for @tickets_sendFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送失败：{msg}'**
  String tickets_sendFailed(String msg);

  /// No description provided for @tickets_statusPending.
  ///
  /// In zh, this message translates to:
  /// **'待处理'**
  String get tickets_statusPending;

  /// No description provided for @tickets_statusReplied.
  ///
  /// In zh, this message translates to:
  /// **'已回复'**
  String get tickets_statusReplied;

  /// No description provided for @tickets_statusResolved.
  ///
  /// In zh, this message translates to:
  /// **'已解决'**
  String get tickets_statusResolved;

  /// No description provided for @tickets_statusClosed.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get tickets_statusClosed;

  /// No description provided for @feedback_titleTicket.
  ///
  /// In zh, this message translates to:
  /// **'新建工单'**
  String get feedback_titleTicket;

  /// No description provided for @feedback_titleFeedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback_titleFeedback;

  /// No description provided for @feedback_typeBug.
  ///
  /// In zh, this message translates to:
  /// **'Bug 上报'**
  String get feedback_typeBug;

  /// No description provided for @feedback_typeSuggestion.
  ///
  /// In zh, this message translates to:
  /// **'产品建议'**
  String get feedback_typeSuggestion;

  /// No description provided for @feedback_typeComplaint.
  ///
  /// In zh, this message translates to:
  /// **'投诉'**
  String get feedback_typeComplaint;

  /// No description provided for @feedback_typeRecharge.
  ///
  /// In zh, this message translates to:
  /// **'充值问题'**
  String get feedback_typeRecharge;

  /// No description provided for @feedback_typeOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get feedback_typeOther;

  /// No description provided for @feedback_typeLabel.
  ///
  /// In zh, this message translates to:
  /// **'问题类型'**
  String get feedback_typeLabel;

  /// No description provided for @feedback_contentLabel.
  ///
  /// In zh, this message translates to:
  /// **'详细描述'**
  String get feedback_contentLabel;

  /// No description provided for @feedback_contentHintTicket.
  ///
  /// In zh, this message translates to:
  /// **'说说你遇到的问题，越详细越快定位…'**
  String get feedback_contentHintTicket;

  /// No description provided for @feedback_contentHintFeedback.
  ///
  /// In zh, this message translates to:
  /// **'说说你的建议 / 遇到的问题…'**
  String get feedback_contentHintFeedback;

  /// No description provided for @feedback_contactLabel.
  ///
  /// In zh, this message translates to:
  /// **'回访邮箱 / 手机（可选）'**
  String get feedback_contactLabel;

  /// No description provided for @feedback_contactHint.
  ///
  /// In zh, this message translates to:
  /// **'填了我们会优先联系你；不填也行'**
  String get feedback_contactHint;

  /// No description provided for @feedback_submit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get feedback_submit;

  /// No description provided for @feedback_submitting.
  ///
  /// In zh, this message translates to:
  /// **'提交中…'**
  String get feedback_submitting;

  /// No description provided for @feedback_submitted.
  ///
  /// In zh, this message translates to:
  /// **'已提交，客服会一对一回复'**
  String get feedback_submitted;

  /// No description provided for @feedback_minLength.
  ///
  /// In zh, this message translates to:
  /// **'请描述至少 5 个字'**
  String get feedback_minLength;

  /// No description provided for @feedback_tip.
  ///
  /// In zh, this message translates to:
  /// **'小提示：上报 Bug 时附上重现步骤 + 截图（截图功能即将上线）会更快定位。\n版本号：{version}'**
  String feedback_tip(String version);

  /// No description provided for @lang_zh.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get lang_zh;

  /// No description provided for @lang_en.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get lang_en;

  /// No description provided for @lang_ja.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get lang_ja;

  /// No description provided for @lang_ko.
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get lang_ko;

  /// No description provided for @lang_ar.
  ///
  /// In zh, this message translates to:
  /// **'العربية'**
  String get lang_ar;

  /// No description provided for @lang_fr.
  ///
  /// In zh, this message translates to:
  /// **'Français'**
  String get lang_fr;

  /// No description provided for @home_noDramaData.
  ///
  /// In zh, this message translates to:
  /// **'暂无短剧数据'**
  String get home_noDramaData;

  /// No description provided for @home_localOnlyLike.
  ///
  /// In zh, this message translates to:
  /// **'本地片源不支持点赞'**
  String get home_localOnlyLike;

  /// No description provided for @home_localOnlyCollect.
  ///
  /// In zh, this message translates to:
  /// **'本地片源不支持收藏'**
  String get home_localOnlyCollect;

  /// No description provided for @home_addedToMy.
  ///
  /// In zh, this message translates to:
  /// **'已收藏到「我的」'**
  String get home_addedToMy;

  /// No description provided for @home_actionLike.
  ///
  /// In zh, this message translates to:
  /// **'点赞'**
  String get home_actionLike;

  /// No description provided for @home_actionCollected.
  ///
  /// In zh, this message translates to:
  /// **'已收藏'**
  String get home_actionCollected;

  /// No description provided for @home_actionCollect.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get home_actionCollect;

  /// No description provided for @home_actionShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get home_actionShare;

  /// No description provided for @home_shopComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'剧中同款 · AI 识别（商品页开发中）'**
  String get home_shopComingSoon;

  /// No description provided for @home_chipAiTheater.
  ///
  /// In zh, this message translates to:
  /// **'AI 剧场'**
  String get home_chipAiTheater;

  /// No description provided for @home_bannerPremiere.
  ///
  /// In zh, this message translates to:
  /// **'AI 短剧首映'**
  String get home_bannerPremiere;

  /// No description provided for @home_btnWatch.
  ///
  /// In zh, this message translates to:
  /// **'观看'**
  String get home_btnWatch;

  /// No description provided for @home_btnDetails.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get home_btnDetails;

  /// No description provided for @home_loadFailedFmt.
  ///
  /// In zh, this message translates to:
  /// **'加载失败\n{message}'**
  String home_loadFailedFmt(String message);

  /// No description provided for @theater_genreAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get theater_genreAll;

  /// No description provided for @theater_genreRomance.
  ///
  /// In zh, this message translates to:
  /// **'爱情'**
  String get theater_genreRomance;

  /// No description provided for @theater_genreUrban.
  ///
  /// In zh, this message translates to:
  /// **'都市'**
  String get theater_genreUrban;

  /// No description provided for @theater_genreInteractive.
  ///
  /// In zh, this message translates to:
  /// **'互动'**
  String get theater_genreInteractive;

  /// No description provided for @theater_genreFinished.
  ///
  /// In zh, this message translates to:
  /// **'完结'**
  String get theater_genreFinished;

  /// No description provided for @theater_sectionHot.
  ///
  /// In zh, this message translates to:
  /// **'正在热播'**
  String get theater_sectionHot;

  /// No description provided for @theater_seeAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get theater_seeAll;

  /// No description provided for @theater_sectionAll.
  ///
  /// In zh, this message translates to:
  /// **'全部剧集'**
  String get theater_sectionAll;

  /// No description provided for @theater_ranking.
  ///
  /// In zh, this message translates to:
  /// **'热度榜'**
  String get theater_ranking;

  /// No description provided for @theater_today.
  ///
  /// In zh, this message translates to:
  /// **'今日推荐'**
  String get theater_today;

  /// No description provided for @theater_labelShort.
  ///
  /// In zh, this message translates to:
  /// **'短剧'**
  String get theater_labelShort;

  /// No description provided for @theater_continueWatch.
  ///
  /// In zh, this message translates to:
  /// **'继续观看 · {name}'**
  String theater_continueWatch(String name);

  /// No description provided for @theater_heatFmt.
  ///
  /// In zh, this message translates to:
  /// **'{heat} 热度'**
  String theater_heatFmt(String heat);

  /// No description provided for @theater_genreHeatFmt.
  ///
  /// In zh, this message translates to:
  /// **'{tag} · {heat} 热度'**
  String theater_genreHeatFmt(String tag, String heat);

  /// No description provided for @cast_sectionPlaying.
  ///
  /// In zh, this message translates to:
  /// **'在播 & 候选剧'**
  String get cast_sectionPlaying;

  /// No description provided for @cast_oppRanking.
  ///
  /// In zh, this message translates to:
  /// **'角色机会榜 ›'**
  String get cast_oppRanking;

  /// No description provided for @cast_universeTitle.
  ///
  /// In zh, this message translates to:
  /// **'角色元宇宙'**
  String get cast_universeTitle;

  /// No description provided for @cast_universeSub.
  ///
  /// In zh, this message translates to:
  /// **'遇见会回应你的人 · 了解这个世界'**
  String get cast_universeSub;

  /// No description provided for @cast_demoBadge.
  ///
  /// In zh, this message translates to:
  /// **'互动样板 · 可玩'**
  String get cast_demoBadge;

  /// No description provided for @cast_demoTitle.
  ///
  /// In zh, this message translates to:
  /// **'互动样板剧'**
  String get cast_demoTitle;

  /// No description provided for @cast_demoSub.
  ///
  /// In zh, this message translates to:
  /// **'你来选——一句台词点燃一部剧'**
  String get cast_demoSub;

  /// No description provided for @cast_inPlay.
  ///
  /// In zh, this message translates to:
  /// **'在播'**
  String get cast_inPlay;

  /// No description provided for @cast_heatTagFmt.
  ///
  /// In zh, this message translates to:
  /// **'热度 {heat} · {tag}'**
  String cast_heatTagFmt(String heat, String tag);

  /// No description provided for @cast_heatOnlyFmt.
  ///
  /// In zh, this message translates to:
  /// **'热度 {heat}'**
  String cast_heatOnlyFmt(String heat);

  /// No description provided for @cb_sectionSupport.
  ///
  /// In zh, this message translates to:
  /// **'应援榜 · 谁在为 TA 打投'**
  String get cb_sectionSupport;

  /// No description provided for @cb_goSupport.
  ///
  /// In zh, this message translates to:
  /// **'去应援 · 助 TA 出道'**
  String get cb_goSupport;

  /// No description provided for @cb_seeBio.
  ///
  /// In zh, this message translates to:
  /// **'看 TA 简介 ›'**
  String get cb_seeBio;

  /// No description provided for @cb_pollHeatPct.
  ///
  /// In zh, this message translates to:
  /// **'打投热度 {pct}%'**
  String cb_pollHeatPct(String pct);

  /// No description provided for @cb_debuted.
  ///
  /// In zh, this message translates to:
  /// **'已出道开机'**
  String get cb_debuted;

  /// No description provided for @cb_toDebutPct.
  ///
  /// In zh, this message translates to:
  /// **'距开机差 {pct}%'**
  String cb_toDebutPct(String pct);

  /// No description provided for @cb_totalSupport.
  ///
  /// In zh, this message translates to:
  /// **'累计应援'**
  String get cb_totalSupport;

  /// No description provided for @cb_coinsFmt.
  ///
  /// In zh, this message translates to:
  /// **'{coins} 鹰币'**
  String cb_coinsFmt(String coins);

  /// No description provided for @cb_topBacker.
  ///
  /// In zh, this message translates to:
  /// **'本剧榜一大哥'**
  String get cb_topBacker;

  /// No description provided for @cb_emptyBackers.
  ///
  /// In zh, this message translates to:
  /// **'还没有人打 call · 快来当 TA 的第一位榜一大哥'**
  String get cb_emptyBackers;

  /// No description provided for @cb_titleSupportFmt.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 应援榜'**
  String cb_titleSupportFmt(String name);

  /// No description provided for @aid_titleHeader.
  ///
  /// In zh, this message translates to:
  /// **'AI 互动剧'**
  String get aid_titleHeader;

  /// No description provided for @aid_aceBadge.
  ///
  /// In zh, this message translates to:
  /// **'王牌'**
  String get aid_aceBadge;

  /// No description provided for @aid_tagline.
  ///
  /// In zh, this message translates to:
  /// **'你的选择，改写结局。'**
  String get aid_tagline;

  /// No description provided for @aid_demoBadge.
  ///
  /// In zh, this message translates to:
  /// **'样板剧 · demo · 免费试玩'**
  String get aid_demoBadge;

  /// No description provided for @aid_lastcallSub.
  ///
  /// In zh, this message translates to:
  /// **'5 层抉择 · 7 种结局 · 你的选择改写结局'**
  String get aid_lastcallSub;

  /// No description provided for @aid_pipelineTitle.
  ///
  /// In zh, this message translates to:
  /// **'星光片场'**
  String get aid_pipelineTitle;

  /// No description provided for @aid_pipelineSub.
  ///
  /// In zh, this message translates to:
  /// **'王牌片单 · 陆续开机'**
  String get aid_pipelineSub;

  /// No description provided for @aid_cameoTitle.
  ///
  /// In zh, this message translates to:
  /// **'客串自己'**
  String get aid_cameoTitle;

  /// No description provided for @aid_cameoSub.
  ///
  /// In zh, this message translates to:
  /// **'上传一张照片，把你写进这部剧'**
  String get aid_cameoSub;

  /// No description provided for @aid_castingBadge.
  ///
  /// In zh, this message translates to:
  /// **'选角中'**
  String get aid_castingBadge;

  /// No description provided for @aid_producingBadge.
  ///
  /// In zh, this message translates to:
  /// **'制作中'**
  String get aid_producingBadge;

  /// No description provided for @aid_castVoteFmt.
  ///
  /// In zh, this message translates to:
  /// **'为 TA 选角 · {pct}%'**
  String aid_castVoteFmt(String pct);

  /// No description provided for @aid_manifesto1.
  ///
  /// In zh, this message translates to:
  /// **'你不再只是看故事。'**
  String get aid_manifesto1;

  /// No description provided for @aid_manifesto2.
  ///
  /// In zh, this message translates to:
  /// **'你替主角做选择，故事就替你改写结局。'**
  String get aid_manifesto2;

  /// No description provided for @aid_manifesto3.
  ///
  /// In zh, this message translates to:
  /// **'每一次抉择，都是你和这个世界的一次对话。'**
  String get aid_manifesto3;

  /// No description provided for @aid_manifestoHeader.
  ///
  /// In zh, this message translates to:
  /// **'我们为什么做互动剧'**
  String get aid_manifestoHeader;

  /// No description provided for @aid_metaversePre.
  ///
  /// In zh, this message translates to:
  /// **'我们把它叫做「互动剧」——\n但它其实是 '**
  String get aid_metaversePre;

  /// No description provided for @aid_metaverseEmph.
  ///
  /// In zh, this message translates to:
  /// **'「决策元宇宙」的第一幕'**
  String get aid_metaverseEmph;

  /// No description provided for @aid_metaversePost.
  ///
  /// In zh, this message translates to:
  /// **'：\n一个你说了算的世界，从这里开始。'**
  String get aid_metaversePost;

  /// No description provided for @aid_step1Title.
  ///
  /// In zh, this message translates to:
  /// **'看剧'**
  String get aid_step1Title;

  /// No description provided for @aid_step1Sub.
  ///
  /// In zh, this message translates to:
  /// **'坐下来，先被一个故事抓住。'**
  String get aid_step1Sub;

  /// No description provided for @aid_step2Title.
  ///
  /// In zh, this message translates to:
  /// **'互动选择'**
  String get aid_step2Title;

  /// No description provided for @aid_step2Sub.
  ///
  /// In zh, this message translates to:
  /// **'在岔路口替角色做决定，剧情就此分叉。'**
  String get aid_step2Sub;

  /// No description provided for @aid_step3Title.
  ///
  /// In zh, this message translates to:
  /// **'客串自己'**
  String get aid_step3Title;

  /// No description provided for @aid_step3Sub.
  ///
  /// In zh, this message translates to:
  /// **'把你的脸、你的名字写进这部剧。'**
  String get aid_step3Sub;

  /// No description provided for @aid_step4Title.
  ///
  /// In zh, this message translates to:
  /// **'应援出道'**
  String get aid_step4Title;

  /// No description provided for @aid_step4Sub.
  ///
  /// In zh, this message translates to:
  /// **'为心动的角色打投，把 TA 推上舞台。'**
  String get aid_step4Sub;

  /// No description provided for @aid_step5Title.
  ///
  /// In zh, this message translates to:
  /// **'决策元宇宙'**
  String get aid_step5Title;

  /// No description provided for @aid_step5Sub.
  ///
  /// In zh, this message translates to:
  /// **'终点，是一个你说了算的世界。'**
  String get aid_step5Sub;

  /// No description provided for @aid_ladderHeader.
  ///
  /// In zh, this message translates to:
  /// **'从一次选择，到一个世界'**
  String get aid_ladderHeader;

  /// No description provided for @aid_liveTitle.
  ///
  /// In zh, this message translates to:
  /// **'已上线 · 可玩'**
  String get aid_liveTitle;

  /// No description provided for @aid_liveSub.
  ///
  /// In zh, this message translates to:
  /// **'真互动剧 · 你的选择改写结局'**
  String get aid_liveSub;

  /// No description provided for @aid_fallbackHook.
  ///
  /// In zh, this message translates to:
  /// **'你的选择，改写她的故事'**
  String get aid_fallbackHook;

  /// No description provided for @aid_aceCardBadge.
  ///
  /// In zh, this message translates to:
  /// **'王牌互动剧 · 可玩'**
  String get aid_aceCardBadge;

  /// No description provided for @player_btnLiked.
  ///
  /// In zh, this message translates to:
  /// **'已赞'**
  String get player_btnLiked;

  /// No description provided for @player_btnEpisodes.
  ///
  /// In zh, this message translates to:
  /// **'选集'**
  String get player_btnEpisodes;

  /// No description provided for @player_btnAiCast.
  ///
  /// In zh, this message translates to:
  /// **'AI入戏'**
  String get player_btnAiCast;

  /// No description provided for @player_episodeNumFmt.
  ///
  /// In zh, this message translates to:
  /// **'第 {n} 集'**
  String player_episodeNumFmt(int n);

  /// No description provided for @player_switchEpFmt.
  ///
  /// In zh, this message translates to:
  /// **'切到第 {n} 集（接后端中）'**
  String player_switchEpFmt(int n);

  /// No description provided for @player_unlockHint.
  ///
  /// In zh, this message translates to:
  /// **'请在剧目详情页解锁鹰币'**
  String get player_unlockHint;

  /// No description provided for @player_comingSoonFmt.
  ///
  /// In zh, this message translates to:
  /// **'{label}（开发中）'**
  String player_comingSoonFmt(String label);

  /// No description provided for @player_sceneSame.
  ///
  /// In zh, this message translates to:
  /// **'场景同款'**
  String get player_sceneSame;

  /// No description provided for @detail_unlockThis.
  ///
  /// In zh, this message translates to:
  /// **'本集'**
  String get detail_unlockThis;

  /// No description provided for @detail_unlockNext5.
  ///
  /// In zh, this message translates to:
  /// **'后续 5 集'**
  String get detail_unlockNext5;

  /// No description provided for @detail_unlockNext10.
  ///
  /// In zh, this message translates to:
  /// **'后续 10 集'**
  String get detail_unlockNext10;

  /// No description provided for @detail_unlockAll.
  ///
  /// In zh, this message translates to:
  /// **'全集'**
  String get detail_unlockAll;

  /// No description provided for @detail_episodeCountFmt.
  ///
  /// In zh, this message translates to:
  /// **'共 {n} 集'**
  String detail_episodeCountFmt(int n);

  /// No description provided for @detail_drawerEpisodes.
  ///
  /// In zh, this message translates to:
  /// **'抽屉选集'**
  String get detail_drawerEpisodes;

  /// No description provided for @detail_unlockSuccess.
  ///
  /// In zh, this message translates to:
  /// **'解锁成功'**
  String get detail_unlockSuccess;

  /// No description provided for @detail_coinBalanceFmt.
  ///
  /// In zh, this message translates to:
  /// **'鹰币余额 {coins}'**
  String detail_coinBalanceFmt(String coins);

  /// No description provided for @detail_playsCountFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 次播放'**
  String detail_playsCountFmt(String n);

  /// No description provided for @detail_priceUnlockFmt.
  ///
  /// In zh, this message translates to:
  /// **'{coins} 鹰币解锁'**
  String detail_priceUnlockFmt(String coins);

  /// No description provided for @detail_playNow.
  ///
  /// In zh, this message translates to:
  /// **'立即播放'**
  String get detail_playNow;

  /// No description provided for @detail_playThis.
  ///
  /// In zh, this message translates to:
  /// **'播放本剧'**
  String get detail_playThis;

  /// No description provided for @detail_noEpisodes.
  ///
  /// In zh, this message translates to:
  /// **'暂无可播放剧集'**
  String get detail_noEpisodes;

  /// No description provided for @login_welcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎来到 FalconFlix'**
  String get login_welcome;

  /// No description provided for @login_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'登录解锁追剧 · 鹰币钱包 · 专属互动剧'**
  String get login_subtitle;

  /// No description provided for @login_emailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get login_emailLabel;

  /// No description provided for @login_passwordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get login_passwordLabel;

  /// No description provided for @login_codeLabel.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get login_codeLabel;

  /// No description provided for @login_codeHint.
  ///
  /// In zh, this message translates to:
  /// **'6 位验证码'**
  String get login_codeHint;

  /// No description provided for @login_pwInputHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get login_pwInputHint;

  /// No description provided for @login_modeOtp.
  ///
  /// In zh, this message translates to:
  /// **'验证码登录'**
  String get login_modeOtp;

  /// No description provided for @login_modePassword.
  ///
  /// In zh, this message translates to:
  /// **'密码登录'**
  String get login_modePassword;

  /// No description provided for @login_getCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get login_getCode;

  /// No description provided for @login_sending.
  ///
  /// In zh, this message translates to:
  /// **'发送中'**
  String get login_sending;

  /// No description provided for @login_loggingIn.
  ///
  /// In zh, this message translates to:
  /// **'登录中…'**
  String get login_loggingIn;

  /// No description provided for @login_loginOrRegister.
  ///
  /// In zh, this message translates to:
  /// **'登录 / 注册'**
  String get login_loginOrRegister;

  /// No description provided for @login_pwHint.
  ///
  /// In zh, this message translates to:
  /// **'首次用密码登录将自动注册并设置该密码'**
  String get login_pwHint;


  /// No description provided for @login_quickLogin.
  ///
  /// In zh, this message translates to:
  /// **'快捷登录'**
  String get login_quickLogin;

  /// No description provided for @login_recommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get login_recommended;

  /// No description provided for @login_success.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get login_success;

  /// No description provided for @login_agreement.
  ///
  /// In zh, this message translates to:
  /// **'登录即代表同意《用户协议》与《隐私政策》'**
  String get login_agreement;

  /// No description provided for @login_emailInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请先填写正确的邮箱'**
  String get login_emailInvalid;

  /// No description provided for @login_emailRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写正确的邮箱'**
  String get login_emailRequired;

  /// No description provided for @login_passwordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写密码'**
  String get login_passwordRequired;

  /// No description provided for @login_codeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写验证码'**
  String get login_codeRequired;

  /// No description provided for @login_codeSent.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送，请查收邮箱'**
  String get login_codeSent;

  /// No description provided for @login_emailNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'邮件通道暂时不可用，请稍后重试'**
  String get login_emailNotConfigured;

  /// No description provided for @login_networkError.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查网络后重试'**
  String get login_networkError;

  /// No description provided for @login_oauthErrorFmt.
  ///
  /// In zh, this message translates to:
  /// **'{provider} 登录失败：{code}'**
  String login_oauthErrorFmt(String provider, String code);

  /// No description provided for @login_oauthRetryFmt.
  ///
  /// In zh, this message translates to:
  /// **'{provider} 登录失败，请稍后重试'**
  String login_oauthRetryFmt(String provider);

  /// No description provided for @login_oauthComingFmt.
  ///
  /// In zh, this message translates to:
  /// **'{name} 登录正在接入中'**
  String login_oauthComingFmt(String name);

  /// No description provided for @login_oauthComingBody.
  ///
  /// In zh, this message translates to:
  /// **'马上就好～现在可以先用邮箱验证码或密码登录。'**
  String get login_oauthComingBody;

  /// No description provided for @login_gotIt.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get login_gotIt;

  /// No description provided for @login_googleNoToken.
  ///
  /// In zh, this message translates to:
  /// **'Google 未返回 idToken，请检查凭证配置'**
  String get login_googleNoToken;

  /// No description provided for @about_tagline.
  ///
  /// In zh, this message translates to:
  /// **'鹰眼短剧 · 看得见的好戏'**
  String get about_tagline;

  /// No description provided for @about_body.
  ///
  /// In zh, this message translates to:
  /// **'FalconFlix 是面向全球的精品短剧平台——在这里追剧、与 AI 角色互动、边看边带货。我们用电影级的制作与 AI 创意，让每一帧都值得停留。'**
  String get about_body;

  /// No description provided for @about_userAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get about_userAgreement;

  /// No description provided for @about_privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get about_privacyPolicy;

  /// No description provided for @about_legalUpdatedFmt.
  ///
  /// In zh, this message translates to:
  /// **'最近更新：{date}'**
  String about_legalUpdatedFmt(String date);

  /// No description provided for @about_operatingEntity.
  ///
  /// In zh, this message translates to:
  /// **'运营主体'**
  String get about_operatingEntity;

  /// No description provided for @about_contactEmailFmt.
  ///
  /// In zh, this message translates to:
  /// **'联系邮箱：{email}'**
  String about_contactEmailFmt(String email);

  /// No description provided for @about_aboutTitleFmt.
  ///
  /// In zh, this message translates to:
  /// **'关于 {appName}'**
  String about_aboutTitleFmt(String appName);

  /// No description provided for @wallet_title.
  ///
  /// In zh, this message translates to:
  /// **'充值鹰币'**
  String get wallet_title;

  /// No description provided for @wallet_chooseRecharge.
  ///
  /// In zh, this message translates to:
  /// **'选择充值包'**
  String get wallet_chooseRecharge;

  /// No description provided for @wallet_introNote.
  ///
  /// In zh, this message translates to:
  /// **'鹰币用于解锁剧集、互动玩法与应援'**
  String get wallet_introNote;

  /// No description provided for @wallet_menuAutoUnlock.
  ///
  /// In zh, this message translates to:
  /// **'自动解锁设置'**
  String get wallet_menuAutoUnlock;

  /// No description provided for @wallet_menuHistory.
  ///
  /// In zh, this message translates to:
  /// **'充值记录'**
  String get wallet_menuHistory;

  /// No description provided for @wallet_menuReceipt.
  ///
  /// In zh, this message translates to:
  /// **'发票邮箱'**
  String get wallet_menuReceipt;

  /// No description provided for @wallet_stripeNotice.
  ///
  /// In zh, this message translates to:
  /// **'支付由 Stripe 安全处理 · 美金结算'**
  String get wallet_stripeNotice;

  /// No description provided for @wallet_loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请稍后再试'**
  String get wallet_loadFailed;

  /// No description provided for @wallet_packsComing.
  ///
  /// In zh, this message translates to:
  /// **'充值套餐即将上线'**
  String get wallet_packsComing;

  /// No description provided for @wallet_packsComingBody.
  ///
  /// In zh, this message translates to:
  /// **'我们正在为你准备最划算的鹰币礼包'**
  String get wallet_packsComingBody;

  /// No description provided for @wallet_coins.
  ///
  /// In zh, this message translates to:
  /// **'鹰币'**
  String get wallet_coins;

  /// No description provided for @wallet_giftFmt.
  ///
  /// In zh, this message translates to:
  /// **'送 {coins}'**
  String wallet_giftFmt(String coins);

  /// No description provided for @wallet_bestDeal.
  ///
  /// In zh, this message translates to:
  /// **'最划算'**
  String get wallet_bestDeal;

  /// No description provided for @wallet_payNowFmt.
  ///
  /// In zh, this message translates to:
  /// **'立即充值 · {price}'**
  String wallet_payNowFmt(String price);

  /// No description provided for @wallet_payNow.
  ///
  /// In zh, this message translates to:
  /// **'立即充值'**
  String get wallet_payNow;

  /// No description provided for @wallet_loginFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先登录再充值'**
  String get wallet_loginFirst;

  /// No description provided for @wallet_openPayFail.
  ///
  /// In zh, this message translates to:
  /// **'无法打开支付页面，请稍后再试'**
  String get wallet_openPayFail;

  /// No description provided for @wallet_payFail.
  ///
  /// In zh, this message translates to:
  /// **'支付失败，请稍后再试'**
  String get wallet_payFail;

  /// No description provided for @wallet_balanceLabel.
  ///
  /// In zh, this message translates to:
  /// **'鹰币余额'**
  String get wallet_balanceLabel;

  /// No description provided for @wallet_loginToView.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看'**
  String get wallet_loginToView;

  /// No description provided for @wallet_legendPeak.
  ///
  /// In zh, this message translates to:
  /// **'传奇巅峰 · 已封顶'**
  String get wallet_legendPeak;

  /// No description provided for @wallet_toLevelFmt.
  ///
  /// In zh, this message translates to:
  /// **'距 V{level}'**
  String wallet_toLevelFmt(String level);

  /// No description provided for @wallet_paidUsdFmt.
  ///
  /// In zh, this message translates to:
  /// **'累计充值 {amount}'**
  String wallet_paidUsdFmt(String amount);

  /// No description provided for @wallet_topUpToLevelFmt.
  ///
  /// In zh, this message translates to:
  /// **'再充 {amount} 升至 V{level}'**
  String wallet_topUpToLevelFmt(String amount, String level);

  /// No description provided for @wallet_successTitle.
  ///
  /// In zh, this message translates to:
  /// **'鹰币充值成功 · 已到账'**
  String get wallet_successTitle;

  /// No description provided for @wallet_tapAnywhere.
  ///
  /// In zh, this message translates to:
  /// **'轻触任意处继续'**
  String get wallet_tapAnywhere;

  /// No description provided for @wallet_successBarrier.
  ///
  /// In zh, this message translates to:
  /// **'充值成功'**
  String get wallet_successBarrier;

  /// No description provided for @creator_title.
  ///
  /// In zh, this message translates to:
  /// **'伙伴中心'**
  String get creator_title;

  /// No description provided for @creator_statSeries.
  ///
  /// In zh, this message translates to:
  /// **'部短剧'**
  String get creator_statSeries;

  /// No description provided for @creator_statPlays.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get creator_statPlays;

  /// No description provided for @creator_statShare.
  ///
  /// In zh, this message translates to:
  /// **'分成'**
  String get creator_statShare;

  /// No description provided for @creator_applyLabel.
  ///
  /// In zh, this message translates to:
  /// **'申请成为剧集伙伴'**
  String get creator_applyLabel;

  /// No description provided for @creator_applyToast.
  ///
  /// In zh, this message translates to:
  /// **'申请提交（开发中）'**
  String get creator_applyToast;

  /// No description provided for @creator_menuRequirement.
  ///
  /// In zh, this message translates to:
  /// **'上传要求'**
  String get creator_menuRequirement;

  /// No description provided for @creator_menuRevenue.
  ///
  /// In zh, this message translates to:
  /// **'分成规则'**
  String get creator_menuRevenue;

  /// No description provided for @creator_menuLangPriv.
  ///
  /// In zh, this message translates to:
  /// **'语言与隐私'**
  String get creator_menuLangPriv;

  /// No description provided for @invite_title.
  ///
  /// In zh, this message translates to:
  /// **'邀请好友'**
  String get invite_title;

  /// No description provided for @invite_stepsTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀请步骤'**
  String get invite_stepsTitle;

  /// No description provided for @invite_step1Title.
  ///
  /// In zh, this message translates to:
  /// **'分享邀请码'**
  String get invite_step1Title;

  /// No description provided for @invite_step1Sub.
  ///
  /// In zh, this message translates to:
  /// **'把你的专属邀请码发给好友'**
  String get invite_step1Sub;

  /// No description provided for @invite_step2Title.
  ///
  /// In zh, this message translates to:
  /// **'好友填码注册'**
  String get invite_step2Title;

  /// No description provided for @invite_step2Sub.
  ///
  /// In zh, this message translates to:
  /// **'好友注册时填入你的邀请码'**
  String get invite_step2Sub;

  /// No description provided for @invite_step3Title.
  ///
  /// In zh, this message translates to:
  /// **'双方领鹰币'**
  String get invite_step3Title;

  /// No description provided for @invite_step3Sub.
  ///
  /// In zh, this message translates to:
  /// **'注册成功后你和好友都能拿鹰币'**
  String get invite_step3Sub;

  /// No description provided for @invite_copyMessage.
  ///
  /// In zh, this message translates to:
  /// **'复制邀请文案分享'**
  String get invite_copyMessage;

  /// No description provided for @invite_loginToGet.
  ///
  /// In zh, this message translates to:
  /// **'登录后获取邀请码'**
  String get invite_loginToGet;

  /// No description provided for @invite_loginToGen.
  ///
  /// In zh, this message translates to:
  /// **'登录后才能生成你的专属邀请码'**
  String get invite_loginToGen;

  /// No description provided for @invite_messageCopied.
  ///
  /// In zh, this message translates to:
  /// **'邀请文案已复制，去粘贴给好友吧'**
  String get invite_messageCopied;

  /// No description provided for @invite_messageTemplateFmt.
  ///
  /// In zh, this message translates to:
  /// **'🦅 我在用 FalconFlix 追短剧，超好看！注册时填我的邀请码 {code}，咱俩都能领鹰币～'**
  String invite_messageTemplateFmt(String code);

  /// No description provided for @invite_bigTitle.
  ///
  /// In zh, this message translates to:
  /// **'邀请好友 一起追剧'**
  String get invite_bigTitle;

  /// No description provided for @invite_bigSub.
  ///
  /// In zh, this message translates to:
  /// **'好友用你的邀请码注册，双方都能领鹰币奖励'**
  String get invite_bigSub;

  /// No description provided for @invite_myCode.
  ///
  /// In zh, this message translates to:
  /// **'我的专属邀请码'**
  String get invite_myCode;

  /// No description provided for @invite_copyBtn.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get invite_copyBtn;

  /// No description provided for @invite_codeCopiedFmt.
  ///
  /// In zh, this message translates to:
  /// **'邀请码已复制：{code}'**
  String invite_codeCopiedFmt(String code);

  /// No description provided for @collect_emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有收藏的剧'**
  String get collect_emptyTitle;

  /// No description provided for @collect_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'在剧里点「收藏」，就会出现在这里，方便随时回来追。'**
  String get collect_emptyBody;

  /// No description provided for @au_title.
  ///
  /// In zh, this message translates to:
  /// **'自动解锁'**
  String get au_title;

  /// No description provided for @au_introTitle.
  ///
  /// In zh, this message translates to:
  /// **'追剧不被打断'**
  String get au_introTitle;

  /// No description provided for @au_introBody.
  ///
  /// In zh, this message translates to:
  /// **'开启后看到下一集自动用鹰币解锁，一口气追到爽'**
  String get au_introBody;

  /// No description provided for @au_toggleLabel.
  ///
  /// In zh, this message translates to:
  /// **'自动解锁下一集'**
  String get au_toggleLabel;

  /// No description provided for @au_on.
  ///
  /// In zh, this message translates to:
  /// **'已开启'**
  String get au_on;

  /// No description provided for @au_off.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get au_off;

  /// No description provided for @au_toggleOnToast.
  ///
  /// In zh, this message translates to:
  /// **'已开启自动解锁'**
  String get au_toggleOnToast;

  /// No description provided for @au_toggleOffToast.
  ///
  /// In zh, this message translates to:
  /// **'已关闭自动解锁'**
  String get au_toggleOffToast;

  /// No description provided for @au_rule1.
  ///
  /// In zh, this message translates to:
  /// **'点已锁剧集会直接扣鹰币解锁，不再每次弹窗确认'**
  String get au_rule1;

  /// No description provided for @au_rule2.
  ///
  /// In zh, this message translates to:
  /// **'鹰币余额不足时仍会提示你去充值，不会乱扣'**
  String get au_rule2;

  /// No description provided for @au_rule3.
  ///
  /// In zh, this message translates to:
  /// **'仅对「单集解锁」生效；整部解锁因金额较大仍需手动确认'**
  String get au_rule3;

  /// No description provided for @rh_title.
  ///
  /// In zh, this message translates to:
  /// **'充值记录'**
  String get rh_title;

  /// No description provided for @rh_loginToView.
  ///
  /// In zh, this message translates to:
  /// **'登录后可查看充值记录'**
  String get rh_loginToView;

  /// No description provided for @rh_emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'还没有充值记录\n去充值鹰币解锁更多剧集吧'**
  String get rh_emptyBody;

  /// No description provided for @rh_fallback.
  ///
  /// In zh, this message translates to:
  /// **'充值鹰币'**
  String get rh_fallback;

  /// No description provided for @re_title.
  ///
  /// In zh, this message translates to:
  /// **'发票邮箱'**
  String get re_title;

  /// No description provided for @re_invalidEmail.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的邮箱地址'**
  String get re_invalidEmail;

  /// No description provided for @re_saved.
  ///
  /// In zh, this message translates to:
  /// **'发票邮箱已保存'**
  String get re_saved;

  /// No description provided for @re_label.
  ///
  /// In zh, this message translates to:
  /// **'收据邮箱'**
  String get re_label;

  /// No description provided for @re_body.
  ///
  /// In zh, this message translates to:
  /// **'充值成功后，Stripe 会把付款收据发到这个邮箱；下次充值收银台也会自动预填它。'**
  String get re_body;

  /// No description provided for @re_useAccountEmailFmt.
  ///
  /// In zh, this message translates to:
  /// **'使用登录邮箱 {email}'**
  String re_useAccountEmailFmt(String email);

  /// No description provided for @re_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get re_save;

  /// No description provided for @common_comingSoonFmt.
  ///
  /// In zh, this message translates to:
  /// **'{name}（开发中）'**
  String common_comingSoonFmt(String name);

  /// No description provided for @sheets_episodeTitle.
  ///
  /// In zh, this message translates to:
  /// **'选集'**
  String get sheets_episodeTitle;

  /// No description provided for @sheets_unlockAllBtn.
  ///
  /// In zh, this message translates to:
  /// **'全部解锁'**
  String get sheets_unlockAllBtn;

  /// No description provided for @sheets_unlockTitle.
  ///
  /// In zh, this message translates to:
  /// **'解锁'**
  String get sheets_unlockTitle;

  /// No description provided for @sheets_unlockChooseCount.
  ///
  /// In zh, this message translates to:
  /// **'选择解锁集数'**
  String get sheets_unlockChooseCount;

  /// No description provided for @sheets_unlockFailed.
  ///
  /// In zh, this message translates to:
  /// **'解锁失败，请稍后重试'**
  String get sheets_unlockFailed;

  /// No description provided for @sheets_networkErr.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请稍后重试'**
  String get sheets_networkErr;

  /// No description provided for @sheets_walletBalance.
  ///
  /// In zh, this message translates to:
  /// **'鹰币余额'**
  String get sheets_walletBalance;

  /// No description provided for @sheets_coinsFmt.
  ///
  /// In zh, this message translates to:
  /// **'{coins} 鹰币'**
  String sheets_coinsFmt(String coins);

  /// No description provided for @sheets_unlockShortFmt.
  ///
  /// In zh, this message translates to:
  /// **'还差 {coins} 鹰币，充值后即可解锁'**
  String sheets_unlockShortFmt(String coins);

  /// No description provided for @sheets_unlockNowFmt.
  ///
  /// In zh, this message translates to:
  /// **'立即解锁 · {coins} 鹰币'**
  String sheets_unlockNowFmt(String coins);

  /// No description provided for @sheets_coinsNotEnough.
  ///
  /// In zh, this message translates to:
  /// **'鹰币不足 · 去充值'**
  String get sheets_coinsNotEnough;

  /// No description provided for @sheets_tierForeverFmt.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 集 · 永久可看'**
  String sheets_tierForeverFmt(String count);

  /// No description provided for @sheets_unlockAllSub.
  ///
  /// In zh, this message translates to:
  /// **'解锁全集'**
  String get sheets_unlockAllSub;

  /// No description provided for @sheets_unlockThisSub.
  ///
  /// In zh, this message translates to:
  /// **'解锁本集'**
  String get sheets_unlockThisSub;

  /// No description provided for @sheets_unlockAllForeverFmt.
  ///
  /// In zh, this message translates to:
  /// **'解锁全部 {count} 集 · 永久可看'**
  String sheets_unlockAllForeverFmt(String count);

  /// No description provided for @sheets_unlockThisForever.
  ///
  /// In zh, this message translates to:
  /// **'解锁本集 · 永久可看'**
  String get sheets_unlockThisForever;

  /// No description provided for @sheets_coinsShort.
  ///
  /// In zh, this message translates to:
  /// **'鹰币'**
  String get sheets_coinsShort;

  /// No description provided for @sheets_vipDiscount.
  ///
  /// In zh, this message translates to:
  /// **'VIP 结算更低'**
  String get sheets_vipDiscount;

  /// No description provided for @sheets_shareTitle.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get sheets_shareTitle;

  /// No description provided for @sheets_shareSub.
  ///
  /// In zh, this message translates to:
  /// **'分享这部好剧'**
  String get sheets_shareSub;

  /// No description provided for @sheets_copyLink.
  ///
  /// In zh, this message translates to:
  /// **'复制链接'**
  String get sheets_copyLink;

  /// No description provided for @sheets_linkCopiedShort.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制'**
  String get sheets_linkCopiedShort;

  /// No description provided for @sheets_linkCopiedLong.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制，去粘贴给好友吧'**
  String get sheets_linkCopiedLong;

  /// No description provided for @sheets_shareTargetMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get sheets_shareTargetMessage;

  /// No description provided for @sheets_shareTargetPoster.
  ///
  /// In zh, this message translates to:
  /// **'海报'**
  String get sheets_shareTargetPoster;

  /// No description provided for @sheets_shareTargetCommunity.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get sheets_shareTargetCommunity;

  /// No description provided for @sheets_shareTargetRemix.
  ///
  /// In zh, this message translates to:
  /// **'混剪'**
  String get sheets_shareTargetRemix;

  /// No description provided for @sheets_remixComingShort.
  ///
  /// In zh, this message translates to:
  /// **'智能混剪 · 即将上线'**
  String get sheets_remixComingShort;

  /// No description provided for @sheets_remixComingFooter.
  ///
  /// In zh, this message translates to:
  /// **'混剪 即将上线，敬请期待'**
  String get sheets_remixComingFooter;

  /// No description provided for @sheets_fallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'FalconFlix 精彩短剧'**
  String get sheets_fallbackTitle;

  /// No description provided for @sheets_shareTextFmt.
  ///
  /// In zh, this message translates to:
  /// **'{title}太好看了，来 FalconFlix 一起追！{url}'**
  String sheets_shareTextFmt(String title, String url);

  /// No description provided for @sheets_posterTitle.
  ///
  /// In zh, this message translates to:
  /// **'海报'**
  String get sheets_posterTitle;

  /// No description provided for @sheets_posterMakeSub.
  ///
  /// In zh, this message translates to:
  /// **'生成专属海报'**
  String get sheets_posterMakeSub;

  /// No description provided for @sheets_posterReady.
  ///
  /// In zh, this message translates to:
  /// **'分享海报'**
  String get sheets_posterReady;

  /// No description provided for @sheets_posterGenerating.
  ///
  /// In zh, this message translates to:
  /// **'海报生成中…'**
  String get sheets_posterGenerating;

  /// No description provided for @sheets_posterGenFail.
  ///
  /// In zh, this message translates to:
  /// **'海报生成失败'**
  String get sheets_posterGenFail;

  /// No description provided for @sheets_posterExportFail.
  ///
  /// In zh, this message translates to:
  /// **'海报导出失败'**
  String get sheets_posterExportFail;

  /// No description provided for @sheets_posterTagline.
  ///
  /// In zh, this message translates to:
  /// **'扫码一起追这部好剧'**
  String get sheets_posterTagline;

  /// No description provided for @ixp_resumeTitle.
  ///
  /// In zh, this message translates to:
  /// **'上次看到一半'**
  String get ixp_resumeTitle;

  /// No description provided for @ixp_resumeBody.
  ///
  /// In zh, this message translates to:
  /// **'要从上次的位置继续看，还是从头来一遍？'**
  String get ixp_resumeBody;

  /// No description provided for @ixp_resumeFromStart.
  ///
  /// In zh, this message translates to:
  /// **'从头看'**
  String get ixp_resumeFromStart;

  /// No description provided for @ixp_resumeContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续上次'**
  String get ixp_resumeContinue;

  /// No description provided for @ixp_fetchFailedFmt.
  ///
  /// In zh, this message translates to:
  /// **'拉取剧情失败（{code}）'**
  String ixp_fetchFailedFmt(String code);

  /// No description provided for @ixp_dataAnomaly.
  ///
  /// In zh, this message translates to:
  /// **'剧情数据异常（无起点节点）'**
  String get ixp_dataAnomaly;

  /// No description provided for @ixp_loadErrorFmt.
  ///
  /// In zh, this message translates to:
  /// **'加载出错：{msg}'**
  String ixp_loadErrorFmt(String msg);

  /// No description provided for @ixp_nodeNotFoundFmt.
  ///
  /// In zh, this message translates to:
  /// **'节点「{id}」不存在'**
  String ixp_nodeNotFoundFmt(String id);

  /// No description provided for @ixp_nodeJumpTitle.
  ///
  /// In zh, this message translates to:
  /// **'节点跳转 · owner 测试'**
  String get ixp_nodeJumpTitle;

  /// No description provided for @ixp_nodeJumpBody.
  ///
  /// In zh, this message translates to:
  /// **'普通用户看不到这个。点任一节点直接跳过去（不会改 flag 状态）。'**
  String get ixp_nodeJumpBody;

  /// No description provided for @ixp_segCountFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 段'**
  String ixp_segCountFmt(String n);

  /// No description provided for @ixp_lockedToastFmt.
  ///
  /// In zh, this message translates to:
  /// **'付费分支（上线后 {price} 鹰币）· 本期免费体验'**
  String ixp_lockedToastFmt(String price);

  /// No description provided for @ixp_fallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'互动剧'**
  String get ixp_fallbackTitle;

  /// No description provided for @ixp_btnSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get ixp_btnSkip;

  /// No description provided for @ixp_btnBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get ixp_btnBack;

  /// No description provided for @ixp_segGenerating.
  ///
  /// In zh, this message translates to:
  /// **'这段还在生成中…'**
  String get ixp_segGenerating;

  /// No description provided for @ixp_btnContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get ixp_btnContinue;

  /// No description provided for @ixp_prepFmt.
  ///
  /// In zh, this message translates to:
  /// **'准备中 {done} / {total}'**
  String ixp_prepFmt(String done, String total);

  /// No description provided for @ixp_prep.
  ///
  /// In zh, this message translates to:
  /// **'准备中…'**
  String get ixp_prep;

  /// No description provided for @ixp_yourChoice.
  ///
  /// In zh, this message translates to:
  /// **'该你选了'**
  String get ixp_yourChoice;

  /// No description provided for @ixp_endingFallback.
  ///
  /// In zh, this message translates to:
  /// **'结局'**
  String get ixp_endingFallback;

  /// No description provided for @ixp_btnReplay.
  ///
  /// In zh, this message translates to:
  /// **'重看'**
  String get ixp_btnReplay;

  /// No description provided for @ixp_endingGood.
  ///
  /// In zh, this message translates to:
  /// **'好结局'**
  String get ixp_endingGood;

  /// No description provided for @ixp_endingBad.
  ///
  /// In zh, this message translates to:
  /// **'坏结局'**
  String get ixp_endingBad;

  /// No description provided for @ixp_endingHidden.
  ///
  /// In zh, this message translates to:
  /// **'隐藏结局'**
  String get ixp_endingHidden;

  /// No description provided for @ixp_endingOpen.
  ///
  /// In zh, this message translates to:
  /// **'开放结局'**
  String get ixp_endingOpen;

  /// No description provided for @ixp_optionsCountFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 选项'**
  String ixp_optionsCountFmt(String n);

  /// No description provided for @ip_busyAiCreatingTitle.
  ///
  /// In zh, this message translates to:
  /// **'已交给 AI 为你创作'**
  String get ip_busyAiCreatingTitle;

  /// No description provided for @ip_busyAiCreatingSub.
  ///
  /// In zh, this message translates to:
  /// **'你的专属结局正在逐帧生成中…\n这通常要几分钟，好了会通知你 —— 你也可以先去逛逛'**
  String get ip_busyAiCreatingSub;

  /// No description provided for @ip_busyDirectorTitle.
  ///
  /// In zh, this message translates to:
  /// **'导演重坐监视器 · 演员为你进场'**
  String get ip_busyDirectorTitle;

  /// No description provided for @ip_busyDirectorSub.
  ///
  /// In zh, this message translates to:
  /// **'正在把你走过的每一个选择、你的脸，写进只属于你的收场'**
  String get ip_busyDirectorSub;

  /// No description provided for @ip_busyDoneTitle.
  ///
  /// In zh, this message translates to:
  /// **'✦ 你的专属结局已生成'**
  String get ip_busyDoneTitle;

  /// No description provided for @ip_busyDoneSub.
  ///
  /// In zh, this message translates to:
  /// **'已永久收进「我的专属结局」'**
  String get ip_busyDoneSub;

  /// No description provided for @ip_titleChipFmt.
  ///
  /// In zh, this message translates to:
  /// **'互动剧 · {n} 种结局'**
  String ip_titleChipFmt(String n);

  /// No description provided for @ip_titleSub.
  ///
  /// In zh, this message translates to:
  /// **'你的每一次选择，都会改写结局'**
  String get ip_titleSub;

  /// No description provided for @ip_titleStart.
  ///
  /// In zh, this message translates to:
  /// **'进入故事'**
  String get ip_titleStart;

  /// No description provided for @ip_btnContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get ip_btnContinue;

  /// No description provided for @ip_voteFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n}% 人这么选'**
  String ip_voteFmt(String n);

  /// No description provided for @ip_endingProgressFmt.
  ///
  /// In zh, this message translates to:
  /// **'已解锁结局 {got} / {total}'**
  String ip_endingProgressFmt(String got, String total);

  /// No description provided for @ip_btnDex.
  ///
  /// In zh, this message translates to:
  /// **'结局图鉴'**
  String get ip_btnDex;

  /// No description provided for @ip_btnReplay.
  ///
  /// In zh, this message translates to:
  /// **'换个选择再玩'**
  String get ip_btnReplay;

  /// No description provided for @ip_dexTitle.
  ///
  /// In zh, this message translates to:
  /// **'结局图鉴'**
  String get ip_dexTitle;

  /// No description provided for @ip_dexLocked.
  ///
  /// In zh, this message translates to:
  /// **'？？？'**
  String get ip_dexLocked;

  /// No description provided for @ip_errorTitleFmt.
  ///
  /// In zh, this message translates to:
  /// **'剧情校验未通过\n{err}'**
  String ip_errorTitleFmt(String err);

  /// No description provided for @ip_unlockTitleAi.
  ///
  /// In zh, this message translates to:
  /// **'定制只属于你的结局'**
  String get ip_unlockTitleAi;

  /// No description provided for @ip_unlockTitle.
  ///
  /// In zh, this message translates to:
  /// **'解锁这条剧情分支'**
  String get ip_unlockTitle;

  /// No description provided for @ip_demoFree.
  ///
  /// In zh, this message translates to:
  /// **'样板剧 · 免费体验'**
  String get ip_demoFree;

  /// No description provided for @ip_unlockBtnAi.
  ///
  /// In zh, this message translates to:
  /// **'开始为我定制'**
  String get ip_unlockBtnAi;

  /// No description provided for @ip_unlockBtn.
  ///
  /// In zh, this message translates to:
  /// **'解锁分支'**
  String get ip_unlockBtn;

  /// No description provided for @ip_unlockCancel.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get ip_unlockCancel;

  /// No description provided for @com_sceneSameFmt.
  ///
  /// In zh, this message translates to:
  /// **'本场景 {n} 件同款'**
  String com_sceneSameFmt(String n);

  /// No description provided for @com_sameInDrama.
  ///
  /// In zh, this message translates to:
  /// **'剧中同款'**
  String get com_sameInDrama;

  /// No description provided for @com_buyNow.
  ///
  /// In zh, this message translates to:
  /// **'立即购买'**
  String get com_buyNow;

  /// No description provided for @com_inStock.
  ///
  /// In zh, this message translates to:
  /// **'现货 · 包邮'**
  String get com_inStock;

  /// No description provided for @com_outOfStock.
  ///
  /// In zh, this message translates to:
  /// **'暂时缺货'**
  String get com_outOfStock;

  /// No description provided for @com_infoMerchant.
  ///
  /// In zh, this message translates to:
  /// **'商家'**
  String get com_infoMerchant;

  /// No description provided for @com_infoEpisode.
  ///
  /// In zh, this message translates to:
  /// **'关联剧集'**
  String get com_infoEpisode;

  /// No description provided for @com_infoScene.
  ///
  /// In zh, this message translates to:
  /// **'出现场景'**
  String get com_infoScene;

  /// No description provided for @com_sceneTimeFmt.
  ///
  /// In zh, this message translates to:
  /// **'{sec}s 起'**
  String com_sceneTimeFmt(String sec);

  /// No description provided for @com_descTitle.
  ///
  /// In zh, this message translates to:
  /// **'商品介绍'**
  String get com_descTitle;

  /// No description provided for @com_descBody.
  ///
  /// In zh, this message translates to:
  /// **'剧中同款精选好物，由 FalconFlix 严选合作商家提供。下单后由平台统一发货，支持七天无理由退换。（示例文案，接入真实商品后替换。）'**
  String get com_descBody;

  /// No description provided for @com_addCart.
  ///
  /// In zh, this message translates to:
  /// **'加入购物车'**
  String get com_addCart;

  /// No description provided for @com_addCartToast.
  ///
  /// In zh, this message translates to:
  /// **'已加入购物车（开发中）'**
  String get com_addCartToast;

  /// No description provided for @com_methodCoin.
  ///
  /// In zh, this message translates to:
  /// **'金币余额'**
  String get com_methodCoin;

  /// No description provided for @com_methodCoinBalanceFmt.
  ///
  /// In zh, this message translates to:
  /// **'余 {n}'**
  String com_methodCoinBalanceFmt(String n);

  /// No description provided for @com_methodWechat.
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get com_methodWechat;

  /// No description provided for @com_methodAlipay.
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get com_methodAlipay;

  /// No description provided for @com_confirmOrder.
  ///
  /// In zh, this message translates to:
  /// **'确认订单'**
  String get com_confirmOrder;

  /// No description provided for @com_qtyOne.
  ///
  /// In zh, this message translates to:
  /// **'数量 1'**
  String get com_qtyOne;

  /// No description provided for @com_payMethod.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get com_payMethod;

  /// No description provided for @com_lineAmount.
  ///
  /// In zh, this message translates to:
  /// **'商品金额'**
  String get com_lineAmount;

  /// No description provided for @com_lineCoupon.
  ///
  /// In zh, this message translates to:
  /// **'优惠码'**
  String get com_lineCoupon;

  /// No description provided for @com_lineCouponUnused.
  ///
  /// In zh, this message translates to:
  /// **'未使用'**
  String get com_lineCouponUnused;

  /// No description provided for @com_lineShipping.
  ///
  /// In zh, this message translates to:
  /// **'运费'**
  String get com_lineShipping;

  /// No description provided for @com_lineShippingFree.
  ///
  /// In zh, this message translates to:
  /// **'包邮'**
  String get com_lineShippingFree;

  /// No description provided for @com_total.
  ///
  /// In zh, this message translates to:
  /// **'合计'**
  String get com_total;

  /// No description provided for @com_submitOrder.
  ///
  /// In zh, this message translates to:
  /// **'提交订单'**
  String get com_submitOrder;

  /// No description provided for @com_submitToast.
  ///
  /// In zh, this message translates to:
  /// **'下单成功（支付功能开发中）'**
  String get com_submitToast;

  /// No description provided for @ss_tier66_label.
  ///
  /// In zh, this message translates to:
  /// **'点亮 TA'**
  String get ss_tier66_label;

  /// No description provided for @ss_tier66_meaning.
  ///
  /// In zh, this message translates to:
  /// **'六六大顺'**
  String get ss_tier66_meaning;

  /// No description provided for @ss_tier188_label.
  ///
  /// In zh, this message translates to:
  /// **'送一捧花'**
  String get ss_tier188_label;

  /// No description provided for @ss_tier188_meaning.
  ///
  /// In zh, this message translates to:
  /// **'心意满满'**
  String get ss_tier188_meaning;

  /// No description provided for @ss_tier520_label.
  ///
  /// In zh, this message translates to:
  /// **'我爱 TA'**
  String get ss_tier520_label;

  /// No description provided for @ss_tier520_meaning.
  ///
  /// In zh, this message translates to:
  /// **'小鹿乱撞'**
  String get ss_tier520_meaning;

  /// No description provided for @ss_tier1314_label.
  ///
  /// In zh, this message translates to:
  /// **'一生一世'**
  String get ss_tier1314_label;

  /// No description provided for @ss_tier1314_meaning.
  ///
  /// In zh, this message translates to:
  /// **'非你不可'**
  String get ss_tier1314_meaning;

  /// No description provided for @ss_tier3344_label.
  ///
  /// In zh, this message translates to:
  /// **'生生世世'**
  String get ss_tier3344_label;

  /// No description provided for @ss_tier3344_meaning.
  ///
  /// In zh, this message translates to:
  /// **'宠 TA 到底'**
  String get ss_tier3344_meaning;

  /// No description provided for @ss_tier9999_label.
  ///
  /// In zh, this message translates to:
  /// **'封神助攻'**
  String get ss_tier9999_label;

  /// No description provided for @ss_tier9999_meaning.
  ///
  /// In zh, this message translates to:
  /// **'榜一就是你'**
  String get ss_tier9999_meaning;

  /// No description provided for @ss_callForFmt.
  ///
  /// In zh, this message translates to:
  /// **'为 {name} 打 call'**
  String ss_callForFmt(String name);

  /// No description provided for @ss_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'砸的鹰币越多 · TA 出道越快 · 你的榜位越高'**
  String get ss_subtitle;

  /// No description provided for @ss_balanceFmt.
  ///
  /// In zh, this message translates to:
  /// **'我的鹰币余额 {n}'**
  String ss_balanceFmt(String n);

  /// No description provided for @ss_localNote.
  ///
  /// In zh, this message translates to:
  /// **'内测体验 · 应援先本地记录，正式上线后从鹰币结算'**
  String get ss_localNote;

  /// No description provided for @ss_celebTitle.
  ///
  /// In zh, this message translates to:
  /// **'应援成功'**
  String get ss_celebTitle;

  /// No description provided for @ss_forFmt.
  ///
  /// In zh, this message translates to:
  /// **'为 {name} · {label}'**
  String ss_forFmt(String name, String label);

  /// No description provided for @ss_pillCoinsFmt.
  ///
  /// In zh, this message translates to:
  /// **'+{coins} 鹰币'**
  String ss_pillCoinsFmt(String coins);

  /// No description provided for @ss_progressFmt.
  ///
  /// In zh, this message translates to:
  /// **'出道进度 +{delta}% · 现 {now}%'**
  String ss_progressFmt(String delta, String now);

  /// No description provided for @ss_kingFmt.
  ///
  /// In zh, this message translates to:
  /// **'👑 你登顶 TA 的榜一大哥！V{level} {tier}'**
  String ss_kingFmt(String level, String tier);

  /// No description provided for @ss_guardianFmt.
  ///
  /// In zh, this message translates to:
  /// **'你是 TA 的第 {rank} 位守护者 · V{level} {tier}'**
  String ss_guardianFmt(String rank, String level, String tier);

  /// No description provided for @ss_tapToContinue.
  ///
  /// In zh, this message translates to:
  /// **'轻触任意处继续'**
  String get ss_tapToContinue;

  /// No description provided for @air_title.
  ///
  /// In zh, this message translates to:
  /// **'角色机会榜'**
  String get air_title;

  /// No description provided for @air_sub.
  ///
  /// In zh, this message translates to:
  /// **'热度攒满就开机出道 · 打投越猛排名越靠前'**
  String get air_sub;

  /// No description provided for @air_segCharRank.
  ///
  /// In zh, this message translates to:
  /// **'角色榜'**
  String get air_segCharRank;

  /// No description provided for @air_segKingRank.
  ///
  /// In zh, this message translates to:
  /// **'榜一大哥'**
  String get air_segKingRank;

  /// No description provided for @air_chipAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get air_chipAll;

  /// No description provided for @air_chipFemale.
  ///
  /// In zh, this message translates to:
  /// **'女宝'**
  String get air_chipFemale;

  /// No description provided for @air_chipMale.
  ///
  /// In zh, this message translates to:
  /// **'男宝'**
  String get air_chipMale;

  /// No description provided for @air_chipTycoon.
  ///
  /// In zh, this message translates to:
  /// **'巨鳄'**
  String get air_chipTycoon;

  /// No description provided for @air_chipDeity.
  ///
  /// In zh, this message translates to:
  /// **'封神'**
  String get air_chipDeity;

  /// No description provided for @air_chipLegend.
  ///
  /// In zh, this message translates to:
  /// **'传奇'**
  String get air_chipLegend;

  /// No description provided for @air_emptyChar.
  ///
  /// In zh, this message translates to:
  /// **'这个分类暂时没有角色'**
  String get air_emptyChar;

  /// No description provided for @air_emptyKing.
  ///
  /// In zh, this message translates to:
  /// **'这个段位暂时虚位以待'**
  String get air_emptyKing;

  /// No description provided for @air_debuted.
  ///
  /// In zh, this message translates to:
  /// **'已开机出道'**
  String get air_debuted;

  /// No description provided for @air_leading.
  ///
  /// In zh, this message translates to:
  /// **'出道领跑'**
  String get air_leading;

  /// No description provided for @air_heatFmt.
  ///
  /// In zh, this message translates to:
  /// **'打投热度 {pct}%'**
  String air_heatFmt(String pct);

  /// No description provided for @air_doneShoot.
  ///
  /// In zh, this message translates to:
  /// **'已出道开机'**
  String get air_doneShoot;

  /// No description provided for @air_toGoFmt.
  ///
  /// In zh, this message translates to:
  /// **'距开机还差 {n}%'**
  String air_toGoFmt(String n);

  /// No description provided for @air_supportKingFmt.
  ///
  /// In zh, this message translates to:
  /// **'本剧应援王 {name}'**
  String air_supportKingFmt(String name);

  /// No description provided for @air_emptyKingPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'虚位以待'**
  String get air_emptyKingPlaceholder;

  /// No description provided for @air_globalKing.
  ///
  /// In zh, this message translates to:
  /// **'全站榜一大哥'**
  String get air_globalKing;

  /// No description provided for @air_tierBackFmt.
  ///
  /// In zh, this message translates to:
  /// **'{tier} · 力挺 {name}'**
  String air_tierBackFmt(String tier, String name);

  /// No description provided for @air_guardFmt.
  ///
  /// In zh, this message translates to:
  /// **'守护 {name}'**
  String air_guardFmt(String name);

  /// No description provided for @cd_secVideos.
  ///
  /// In zh, this message translates to:
  /// **'TA 的视频'**
  String get cd_secVideos;

  /// No description provided for @cd_secMoments.
  ///
  /// In zh, this message translates to:
  /// **'深入沟通的时刻'**
  String get cd_secMoments;

  /// No description provided for @cd_actUnlock.
  ///
  /// In zh, this message translates to:
  /// **'鹰币解锁'**
  String get cd_actUnlock;

  /// No description provided for @cd_secCredits.
  ///
  /// In zh, this message translates to:
  /// **'TA 参演的剧'**
  String get cd_secCredits;

  /// No description provided for @cd_secBoardFmt.
  ///
  /// In zh, this message translates to:
  /// **'应援榜 · {n} 位支持者'**
  String cd_secBoardFmt(String n);

  /// No description provided for @cd_actImInToo.
  ///
  /// In zh, this message translates to:
  /// **'我也要上榜 ›'**
  String get cd_actImInToo;

  /// No description provided for @cd_swipeHint.
  ///
  /// In zh, this message translates to:
  /// **'下滑了解 TA · 打 call · 解锁'**
  String get cd_swipeHint;

  /// No description provided for @cd_introBadge.
  ///
  /// In zh, this message translates to:
  /// **'TA 的自我介绍'**
  String get cd_introBadge;

  /// No description provided for @cd_debutProgress.
  ///
  /// In zh, this message translates to:
  /// **'出道打投进度'**
  String get cd_debutProgress;

  /// No description provided for @cd_debutHint.
  ///
  /// In zh, this message translates to:
  /// **'攒满即触发开机 · 真人＋AI 结合的精品互动剧'**
  String get cd_debutHint;

  /// No description provided for @cd_clipToastFmt.
  ///
  /// In zh, this message translates to:
  /// **'播放片段「{name}」· 开发中'**
  String cd_clipToastFmt(String name);

  /// No description provided for @cd_momentToastFmt.
  ///
  /// In zh, this message translates to:
  /// **'解锁「{title}」· 鹰币功能开发中'**
  String cd_momentToastFmt(String title);

  /// No description provided for @cd_creditToastFmt.
  ///
  /// In zh, this message translates to:
  /// **'《{name}》· 欣赏功能开发中'**
  String cd_creditToastFmt(String name);

  /// No description provided for @cd_kingBadge.
  ///
  /// In zh, this message translates to:
  /// **'本剧应援王'**
  String get cd_kingBadge;

  /// No description provided for @cd_btnSupport.
  ///
  /// In zh, this message translates to:
  /// **'应援'**
  String get cd_btnSupport;

  /// No description provided for @cd_btnChat.
  ///
  /// In zh, this message translates to:
  /// **'聊天 · 解锁'**
  String get cd_btnChat;

  /// No description provided for @sp_toolPosterName.
  ///
  /// In zh, this message translates to:
  /// **'剧照海报生成'**
  String get sp_toolPosterName;

  /// No description provided for @sp_toolPosterDesc.
  ///
  /// In zh, this message translates to:
  /// **'上传人脸，生成你在这部剧里的竖版海报。'**
  String get sp_toolPosterDesc;

  /// No description provided for @sp_toolPosterCost.
  ///
  /// In zh, this message translates to:
  /// **'约 5-25 金币'**
  String get sp_toolPosterCost;

  /// No description provided for @sp_toolVideoNameShort.
  ///
  /// In zh, this message translates to:
  /// **'3秒 AI 片段'**
  String get sp_toolVideoNameShort;

  /// No description provided for @sp_toolVideoName.
  ///
  /// In zh, this message translates to:
  /// **'3秒 AI 短剧片段'**
  String get sp_toolVideoName;

  /// No description provided for @sp_toolVideoDesc.
  ///
  /// In zh, this message translates to:
  /// **'用图片或一句话生成轻量竖版短剧片段。'**
  String get sp_toolVideoDesc;

  /// No description provided for @sp_toolVideoCost.
  ///
  /// In zh, this message translates to:
  /// **'约 40 金币'**
  String get sp_toolVideoCost;

  /// No description provided for @sp_toolMakeoverName.
  ///
  /// In zh, this message translates to:
  /// **'AI 变装'**
  String get sp_toolMakeoverName;

  /// No description provided for @sp_toolMakeoverDesc.
  ///
  /// In zh, this message translates to:
  /// **'一张照片尝试古装、职业装、动漫、复古和写真。'**
  String get sp_toolMakeoverDesc;

  /// No description provided for @sp_toolMakeoverCost.
  ///
  /// In zh, this message translates to:
  /// **'约 25 金币'**
  String get sp_toolMakeoverCost;

  /// No description provided for @sp_toolAvatarName.
  ///
  /// In zh, this message translates to:
  /// **'AI 专属头像'**
  String get sp_toolAvatarName;

  /// No description provided for @sp_toolAvatarDesc.
  ///
  /// In zh, this message translates to:
  /// **'用人脸参考生成个人头像，可直接更新资料页。'**
  String get sp_toolAvatarDesc;

  /// No description provided for @sp_toolAvatarCost.
  ///
  /// In zh, this message translates to:
  /// **'约 5-25 金币'**
  String get sp_toolAvatarCost;

  /// No description provided for @sp_sectionHeader.
  ///
  /// In zh, this message translates to:
  /// **'AI 玩法'**
  String get sp_sectionHeader;

  /// No description provided for @sp_subtitle.
  ///
  /// In zh, this message translates to:
  /// **'和短剧观看连接的轻量 AI 玩法。'**
  String get sp_subtitle;

  /// No description provided for @sp_creatingFmt.
  ///
  /// In zh, this message translates to:
  /// **'正在为《{title}》创作'**
  String sp_creatingFmt(String title);

  /// No description provided for @sp_chipLinked.
  ///
  /// In zh, this message translates to:
  /// **'剧情联动'**
  String get sp_chipLinked;

  /// No description provided for @sp_chipMall.
  ///
  /// In zh, this message translates to:
  /// **'短剧商城'**
  String get sp_chipMall;

  /// No description provided for @sp_putInDramaTitle.
  ///
  /// In zh, this message translates to:
  /// **'把自己放进短剧'**
  String get sp_putInDramaTitle;

  /// No description provided for @sp_putInDramaBody.
  ///
  /// In zh, this message translates to:
  /// **'拍照或上传照片，生成当前短剧的海报或小片段。'**
  String get sp_putInDramaBody;

  /// No description provided for @sp_btnTryRoleplay.
  ///
  /// In zh, this message translates to:
  /// **'试试 AI 入戏'**
  String get sp_btnTryRoleplay;

  /// No description provided for @sp_sceneMallTitle.
  ///
  /// In zh, this message translates to:
  /// **'场景商城'**
  String get sp_sceneMallTitle;

  /// No description provided for @sp_sceneMallBody.
  ///
  /// In zh, this message translates to:
  /// **'查看短剧同款、场景商品和创作者联名商品。'**
  String get sp_sceneMallBody;

  /// No description provided for @spf_settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'工具设置'**
  String get spf_settingsTitle;

  /// No description provided for @spf_linkedToFmt.
  ///
  /// In zh, this message translates to:
  /// **'关联《{title}》'**
  String spf_linkedToFmt(String title);

  /// No description provided for @spf_chooseTool.
  ///
  /// In zh, this message translates to:
  /// **'选择玩法'**
  String get spf_chooseTool;

  /// No description provided for @spf_genBtnFmt.
  ///
  /// In zh, this message translates to:
  /// **'生成 · {cost}'**
  String spf_genBtnFmt(String cost);

  /// No description provided for @spf_noPhotoBtn.
  ///
  /// In zh, this message translates to:
  /// **'请先上传照片'**
  String get spf_noPhotoBtn;

  /// No description provided for @spf_photoReady.
  ///
  /// In zh, this message translates to:
  /// **'照片已就绪'**
  String get spf_photoReady;

  /// No description provided for @spf_uploadPhoto.
  ///
  /// In zh, this message translates to:
  /// **'上传你的照片'**
  String get spf_uploadPhoto;

  /// No description provided for @spf_photoTapToReplace.
  ///
  /// In zh, this message translates to:
  /// **'可点击重新选择'**
  String get spf_photoTapToReplace;

  /// No description provided for @spf_photoHint.
  ///
  /// In zh, this message translates to:
  /// **'正面或全身，确保人脸清晰'**
  String get spf_photoHint;

  /// No description provided for @spf_generating.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在生成…'**
  String get spf_generating;

  /// No description provided for @spf_generatingSub.
  ///
  /// In zh, this message translates to:
  /// **'正在把你放进短剧，请稍候'**
  String get spf_generatingSub;

  /// No description provided for @spf_genDoneTag.
  ///
  /// In zh, this message translates to:
  /// **'生成完成'**
  String get spf_genDoneTag;

  /// No description provided for @spf_genDoneTitleFmt.
  ///
  /// In zh, this message translates to:
  /// **'{tool} · 成片'**
  String spf_genDoneTitleFmt(String tool);

  /// No description provided for @spf_genDoneBody.
  ///
  /// In zh, this message translates to:
  /// **'保存到作品、分享，或重新生成。'**
  String get spf_genDoneBody;

  /// No description provided for @spf_btnSave.
  ///
  /// In zh, this message translates to:
  /// **'保存到我的作品'**
  String get spf_btnSave;

  /// No description provided for @spf_savedToast.
  ///
  /// In zh, this message translates to:
  /// **'已保存（功能开发中）'**
  String get spf_savedToast;

  /// No description provided for @spf_shareLabel.
  ///
  /// In zh, this message translates to:
  /// **'AI 成片'**
  String get spf_shareLabel;

  /// No description provided for @cui_chipAI.
  ///
  /// In zh, this message translates to:
  /// **'AI 互动'**
  String get cui_chipAI;

  /// No description provided for @cui_chipMetaverse.
  ///
  /// In zh, this message translates to:
  /// **'元宇宙世界观'**
  String get cui_chipMetaverse;

  /// No description provided for @cui_title.
  ///
  /// In zh, this message translates to:
  /// **'角色元宇宙'**
  String get cui_title;

  /// No description provided for @cui_lead.
  ///
  /// In zh, this message translates to:
  /// **'在这里，你遇见的不是演员，是会回应你的人。'**
  String get cui_lead;

  /// No description provided for @cui_body.
  ///
  /// In zh, this message translates to:
  /// **'每一个角色，都有自己的性格、声音和故事。你可以陪 TA 聊天，为 TA 打 call，把心动的那一个亲手推上舞台——从一句台词，到一部属于你们的精品互动剧。'**
  String get cui_body;

  /// No description provided for @cui_step1Title.
  ///
  /// In zh, this message translates to:
  /// **'遇见 & 私聊'**
  String get cui_step1Title;

  /// No description provided for @cui_step1Desc.
  ///
  /// In zh, this message translates to:
  /// **'长按角色听 TA 说话，进去与 TA 一对一聊天。能量陪伴，越聊越懂你。'**
  String get cui_step1Desc;

  /// No description provided for @cui_step2Title.
  ///
  /// In zh, this message translates to:
  /// **'应援 & 打投'**
  String get cui_step2Title;

  /// No description provided for @cui_step2Desc.
  ///
  /// In zh, this message translates to:
  /// **'为心动的 TA 投出鹰币，实名登上应援榜，成为 TA 的「应援王」。'**
  String get cui_step2Desc;

  /// No description provided for @cui_step3Title.
  ///
  /// In zh, this message translates to:
  /// **'开机 & 出道'**
  String get cui_step3Title;

  /// No description provided for @cui_step3Desc.
  ///
  /// In zh, this message translates to:
  /// **'打投进度攒满，TA 正式出道——真人＋AI 打造的精品互动剧，由你点燃。'**
  String get cui_step3Desc;

  /// No description provided for @cui_step4Title.
  ///
  /// In zh, this message translates to:
  /// **'客串 & 深入'**
  String get cui_step4Title;

  /// No description provided for @cui_step4Desc.
  ///
  /// In zh, this message translates to:
  /// **'解锁与 TA 专属的剧情和「深入沟通的时刻」，甚至把自己写进这部剧里。'**
  String get cui_step4Desc;

  /// No description provided for @cui_footer.
  ///
  /// In zh, this message translates to:
  /// **'你投出的每一票，都在改写谁会成为下一个主角。'**
  String get cui_footer;

  /// No description provided for @com2_title.
  ///
  /// In zh, this message translates to:
  /// **'社区动态'**
  String get com2_title;

  /// No description provided for @com2_chipPlaza.
  ///
  /// In zh, this message translates to:
  /// **'追剧广场'**
  String get com2_chipPlaza;

  /// No description provided for @com2_emptyHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有动态，来发第一条吧'**
  String get com2_emptyHint;

  /// No description provided for @com2_btnPost.
  ///
  /// In zh, this message translates to:
  /// **'发动态'**
  String get com2_btnPost;

  /// No description provided for @com2_watching.
  ///
  /// In zh, this message translates to:
  /// **'正在追这部'**
  String get com2_watching;

  /// No description provided for @com2_fallbackDrama.
  ///
  /// In zh, this message translates to:
  /// **'FalconFlix 短剧'**
  String get com2_fallbackDrama;

  /// No description provided for @com2_publishedToast.
  ///
  /// In zh, this message translates to:
  /// **'已发布到社区动态'**
  String get com2_publishedToast;

  /// No description provided for @com2_postHint.
  ///
  /// In zh, this message translates to:
  /// **'说说你对这部剧的感受，安利给大家…'**
  String get com2_postHint;

  /// No description provided for @com2_publish.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get com2_publish;

  /// No description provided for @com2_attachDrama.
  ///
  /// In zh, this message translates to:
  /// **'附带这部剧'**
  String get com2_attachDrama;

  /// No description provided for @dhc_connected.
  ///
  /// In zh, this message translates to:
  /// **'已接通'**
  String get dhc_connected;

  /// No description provided for @dhc_connecting.
  ///
  /// In zh, this message translates to:
  /// **'接通中'**
  String get dhc_connecting;

  /// No description provided for @dhc_ended.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get dhc_ended;

  /// No description provided for @dhc_error.
  ///
  /// In zh, this message translates to:
  /// **'出错'**
  String get dhc_error;

  /// No description provided for @dhc_connectingHint.
  ///
  /// In zh, this message translates to:
  /// **'正在接通…请稍等'**
  String get dhc_connectingHint;

  /// No description provided for @dhc_talkingFmt.
  ///
  /// In zh, this message translates to:
  /// **'{name} 正在说…'**
  String dhc_talkingFmt(String name);

  /// No description provided for @dhc_listening.
  ///
  /// In zh, this message translates to:
  /// **'在聆听你说…'**
  String get dhc_listening;

  /// No description provided for @dhc_backLabel.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get dhc_backLabel;

  /// No description provided for @dhc_actorsReady.
  ///
  /// In zh, this message translates to:
  /// **'演员正在就位…'**
  String get dhc_actorsReady;

  /// No description provided for @ss2_searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜短剧 / 演员 / 标签'**
  String get ss2_searchHint;

  /// No description provided for @ss2_history.
  ///
  /// In zh, this message translates to:
  /// **'搜索历史'**
  String get ss2_history;

  /// No description provided for @ss2_clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get ss2_clear;

  /// No description provided for @ss2_hot.
  ///
  /// In zh, this message translates to:
  /// **'热门搜索'**
  String get ss2_hot;

  /// No description provided for @ss2_hotBadge.
  ///
  /// In zh, this message translates to:
  /// **'热'**
  String get ss2_hotBadge;

  /// No description provided for @ss2_noResultFmt.
  ///
  /// In zh, this message translates to:
  /// **'没有找到「{q}」相关短剧'**
  String ss2_noResultFmt(String q);

  /// No description provided for @ss2_foundFmt.
  ///
  /// In zh, this message translates to:
  /// **'找到 {n} 部'**
  String ss2_foundFmt(String n);

  /// No description provided for @ss2_chipCEO.
  ///
  /// In zh, this message translates to:
  /// **'霸总'**
  String get ss2_chipCEO;

  /// No description provided for @ss2_chipTimeTravel.
  ///
  /// In zh, this message translates to:
  /// **'穿越'**
  String get ss2_chipTimeTravel;

  /// No description provided for @ss2_chipMystery.
  ///
  /// In zh, this message translates to:
  /// **'悬疑'**
  String get ss2_chipMystery;

  /// No description provided for @ss2_chipModern.
  ///
  /// In zh, this message translates to:
  /// **'现言'**
  String get ss2_chipModern;

  /// No description provided for @ss2_chipSweetPet.
  ///
  /// In zh, this message translates to:
  /// **'甜宠'**
  String get ss2_chipSweetPet;

  /// No description provided for @rk_emptyCat.
  ///
  /// In zh, this message translates to:
  /// **'该分类暂无榜单'**
  String get rk_emptyCat;

  /// No description provided for @rk_hotTitle.
  ///
  /// In zh, this message translates to:
  /// **'热播榜单'**
  String get rk_hotTitle;

  /// No description provided for @rk_hotSub.
  ///
  /// In zh, this message translates to:
  /// **'按今日热度实时排序'**
  String get rk_hotSub;

  /// No description provided for @rk_top1Today.
  ///
  /// In zh, this message translates to:
  /// **'# 1  今日最热'**
  String get rk_top1Today;

  /// No description provided for @rk_heatFmt.
  ///
  /// In zh, this message translates to:
  /// **'{plays} 热度 · 持续上升'**
  String rk_heatFmt(String plays);

  /// No description provided for @rk_chipUrban.
  ///
  /// In zh, this message translates to:
  /// **'都市'**
  String get rk_chipUrban;

  /// No description provided for @rk_chipFinished.
  ///
  /// In zh, this message translates to:
  /// **'完结'**
  String get rk_chipFinished;

  /// No description provided for @rk_chipRomance.
  ///
  /// In zh, this message translates to:
  /// **'爱情'**
  String get rk_chipRomance;

  /// No description provided for @aic_lowEnergyNag.
  ///
  /// In zh, this message translates to:
  /// **'呜…人家有点没力气了，给我充点能量好不好~'**
  String get aic_lowEnergyNag;

  /// No description provided for @aic_chargedReply.
  ///
  /// In zh, this message translates to:
  /// **'谢谢你！满血复活，我们继续聊~'**
  String get aic_chargedReply;

  /// No description provided for @aic_chargeToast.
  ///
  /// In zh, this message translates to:
  /// **'充能 · 鹰币计费功能开发中（已 mock 充满）'**
  String get aic_chargeToast;

  /// No description provided for @aic_energyFmt.
  ///
  /// In zh, this message translates to:
  /// **'能量 {pct}%'**
  String aic_energyFmt(String pct);

  /// No description provided for @aic_chargeBtnFmt.
  ///
  /// In zh, this message translates to:
  /// **'给 {name} 充能'**
  String aic_chargeBtnFmt(String name);

  /// No description provided for @aic_hintFmt.
  ///
  /// In zh, this message translates to:
  /// **'对 {name} 说点什么…'**
  String aic_hintFmt(String name);

  /// No description provided for @lg_needLevelFmt.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 需 V{level} 解锁'**
  String lg_needLevelFmt(String name, String level);

  /// No description provided for @lg_topUpFmt.
  ///
  /// In zh, this message translates to:
  /// **'再充 {amount} 升到 V{level} 即可解锁'**
  String lg_topUpFmt(String amount, String level);

  /// No description provided for @lg_btnTopUp.
  ///
  /// In zh, this message translates to:
  /// **'去充值升级'**
  String get lg_btnTopUp;

  /// No description provided for @lg_btnLater.
  ///
  /// In zh, this message translates to:
  /// **'以后再说'**
  String get lg_btnLater;

  /// No description provided for @me_defaultName.
  ///
  /// In zh, this message translates to:
  /// **'鹰眼用户'**
  String get me_defaultName;

  /// No description provided for @me_avatarUpdated.
  ///
  /// In zh, this message translates to:
  /// **'头像已更新'**
  String get me_avatarUpdated;

  /// No description provided for @me_avatarUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'头像更新失败，请重试'**
  String get me_avatarUpdateFailed;

  /// No description provided for @me_tapAvatarToChange.
  ///
  /// In zh, this message translates to:
  /// **'点头像可更换自己的图片'**
  String get me_tapAvatarToChange;

  /// No description provided for @me_myLevel.
  ///
  /// In zh, this message translates to:
  /// **'我的等级'**
  String get me_myLevel;

  /// No description provided for @me_loginEmail.
  ///
  /// In zh, this message translates to:
  /// **'登录邮箱'**
  String get me_loginEmail;

  /// No description provided for @me_membership.
  ///
  /// In zh, this message translates to:
  /// **'会员'**
  String get me_membership;

  /// No description provided for @me_uploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中…'**
  String get me_uploading;

  /// No description provided for @me_changeAvatar.
  ///
  /// In zh, this message translates to:
  /// **'更换头像'**
  String get me_changeAvatar;

  /// No description provided for @me_copiedFmt.
  ///
  /// In zh, this message translates to:
  /// **'已复制：{value}'**
  String me_copiedFmt(String value);

  /// No description provided for @tier_commoner.
  ///
  /// In zh, this message translates to:
  /// **'平民'**
  String get tier_commoner;

  /// No description provided for @tier_rookie.
  ///
  /// In zh, this message translates to:
  /// **'入门'**
  String get tier_rookie;

  /// No description provided for @tier_advanced.
  ///
  /// In zh, this message translates to:
  /// **'进阶'**
  String get tier_advanced;

  /// No description provided for @tier_lord.
  ///
  /// In zh, this message translates to:
  /// **'大佬'**
  String get tier_lord;

  /// No description provided for @tier_tycoon.
  ///
  /// In zh, this message translates to:
  /// **'巨鳄'**
  String get tier_tycoon;

  /// No description provided for @tier_deity.
  ///
  /// In zh, this message translates to:
  /// **'封神'**
  String get tier_deity;

  /// No description provided for @tier_legend.
  ///
  /// In zh, this message translates to:
  /// **'传奇'**
  String get tier_legend;

  /// No description provided for @rch_statusPaid.
  ///
  /// In zh, this message translates to:
  /// **'已到账'**
  String get rch_statusPaid;

  /// No description provided for @rch_statusPending.
  ///
  /// In zh, this message translates to:
  /// **'待支付'**
  String get rch_statusPending;

  /// No description provided for @rch_statusCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get rch_statusCanceled;

  /// No description provided for @rch_statusProcessing.
  ///
  /// In zh, this message translates to:
  /// **'处理中'**
  String get rch_statusProcessing;

  /// No description provided for @data_goodsCoinsFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 鹰币'**
  String data_goodsCoinsFmt(String n);

  /// No description provided for @time_justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get time_justNow;

  /// No description provided for @time_minutesAgoFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 分钟前'**
  String time_minutesAgoFmt(String n);

  /// No description provided for @time_hoursAgoFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 小时前'**
  String time_hoursAgoFmt(String n);

  /// No description provided for @time_daysAgoFmt.
  ///
  /// In zh, this message translates to:
  /// **'{n} 天前'**
  String time_daysAgoFmt(String n);

  /// No description provided for @notify_typeRecharge.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get notify_typeRecharge;

  /// No description provided for @notify_typeInvite.
  ///
  /// In zh, this message translates to:
  /// **'邀请'**
  String get notify_typeInvite;

  /// No description provided for @notify_typeSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get notify_typeSystem;

  /// No description provided for @notify_typeActivity.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get notify_typeActivity;

  /// No description provided for @notify_typeInteractive.
  ///
  /// In zh, this message translates to:
  /// **'互动剧'**
  String get notify_typeInteractive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
