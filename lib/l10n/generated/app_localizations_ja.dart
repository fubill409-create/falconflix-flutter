// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabTheater => '劇場';

  @override
  String get tabInteractive => 'インタラクティブ';

  @override
  String get tabCharacter => 'キャラ';

  @override
  String get tabMe => 'マイ';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_confirm => '確認';

  @override
  String get common_save => '保存';

  @override
  String get common_back => '戻る';

  @override
  String get common_close => '閉じる';

  @override
  String get common_retry => '再試行';

  @override
  String get common_loading => '読み込み中…';

  @override
  String get common_more => 'もっと見る';

  @override
  String get common_yes => 'はい';

  @override
  String get common_no => 'いいえ';

  @override
  String get common_free => '無料';

  @override
  String get common_login => 'ログイン';

  @override
  String get common_logout => 'ログアウト';

  @override
  String get common_loadFailed => '読み込み失敗';

  @override
  String get common_pleaseLogin => '先にログインしてください';

  @override
  String get common_done => '完了';

  @override
  String get common_edit => '編集';

  @override
  String get common_delete => '削除';

  @override
  String get common_send => '送信';

  @override
  String get me_title => 'マイ';

  @override
  String get me_loginPrompt => 'ログイン / 新規登録';

  @override
  String get me_loginSubtitle => 'ログインしてライブラリ・ウォレット・インタラクティブドラマを使う';

  @override
  String get me_membershipNormal => '一般会員';

  @override
  String get me_membershipVip => 'VIP';

  @override
  String get me_inviteCode => '招待コード';

  @override
  String get me_statEagleCoins => 'Eagle コイン';

  @override
  String get me_statBoughtEpisodes => '購入済';

  @override
  String get me_statCollections => 'お気に入り';

  @override
  String get me_sectionMyContent => 'マイコンテンツ';

  @override
  String get me_sectionWallet => 'ウォレット';

  @override
  String get me_sectionCommunity => 'コミュニティ';

  @override
  String get me_sectionCreator => 'クリエイター';

  @override
  String get me_sectionSettings => '設定';

  @override
  String get me_sectionHelpAbout => 'ヘルプ・このアプリ';

  @override
  String get me_rowCollections => 'お気に入り';

  @override
  String get me_rowHistory => '視聴履歴';

  @override
  String get me_rowCommunity => 'コミュニティ';

  @override
  String get me_rowWallet => 'ウォレット・会員';

  @override
  String get me_rowOrders => 'ご注文';

  @override
  String get me_rowInvite => '友達招待';

  @override
  String get me_rowPartner => 'クリエイターパートナー';

  @override
  String get me_rowNotifications => '通知';

  @override
  String get me_rowSettings => '設定';

  @override
  String get me_rowHelpAbout => 'ヘルプ・このアプリ';

  @override
  String get me_rowAbout => 'FalconFlix について';

  @override
  String get me_logoutConfirm => 'ログアウトしますか？';

  @override
  String get history_title => '視聴履歴';

  @override
  String get history_emptyTitle => 'まだ視聴履歴がありません';

  @override
  String get history_emptyBody => '視聴した話数がここに表示されます。続きから簡単に再生できます。';

  @override
  String get history_loginBody => 'ログインすると視聴履歴を確認できます。';

  @override
  String get history_actionDelSelected => '選択を削除';

  @override
  String get history_actionClearAll => '全て削除';

  @override
  String get history_episodeFallback => 'シリーズ全体';

  @override
  String get history_unknown => '（不明なタイトル）';

  @override
  String history_selectedCount(int n) {
    return '$n 件選択中';
  }

  @override
  String history_delConfirmTitle(int n) {
    return '$n 件の履歴を削除しますか？';
  }

  @override
  String get history_delConfirmBody =>
      'この操作は取り消せません。作品自体には影響しません。再生時に新しい履歴が作成されます。';

  @override
  String get history_clearConfirmTitle => '全ての視聴履歴を削除しますか？';

  @override
  String get history_clearConfirmBody => 'この操作は取り消せません。再生時に新しい履歴が作成されます。';

  @override
  String history_toastDeleted(int n) {
    return '$n 件削除しました';
  }

  @override
  String get history_toastCleared => '削除しました';

  @override
  String get orders_title => 'ご注文';

  @override
  String get orders_tabFull => 'シリーズ';

  @override
  String get orders_tabEpisode => '1 話';

  @override
  String get orders_tabRecharge => 'チャージ履歴';

  @override
  String get orders_emptyFull => 'シリーズの購入履歴はありません';

  @override
  String get orders_emptyEpisode => '1 話購入の履歴はありません';

  @override
  String get orders_emptyBody => 'アンロックした作品がここに表示されます。';

  @override
  String get orders_emptyRecharge => 'チャージ履歴はありません';

  @override
  String get orders_emptyRechargeBody => '最初のチャージが完了するとここに表示されます。';

  @override
  String get orders_loginBodyOrders => 'ログインすると注文履歴を確認できます。';

  @override
  String get orders_loginBodyRecharge => 'ログインするとチャージ履歴を確認できます。';

  @override
  String get orders_kvAmount => '金額';

  @override
  String get orders_kvPayMethod => '支払方法';

  @override
  String get orders_kvTime => '日時';

  @override
  String orders_orderCopied(String orderNo) {
    return '注文番号をコピーしました · $orderNo';
  }

  @override
  String get orders_paid => '決済済';

  @override
  String get orders_pending => '未決済';

  @override
  String get orders_payEagle => 'Eagle コイン';

  @override
  String get orders_unknownTitle => '（不明なタイトル）';

  @override
  String get orders_rechargeFallback => 'Eagle コインチャージ';

  @override
  String get inbox_title => '通知';

  @override
  String get inbox_tabAll => 'すべて';

  @override
  String get inbox_tabRecharge => 'チャージ';

  @override
  String get inbox_tabInvite => '招待';

  @override
  String get inbox_tabSystem => 'システム';

  @override
  String get inbox_tabActivity => 'キャンペーン';

  @override
  String get inbox_tabInteractive => 'インタラクティブ';

  @override
  String get inbox_emptyTitle => 'メッセージはまだありません';

  @override
  String get inbox_emptyBody => 'チャージ完了、招待報酬、キャンペーン、システム通知が届きます。';

  @override
  String get inbox_loginBody => 'ログインすると通知を確認できます。';

  @override
  String get settings_title => '設定';

  @override
  String get settings_sectionNotificationPlayback => '通知と再生';

  @override
  String get settings_sectionAccount => 'アカウント';

  @override
  String get settings_sectionUIStorage => '表示とストレージ';

  @override
  String get settings_rowNotifyPrefs => '通知設定';

  @override
  String get settings_rowPlayPrefs => '再生・ダウンロード設定';

  @override
  String get settings_rowAccountSecurity => 'アカウントとセキュリティ';

  @override
  String get settings_rowPrivacy => 'プライバシー';

  @override
  String get settings_rowLanguage => '言語';

  @override
  String get settings_rowClearCache => 'キャッシュを削除';

  @override
  String get settings_clearCacheTitle => 'キャッシュを削除しますか？';

  @override
  String get settings_clearCacheBody =>
      'ダウンロード済の動画と画像キャッシュを削除します。購入履歴・ログイン・設定は影響を受けません。';

  @override
  String get settings_clearCacheAction => '今すぐ削除';

  @override
  String settings_clearCacheDone(String size) {
    return '$size のキャッシュを削除しました';
  }

  @override
  String get notifyPrefs_title => '通知設定';

  @override
  String get notifyPrefs_pushMaster => 'プッシュ通知 全体';

  @override
  String get notifyPrefs_pushMasterDesc => 'オフにするとプッシュは停止しますが、アプリ内メッセージは届きます';

  @override
  String get notifyPrefs_recharge => 'チャージ完了';

  @override
  String get notifyPrefs_rechargeDesc => '決済成功・コイン入金通知';

  @override
  String get notifyPrefs_invite => '招待報酬';

  @override
  String get notifyPrefs_inviteDesc => '友達が登録・報酬到着';

  @override
  String get notifyPrefs_system => 'システム通知';

  @override
  String get notifyPrefs_systemDesc => 'アカウント安全・重要なお知らせ';

  @override
  String get notifyPrefs_activity => 'キャンペーン';

  @override
  String get notifyPrefs_activityDesc => '新作公開・チャージ特典';

  @override
  String get notifyPrefs_interactive => 'インタラクティブ進捗';

  @override
  String get notifyPrefs_interactiveDesc => '視聴中ドラマの新章・エンディング解放';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return '保存失敗：$msg';
  }

  @override
  String get playPrefs_title => '再生・ダウンロード設定';

  @override
  String get playPrefs_autoplay => '次を自動再生';

  @override
  String get playPrefs_autoplayDesc => '1 本見終わると次を自動再生';

  @override
  String get playPrefs_wifiOnlyAutoplay => 'Wi-Fi 時のみ自動再生';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc => 'モバイル回線では自動再生せず、データ通信を節約';

  @override
  String get playPrefs_quality => '既定画質';

  @override
  String get playPrefs_qualityAuto => '自動（回線に合わせる）';

  @override
  String get playPrefs_quality480 => 'SD 480p';

  @override
  String get playPrefs_quality720 => 'HD 720p';

  @override
  String get playPrefs_quality1080 => 'フル HD 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => 'Wi-Fi 時のみダウンロード';

  @override
  String get playPrefs_wifiOnlyDownloadDesc => 'インタラクティブ動画・オフライン保存は Wi-Fi 時のみ';

  @override
  String get accountSec_title => 'アカウントとセキュリティ';

  @override
  String get accountSec_sectionLogin => 'ログイン';

  @override
  String get accountSec_sectionDeletion => 'アカウント削除';

  @override
  String get accountSec_rowChangePwd => 'パスワード変更';

  @override
  String get accountSec_rowChangePwdDesc => '現在のパスワードが必要です';

  @override
  String get accountSec_rowDelete => 'アカウント削除';

  @override
  String get accountSec_rowDeleteDesc => '7 日間のクーリング期間、その間ログインで取消可';

  @override
  String get accountSec_oldPwHint => '現在のパスワード';

  @override
  String get accountSec_newPwHint => '新しいパスワード（8 文字以上）';

  @override
  String get accountSec_confirmPwHint => '新しいパスワード（再入力）';

  @override
  String get accountSec_errMinLen => '新しいパスワードは 8 文字以上';

  @override
  String get accountSec_errMismatch => '入力が一致しません';

  @override
  String get accountSec_saveNewPw => '新しいパスワードを保存';

  @override
  String get accountSec_saving => '保存中…';

  @override
  String get accountSec_pwUpdated => 'パスワードを更新しました';

  @override
  String get privacyPrefs_title => 'プライバシー';

  @override
  String get privacyPrefs_sectionData => 'マイデータ';

  @override
  String get privacyPrefs_sectionLegal => '規約とポリシー';

  @override
  String get privacyPrefs_rowExport => 'データダウンロード';

  @override
  String get privacyPrefs_rowExportDesc => 'GDPR / CCPA 準拠：全データの一括ダウンロードを申請';

  @override
  String get privacyPrefs_rowPolicy => 'プライバシーポリシー';

  @override
  String get deleteAcc_title => 'アカウント削除';

  @override
  String get deleteAcc_inProgress => 'アカウント削除を申請中';

  @override
  String deleteAcc_scheduledAt(String time) {
    return '実行予定：$time';
  }

  @override
  String get deleteAcc_pendingHint => '7 日間のクーリング期間中は、ログインすることで削除をキャンセルできます。';

  @override
  String get deleteAcc_cancelBtn => '削除を取り消す';

  @override
  String get deleteAcc_willDelete => 'アカウントを削除すると以下が消えます';

  @override
  String get deleteAcc_bullet1 => 'プロフィール、ニックネーム、アバター、メール、電話の紐付け';

  @override
  String get deleteAcc_bullet2 => 'ウォレット残高（Eagle コインは返金不可）、VIP・レベル';

  @override
  String get deleteAcc_bullet3 => '購入したドラマとインタラクティブの解放履歴';

  @override
  String get deleteAcc_bullet4 => '視聴履歴、お気に入り、コミュニティ投稿、インタラクティブのセーブ';

  @override
  String get deleteAcc_bullet5 => '招待関係（被招待側の記録は残ります）';

  @override
  String get deleteAcc_coolingHint =>
      '送信後、7 日間のクーリング期間が始まります。その間にログインすれば取消可。期限を過ぎると完全削除され、復元できません。';

  @override
  String get deleteAcc_reasonLabel => '削除理由（任意・改善に役立てます）';

  @override
  String get deleteAcc_reasonHint => 'ご意見をお聞かせください（任意）';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return '「$phrase」と入力して確認してください';
  }

  @override
  String get deleteAcc_confirmPhrase => 'アカウント削除';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return '「$phrase」を正確に入力してください';
  }

  @override
  String get deleteAcc_submit => '削除を申請';

  @override
  String get deleteAcc_finalTitle => '最終確認';

  @override
  String get deleteAcc_finalBody =>
      '送信後、7 日間のクーリング期間が始まります。その間にログインすれば取消可。\n\n期限を過ぎるとデータは永久に削除され、復元できません。';

  @override
  String get deleteAcc_finalSubmit => '削除を送信';

  @override
  String get deleteAcc_submitted => '申請を受け付けました。7 日後に実行されます。';

  @override
  String get deleteAcc_cancelled => '削除申請を取り消しました';

  @override
  String get deleteAcc_thinkAgain => 'やめておく';

  @override
  String get dataExport_title => 'データダウンロード';

  @override
  String get dataExport_introTitle => 'あなたのデータの控えを取得';

  @override
  String get dataExport_introBody =>
      'GDPR Article 15（EU）と CCPA（カリフォルニア）に基づき、当社が保有するあなたの個人データ全件を受け取る権利があります。\n\n申請後、ZIP で非同期に作成します：\n  · プロフィール / メール / 電話\n  · Eagle コイン残高と履歴\n  · 注文、視聴履歴、お気に入り\n  · コミュニティ投稿、インタラクティブ解放履歴\n\n準備完了したらアプリ内通知でお知らせします。ダウンロードリンクの有効期限は 7 日です。';

  @override
  String get dataExport_statusQueued => '待機中 · キュー';

  @override
  String get dataExport_statusProcessing => '処理中 · パッケージング';

  @override
  String get dataExport_statusReady => '準備完了 · ダウンロード可';

  @override
  String get dataExport_statusExpired => '期限切れ · 再申請してください';

  @override
  String get dataExport_statusFailed => '生成失敗 · 再申請してください';

  @override
  String dataExport_expiresAt(String time) {
    return 'リンク有効期限 $time';
  }

  @override
  String get dataExport_downloadBtn => 'ダウンロード';

  @override
  String get dataExport_submitBtn => 'ダウンロードを申請';

  @override
  String get dataExport_submitting => '送信中…';

  @override
  String get dataExport_submitted => '申請を受け付けました。準備完了次第お知らせします。';

  @override
  String get helpAbout_title => 'ヘルプ・このアプリ';

  @override
  String get helpAbout_sectionHelp => 'ヘルプ';

  @override
  String get helpAbout_sectionAbout => 'このアプリ';

  @override
  String get helpAbout_rowFaq => 'ヘルプセンター';

  @override
  String get helpAbout_rowFaqDesc => 'よくある質問';

  @override
  String get helpAbout_rowSupport => 'サポートに連絡';

  @override
  String get helpAbout_rowSupportDesc => '1 対 1 のチケットチャット';

  @override
  String get helpAbout_rowFeedback => 'フィードバック';

  @override
  String get helpAbout_rowFeedbackDesc => '提案・バグ報告';

  @override
  String get faq_title => 'ヘルプセンター';

  @override
  String get faq_catAll => 'すべて';

  @override
  String get faq_catAccount => 'アカウント';

  @override
  String get faq_catRecharge => 'チャージ';

  @override
  String get faq_catPlayback => '再生';

  @override
  String get faq_catInteractive => 'インタラクティブ';

  @override
  String get faq_catOther => 'その他';

  @override
  String get faq_emptyTitle => 'FAQ はまだありません';

  @override
  String get faq_emptyBody => '問題が発生した場合は「サポートに連絡」からチケットを作成してください。';

  @override
  String get tickets_title => 'サポートに連絡';

  @override
  String get tickets_newBtn => '新規チケット';

  @override
  String get tickets_emptyTitle => 'チケットはまだありません';

  @override
  String get tickets_emptyBody => 'ボタンをタップして新しいチケットを作成。サポートが 1 対 1 で返信します。';

  @override
  String get tickets_threadTitle => 'チケット詳細';

  @override
  String get tickets_initial => '最初の質問';

  @override
  String get tickets_speakerStaff => 'サポート';

  @override
  String get tickets_speakerSelf => '自分';

  @override
  String get tickets_replyHint => '返信…';

  @override
  String tickets_sendFailed(String msg) {
    return '送信失敗：$msg';
  }

  @override
  String get tickets_statusPending => '対応待ち';

  @override
  String get tickets_statusReplied => '返信済';

  @override
  String get tickets_statusResolved => '解決済';

  @override
  String get tickets_statusClosed => 'クローズ';

  @override
  String get feedback_titleTicket => '新規チケット';

  @override
  String get feedback_titleFeedback => 'フィードバック';

  @override
  String get feedback_typeBug => 'バグ報告';

  @override
  String get feedback_typeSuggestion => '提案';

  @override
  String get feedback_typeComplaint => 'クレーム';

  @override
  String get feedback_typeRecharge => 'チャージの問題';

  @override
  String get feedback_typeOther => 'その他';

  @override
  String get feedback_typeLabel => '問題の種類';

  @override
  String get feedback_contentLabel => '詳細';

  @override
  String get feedback_contentHintTicket => '問題を詳しくお書きください…';

  @override
  String get feedback_contentHintFeedback => 'ご意見をお聞かせください…';

  @override
  String get feedback_contactLabel => '返信用メール・電話（任意）';

  @override
  String get feedback_contactHint => 'ご記入いただくと優先的に対応します。任意。';

  @override
  String get feedback_submit => '送信';

  @override
  String get feedback_submitting => '送信中…';

  @override
  String get feedback_submitted => '送信しました。サポートから返信します。';

  @override
  String get feedback_minLength => '5 文字以上で入力してください';

  @override
  String feedback_tip(String version) {
    return 'ヒント：バグ報告では再現手順 + スクリーンショット（近日対応）を添えると早く特定できます。\nバージョン：$version';
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
  String get home_noDramaData => 'まだドラマがありません';

  @override
  String get home_localOnlyLike => 'ローカル動画はいいね非対応';

  @override
  String get home_localOnlyCollect => 'ローカル動画は保存非対応';

  @override
  String get home_addedToMy => '「マイ」に保存しました';

  @override
  String get home_actionLike => 'いいね';

  @override
  String get home_actionCollected => '保存済み';

  @override
  String get home_actionCollect => '保存';

  @override
  String get home_actionShare => 'シェア';

  @override
  String get home_shopComingSoon => '劇中アイテム · AI 認識（ショップ開発中）';

  @override
  String get home_chipAiTheater => 'AI シアター';

  @override
  String get home_bannerPremiere => 'AI ドラマ初公開';

  @override
  String get home_btnWatch => '観る';

  @override
  String get home_btnDetails => '詳細';

  @override
  String home_loadFailedFmt(String message) {
    return '読み込み失敗\n$message';
  }

  @override
  String get theater_genreAll => 'すべて';

  @override
  String get theater_genreRomance => '恋愛';

  @override
  String get theater_genreUrban => '都市';

  @override
  String get theater_genreInteractive => 'インタラクティブ';

  @override
  String get theater_genreFinished => '完結';

  @override
  String get theater_sectionHot => '配信中';

  @override
  String get theater_seeAll => 'すべて見る';

  @override
  String get theater_sectionAll => '全ドラマ';

  @override
  String get theater_ranking => '人気ランキング';

  @override
  String get theater_today => '今日のおすすめ';

  @override
  String get theater_labelShort => 'ショートドラマ';

  @override
  String theater_continueWatch(String name) {
    return '続きを見る · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '視聴 $heat';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · 視聴 $heat';
  }

  @override
  String get cast_sectionPlaying => '配信中＆オーディション中';

  @override
  String get cast_oppRanking => 'キャスティング機会 ›';

  @override
  String get cast_universeTitle => 'キャラクターメタバース';

  @override
  String get cast_universeSub => '答えてくれる人に出会う · 世界を知る';

  @override
  String get cast_demoBadge => 'デモ・プレイ可能';

  @override
  String get cast_demoTitle => 'デモ版インタラクティブドラマ';

  @override
  String get cast_demoSub => '君が選ぶ──一言からドラマが始まる';

  @override
  String get cast_inPlay => '配信中';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '視聴 $heat · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '視聴 $heat';
  }

  @override
  String get cb_sectionSupport => '応援ランキング · TAを推す人たち';

  @override
  String get cb_goSupport => '応援する · TAをデビューへ';

  @override
  String get cb_seeBio => 'プロフィールを見る ›';

  @override
  String cb_pollHeatPct(String pct) {
    return '応援 $pct%';
  }

  @override
  String get cb_debuted => '撮影開始済み';

  @override
  String cb_toDebutPct(String pct) {
    return 'デビューまで $pct%';
  }

  @override
  String get cb_totalSupport => '累計応援';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins イーグルコイン';
  }

  @override
  String get cb_topBacker => '一番の応援者';

  @override
  String get cb_emptyBackers => 'まだ応援者がいません · TAの一番手になろう';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · 応援ランキング';
  }

  @override
  String get aid_titleHeader => 'AI インタラクティブドラマ';

  @override
  String get aid_aceBadge => 'エース';

  @override
  String get aid_tagline => 'あなたの選択が、結末を書き換える。';

  @override
  String get aid_demoBadge => 'デモ · 無料試遊';

  @override
  String get aid_lastcallSub => '5 層の選択 · 7 つの結末 · あなたの選択が物語を変える';

  @override
  String get aid_pipelineTitle => 'スターラインナップ';

  @override
  String get aid_pipelineSub => 'エース作品 · 続々始動';

  @override
  String get aid_cameoTitle => '自分が出演';

  @override
  String get aid_cameoSub => '写真 1 枚で、あなたを作品に書き込む';

  @override
  String get aid_castingBadge => 'キャスティング中';

  @override
  String get aid_producingBadge => '制作中';

  @override
  String aid_castVoteFmt(String pct) {
    return 'キャストに投票 · $pct%';
  }

  @override
  String get aid_manifesto1 => 'あなたはもう、ただ物語を見るだけじゃない。';

  @override
  String get aid_manifesto2 => '主人公の代わりに選択する──物語があなたの結末を書く。';

  @override
  String get aid_manifesto3 => '一つひとつの選択が、世界との対話になる。';

  @override
  String get aid_manifestoHeader => 'なぜインタラクティブドラマを作るのか';

  @override
  String get aid_metaversePre => '私たちはこれを「インタラクティブドラマ」と呼ぶ──\nでも本当は ';

  @override
  String get aid_metaverseEmph => '「ディシジョン・メタバース」第一幕';

  @override
  String get aid_metaversePost => '：\nあなたが決める世界が、ここから始まる。';

  @override
  String get aid_step1Title => '観る';

  @override
  String get aid_step1Sub => '腰を下ろし、物語に心を掴ませる。';

  @override
  String get aid_step2Title => '選択する';

  @override
  String get aid_step2Sub => '分岐点で主人公に代わって決める。物語が枝分かれする。';

  @override
  String get aid_step3Title => '自分が出演';

  @override
  String get aid_step3Sub => 'あなたの顔と名前を、この作品に刻む。';

  @override
  String get aid_step4Title => '推してデビューさせる';

  @override
  String get aid_step4Sub => '推しキャラを応援して、舞台へ送り出す。';

  @override
  String get aid_step5Title => 'ディシジョン・メタバース';

  @override
  String get aid_step5Sub => '到達点は、あなたが決める世界。';

  @override
  String get aid_ladderHeader => 'ひとつの選択から、ひとつの世界へ';

  @override
  String get aid_liveTitle => '配信中 · プレイ可能';

  @override
  String get aid_liveSub => '本物のインタラクティブドラマ · あなたの選択が物語を変える';

  @override
  String get aid_fallbackHook => 'あなたの選択が、彼女の物語を変える';

  @override
  String get aid_aceCardBadge => 'エースインタラクティブ · プレイ可能';

  @override
  String get player_btnLiked => 'いいね済み';

  @override
  String get player_btnEpisodes => 'エピソード';

  @override
  String get player_btnAiCast => 'AI カメオ';

  @override
  String player_episodeNumFmt(int n) {
    return '第 $n 話';
  }

  @override
  String player_switchEpFmt(int n) {
    return '第 $n 話へ切替（バックエンド対応中）';
  }

  @override
  String get player_unlockHint => '作品ページからイーグルコインで解放してください';

  @override
  String player_comingSoonFmt(String label) {
    return '$label（開発中）';
  }

  @override
  String get player_sceneSame => '劇中アイテム';

  @override
  String get detail_unlockThis => '本話';

  @override
  String get detail_unlockNext5 => '次 5 話';

  @override
  String get detail_unlockNext10 => '次 10 話';

  @override
  String get detail_unlockAll => '全話';

  @override
  String detail_episodeCountFmt(int n) {
    return '全 $n 話';
  }

  @override
  String get detail_drawerEpisodes => '話一覧';

  @override
  String get detail_unlockSuccess => '解放完了';

  @override
  String detail_coinBalanceFmt(String coins) {
    return '残高 $coins イーグルコイン';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n 回視聴';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return '$coins イーグルコインで解放';
  }

  @override
  String get detail_playNow => '今すぐ再生';

  @override
  String get detail_playThis => 'この作品を再生';

  @override
  String get detail_noEpisodes => '再生可能なエピソードがありません';

  @override
  String get login_welcome => 'FalconFlix へようこそ';

  @override
  String get login_subtitle => 'ログインで視聴・イーグルコイン・インタラクティブドラマ解放';

  @override
  String get login_emailLabel => 'メール';

  @override
  String get login_passwordLabel => 'パスワード';

  @override
  String get login_codeLabel => '認証コード';

  @override
  String get login_codeHint => '6 桁の認証コード';

  @override
  String get login_pwInputHint => 'パスワードを入力';

  @override
  String get login_modeOtp => 'コードでログイン';

  @override
  String get login_modePassword => 'パスワードでログイン';

  @override
  String get login_getCode => 'コード取得';

  @override
  String get login_sending => '送信中';

  @override
  String get login_loggingIn => 'ログイン中…';

  @override
  String get login_loginOrRegister => 'ログイン / 登録';

  @override
  String get login_pwHint => '初回パスワードログインで自動登録されます';


  @override
  String get login_quickLogin => '簡単ログイン';

  @override
  String get login_recommended => 'おすすめ';

  @override
  String get login_success => 'ログイン成功';

  @override
  String get login_agreement => 'ログインは利用規約とプライバシーポリシーへの同意となります';

  @override
  String get login_emailInvalid => '正しいメールアドレスをご入力ください';

  @override
  String get login_emailRequired => '正しいメールアドレスをご入力ください';

  @override
  String get login_passwordRequired => 'パスワードをご入力ください';

  @override
  String get login_codeRequired => '認証コードをご入力ください';

  @override
  String get login_codeSent => '認証コードを送信しました。メールをご確認ください。';

  @override
  String get login_emailNotConfigured => 'メール送信が一時的に利用できません。後でもう一度お試しください。';

  @override
  String get login_networkError => 'ログイン失敗。ネットワークをご確認のうえ再試行してください';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return '$provider ログイン失敗：$code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return '$provider ログイン失敗。しばらくしてから再試行してください';
  }

  @override
  String login_oauthComingFmt(String name) {
    return '$name ログインは準備中';
  }

  @override
  String get login_oauthComingBody => 'まもなく対応〜今はメールコードまたはパスワードでログインください。';

  @override
  String get login_gotIt => '了解しました';

  @override
  String get login_googleNoToken => 'Google が idToken を返しません。資格情報をご確認ください';

  @override
  String get about_tagline => 'FalconFlix · 見る価値のあるドラマ';

  @override
  String get about_body =>
      'FalconFlix はグローバル向けプレミアム短編ドラマプラットフォームです。ドラマを観る、AI キャラと話す、見ながらショッピング。映画級の制作と AI のクリエイティブで、一フレームごとに価値を。';

  @override
  String get about_userAgreement => '利用規約';

  @override
  String get about_privacyPolicy => 'プライバシーポリシー';

  @override
  String about_legalUpdatedFmt(String date) {
    return '最終更新：$date';
  }

  @override
  String get about_operatingEntity => '運営会社';

  @override
  String about_contactEmailFmt(String email) {
    return '連絡先：$email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return '$appName について';
  }

  @override
  String get wallet_title => 'イーグルコインをチャージ';

  @override
  String get wallet_chooseRecharge => 'パックを選ぶ';

  @override
  String get wallet_introNote => 'イーグルコインでエピソードや応援機能を解放';

  @override
  String get wallet_menuAutoUnlock => '自動解放設定';

  @override
  String get wallet_menuHistory => 'チャージ履歴';

  @override
  String get wallet_menuReceipt => '領収書メール';

  @override
  String get wallet_stripeNotice => '決済は Stripe による安全処理・USD';

  @override
  String get wallet_loadFailed => '読み込み失敗、再試行ください';

  @override
  String get wallet_packsComing => 'パック準備中';

  @override
  String get wallet_packsComingBody => 'お得なコインパックを準備中';

  @override
  String get wallet_coins => 'イーグルコイン';

  @override
  String wallet_giftFmt(String coins) {
    return '+$coins ボーナス';
  }

  @override
  String get wallet_bestDeal => '一番お得';

  @override
  String wallet_payNowFmt(String price) {
    return '今すぐ $price で支払う';
  }

  @override
  String get wallet_payNow => '今すぐ支払う';

  @override
  String get wallet_loginFirst => '先にログインしてください';

  @override
  String get wallet_openPayFail => '決済ページを開けません。再試行ください';

  @override
  String get wallet_payFail => '決済失敗、再試行ください';

  @override
  String get wallet_balanceLabel => 'イーグルコイン残高';

  @override
  String get wallet_loginToView => 'ログインして表示';

  @override
  String get wallet_legendPeak => 'レジェンド到達・MAX';

  @override
  String wallet_toLevelFmt(String level) {
    return 'V$level まで';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return '累計チャージ $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return 'あと $amount で V$level';
  }

  @override
  String get wallet_successTitle => 'チャージ成功・反映済み';

  @override
  String get wallet_tapAnywhere => '画面をタップして続行';

  @override
  String get wallet_successBarrier => 'チャージ成功';

  @override
  String get creator_title => 'パートナーセンター';

  @override
  String get creator_statSeries => '本';

  @override
  String get creator_statPlays => '再生';

  @override
  String get creator_statShare => '配分';

  @override
  String get creator_applyLabel => 'シリーズパートナーに申し込む';

  @override
  String get creator_applyToast => '申し込み受付（開発中）';

  @override
  String get creator_menuRequirement => 'アップロード要件';

  @override
  String get creator_menuRevenue => '配分ルール';

  @override
  String get creator_menuLangPriv => '言語とプライバシー';

  @override
  String get invite_title => '友達を招待';

  @override
  String get invite_stepsTitle => '招待の流れ';

  @override
  String get invite_step1Title => '招待コードをシェア';

  @override
  String get invite_step1Sub => 'あなた専用のコードを友達に送る';

  @override
  String get invite_step2Title => '友達がコードで登録';

  @override
  String get invite_step2Sub => '友達は登録時にあなたのコードを入力';

  @override
  String get invite_step3Title => '双方コイン獲得';

  @override
  String get invite_step3Sub => '登録成功後、双方がイーグルコインを獲得';

  @override
  String get invite_copyMessage => '招待メッセージをコピー';

  @override
  String get invite_loginToGet => 'ログインしてコードを取得';

  @override
  String get invite_loginToGen => 'ログインして招待コードを発行';

  @override
  String get invite_messageCopied => 'メッセージをコピーしました。友達に送ってください';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 FalconFlix で短編ドラマ観てるんだけど超おもしろい！登録時に招待コード $code を入れて、二人ともコインゲット〜';
  }

  @override
  String get invite_bigTitle => '友達を招待して一緒に観よう';

  @override
  String get invite_bigSub => '友達があなたのコードで登録すると、双方がコインを獲得';

  @override
  String get invite_myCode => 'あなたの招待コード';

  @override
  String get invite_copyBtn => 'コピー';

  @override
  String invite_codeCopiedFmt(String code) {
    return 'コード $code をコピーしました';
  }

  @override
  String get collect_emptyTitle => 'まだお気に入りなし';

  @override
  String get collect_emptyBody => 'ドラマで「保存」をタップすると、ここに表示されます。';

  @override
  String get au_title => '自動解放';

  @override
  String get au_introTitle => '視聴を止めない';

  @override
  String get au_introBody => 'オンにすると、次の話を自動でコイン解放し続けて視聴できます';

  @override
  String get au_toggleLabel => '次の話を自動解放';

  @override
  String get au_on => 'オン';

  @override
  String get au_off => 'オフ';

  @override
  String get au_toggleOnToast => '自動解放をオンにしました';

  @override
  String get au_toggleOffToast => '自動解放をオフにしました';

  @override
  String get au_rule1 => 'ロック中のエピソードはポップアップなしで自動解放';

  @override
  String get au_rule2 => '残高不足時はチャージを促します。勝手な引き落としはありません';

  @override
  String get au_rule3 => '単話解放のみ対象。全話解放は手動確認が必要';

  @override
  String get rh_title => 'チャージ履歴';

  @override
  String get rh_loginToView => 'ログインして履歴を表示';

  @override
  String get rh_emptyBody => 'チャージ履歴なし\nチャージしてもっと観よう';

  @override
  String get rh_fallback => 'コインチャージ';

  @override
  String get re_title => '領収書メール';

  @override
  String get re_invalidEmail => '有効なメールアドレスをご入力ください';

  @override
  String get re_saved => '領収書メールを保存しました';

  @override
  String get re_label => '領収書メール';

  @override
  String get re_body =>
      'チャージ成功後、Stripe から領収書がこのメールに送信されます。次回のチェックアウトでも自動入力されます。';

  @override
  String re_useAccountEmailFmt(String email) {
    return 'ログインメール $email を使う';
  }

  @override
  String get re_save => '保存';

  @override
  String common_comingSoonFmt(String name) {
    return '$name（開発中）';
  }

  @override
  String get sheets_episodeTitle => 'エピソード';

  @override
  String get sheets_unlockAllBtn => 'すべて解放';

  @override
  String get sheets_unlockTitle => '解放';

  @override
  String get sheets_unlockChooseCount => '解放数を選択';

  @override
  String get sheets_unlockFailed => '解放に失敗しました。再試行してください。';

  @override
  String get sheets_networkErr => 'ネットワークエラー。再試行してください。';

  @override
  String get sheets_walletBalance => 'コイン残高';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins コイン';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return 'あと $coins コイン不足 — チャージで解放';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return '今すぐ解放 · $coins コイン';
  }

  @override
  String get sheets_coinsNotEnough => 'コイン不足 · チャージへ';

  @override
  String sheets_tierForeverFmt(String count) {
    return '$count 話 · 永久視聴';
  }

  @override
  String get sheets_unlockAllSub => '全話を解放';

  @override
  String get sheets_unlockThisSub => 'この話を解放';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return '全 $count 話を解放 · 永久視聴';
  }

  @override
  String get sheets_unlockThisForever => 'この話を解放 · 永久視聴';

  @override
  String get sheets_coinsShort => 'コイン';

  @override
  String get sheets_vipDiscount => 'VIPはさらにお得';

  @override
  String get sheets_shareTitle => 'シェア';

  @override
  String get sheets_shareSub => 'このドラマをシェア';

  @override
  String get sheets_copyLink => 'リンクをコピー';

  @override
  String get sheets_linkCopiedShort => 'リンクをコピーしました';

  @override
  String get sheets_linkCopiedLong => 'リンクをコピーしました。友達に貼り付けてね';

  @override
  String get sheets_shareTargetMessage => 'メッセージ';

  @override
  String get sheets_shareTargetPoster => 'ポスター';

  @override
  String get sheets_shareTargetCommunity => 'フィード';

  @override
  String get sheets_shareTargetRemix => 'リミックス';

  @override
  String get sheets_remixComingShort => 'AIリミックス · 近日公開';

  @override
  String get sheets_remixComingFooter => 'AIリミックスは近日公開 · お楽しみに';

  @override
  String get sheets_fallbackTitle => 'FalconFlixの良作ドラマ';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title が面白すぎる！FalconFlixで一緒に見よう！$url';
  }

  @override
  String get sheets_posterTitle => 'ポスター';

  @override
  String get sheets_posterMakeSub => 'オリジナルポスターを作成';

  @override
  String get sheets_posterReady => 'ポスターをシェア';

  @override
  String get sheets_posterGenerating => 'ポスター生成中…';

  @override
  String get sheets_posterGenFail => 'ポスター生成に失敗';

  @override
  String get sheets_posterExportFail => 'ポスター書き出しに失敗';

  @override
  String get sheets_posterTagline => 'スキャンして一緒に観よう';

  @override
  String get ixp_resumeTitle => '前回の続きから';

  @override
  String get ixp_resumeBody => '前回の場所から続きを見ますか？それとも最初から見直しますか？';

  @override
  String get ixp_resumeFromStart => '最初から';

  @override
  String get ixp_resumeContinue => '続きから';

  @override
  String ixp_fetchFailedFmt(String code) {
    return 'ストーリー取得失敗（$code）';
  }

  @override
  String get ixp_dataAnomaly => 'ストーリーデータ異常（起点ノードなし）';

  @override
  String ixp_loadErrorFmt(String msg) {
    return '読み込みエラー：$msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return 'ノード「$id」が見つかりません';
  }

  @override
  String get ixp_nodeJumpTitle => 'ノードジャンプ · オーナーテスト';

  @override
  String get ixp_nodeJumpBody => '通常ユーザーには非表示。任意のノードをタップで直接移動（フラグは変えません）。';

  @override
  String ixp_segCountFmt(String n) {
    return '$n 段';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return '有料分岐（公開後 $price コイン）· 今回は無料体験';
  }

  @override
  String get ixp_fallbackTitle => 'インタラクティブドラマ';

  @override
  String get ixp_btnSkip => 'スキップ';

  @override
  String get ixp_btnBack => '戻る';

  @override
  String get ixp_segGenerating => 'このパートはまだ生成中…';

  @override
  String get ixp_btnContinue => '続ける';

  @override
  String ixp_prepFmt(String done, String total) {
    return '準備中 $done / $total';
  }

  @override
  String get ixp_prep => '準備中…';

  @override
  String get ixp_yourChoice => 'あなたの選択';

  @override
  String get ixp_endingFallback => 'エンディング';

  @override
  String get ixp_btnReplay => 'もう一度';

  @override
  String get ixp_endingGood => 'グッドエンド';

  @override
  String get ixp_endingBad => 'バッドエンド';

  @override
  String get ixp_endingHidden => '隠しエンド';

  @override
  String get ixp_endingOpen => 'オープンエンド';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n 選択肢';
  }

  @override
  String get ip_busyAiCreatingTitle => 'AIに創作を依頼しました';

  @override
  String get ip_busyAiCreatingSub =>
      'あなた専用のエンディングを1フレームずつ生成中…\n数分かかります、完了次第お知らせします — ほかも楽しんでてね';

  @override
  String get ip_busyDirectorTitle => '監督がモニター前に着席 · キャストが入場';

  @override
  String get ip_busyDirectorSub => 'あなたが選んだすべて、あなたの顔を、あなただけのフィナーレに織り込んでいます';

  @override
  String get ip_busyDoneTitle => '✦ あなた専用のエンディングが完成';

  @override
  String get ip_busyDoneSub => '「マイ専用エンディング」に永久保存しました';

  @override
  String ip_titleChipFmt(String n) {
    return 'インタラクティブ · $n 種のエンディング';
  }

  @override
  String get ip_titleSub => 'あなたの選択ひとつひとつが、結末を書き換える';

  @override
  String get ip_titleStart => '物語を始める';

  @override
  String get ip_btnContinue => '続ける';

  @override
  String ip_voteFmt(String n) {
    return '$n% の人がこの選択';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return '解放エンディング $got / $total';
  }

  @override
  String get ip_btnDex => 'エンディング図鑑';

  @override
  String get ip_btnReplay => '別の選択でもう一度';

  @override
  String get ip_dexTitle => 'エンディング図鑑';

  @override
  String get ip_dexLocked => '？？？';

  @override
  String ip_errorTitleFmt(String err) {
    return 'ストーリー検証エラー\n$err';
  }

  @override
  String get ip_unlockTitleAi => 'あなただけのエンディングを創る';

  @override
  String get ip_unlockTitle => 'このストーリー分岐を解放';

  @override
  String get ip_demoFree => 'サンプルドラマ · 無料体験';

  @override
  String get ip_unlockBtnAi => '私のために創り始める';

  @override
  String get ip_unlockBtn => '分岐を解放';

  @override
  String get ip_unlockCancel => 'やめておく';

  @override
  String com_sceneSameFmt(String n) {
    return 'このシーンに $n 件';
  }

  @override
  String get com_sameInDrama => '劇中アイテム';

  @override
  String get com_buyNow => '今すぐ購入';

  @override
  String get com_inStock => '在庫あり · 送料無料';

  @override
  String get com_outOfStock => '在庫切れ';

  @override
  String get com_infoMerchant => 'ショップ';

  @override
  String get com_infoEpisode => '関連エピソード';

  @override
  String get com_infoScene => '登場シーン';

  @override
  String com_sceneTimeFmt(String sec) {
    return '${sec}s から';
  }

  @override
  String get com_descTitle => '商品説明';

  @override
  String get com_descBody =>
      '劇中アイテムをFalconFlix厳選パートナーが提供。プラットフォームから発送、7日間返品可能。（サンプル文、実商品連携後に置換）';

  @override
  String get com_addCart => 'カートに追加';

  @override
  String get com_addCartToast => 'カートに追加しました（開発中）';

  @override
  String get com_methodCoin => 'コイン残高';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return '残 $n';
  }

  @override
  String get com_methodWechat => 'WeChat Pay';

  @override
  String get com_methodAlipay => 'Alipay';

  @override
  String get com_confirmOrder => '注文を確認';

  @override
  String get com_qtyOne => '数量 1';

  @override
  String get com_payMethod => '支払方法';

  @override
  String get com_lineAmount => '商品金額';

  @override
  String get com_lineCoupon => 'クーポン';

  @override
  String get com_lineCouponUnused => '未使用';

  @override
  String get com_lineShipping => '送料';

  @override
  String get com_lineShippingFree => '無料';

  @override
  String get com_total => '合計';

  @override
  String get com_submitOrder => '注文を確定';

  @override
  String get com_submitToast => '注文完了（決済機能は開発中）';

  @override
  String get ss_tier66_label => 'ライトアップ';

  @override
  String get ss_tier66_meaning => 'ラッキー66';

  @override
  String get ss_tier188_label => '花束を贈る';

  @override
  String get ss_tier188_meaning => '気持ちいっぱい';

  @override
  String get ss_tier520_label => 'TAが好き';

  @override
  String get ss_tier520_meaning => '胸キュン';

  @override
  String get ss_tier1314_label => '一生一世';

  @override
  String get ss_tier1314_meaning => 'あなたしか';

  @override
  String get ss_tier3344_label => '永遠に';

  @override
  String get ss_tier3344_meaning => 'とことん推す';

  @override
  String get ss_tier9999_label => '伝説の応援';

  @override
  String get ss_tier9999_meaning => 'あなたが1位';

  @override
  String ss_callForFmt(String name) {
    return '$name に応援';
  }

  @override
  String get ss_subtitle => 'コインが多いほど · デビューが早まる · 順位が上がる';

  @override
  String ss_balanceFmt(String n) {
    return 'コイン残高 $n';
  }

  @override
  String get ss_localNote => 'ベータ · 応援はローカル保存、正式版でコイン決済';

  @override
  String get ss_celebTitle => '応援完了！';

  @override
  String ss_forFmt(String name, String label) {
    return '$name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins コイン';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return 'デビュー +$delta% · 現在 $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 あなたが TA の1位ファン！V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return 'あなたは TA の第 $rank 番ガーディアン · V$level $tier';
  }

  @override
  String get ss_tapToContinue => 'タップで続行';

  @override
  String get air_title => 'キャスティングランキング';

  @override
  String get air_sub => '熱量が満タンでデビュー · 応援が熱いほど上位に';

  @override
  String get air_segCharRank => 'キャラ';

  @override
  String get air_segKingRank => 'トップファン';

  @override
  String get air_chipAll => 'すべて';

  @override
  String get air_chipFemale => '女子';

  @override
  String get air_chipMale => '男子';

  @override
  String get air_chipTycoon => '大富豪';

  @override
  String get air_chipDeity => '神級';

  @override
  String get air_chipLegend => '伝説';

  @override
  String get air_emptyChar => 'このカテゴリーにキャラはまだ';

  @override
  String get air_emptyKing => 'このランクはまだ空席';

  @override
  String get air_debuted => 'デビュー済';

  @override
  String get air_leading => '首位';

  @override
  String air_heatFmt(String pct) {
    return '応援熱度 $pct%';
  }

  @override
  String get air_doneShoot => '撮影開始';

  @override
  String air_toGoFmt(String n) {
    return 'デビューまで $n%';
  }

  @override
  String air_supportKingFmt(String name) {
    return 'トップファン: $name';
  }

  @override
  String get air_emptyKingPlaceholder => 'チャンピオン募集中';

  @override
  String get air_globalKing => '全体トップファン';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · 推し $name';
  }

  @override
  String air_guardFmt(String name) {
    return '$name を守護';
  }

  @override
  String get cd_secVideos => 'TA の動画';

  @override
  String get cd_secMoments => 'もっと深く知る';

  @override
  String get cd_actUnlock => 'コインで解放';

  @override
  String get cd_secCredits => 'TA の出演ドラマ';

  @override
  String cd_secBoardFmt(String n) {
    return '応援ボード · $n 人の支持者';
  }

  @override
  String get cd_actImInToo => '私も参加 ›';

  @override
  String get cd_swipeHint => '下にスワイプ · 応援 · 解放';

  @override
  String get cd_introBadge => 'TA の自己紹介';

  @override
  String get cd_debutProgress => 'デビュー応援進捗';

  @override
  String get cd_debutHint => '満タンで撮影開始 · 実写＋AIのプレミアム作品';

  @override
  String cd_clipToastFmt(String name) {
    return 'クリップ「$name」を再生 · 開発中';
  }

  @override
  String cd_momentToastFmt(String title) {
    return '「$title」を解放 · コイン機能開発中';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '『$name』· 視聴機能開発中';
  }

  @override
  String get cd_kingBadge => '作品トップファン';

  @override
  String get cd_btnSupport => '応援';

  @override
  String get cd_btnChat => 'チャット · 解放';

  @override
  String get sp_toolPosterName => 'ドラマポスター生成';

  @override
  String get sp_toolPosterDesc => '顔写真をアップロードして、このドラマでの縦型ポスターを生成。';

  @override
  String get sp_toolPosterCost => '約 5-25 コイン';

  @override
  String get sp_toolVideoNameShort => '3秒 AI クリップ';

  @override
  String get sp_toolVideoName => '3秒 AI ドラマクリップ';

  @override
  String get sp_toolVideoDesc => '写真や1行から軽量な縦型クリップを生成。';

  @override
  String get sp_toolVideoCost => '約 40 コイン';

  @override
  String get sp_toolMakeoverName => 'AI コスチューム';

  @override
  String get sp_toolMakeoverDesc => '1枚の写真で時代物、職業、アニメ、レトロ、ポートレートを試す。';

  @override
  String get sp_toolMakeoverCost => '約 25 コイン';

  @override
  String get sp_toolAvatarName => 'AI 専用アバター';

  @override
  String get sp_toolAvatarDesc => '顔写真から個人アバター生成、プロフィールに直接更新可能。';

  @override
  String get sp_toolAvatarCost => '約 5-25 コイン';

  @override
  String get sp_sectionHeader => 'AI プレイ';

  @override
  String get sp_subtitle => 'ドラマ視聴とつながる軽量AIプレイ。';

  @override
  String sp_creatingFmt(String title) {
    return '『$title』のために創作中';
  }

  @override
  String get sp_chipLinked => 'ストーリー連動';

  @override
  String get sp_chipMall => 'ドラマモール';

  @override
  String get sp_putInDramaTitle => '自分をドラマに入れる';

  @override
  String get sp_putInDramaBody => '撮影や写真アップロードで、現在のドラマのポスターやクリップを生成。';

  @override
  String get sp_btnTryRoleplay => 'AI ロールプレイを試す';

  @override
  String get sp_sceneMallTitle => 'シーンモール';

  @override
  String get sp_sceneMallBody => '劇中アイテム、シーン商品、クリエイターコラボ品を見る。';

  @override
  String get spf_settingsTitle => 'ツール設定';

  @override
  String spf_linkedToFmt(String title) {
    return '『$title』に連動';
  }

  @override
  String get spf_chooseTool => 'ツールを選ぶ';

  @override
  String spf_genBtnFmt(String cost) {
    return '生成 · $cost';
  }

  @override
  String get spf_noPhotoBtn => '写真をアップロードしてください';

  @override
  String get spf_photoReady => '写真の準備完了';

  @override
  String get spf_uploadPhoto => '写真をアップロード';

  @override
  String get spf_photoTapToReplace => 'タップで再選択';

  @override
  String get spf_photoHint => '正面または全身、顔がはっきり';

  @override
  String get spf_generating => 'AI が生成中…';

  @override
  String get spf_generatingSub => 'あなたをドラマに入れています、少々お待ちを';

  @override
  String get spf_genDoneTag => '完了';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · 完成';
  }

  @override
  String get spf_genDoneBody => '作品に保存、シェア、または再生成。';

  @override
  String get spf_btnSave => 'マイ作品に保存';

  @override
  String get spf_savedToast => '保存しました（開発中）';

  @override
  String get spf_shareLabel => 'AI 作品';

  @override
  String get cui_chipAI => 'AI インタラクティブ';

  @override
  String get cui_chipMetaverse => 'メタバース世界観';

  @override
  String get cui_title => 'キャラクターメタバース';

  @override
  String get cui_lead => 'ここで出会うのは俳優ではなく、あなたに応えてくれる「人」。';

  @override
  String get cui_body =>
      'それぞれのキャラには性格、声、物語がある。一緒におしゃべりし、応援し、心を奪うあの子を自分の手で舞台に上げる——一言のセリフから、二人だけのプレミアム・インタラクティブドラマまで。';

  @override
  String get cui_step1Title => '出会い & 個チャ';

  @override
  String get cui_step1Desc => 'キャラを長押しで声を聞き、1対1のチャットへ。AIの寄り添い、話すほど分かり合える。';

  @override
  String get cui_step2Title => '応援 & 投票';

  @override
  String get cui_step2Desc => '推しにコインを投じ、応援ボードに名を刻み、トップファンになる。';

  @override
  String get cui_step3Title => '撮影開始 & デビュー';

  @override
  String get cui_step3Desc => '応援が満タンで正式デビュー——実写＋AIのプレミアム作品、あなたが点火する。';

  @override
  String get cui_step4Title => '客演 & 深掘り';

  @override
  String get cui_step4Desc => '推しとの専用ストーリーや「深い時間」を解放、自分自身を物語に書き込むことも。';

  @override
  String get cui_footer => 'あなたの一票一票が、次の主役を書き換える。';

  @override
  String get com2_title => 'コミュニティ';

  @override
  String get com2_chipPlaza => '視聴広場';

  @override
  String get com2_emptyHint => 'まだ投稿なし — 最初の投稿をどうぞ';

  @override
  String get com2_btnPost => '新規投稿';

  @override
  String get com2_watching => '視聴中';

  @override
  String get com2_fallbackDrama => 'FalconFlix ドラマ';

  @override
  String get com2_publishedToast => 'コミュニティに投稿しました';

  @override
  String get com2_postHint => 'このドラマの感想、シェアしましょう…';

  @override
  String get com2_publish => '投稿';

  @override
  String get com2_attachDrama => 'このドラマを添付';

  @override
  String get dhc_connected => '接続完了';

  @override
  String get dhc_connecting => '接続中';

  @override
  String get dhc_ended => '終了';

  @override
  String get dhc_error => 'エラー';

  @override
  String get dhc_connectingHint => '接続中…お待ちください';

  @override
  String dhc_talkingFmt(String name) {
    return '$name が話しています…';
  }

  @override
  String get dhc_listening => '聞いています…';

  @override
  String get dhc_backLabel => '戻る';

  @override
  String get dhc_actorsReady => '俳優がポジションに着いています…';

  @override
  String get ss2_searchHint => 'ドラマ / 俳優 / タグを検索';

  @override
  String get ss2_history => '検索履歴';

  @override
  String get ss2_clear => 'クリア';

  @override
  String get ss2_hot => '人気の検索';

  @override
  String get ss2_hotBadge => '人気';

  @override
  String ss2_noResultFmt(String q) {
    return '「$q」のドラマが見つかりません';
  }

  @override
  String ss2_foundFmt(String n) {
    return '$n 本のドラマ';
  }

  @override
  String get ss2_chipCEO => '御曹司';

  @override
  String get ss2_chipTimeTravel => 'タイムスリップ';

  @override
  String get ss2_chipMystery => 'ミステリー';

  @override
  String get ss2_chipModern => '現代恋愛';

  @override
  String get ss2_chipSweetPet => '甘々ラブ';

  @override
  String get rk_emptyCat => 'このカテゴリのランキングなし';

  @override
  String get rk_hotTitle => '人気ランキング';

  @override
  String get rk_hotSub => '今日の熱量でリアルタイム順';

  @override
  String get rk_top1Today => '# 1  今日最熱';

  @override
  String rk_heatFmt(String plays) {
    return '$plays 熱度 · 上昇中';
  }

  @override
  String get rk_chipUrban => '都市';

  @override
  String get rk_chipFinished => '完結';

  @override
  String get rk_chipRomance => '恋愛';

  @override
  String get aic_lowEnergyNag => 'ぐぬぬ…ちょっとエネルギー切れ、チャージしてくれない？~';

  @override
  String get aic_chargedReply => 'ありがとう！満タン復活、続けよっか~';

  @override
  String get aic_chargeToast => 'チャージ · コイン課金は開発中（モックで満タン）';

  @override
  String aic_energyFmt(String pct) {
    return 'エネルギー $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return '$name にチャージ';
  }

  @override
  String aic_hintFmt(String name) {
    return '$name に話しかける…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · V$level 必須';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return '$amount チャージで V$level に';
  }

  @override
  String get lg_btnTopUp => 'チャージしてアップグレード';

  @override
  String get lg_btnLater => 'あとで';

  @override
  String get me_defaultName => 'FalconFlix 視聴者';

  @override
  String get me_avatarUpdated => 'アバターを更新しました';

  @override
  String get me_avatarUpdateFailed => 'アバター更新に失敗、再試行してください';

  @override
  String get me_tapAvatarToChange => 'アバターをタップで画像を変更';

  @override
  String get me_myLevel => 'マイレベル';

  @override
  String get me_loginEmail => 'ログインメール';

  @override
  String get me_membership => '会員';

  @override
  String get me_uploading => 'アップロード中…';

  @override
  String get me_changeAvatar => 'アバター変更';

  @override
  String me_copiedFmt(String value) {
    return 'コピー済み: $value';
  }

  @override
  String get tier_commoner => '平民';

  @override
  String get tier_rookie => '入門';

  @override
  String get tier_advanced => '中級';

  @override
  String get tier_lord => '大物';

  @override
  String get tier_tycoon => '大富豪';

  @override
  String get tier_deity => '神級';

  @override
  String get tier_legend => '伝説';

  @override
  String get rch_statusPaid => '入金済み';

  @override
  String get rch_statusPending => '支払い待ち';

  @override
  String get rch_statusCanceled => 'キャンセル';

  @override
  String get rch_statusProcessing => '処理中';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n コイン';
  }

  @override
  String get time_justNow => 'たった今';

  @override
  String time_minutesAgoFmt(String n) {
    return '$n分前';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return '$n時間前';
  }

  @override
  String time_daysAgoFmt(String n) {
    return '$n日前';
  }

  @override
  String get notify_typeRecharge => 'チャージ';

  @override
  String get notify_typeInvite => '招待';

  @override
  String get notify_typeSystem => 'システム';

  @override
  String get notify_typeActivity => 'イベント';

  @override
  String get notify_typeInteractive => 'インタラクティブ';
}
