// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTheater => 'Theater';

  @override
  String get tabInteractive => 'Interactive';

  @override
  String get tabCharacter => 'Cast';

  @override
  String get tabMe => 'Me';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_save => 'Save';

  @override
  String get common_back => 'Back';

  @override
  String get common_close => 'Close';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_more => 'More';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_free => 'Free';

  @override
  String get common_login => 'Sign in';

  @override
  String get common_logout => 'Sign out';

  @override
  String get common_loadFailed => 'Load failed';

  @override
  String get common_pleaseLogin => 'Please sign in first';

  @override
  String get common_done => 'Done';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_send => 'Send';

  @override
  String get me_title => 'Me';

  @override
  String get me_loginPrompt => 'Sign in / Sign up';

  @override
  String get me_loginSubtitle =>
      'Sign in to unlock your library, wallet and interactive dramas';

  @override
  String get me_membershipNormal => 'Member';

  @override
  String get me_membershipVip => 'VIP';

  @override
  String get me_inviteCode => 'Invite code';

  @override
  String get me_statEagleCoins => 'Eagle Coins';

  @override
  String get me_statBoughtEpisodes => 'Owned';

  @override
  String get me_statCollections => 'Saved';

  @override
  String get me_sectionMyContent => 'My Content';

  @override
  String get me_sectionWallet => 'Wallet';

  @override
  String get me_sectionCommunity => 'Community';

  @override
  String get me_sectionCreator => 'Creator';

  @override
  String get me_sectionSettings => 'Settings';

  @override
  String get me_sectionHelpAbout => 'Help & About';

  @override
  String get me_rowCollections => 'My Saves';

  @override
  String get me_rowHistory => 'Watch History';

  @override
  String get me_rowCommunity => 'Community Feed';

  @override
  String get me_rowWallet => 'Wallet & Membership';

  @override
  String get me_rowOrders => 'My Orders';

  @override
  String get me_rowInvite => 'Invite Friends';

  @override
  String get me_rowPartner => 'Creator Partner';

  @override
  String get me_rowNotifications => 'Notifications';

  @override
  String get me_rowSettings => 'Settings';

  @override
  String get me_rowHelpAbout => 'Help & About';

  @override
  String get me_rowAbout => 'About FalconFlix';

  @override
  String get me_logoutConfirm => 'Sign out of your account?';

  @override
  String get history_title => 'Watch History';

  @override
  String get history_emptyTitle => 'No watch history yet';

  @override
  String get history_emptyBody =>
      'Each episode you watch will show up here so you can jump back where you left off.';

  @override
  String get history_loginBody => 'Sign in to see what you\'ve watched.';

  @override
  String get history_actionDelSelected => 'Delete selected';

  @override
  String get history_actionClearAll => 'Clear all';

  @override
  String get history_episodeFallback => 'Full series';

  @override
  String get history_unknown => '(Unknown title)';

  @override
  String history_selectedCount(int n) {
    return '$n selected';
  }

  @override
  String history_delConfirmTitle(int n) {
    return 'Delete $n record(s)?';
  }

  @override
  String get history_delConfirmBody =>
      'This can\'t be undone. The drama itself isn\'t affected — a new record is created next time you play.';

  @override
  String get history_clearConfirmTitle => 'Clear all watch history?';

  @override
  String get history_clearConfirmBody =>
      'This can\'t be undone. Records will be re-created next time you play.';

  @override
  String history_toastDeleted(int n) {
    return 'Deleted $n';
  }

  @override
  String get history_toastCleared => 'Cleared';

  @override
  String get orders_title => 'My Orders';

  @override
  String get orders_tabFull => 'Series';

  @override
  String get orders_tabEpisode => 'Episode';

  @override
  String get orders_tabRecharge => 'Top-ups';

  @override
  String get orders_emptyFull => 'No full-series orders yet';

  @override
  String get orders_emptyEpisode => 'No episode orders yet';

  @override
  String get orders_emptyBody =>
      'Unlocked dramas show up here — handy for receipts and support.';

  @override
  String get orders_emptyRecharge => 'No top-up history yet';

  @override
  String get orders_emptyRechargeBody => 'Your first top-up will appear here.';

  @override
  String get orders_loginBodyOrders => 'Sign in to see your orders.';

  @override
  String get orders_loginBodyRecharge => 'Sign in to see top-up history.';

  @override
  String get orders_kvAmount => 'Amount';

  @override
  String get orders_kvPayMethod => 'Method';

  @override
  String get orders_kvTime => 'Time';

  @override
  String orders_orderCopied(String orderNo) {
    return 'Order # copied · $orderNo';
  }

  @override
  String get orders_paid => 'Paid';

  @override
  String get orders_pending => 'Pending';

  @override
  String get orders_payEagle => 'Eagle Coins';

  @override
  String get orders_unknownTitle => '(Unknown title)';

  @override
  String get orders_rechargeFallback => 'Eagle Coin top-up';

  @override
  String get inbox_title => 'Notifications';

  @override
  String get inbox_tabAll => 'All';

  @override
  String get inbox_tabRecharge => 'Top-up';

  @override
  String get inbox_tabInvite => 'Invites';

  @override
  String get inbox_tabSystem => 'System';

  @override
  String get inbox_tabActivity => 'Promo';

  @override
  String get inbox_tabInteractive => 'Interactive';

  @override
  String get inbox_emptyTitle => 'No messages yet';

  @override
  String get inbox_emptyBody =>
      'Top-up receipts, invite rewards, promos and system notices all show up here.';

  @override
  String get inbox_loginBody =>
      'Sign in to see top-up / invite / system messages.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_sectionNotificationPlayback => 'Notifications & Playback';

  @override
  String get settings_sectionAccount => 'Account';

  @override
  String get settings_sectionUIStorage => 'Interface & Storage';

  @override
  String get settings_rowNotifyPrefs => 'Notifications';

  @override
  String get settings_rowPlayPrefs => 'Playback & Downloads';

  @override
  String get settings_rowAccountSecurity => 'Account & Security';

  @override
  String get settings_rowPrivacy => 'Privacy';

  @override
  String get settings_rowLanguage => 'Language';

  @override
  String get settings_rowClearCache => 'Clear cache';

  @override
  String get settings_clearCacheTitle => 'Clear cache?';

  @override
  String get settings_clearCacheBody =>
      'Clears downloaded interactive videos and image cache. Your purchases, sign-in and settings are not affected.';

  @override
  String get settings_clearCacheAction => 'Clear now';

  @override
  String settings_clearCacheDone(String size) {
    return 'Cleared $size';
  }

  @override
  String get notifyPrefs_title => 'Notifications';

  @override
  String get notifyPrefs_pushMaster => 'Push master switch';

  @override
  String get notifyPrefs_pushMasterDesc =>
      'Turning off pauses all push notifications. In-app inbox still delivers.';

  @override
  String get notifyPrefs_recharge => 'Top-up confirmations';

  @override
  String get notifyPrefs_rechargeDesc =>
      'Successful top-up / Eagle Coins credited';

  @override
  String get notifyPrefs_invite => 'Invite rewards';

  @override
  String get notifyPrefs_inviteDesc =>
      'Your invited friends sign up / rewards arrive';

  @override
  String get notifyPrefs_system => 'System notices';

  @override
  String get notifyPrefs_systemDesc => 'Account security / important changes';

  @override
  String get notifyPrefs_activity => 'Promotions';

  @override
  String get notifyPrefs_activityDesc => 'New drama launches / top-up promos';

  @override
  String get notifyPrefs_interactive => 'Interactive drama updates';

  @override
  String get notifyPrefs_interactiveDesc => 'New episodes / endings unlocked';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return 'Save failed: $msg';
  }

  @override
  String get playPrefs_title => 'Playback & Downloads';

  @override
  String get playPrefs_autoplay => 'Auto-play next';

  @override
  String get playPrefs_autoplayDesc =>
      'Auto-play the next video when one finishes';

  @override
  String get playPrefs_wifiOnlyAutoplay => 'Wi-Fi only auto-play';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc =>
      'Don\'t auto-play on cellular, save data';

  @override
  String get playPrefs_quality => 'Default quality';

  @override
  String get playPrefs_qualityAuto => 'Auto (network)';

  @override
  String get playPrefs_quality480 => 'SD 480p';

  @override
  String get playPrefs_quality720 => 'HD 720p';

  @override
  String get playPrefs_quality1080 => 'Full HD 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => 'Wi-Fi only downloads';

  @override
  String get playPrefs_wifiOnlyDownloadDesc =>
      'Interactive videos / offline cache only over Wi-Fi';

  @override
  String get accountSec_title => 'Account & Security';

  @override
  String get accountSec_sectionLogin => 'Sign-in';

  @override
  String get accountSec_sectionDeletion => 'Account deletion';

  @override
  String get accountSec_rowChangePwd => 'Change password';

  @override
  String get accountSec_rowChangePwdDesc => 'Requires your current password';

  @override
  String get accountSec_rowDelete => 'Delete account';

  @override
  String get accountSec_rowDeleteDesc =>
      '7-day cooling-off period, sign in to cancel';

  @override
  String get accountSec_oldPwHint => 'Current password';

  @override
  String get accountSec_newPwHint => 'New password (8+ characters)';

  @override
  String get accountSec_confirmPwHint => 'Re-enter new password';

  @override
  String get accountSec_errMinLen =>
      'New password must be at least 8 characters';

  @override
  String get accountSec_errMismatch => 'Passwords don\'t match';

  @override
  String get accountSec_saveNewPw => 'Save new password';

  @override
  String get accountSec_saving => 'Saving…';

  @override
  String get accountSec_pwUpdated => 'Password updated';

  @override
  String get privacyPrefs_title => 'Privacy';

  @override
  String get privacyPrefs_sectionData => 'My data';

  @override
  String get privacyPrefs_sectionLegal => 'Terms & policy';

  @override
  String get privacyPrefs_rowExport => 'Download my data';

  @override
  String get privacyPrefs_rowExportDesc =>
      'GDPR / CCPA: request a package of all your data';

  @override
  String get privacyPrefs_rowPolicy => 'Privacy policy';

  @override
  String get deleteAcc_title => 'Delete account';

  @override
  String get deleteAcc_inProgress => 'Account deletion in progress';

  @override
  String deleteAcc_scheduledAt(String time) {
    return 'Scheduled: $time';
  }

  @override
  String get deleteAcc_pendingHint =>
      'Sign in any time during the 7-day cooling-off period to cancel. Once cancelled your account and data resume normally.';

  @override
  String get deleteAcc_cancelBtn => 'Cancel deletion, keep account';

  @override
  String get deleteAcc_willDelete => 'Deleting your account will remove';

  @override
  String get deleteAcc_bullet1 =>
      'Profile, nickname, avatar, email, phone bindings';

  @override
  String get deleteAcc_bullet2 =>
      'Wallet balance (Eagle Coins non-refundable), VIP / level';

  @override
  String get deleteAcc_bullet3 =>
      'Purchased dramas and interactive drama unlocks';

  @override
  String get deleteAcc_bullet4 =>
      'Watch history, saves, community posts, interactive saves';

  @override
  String get deleteAcc_bullet5 =>
      'Invitations (records on the invitee side remain)';

  @override
  String get deleteAcc_coolingHint =>
      'Submission enters a 7-day cooling-off period. Sign in during that window to cancel. After it expires the account is permanently deleted.';

  @override
  String get deleteAcc_reasonLabel => 'Reason (optional, helps us improve)';

  @override
  String get deleteAcc_reasonHint => 'Tell us what\'s wrong (optional)';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return 'Type \"$phrase\" to confirm';
  }

  @override
  String get deleteAcc_confirmPhrase => 'DELETE MY ACCOUNT';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return 'Please type \"$phrase\" exactly';
  }

  @override
  String get deleteAcc_submit => 'Submit deletion';

  @override
  String get deleteAcc_finalTitle => 'Final confirmation';

  @override
  String get deleteAcc_finalBody =>
      'This starts a 7-day cooling-off period. You can sign in any time during that window to cancel.\n\nAfter it expires, your data is permanently deleted and cannot be recovered.';

  @override
  String get deleteAcc_finalSubmit => 'Submit deletion';

  @override
  String get deleteAcc_submitted => 'Deletion submitted — scheduled in 7 days';

  @override
  String get deleteAcc_cancelled => 'Deletion cancelled';

  @override
  String get deleteAcc_thinkAgain => 'Not yet, take me back';

  @override
  String get dataExport_title => 'Download my data';

  @override
  String get dataExport_introTitle => 'Get a copy of your data';

  @override
  String get dataExport_introBody =>
      'Under GDPR Article 15 (EU) and CCPA (California) you have the right to receive all personal data we hold about you.\n\nAfter you submit, we\'ll asynchronously generate a zip package including:\n  · Profile / email / phone\n  · Eagle Coin balance and transactions\n  · Orders, watch history, saves\n  · Community posts, interactive drama unlocks\n\nWhen ready, we\'ll notify you in-app. The download link is valid for 7 days.';

  @override
  String get dataExport_statusQueued => 'Pending · queued';

  @override
  String get dataExport_statusProcessing => 'Processing · packaging';

  @override
  String get dataExport_statusReady => 'Ready · download now';

  @override
  String get dataExport_statusExpired => 'Expired · request again';

  @override
  String get dataExport_statusFailed => 'Failed · request again';

  @override
  String dataExport_expiresAt(String time) {
    return 'Link expires $time';
  }

  @override
  String get dataExport_downloadBtn => 'Download';

  @override
  String get dataExport_submitBtn => 'Request download';

  @override
  String get dataExport_submitting => 'Submitting…';

  @override
  String get dataExport_submitted =>
      'Request submitted — we\'ll let you know when ready';

  @override
  String get helpAbout_title => 'Help & About';

  @override
  String get helpAbout_sectionHelp => 'Help';

  @override
  String get helpAbout_sectionAbout => 'About';

  @override
  String get helpAbout_rowFaq => 'Help center';

  @override
  String get helpAbout_rowFaqDesc => 'Frequently asked questions';

  @override
  String get helpAbout_rowSupport => 'Contact support';

  @override
  String get helpAbout_rowSupportDesc => 'One-on-one ticket chat';

  @override
  String get helpAbout_rowFeedback => 'Send feedback';

  @override
  String get helpAbout_rowFeedbackDesc => 'Product ideas / bug reports';

  @override
  String get faq_title => 'Help Center';

  @override
  String get faq_catAll => 'All';

  @override
  String get faq_catAccount => 'Account';

  @override
  String get faq_catRecharge => 'Top-up';

  @override
  String get faq_catPlayback => 'Playback';

  @override
  String get faq_catInteractive => 'Interactive';

  @override
  String get faq_catOther => 'Other';

  @override
  String get faq_emptyTitle => 'No FAQs yet';

  @override
  String get faq_emptyBody =>
      'If you ran into an issue, please open a support ticket.';

  @override
  String get tickets_title => 'Contact Support';

  @override
  String get tickets_newBtn => 'New ticket';

  @override
  String get tickets_emptyTitle => 'No tickets yet';

  @override
  String get tickets_emptyBody =>
      'Tap the button to start a new ticket. Support will reply one-on-one.';

  @override
  String get tickets_threadTitle => 'Ticket detail';

  @override
  String get tickets_initial => 'Initial issue';

  @override
  String get tickets_speakerStaff => 'Support';

  @override
  String get tickets_speakerSelf => 'Me';

  @override
  String get tickets_replyHint => 'Reply…';

  @override
  String tickets_sendFailed(String msg) {
    return 'Send failed: $msg';
  }

  @override
  String get tickets_statusPending => 'Pending';

  @override
  String get tickets_statusReplied => 'Replied';

  @override
  String get tickets_statusResolved => 'Resolved';

  @override
  String get tickets_statusClosed => 'Closed';

  @override
  String get feedback_titleTicket => 'New ticket';

  @override
  String get feedback_titleFeedback => 'Send feedback';

  @override
  String get feedback_typeBug => 'Bug report';

  @override
  String get feedback_typeSuggestion => 'Suggestion';

  @override
  String get feedback_typeComplaint => 'Complaint';

  @override
  String get feedback_typeRecharge => 'Top-up issue';

  @override
  String get feedback_typeOther => 'Other';

  @override
  String get feedback_typeLabel => 'Issue type';

  @override
  String get feedback_contentLabel => 'Details';

  @override
  String get feedback_contentHintTicket =>
      'Describe the issue in detail so we can help faster…';

  @override
  String get feedback_contentHintFeedback => 'Tell us what you think…';

  @override
  String get feedback_contactLabel => 'Reply email / phone (optional)';

  @override
  String get feedback_contactHint => 'We\'ll prioritize replying. Optional.';

  @override
  String get feedback_submit => 'Submit';

  @override
  String get feedback_submitting => 'Submitting…';

  @override
  String get feedback_submitted => 'Submitted — support will reply';

  @override
  String get feedback_minLength => 'Please write at least 5 characters';

  @override
  String feedback_tip(String version) {
    return 'Tip: include reproduction steps + screenshots (coming soon) for fastest triage.\nVersion: $version';
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
  String get home_noDramaData => 'No dramas yet';

  @override
  String get home_localOnlyLike => 'Local source doesn\'t support likes';

  @override
  String get home_localOnlyCollect => 'Local source doesn\'t support saving';

  @override
  String get home_addedToMy => 'Saved to My';

  @override
  String get home_actionLike => 'Like';

  @override
  String get home_actionCollected => 'Saved';

  @override
  String get home_actionCollect => 'Save';

  @override
  String get home_actionShare => 'Share';

  @override
  String get home_shopComingSoon =>
      'Same item from the show · AI lookup (shop coming soon)';

  @override
  String get home_chipAiTheater => 'AI Theater';

  @override
  String get home_bannerPremiere => 'AI Drama Premiere';

  @override
  String get home_btnWatch => 'Watch';

  @override
  String get home_btnDetails => 'Details';

  @override
  String home_loadFailedFmt(String message) {
    return 'Failed to load\n$message';
  }

  @override
  String get theater_genreAll => 'All';

  @override
  String get theater_genreRomance => 'Romance';

  @override
  String get theater_genreUrban => 'Urban';

  @override
  String get theater_genreInteractive => 'Interactive';

  @override
  String get theater_genreFinished => 'Completed';

  @override
  String get theater_sectionHot => 'Trending Now';

  @override
  String get theater_seeAll => 'See all';

  @override
  String get theater_sectionAll => 'All Dramas';

  @override
  String get theater_ranking => 'Top Charts';

  @override
  String get theater_today => 'Today\'s Pick';

  @override
  String get theater_labelShort => 'Short Drama';

  @override
  String theater_continueWatch(String name) {
    return 'Continue · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '$heat views';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · $heat views';
  }

  @override
  String get cast_sectionPlaying => 'Now Playing & Casting';

  @override
  String get cast_oppRanking => 'Opportunity Board ›';

  @override
  String get cast_universeTitle => 'Character Metaverse';

  @override
  String get cast_universeSub =>
      'Meet people who answer back · Explore this world';

  @override
  String get cast_demoBadge => 'Demo · Playable';

  @override
  String get cast_demoTitle => 'Demo Interactive Drama';

  @override
  String get cast_demoSub => 'Your call — one line ignites a whole drama';

  @override
  String get cast_inPlay => 'On Air';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '$heat views · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '$heat views';
  }

  @override
  String get cb_sectionSupport => 'Top Supporters · Who\'s voting for them';

  @override
  String get cb_goSupport => 'Vote · Send them to set';

  @override
  String get cb_seeBio => 'See bio ›';

  @override
  String cb_pollHeatPct(String pct) {
    return 'Backing $pct%';
  }

  @override
  String get cb_debuted => 'On Set';

  @override
  String cb_toDebutPct(String pct) {
    return '$pct% to set';
  }

  @override
  String get cb_totalSupport => 'Total Support';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins Eagle Coins';
  }

  @override
  String get cb_topBacker => 'Top Backer';

  @override
  String get cb_emptyBackers => 'No backers yet · Be the first to support';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · Support Board';
  }

  @override
  String get aid_titleHeader => 'AI Interactive Drama';

  @override
  String get aid_aceBadge => 'Ace';

  @override
  String get aid_tagline => 'Your choices rewrite the ending.';

  @override
  String get aid_demoBadge => 'Demo · Free Trial';

  @override
  String get aid_lastcallSub =>
      '5 layers · 7 endings · Your choice rewrites the story';

  @override
  String get aid_pipelineTitle => 'Star Studio';

  @override
  String get aid_pipelineSub => 'Ace slate · Productions rolling in';

  @override
  String get aid_cameoTitle => 'Cast Yourself';

  @override
  String get aid_cameoSub => 'Upload a photo, write yourself into the show';

  @override
  String get aid_castingBadge => 'Casting';

  @override
  String get aid_producingBadge => 'In Production';

  @override
  String aid_castVoteFmt(String pct) {
    return 'Vote for cast · $pct%';
  }

  @override
  String get aid_manifesto1 => 'You no longer just watch stories.';

  @override
  String get aid_manifesto2 =>
      'You make the hero\'s choices, and the story rewrites the ending.';

  @override
  String get aid_manifesto3 =>
      'Every choice is a conversation between you and this world.';

  @override
  String get aid_manifestoHeader => 'Why we build interactive drama';

  @override
  String get aid_metaversePre =>
      'We call it \"interactive drama\" —\nbut really it\'s ';

  @override
  String get aid_metaverseEmph => 'Act One of the \"Decision Metaverse\"';

  @override
  String get aid_metaversePost =>
      ':\na world where you call the shots, starting here.';

  @override
  String get aid_step1Title => 'Watch';

  @override
  String get aid_step1Sub => 'Sit back, let a story take you in.';

  @override
  String get aid_step2Title => 'Interactive Choice';

  @override
  String get aid_step2Sub =>
      'At each fork, decide for the hero; the story branches.';

  @override
  String get aid_step3Title => 'Cast Yourself';

  @override
  String get aid_step3Sub => 'Put your face and your name into the show.';

  @override
  String get aid_step4Title => 'Vote them to Debut';

  @override
  String get aid_step4Sub =>
      'Back the character you love, push them onto the stage.';

  @override
  String get aid_step5Title => 'Decision Metaverse';

  @override
  String get aid_step5Sub =>
      'The destination: a world where you call the shots.';

  @override
  String get aid_ladderHeader => 'From one choice, to a whole world';

  @override
  String get aid_liveTitle => 'Live · Playable';

  @override
  String get aid_liveSub =>
      'Real interactive drama · Your choices rewrite the story';

  @override
  String get aid_fallbackHook => 'Your choices rewrite her story';

  @override
  String get aid_aceCardBadge => 'Ace Interactive · Playable';

  @override
  String get player_btnLiked => 'Liked';

  @override
  String get player_btnEpisodes => 'Episodes';

  @override
  String get player_btnAiCast => 'AI Cameo';

  @override
  String player_episodeNumFmt(int n) {
    return 'Ep $n';
  }

  @override
  String player_switchEpFmt(int n) {
    return 'Switching to Ep $n (backend pending)';
  }

  @override
  String get player_unlockHint => 'Unlock with Eagle Coins on the show page';

  @override
  String player_comingSoonFmt(String label) {
    return '$label (coming soon)';
  }

  @override
  String get player_sceneSame => 'Same as scene';

  @override
  String get detail_unlockThis => 'This Ep';

  @override
  String get detail_unlockNext5 => 'Next 5 Eps';

  @override
  String get detail_unlockNext10 => 'Next 10 Eps';

  @override
  String get detail_unlockAll => 'Full Series';

  @override
  String detail_episodeCountFmt(int n) {
    return '$n episodes';
  }

  @override
  String get detail_drawerEpisodes => 'Episode Drawer';

  @override
  String get detail_unlockSuccess => 'Unlocked!';

  @override
  String detail_coinBalanceFmt(String coins) {
    return 'Balance: $coins Eagle Coins';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n views';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return 'Unlock for $coins Eagle Coins';
  }

  @override
  String get detail_playNow => 'Play Now';

  @override
  String get detail_playThis => 'Play This Show';

  @override
  String get detail_noEpisodes => 'No episodes available';

  @override
  String get login_welcome => 'Welcome to FalconFlix';

  @override
  String get login_subtitle =>
      'Sign in to unlock dramas · Eagle Coins · interactive shows';

  @override
  String get login_emailLabel => 'Email';

  @override
  String get login_passwordLabel => 'Password';

  @override
  String get login_codeLabel => 'Verification Code';

  @override
  String get login_codeHint => '6-digit code';

  @override
  String get login_pwInputHint => 'Enter password';

  @override
  String get login_modeOtp => 'Email Code';

  @override
  String get login_modePassword => 'Password';

  @override
  String get login_getCode => 'Send Code';

  @override
  String get login_sending => 'Sending';

  @override
  String get login_loggingIn => 'Signing in…';

  @override
  String get login_loginOrRegister => 'Sign In / Up';

  @override
  String get login_pwHint =>
      'First-time password sign-in will auto-register and set this password';

  @override
  String get login_devHint => 'Dev: enter code 749301 to bypass';

  @override
  String get login_quickLogin => 'Quick Sign-in';

  @override
  String get login_recommended => 'Recommended';

  @override
  String get login_success => 'Signed in';

  @override
  String get login_agreement =>
      'By signing in, you agree to the Terms of Service & Privacy Policy';

  @override
  String get login_emailInvalid => 'Please enter a valid email first';

  @override
  String get login_emailRequired => 'Please enter a valid email';

  @override
  String get login_passwordRequired => 'Please enter your password';

  @override
  String get login_codeRequired => 'Please enter the code';

  @override
  String get login_codeSent => 'Code sent. Please check your inbox.';

  @override
  String get login_emailNotConfigured =>
      'Email channel not configured; use test code 749301';

  @override
  String get login_networkError =>
      'Sign-in failed; please check network and retry';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return '$provider sign-in failed: $code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return '$provider sign-in failed; please retry later';
  }

  @override
  String login_oauthComingFmt(String name) {
    return '$name sign-in is coming soon';
  }

  @override
  String get login_oauthComingBody =>
      'Almost ready — please sign in with email code or password for now.';

  @override
  String get login_gotIt => 'Got it';

  @override
  String get login_googleNoToken =>
      'Google did not return an idToken; please check credentials';

  @override
  String get about_tagline => 'FalconFlix · Drama worth seeing';

  @override
  String get about_body =>
      'FalconFlix is a global premium short-drama platform — binge dramas, chat with AI characters, shop as you watch. We pair cinematic production with AI creativity so every frame is worth staying for.';

  @override
  String get about_userAgreement => 'Terms of Service';

  @override
  String get about_privacyPolicy => 'Privacy Policy';

  @override
  String about_legalUpdatedFmt(String date) {
    return 'Last updated: $date';
  }

  @override
  String get about_operatingEntity => 'Operating entity';

  @override
  String about_contactEmailFmt(String email) {
    return 'Contact: $email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return 'About $appName';
  }

  @override
  String get wallet_title => 'Top Up Eagle Coins';

  @override
  String get wallet_chooseRecharge => 'Choose a pack';

  @override
  String get wallet_introNote =>
      'Eagle Coins unlock episodes, interactive plays and support';

  @override
  String get wallet_menuAutoUnlock => 'Auto-unlock Settings';

  @override
  String get wallet_menuHistory => 'Top-up History';

  @override
  String get wallet_menuReceipt => 'Receipt Email';

  @override
  String get wallet_stripeNotice => 'Payments secured by Stripe · USD';

  @override
  String get wallet_loadFailed => 'Failed to load, please retry';

  @override
  String get wallet_packsComing => 'Packs coming soon';

  @override
  String get wallet_packsComingBody =>
      'We\'re preparing the best-value coin bundles for you';

  @override
  String get wallet_coins => 'Eagle Coins';

  @override
  String wallet_giftFmt(String coins) {
    return '+$coins bonus';
  }

  @override
  String get wallet_bestDeal => 'Best Value';

  @override
  String wallet_payNowFmt(String price) {
    return 'Pay $price now';
  }

  @override
  String get wallet_payNow => 'Pay Now';

  @override
  String get wallet_loginFirst => 'Please sign in first';

  @override
  String get wallet_openPayFail => 'Cannot open payment page, please retry';

  @override
  String get wallet_payFail => 'Payment failed, please retry';

  @override
  String get wallet_balanceLabel => 'Eagle Coin Balance';

  @override
  String get wallet_loginToView => 'Sign in to view';

  @override
  String get wallet_legendPeak => 'Legendary Peak · Maxed';

  @override
  String wallet_toLevelFmt(String level) {
    return 'to V$level';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return 'Total paid $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return 'Top up $amount more to V$level';
  }

  @override
  String get wallet_successTitle => 'Top-up Success · Credited';

  @override
  String get wallet_tapAnywhere => 'Tap anywhere to continue';

  @override
  String get wallet_successBarrier => 'Top-up Success';

  @override
  String get creator_title => 'Creator Partner';

  @override
  String get creator_statSeries => 'Series';

  @override
  String get creator_statPlays => 'Plays';

  @override
  String get creator_statShare => 'Share';

  @override
  String get creator_applyLabel => 'Apply as Series Partner';

  @override
  String get creator_applyToast => 'Application submitted (coming soon)';

  @override
  String get creator_menuRequirement => 'Upload Guidelines';

  @override
  String get creator_menuRevenue => 'Revenue Sharing';

  @override
  String get creator_menuLangPriv => 'Languages & Privacy';

  @override
  String get invite_title => 'Invite Friends';

  @override
  String get invite_stepsTitle => 'How it works';

  @override
  String get invite_step1Title => 'Share your code';

  @override
  String get invite_step1Sub => 'Send your invite code to a friend';

  @override
  String get invite_step2Title => 'Friend signs up with it';

  @override
  String get invite_step2Sub => 'They enter your code when registering';

  @override
  String get invite_step3Title => 'Both earn coins';

  @override
  String get invite_step3Sub => 'Once they sign up, you both get Eagle Coins';

  @override
  String get invite_copyMessage => 'Copy invite message';

  @override
  String get invite_loginToGet => 'Sign in to get your code';

  @override
  String get invite_loginToGen => 'Sign in to generate your invite code';

  @override
  String get invite_messageCopied => 'Message copied — paste it to your friend';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 I\'m binging FalconFlix and it\'s amazing! Use my invite code $code when you sign up — we both get Eagle Coins~';
  }

  @override
  String get invite_bigTitle => 'Invite friends, binge together';

  @override
  String get invite_bigSub =>
      'When friends sign up with your code, you both earn Eagle Coins';

  @override
  String get invite_myCode => 'My invite code';

  @override
  String get invite_copyBtn => 'Copy';

  @override
  String invite_codeCopiedFmt(String code) {
    return 'Code copied: $code';
  }

  @override
  String get collect_emptyTitle => 'No saved dramas yet';

  @override
  String get collect_emptyBody =>
      'Tap \'Save\' on any drama and it\'ll appear here for easy access.';

  @override
  String get au_title => 'Auto-unlock';

  @override
  String get au_introTitle => 'Don\'t break the binge';

  @override
  String get au_introBody =>
      'When enabled, the next episode auto-unlocks with Eagle Coins so you keep watching';

  @override
  String get au_toggleLabel => 'Auto-unlock next episode';

  @override
  String get au_on => 'On';

  @override
  String get au_off => 'Off';

  @override
  String get au_toggleOnToast => 'Auto-unlock turned on';

  @override
  String get au_toggleOffToast => 'Auto-unlock turned off';

  @override
  String get au_rule1 =>
      'Locked episodes auto-unlock with coins — no per-episode popup';

  @override
  String get au_rule2 =>
      'If balance is low, you\'ll be prompted to top up — never charged surprise';

  @override
  String get au_rule3 =>
      'Single-episode only; full-series unlock still needs manual confirm';

  @override
  String get rh_title => 'Top-up History';

  @override
  String get rh_loginToView => 'Sign in to view top-up history';

  @override
  String get rh_emptyBody =>
      'No top-ups yet\nTop up Eagle Coins to unlock more dramas';

  @override
  String get rh_fallback => 'Eagle Coin Top-up';

  @override
  String get re_title => 'Receipt Email';

  @override
  String get re_invalidEmail => 'Please enter a valid email address';

  @override
  String get re_saved => 'Receipt email saved';

  @override
  String get re_label => 'Receipt Email';

  @override
  String get re_body =>
      'After a successful top-up, Stripe sends the receipt to this email; the next checkout will pre-fill it.';

  @override
  String re_useAccountEmailFmt(String email) {
    return 'Use sign-in email $email';
  }

  @override
  String get re_save => 'Save';

  @override
  String common_comingSoonFmt(String name) {
    return '$name (coming soon)';
  }

  @override
  String get sheets_episodeTitle => 'Episodes';

  @override
  String get sheets_unlockAllBtn => 'Unlock all';

  @override
  String get sheets_unlockTitle => 'Unlock';

  @override
  String get sheets_unlockChooseCount => 'Choose how many to unlock';

  @override
  String get sheets_unlockFailed => 'Unlock failed. Please try again.';

  @override
  String get sheets_networkErr => 'Network error. Please try again.';

  @override
  String get sheets_walletBalance => 'Coin balance';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins coins';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return '$coins more coins needed — top up to unlock';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return 'Unlock now · $coins coins';
  }

  @override
  String get sheets_coinsNotEnough => 'Not enough coins · Top up';

  @override
  String sheets_tierForeverFmt(String count) {
    return '$count episodes · forever';
  }

  @override
  String get sheets_unlockAllSub => 'Unlock full series';

  @override
  String get sheets_unlockThisSub => 'Unlock this episode';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return 'Unlock all $count episodes · forever';
  }

  @override
  String get sheets_unlockThisForever => 'Unlock this episode · forever';

  @override
  String get sheets_coinsShort => 'coins';

  @override
  String get sheets_vipDiscount => 'VIP price lower';

  @override
  String get sheets_shareTitle => 'Share';

  @override
  String get sheets_shareSub => 'Share this drama';

  @override
  String get sheets_copyLink => 'Copy link';

  @override
  String get sheets_linkCopiedShort => 'Link copied';

  @override
  String get sheets_linkCopiedLong => 'Link copied — paste to your friend';

  @override
  String get sheets_shareTargetMessage => 'Message';

  @override
  String get sheets_shareTargetPoster => 'Poster';

  @override
  String get sheets_shareTargetCommunity => 'Feed';

  @override
  String get sheets_shareTargetRemix => 'Remix';

  @override
  String get sheets_remixComingShort => 'AI remix · coming soon';

  @override
  String get sheets_remixComingFooter => 'AI remix coming soon — stay tuned';

  @override
  String get sheets_fallbackTitle => 'Premium drama on FalconFlix';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title is amazing — come watch on FalconFlix! $url';
  }

  @override
  String get sheets_posterTitle => 'Poster';

  @override
  String get sheets_posterMakeSub => 'Make your signature poster';

  @override
  String get sheets_posterReady => 'Share poster';

  @override
  String get sheets_posterGenerating => 'Generating poster…';

  @override
  String get sheets_posterGenFail => 'Poster generation failed';

  @override
  String get sheets_posterExportFail => 'Poster export failed';

  @override
  String get sheets_posterTagline => 'Scan to watch this drama together';

  @override
  String get ixp_resumeTitle => 'Picked up where you left off';

  @override
  String get ixp_resumeBody =>
      'Continue from your last spot, or start over from the beginning?';

  @override
  String get ixp_resumeFromStart => 'Start over';

  @override
  String get ixp_resumeContinue => 'Continue';

  @override
  String ixp_fetchFailedFmt(String code) {
    return 'Failed to load story ($code)';
  }

  @override
  String get ixp_dataAnomaly => 'Story data invalid (no start node)';

  @override
  String ixp_loadErrorFmt(String msg) {
    return 'Load error: $msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return 'Node \"$id\" not found';
  }

  @override
  String get ixp_nodeJumpTitle => 'Node jump · owner test';

  @override
  String get ixp_nodeJumpBody =>
      'Hidden from regular users. Tap any node to jump straight there (flags stay unchanged).';

  @override
  String ixp_segCountFmt(String n) {
    return '$n segs';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return 'Paid branch ($price coins after launch) · free trial this run';
  }

  @override
  String get ixp_fallbackTitle => 'Interactive drama';

  @override
  String get ixp_btnSkip => 'Skip';

  @override
  String get ixp_btnBack => 'Back';

  @override
  String get ixp_segGenerating => 'This part is still being generated…';

  @override
  String get ixp_btnContinue => 'Continue';

  @override
  String ixp_prepFmt(String done, String total) {
    return 'Preparing $done / $total';
  }

  @override
  String get ixp_prep => 'Preparing…';

  @override
  String get ixp_yourChoice => 'Your turn';

  @override
  String get ixp_endingFallback => 'Ending';

  @override
  String get ixp_btnReplay => 'Replay';

  @override
  String get ixp_endingGood => 'Good ending';

  @override
  String get ixp_endingBad => 'Bad ending';

  @override
  String get ixp_endingHidden => 'Hidden ending';

  @override
  String get ixp_endingOpen => 'Open ending';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n options';
  }

  @override
  String get ip_busyAiCreatingTitle => 'Handing it to AI to craft for you';

  @override
  String get ip_busyAiCreatingSub =>
      'Your custom ending is being generated frame by frame…\nThis usually takes a few minutes — we\'ll notify you. Feel free to explore elsewhere.';

  @override
  String get ip_busyDirectorTitle =>
      'Director\'s back at the monitor · Cast entering for you';

  @override
  String get ip_busyDirectorSub =>
      'Weaving every choice you made, and your face, into an ending only yours';

  @override
  String get ip_busyDoneTitle => '✦ Your custom ending is ready';

  @override
  String get ip_busyDoneSub => 'Saved forever to \"My Custom Endings\"';

  @override
  String ip_titleChipFmt(String n) {
    return 'Interactive · $n endings';
  }

  @override
  String get ip_titleSub => 'Every choice rewrites the ending';

  @override
  String get ip_titleStart => 'Begin story';

  @override
  String get ip_btnContinue => 'Continue';

  @override
  String ip_voteFmt(String n) {
    return '$n% pick this';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return 'Endings unlocked $got / $total';
  }

  @override
  String get ip_btnDex => 'Ending dex';

  @override
  String get ip_btnReplay => 'Try another path';

  @override
  String get ip_dexTitle => 'Ending dex';

  @override
  String get ip_dexLocked => '? ? ?';

  @override
  String ip_errorTitleFmt(String err) {
    return 'Story validation failed\n$err';
  }

  @override
  String get ip_unlockTitleAi => 'Craft an ending just for you';

  @override
  String get ip_unlockTitle => 'Unlock this story branch';

  @override
  String get ip_demoFree => 'Sample drama · free trial';

  @override
  String get ip_unlockBtnAi => 'Start crafting for me';

  @override
  String get ip_unlockBtn => 'Unlock branch';

  @override
  String get ip_unlockCancel => 'Maybe later';

  @override
  String com_sceneSameFmt(String n) {
    return '$n items in this scene';
  }

  @override
  String get com_sameInDrama => 'Same as on screen';

  @override
  String get com_buyNow => 'Buy now';

  @override
  String get com_inStock => 'In stock · free shipping';

  @override
  String get com_outOfStock => 'Out of stock';

  @override
  String get com_infoMerchant => 'Seller';

  @override
  String get com_infoEpisode => 'Linked episode';

  @override
  String get com_infoScene => 'Appears in scene';

  @override
  String com_sceneTimeFmt(String sec) {
    return 'from ${sec}s';
  }

  @override
  String get com_descTitle => 'Description';

  @override
  String get com_descBody =>
      'On-screen product, curated by FalconFlix partners. Shipped by the platform, with 7-day no-questions returns. (Placeholder copy, replaced when a real product is connected.)';

  @override
  String get com_addCart => 'Add to cart';

  @override
  String get com_addCartToast => 'Added to cart (coming soon)';

  @override
  String get com_methodCoin => 'Coin balance';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return 'Bal $n';
  }

  @override
  String get com_methodWechat => 'WeChat Pay';

  @override
  String get com_methodAlipay => 'Alipay';

  @override
  String get com_confirmOrder => 'Review order';

  @override
  String get com_qtyOne => 'Qty 1';

  @override
  String get com_payMethod => 'Payment method';

  @override
  String get com_lineAmount => 'Item amount';

  @override
  String get com_lineCoupon => 'Coupon';

  @override
  String get com_lineCouponUnused => 'Unused';

  @override
  String get com_lineShipping => 'Shipping';

  @override
  String get com_lineShippingFree => 'Free';

  @override
  String get com_total => 'Total';

  @override
  String get com_submitOrder => 'Place order';

  @override
  String get com_submitToast => 'Order placed (payment coming soon)';

  @override
  String get ss_tier66_label => 'Light up';

  @override
  String get ss_tier66_meaning => 'Lucky charm';

  @override
  String get ss_tier188_label => 'Bouquet';

  @override
  String get ss_tier188_meaning => 'Heartfelt';

  @override
  String get ss_tier520_label => 'I love you';

  @override
  String get ss_tier520_meaning => 'Butterflies';

  @override
  String get ss_tier1314_label => 'Forever';

  @override
  String get ss_tier1314_meaning => 'Only you';

  @override
  String get ss_tier3344_label => 'Eternity';

  @override
  String get ss_tier3344_meaning => 'Spoil them';

  @override
  String get ss_tier9999_label => 'Legendary';

  @override
  String get ss_tier9999_meaning => 'Top fan';

  @override
  String ss_callForFmt(String name) {
    return 'Cheer for $name';
  }

  @override
  String get ss_subtitle => 'More coins · faster debut · higher rank';

  @override
  String ss_balanceFmt(String n) {
    return 'My coin balance $n';
  }

  @override
  String get ss_localNote =>
      'Beta · cheers are saved locally; coin settle at official launch';

  @override
  String get ss_celebTitle => 'Cheers sent!';

  @override
  String ss_forFmt(String name, String label) {
    return 'For $name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins coins';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return 'Debut +$delta% · now $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 You\'re TA\'s #1 fan! V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return 'You\'re TA\'s #$rank guardian · V$level $tier';
  }

  @override
  String get ss_tapToContinue => 'Tap anywhere to continue';

  @override
  String get air_title => 'Casting Leaderboard';

  @override
  String get air_sub =>
      'Hit the heat goal to debut · the bigger the cheers, the higher you rank';

  @override
  String get air_segCharRank => 'Characters';

  @override
  String get air_segKingRank => 'Top fans';

  @override
  String get air_chipAll => 'All';

  @override
  String get air_chipFemale => 'Girls';

  @override
  String get air_chipMale => 'Boys';

  @override
  String get air_chipTycoon => 'Tycoon';

  @override
  String get air_chipDeity => 'Deity';

  @override
  String get air_chipLegend => 'Legend';

  @override
  String get air_emptyChar => 'No characters in this category yet';

  @override
  String get air_emptyKing => 'This tier has no holder yet';

  @override
  String get air_debuted => 'Debuted';

  @override
  String get air_leading => 'Leading';

  @override
  String air_heatFmt(String pct) {
    return 'Heat $pct%';
  }

  @override
  String get air_doneShoot => 'Shooting begun';

  @override
  String air_toGoFmt(String n) {
    return '$n% to debut';
  }

  @override
  String air_supportKingFmt(String name) {
    return 'Top fan: $name';
  }

  @override
  String get air_emptyKingPlaceholder => 'Awaiting a champion';

  @override
  String get air_globalKing => 'Global #1 fan';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · backs $name';
  }

  @override
  String air_guardFmt(String name) {
    return 'Guarding $name';
  }

  @override
  String get cd_secVideos => 'TA\'s videos';

  @override
  String get cd_secMoments => 'Deeper moments';

  @override
  String get cd_actUnlock => 'Unlock with coins';

  @override
  String get cd_secCredits => 'TA\'s dramas';

  @override
  String cd_secBoardFmt(String n) {
    return 'Support board · $n backers';
  }

  @override
  String get cd_actImInToo => 'I\'m in too ›';

  @override
  String get cd_swipeHint => 'Scroll for TA · cheer · unlock';

  @override
  String get cd_introBadge => 'TA\'s intro';

  @override
  String get cd_debutProgress => 'Debut campaign';

  @override
  String get cd_debutHint =>
      'Fill up to greenlight · live actors + AI premium interactive drama';

  @override
  String cd_clipToastFmt(String name) {
    return 'Play clip \"$name\" · coming soon';
  }

  @override
  String cd_momentToastFmt(String title) {
    return 'Unlock \"$title\" · coin feature coming soon';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '\"$name\" · enjoy feature coming soon';
  }

  @override
  String get cd_kingBadge => 'Top fan';

  @override
  String get cd_btnSupport => 'Cheer';

  @override
  String get cd_btnChat => 'Chat · unlock';

  @override
  String get sp_toolPosterName => 'Drama poster maker';

  @override
  String get sp_toolPosterDesc =>
      'Upload a face to generate a vertical poster of you in this drama.';

  @override
  String get sp_toolPosterCost => '~5-25 coins';

  @override
  String get sp_toolVideoNameShort => '3s AI clip';

  @override
  String get sp_toolVideoName => '3s AI drama clip';

  @override
  String get sp_toolVideoDesc =>
      'Generate a light vertical clip from a photo or one line.';

  @override
  String get sp_toolVideoCost => '~40 coins';

  @override
  String get sp_toolMakeoverName => 'AI makeover';

  @override
  String get sp_toolMakeoverDesc =>
      'Try ancient, professional, anime, retro, and portrait looks from one photo.';

  @override
  String get sp_toolMakeoverCost => '~25 coins';

  @override
  String get sp_toolAvatarName => 'AI signature avatar';

  @override
  String get sp_toolAvatarDesc =>
      'Generate a personal avatar from your face, ready to update your profile.';

  @override
  String get sp_toolAvatarCost => '~5-25 coins';

  @override
  String get sp_sectionHeader => 'AI playground';

  @override
  String get sp_subtitle =>
      'Lightweight AI playthings tied to your drama watching.';

  @override
  String sp_creatingFmt(String title) {
    return 'Creating for \"$title\"';
  }

  @override
  String get sp_chipLinked => 'Story-linked';

  @override
  String get sp_chipMall => 'Drama mall';

  @override
  String get sp_putInDramaTitle => 'Put yourself in the drama';

  @override
  String get sp_putInDramaBody =>
      'Take or upload a photo to generate a poster or short clip of this drama.';

  @override
  String get sp_btnTryRoleplay => 'Try AI roleplay';

  @override
  String get sp_sceneMallTitle => 'Scene mall';

  @override
  String get sp_sceneMallBody =>
      'Browse on-screen items, scene products, and creator-collab goods.';

  @override
  String get spf_settingsTitle => 'Tool settings';

  @override
  String spf_linkedToFmt(String title) {
    return 'Linked to \"$title\"';
  }

  @override
  String get spf_chooseTool => 'Choose a tool';

  @override
  String spf_genBtnFmt(String cost) {
    return 'Generate · $cost';
  }

  @override
  String get spf_noPhotoBtn => 'Upload a photo first';

  @override
  String get spf_photoReady => 'Photo ready';

  @override
  String get spf_uploadPhoto => 'Upload your photo';

  @override
  String get spf_photoTapToReplace => 'Tap to replace';

  @override
  String get spf_photoHint => 'Front-facing or full body, with a clear face';

  @override
  String get spf_generating => 'AI is generating…';

  @override
  String get spf_generatingSub => 'Placing you into the drama, hang tight';

  @override
  String get spf_genDoneTag => 'Done';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · ready';
  }

  @override
  String get spf_genDoneBody => 'Save to your works, share, or generate again.';

  @override
  String get spf_btnSave => 'Save to my works';

  @override
  String get spf_savedToast => 'Saved (coming soon)';

  @override
  String get spf_shareLabel => 'AI creation';

  @override
  String get cui_chipAI => 'AI interactive';

  @override
  String get cui_chipMetaverse => 'Metaverse lore';

  @override
  String get cui_title => 'Character Metaverse';

  @override
  String get cui_lead =>
      'Here, who you meet isn\'t an actor — it\'s someone who responds to you.';

  @override
  String get cui_body =>
      'Every character has their own personality, voice and story. You can chat with them, cheer them on, push the one who steals your heart onto the stage — from a single line to a premium interactive drama that belongs to both of you.';

  @override
  String get cui_step1Title => 'Meet & DM';

  @override
  String get cui_step1Desc =>
      'Long-press a character to hear them speak, then dive into a 1-on-1 chat. Companionship powered by AI, getting smarter the more you talk.';

  @override
  String get cui_step2Title => 'Cheer & vote';

  @override
  String get cui_step2Desc =>
      'Spend coins to vote for the one you love, climb the support board, become their #1 fan.';

  @override
  String get cui_step3Title => 'Greenlight & debut';

  @override
  String get cui_step3Desc =>
      'When the campaign fills, they officially debut — a premium drama by real actors + AI, lit by you.';

  @override
  String get cui_step4Title => 'Cameo & dive deeper';

  @override
  String get cui_step4Desc =>
      'Unlock private stories and deeper moments with them — even write yourself into the drama.';

  @override
  String get cui_footer =>
      'Every vote you cast rewrites who becomes the next lead.';

  @override
  String get com2_title => 'Community';

  @override
  String get com2_chipPlaza => 'Watch plaza';

  @override
  String get com2_emptyHint => 'No posts yet — be the first to post';

  @override
  String get com2_btnPost => 'New post';

  @override
  String get com2_watching => 'Watching';

  @override
  String get com2_fallbackDrama => 'FalconFlix drama';

  @override
  String get com2_publishedToast => 'Posted to community';

  @override
  String get com2_postHint =>
      'Share how this drama hit you, recommend it to others…';

  @override
  String get com2_publish => 'Publish';

  @override
  String get com2_attachDrama => 'Attach this drama';

  @override
  String get dhc_connected => 'Connected';

  @override
  String get dhc_connecting => 'Connecting';

  @override
  String get dhc_ended => 'Ended';

  @override
  String get dhc_error => 'Error';

  @override
  String get dhc_connectingHint => 'Connecting…please hold';

  @override
  String dhc_talkingFmt(String name) {
    return '$name is talking…';
  }

  @override
  String get dhc_listening => 'Listening to you…';

  @override
  String get dhc_backLabel => 'Back';

  @override
  String get dhc_actorsReady => 'Actors are taking their marks…';

  @override
  String get ss2_searchHint => 'Search dramas / actors / tags';

  @override
  String get ss2_history => 'Recent searches';

  @override
  String get ss2_clear => 'Clear';

  @override
  String get ss2_hot => 'Trending searches';

  @override
  String get ss2_hotBadge => 'Hot';

  @override
  String ss2_noResultFmt(String q) {
    return 'No dramas found for \"$q\"';
  }

  @override
  String ss2_foundFmt(String n) {
    return 'Found $n dramas';
  }

  @override
  String get ss2_chipCEO => 'CEO crush';

  @override
  String get ss2_chipTimeTravel => 'Time travel';

  @override
  String get ss2_chipMystery => 'Mystery';

  @override
  String get ss2_chipModern => 'Modern romance';

  @override
  String get ss2_chipSweetPet => 'Sweet love';

  @override
  String get rk_emptyCat => 'No ranking in this category yet';

  @override
  String get rk_hotTitle => 'Hot rankings';

  @override
  String get rk_hotSub => 'Live order by today\'s heat';

  @override
  String get rk_top1Today => '# 1  hottest today';

  @override
  String rk_heatFmt(String plays) {
    return '$plays heat · still rising';
  }

  @override
  String get rk_chipUrban => 'Urban';

  @override
  String get rk_chipFinished => 'Finished';

  @override
  String get rk_chipRomance => 'Romance';

  @override
  String get aic_lowEnergyNag =>
      'Aww… I\'m a little out of energy, give me some please~';

  @override
  String get aic_chargedReply =>
      'Thank you! Fully recharged, let\'s keep going~';

  @override
  String get aic_chargeToast =>
      'Recharge · coin billing in progress (mocked to full)';

  @override
  String aic_energyFmt(String pct) {
    return 'Energy $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return 'Recharge for $name';
  }

  @override
  String aic_hintFmt(String name) {
    return 'Say something to $name…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · needs V$level';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return 'Top up $amount to reach V$level';
  }

  @override
  String get lg_btnTopUp => 'Top up to upgrade';

  @override
  String get lg_btnLater => 'Maybe later';

  @override
  String get me_defaultName => 'FalconFlix viewer';

  @override
  String get me_avatarUpdated => 'Avatar updated';

  @override
  String get me_avatarUpdateFailed => 'Avatar update failed, try again';

  @override
  String get me_tapAvatarToChange => 'Tap the avatar to change your picture';

  @override
  String get me_myLevel => 'My level';

  @override
  String get me_loginEmail => 'Sign-in email';

  @override
  String get me_membership => 'Membership';

  @override
  String get me_uploading => 'Uploading…';

  @override
  String get me_changeAvatar => 'Change avatar';

  @override
  String me_copiedFmt(String value) {
    return 'Copied: $value';
  }

  @override
  String get tier_commoner => 'Commoner';

  @override
  String get tier_rookie => 'Rookie';

  @override
  String get tier_advanced => 'Advanced';

  @override
  String get tier_lord => 'Lord';

  @override
  String get tier_tycoon => 'Tycoon';

  @override
  String get tier_deity => 'Deity';

  @override
  String get tier_legend => 'Legend';

  @override
  String get rch_statusPaid => 'Settled';

  @override
  String get rch_statusPending => 'Pending';

  @override
  String get rch_statusCanceled => 'Canceled';

  @override
  String get rch_statusProcessing => 'Processing';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n coins';
  }

  @override
  String get time_justNow => 'Just now';

  @override
  String time_minutesAgoFmt(String n) {
    return '${n}m ago';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return '${n}h ago';
  }

  @override
  String time_daysAgoFmt(String n) {
    return '${n}d ago';
  }

  @override
  String get notify_typeRecharge => 'Top-up';

  @override
  String get notify_typeInvite => 'Invite';

  @override
  String get notify_typeSystem => 'System';

  @override
  String get notify_typeActivity => 'Event';

  @override
  String get notify_typeInteractive => 'Interactive';
}
