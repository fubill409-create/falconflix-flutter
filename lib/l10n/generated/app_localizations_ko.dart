// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => '홈';

  @override
  String get tabTheater => '극장';

  @override
  String get tabInteractive => '인터랙티브';

  @override
  String get tabCharacter => '캐릭터';

  @override
  String get tabMe => '마이';

  @override
  String get common_cancel => '취소';

  @override
  String get common_confirm => '확인';

  @override
  String get common_save => '저장';

  @override
  String get common_back => '뒤로';

  @override
  String get common_close => '닫기';

  @override
  String get common_retry => '다시 시도';

  @override
  String get common_loading => '불러오는 중…';

  @override
  String get common_more => '더 보기';

  @override
  String get common_yes => '예';

  @override
  String get common_no => '아니오';

  @override
  String get common_free => '무료';

  @override
  String get common_login => '로그인';

  @override
  String get common_logout => '로그아웃';

  @override
  String get common_loadFailed => '불러오기 실패';

  @override
  String get common_pleaseLogin => '먼저 로그인해 주세요';

  @override
  String get common_done => '완료';

  @override
  String get common_edit => '편집';

  @override
  String get common_delete => '삭제';

  @override
  String get common_send => '보내기';

  @override
  String get me_title => '마이';

  @override
  String get me_loginPrompt => '로그인 / 가입';

  @override
  String get me_loginSubtitle => '로그인하면 라이브러리·지갑·인터랙티브 드라마를 이용할 수 있습니다';

  @override
  String get me_membershipNormal => '일반 회원';

  @override
  String get me_membershipVip => 'VIP';

  @override
  String get me_inviteCode => '초대 코드';

  @override
  String get me_statEagleCoins => 'Eagle 코인';

  @override
  String get me_statBoughtEpisodes => '구매함';

  @override
  String get me_statCollections => '찜';

  @override
  String get me_sectionMyContent => '내 콘텐츠';

  @override
  String get me_sectionWallet => '지갑';

  @override
  String get me_sectionCommunity => '커뮤니티';

  @override
  String get me_sectionCreator => '크리에이터';

  @override
  String get me_sectionSettings => '설정';

  @override
  String get me_sectionHelpAbout => '도움말·앱 정보';

  @override
  String get me_rowCollections => '내 찜';

  @override
  String get me_rowHistory => '시청 기록';

  @override
  String get me_rowCommunity => '커뮤니티 피드';

  @override
  String get me_rowWallet => '지갑·멤버십';

  @override
  String get me_rowOrders => '주문 내역';

  @override
  String get me_rowInvite => '친구 초대';

  @override
  String get me_rowPartner => '크리에이터 파트너';

  @override
  String get me_rowNotifications => '알림';

  @override
  String get me_rowSettings => '설정';

  @override
  String get me_rowHelpAbout => '도움말·앱 정보';

  @override
  String get me_rowAbout => 'FalconFlix 정보';

  @override
  String get me_logoutConfirm => '로그아웃하시겠습니까?';

  @override
  String get history_title => '시청 기록';

  @override
  String get history_emptyTitle => '시청 기록이 없습니다';

  @override
  String get history_emptyBody => '시청한 회차가 여기에 표시됩니다. 마지막으로 본 지점부터 이어 보세요.';

  @override
  String get history_loginBody => '로그인하면 시청 기록을 확인할 수 있습니다.';

  @override
  String get history_actionDelSelected => '선택 삭제';

  @override
  String get history_actionClearAll => '전체 삭제';

  @override
  String get history_episodeFallback => '전체 시리즈';

  @override
  String get history_unknown => '(알 수 없는 작품)';

  @override
  String history_selectedCount(int n) {
    return '$n개 선택됨';
  }

  @override
  String history_delConfirmTitle(int n) {
    return '$n개 기록을 삭제하시겠습니까?';
  }

  @override
  String get history_delConfirmBody =>
      '되돌릴 수 없습니다. 작품 자체에는 영향이 없으며, 다음 재생 시 새 기록이 생성됩니다.';

  @override
  String get history_clearConfirmTitle => '모든 시청 기록을 삭제하시겠습니까?';

  @override
  String get history_clearConfirmBody => '되돌릴 수 없습니다. 다음 재생 시 새 기록이 생성됩니다.';

  @override
  String history_toastDeleted(int n) {
    return '$n개 삭제됨';
  }

  @override
  String get history_toastCleared => '삭제했습니다';

  @override
  String get orders_title => '주문 내역';

  @override
  String get orders_tabFull => '시리즈';

  @override
  String get orders_tabEpisode => '에피소드';

  @override
  String get orders_tabRecharge => '충전 내역';

  @override
  String get orders_emptyFull => '시리즈 주문이 없습니다';

  @override
  String get orders_emptyEpisode => '에피소드 주문이 없습니다';

  @override
  String get orders_emptyBody => '잠금 해제한 드라마가 여기에 표시됩니다.';

  @override
  String get orders_emptyRecharge => '충전 기록이 없습니다';

  @override
  String get orders_emptyRechargeBody => '첫 충전이 완료되면 여기에 표시됩니다.';

  @override
  String get orders_loginBodyOrders => '로그인하면 주문 내역을 확인할 수 있습니다.';

  @override
  String get orders_loginBodyRecharge => '로그인하면 충전 내역을 확인할 수 있습니다.';

  @override
  String get orders_kvAmount => '금액';

  @override
  String get orders_kvPayMethod => '결제 수단';

  @override
  String get orders_kvTime => '시간';

  @override
  String orders_orderCopied(String orderNo) {
    return '주문번호 복사됨 · $orderNo';
  }

  @override
  String get orders_paid => '결제 완료';

  @override
  String get orders_pending => '결제 대기';

  @override
  String get orders_payEagle => 'Eagle 코인';

  @override
  String get orders_unknownTitle => '(알 수 없는 작품)';

  @override
  String get orders_rechargeFallback => 'Eagle 코인 충전';

  @override
  String get inbox_title => '알림';

  @override
  String get inbox_tabAll => '전체';

  @override
  String get inbox_tabRecharge => '충전';

  @override
  String get inbox_tabInvite => '초대';

  @override
  String get inbox_tabSystem => '시스템';

  @override
  String get inbox_tabActivity => '프로모션';

  @override
  String get inbox_tabInteractive => '인터랙티브';

  @override
  String get inbox_emptyTitle => '메시지가 없습니다';

  @override
  String get inbox_emptyBody => '충전 완료·초대 보상·프로모션·시스템 알림이 여기에 표시됩니다.';

  @override
  String get inbox_loginBody => '로그인하면 알림을 확인할 수 있습니다.';

  @override
  String get settings_title => '설정';

  @override
  String get settings_sectionNotificationPlayback => '알림과 재생';

  @override
  String get settings_sectionAccount => '계정';

  @override
  String get settings_sectionUIStorage => '화면과 저장';

  @override
  String get settings_rowNotifyPrefs => '알림 설정';

  @override
  String get settings_rowPlayPrefs => '재생·다운로드';

  @override
  String get settings_rowAccountSecurity => '계정과 보안';

  @override
  String get settings_rowPrivacy => '개인정보';

  @override
  String get settings_rowLanguage => '언어';

  @override
  String get settings_rowClearCache => '캐시 삭제';

  @override
  String get settings_clearCacheTitle => '캐시를 삭제하시겠습니까?';

  @override
  String get settings_clearCacheBody =>
      '다운로드한 인터랙티브 영상과 이미지 캐시를 삭제합니다. 구매·로그인·설정은 영향이 없습니다.';

  @override
  String get settings_clearCacheAction => '지금 삭제';

  @override
  String settings_clearCacheDone(String size) {
    return '$size 삭제 완료';
  }

  @override
  String get notifyPrefs_title => '알림 설정';

  @override
  String get notifyPrefs_pushMaster => '푸시 전체 스위치';

  @override
  String get notifyPrefs_pushMasterDesc => '끄면 모든 푸시가 멈춥니다. 앱 내 메시지는 계속 도착합니다.';

  @override
  String get notifyPrefs_recharge => '충전 완료';

  @override
  String get notifyPrefs_rechargeDesc => '결제 성공·코인 입금';

  @override
  String get notifyPrefs_invite => '초대 보상';

  @override
  String get notifyPrefs_inviteDesc => '초대한 친구 가입·보상 도착';

  @override
  String get notifyPrefs_system => '시스템 공지';

  @override
  String get notifyPrefs_systemDesc => '계정 보안·중요 변경';

  @override
  String get notifyPrefs_activity => '프로모션';

  @override
  String get notifyPrefs_activityDesc => '신작 공개·충전 이벤트';

  @override
  String get notifyPrefs_interactive => '인터랙티브 진행';

  @override
  String get notifyPrefs_interactiveDesc => '시청 중 드라마의 신규 회차·엔딩 해제';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return '저장 실패: $msg';
  }

  @override
  String get playPrefs_title => '재생·다운로드';

  @override
  String get playPrefs_autoplay => '자동 연속 재생';

  @override
  String get playPrefs_autoplayDesc => '한 편이 끝나면 다음 편 자동 재생';

  @override
  String get playPrefs_wifiOnlyAutoplay => 'Wi-Fi에서만 자동 재생';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc => '모바일 데이터에서는 자동 재생하지 않음';

  @override
  String get playPrefs_quality => '기본 화질';

  @override
  String get playPrefs_qualityAuto => '자동 (네트워크에 맞춤)';

  @override
  String get playPrefs_quality480 => 'SD 480p';

  @override
  String get playPrefs_quality720 => 'HD 720p';

  @override
  String get playPrefs_quality1080 => 'FHD 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => 'Wi-Fi에서만 다운로드';

  @override
  String get playPrefs_wifiOnlyDownloadDesc => '인터랙티브·오프라인 캐시는 Wi-Fi에서만';

  @override
  String get accountSec_title => '계정과 보안';

  @override
  String get accountSec_sectionLogin => '로그인';

  @override
  String get accountSec_sectionDeletion => '계정 삭제';

  @override
  String get accountSec_rowChangePwd => '비밀번호 변경';

  @override
  String get accountSec_rowChangePwdDesc => '현재 비밀번호 입력이 필요합니다';

  @override
  String get accountSec_rowDelete => '계정 삭제';

  @override
  String get accountSec_rowDeleteDesc => '7일 유예 기간, 그동안 로그인하면 취소 가능';

  @override
  String get accountSec_oldPwHint => '현재 비밀번호';

  @override
  String get accountSec_newPwHint => '새 비밀번호 (8자 이상)';

  @override
  String get accountSec_confirmPwHint => '새 비밀번호 재입력';

  @override
  String get accountSec_errMinLen => '새 비밀번호는 8자 이상';

  @override
  String get accountSec_errMismatch => '입력이 일치하지 않습니다';

  @override
  String get accountSec_saveNewPw => '새 비밀번호 저장';

  @override
  String get accountSec_saving => '저장 중…';

  @override
  String get accountSec_pwUpdated => '비밀번호가 변경되었습니다';

  @override
  String get privacyPrefs_title => '개인정보';

  @override
  String get privacyPrefs_sectionData => '내 데이터';

  @override
  String get privacyPrefs_sectionLegal => '약관과 정책';

  @override
  String get privacyPrefs_rowExport => '내 데이터 다운로드';

  @override
  String get privacyPrefs_rowExportDesc => 'GDPR / CCPA: 전체 데이터를 묶어 다운로드 신청';

  @override
  String get privacyPrefs_rowPolicy => '개인정보 처리방침';

  @override
  String get deleteAcc_title => '계정 삭제';

  @override
  String get deleteAcc_inProgress => '계정 삭제 신청 중';

  @override
  String deleteAcc_scheduledAt(String time) {
    return '실행 예정: $time';
  }

  @override
  String get deleteAcc_pendingHint => '7일 유예 기간 중 언제든 로그인하면 삭제를 취소할 수 있습니다.';

  @override
  String get deleteAcc_cancelBtn => '삭제 취소, 계정 유지';

  @override
  String get deleteAcc_willDelete => '삭제하면 다음 항목이 사라집니다';

  @override
  String get deleteAcc_bullet1 => '프로필·닉네임·아바타·이메일·전화 연결';

  @override
  String get deleteAcc_bullet2 => '지갑 잔액 (Eagle 코인 환불 불가)·VIP·레벨';

  @override
  String get deleteAcc_bullet3 => '구매한 드라마·인터랙티브 해제 기록';

  @override
  String get deleteAcc_bullet4 => '시청 기록·찜·커뮤니티 글·인터랙티브 저장';

  @override
  String get deleteAcc_bullet5 => '초대 관계 (초대된 측 기록은 남음)';

  @override
  String get deleteAcc_coolingHint =>
      '제출 후 7일 유예가 시작됩니다. 그동안 로그인하면 취소 가능. 만료되면 영구 삭제됩니다.';

  @override
  String get deleteAcc_reasonLabel => '삭제 사유 (선택, 제품 개선에 활용)';

  @override
  String get deleteAcc_reasonHint => '의견을 들려주세요 (선택)';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return '확인을 위해 \"$phrase\"를 입력해 주세요';
  }

  @override
  String get deleteAcc_confirmPhrase => '내 계정 삭제';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return '\"$phrase\"를 정확히 입력해 주세요';
  }

  @override
  String get deleteAcc_submit => '삭제 신청';

  @override
  String get deleteAcc_finalTitle => '최종 확인';

  @override
  String get deleteAcc_finalBody =>
      '제출 후 7일 유예가 시작됩니다. 그동안 로그인하면 취소 가능합니다.\n\n만료되면 데이터가 영구 삭제되며 복구할 수 없습니다.';

  @override
  String get deleteAcc_finalSubmit => '삭제 제출';

  @override
  String get deleteAcc_submitted => '삭제 신청 완료. 7일 뒤 실행됩니다.';

  @override
  String get deleteAcc_cancelled => '삭제 신청을 취소했습니다';

  @override
  String get deleteAcc_thinkAgain => '다시 생각해볼게요';

  @override
  String get dataExport_title => '내 데이터 다운로드';

  @override
  String get dataExport_introTitle => '내 데이터 사본 받기';

  @override
  String get dataExport_introBody =>
      'GDPR Article 15 (EU)·CCPA (캘리포니아)에 따라, 우리가 보유한 귀하의 개인 데이터 전체를 받을 권리가 있습니다.\n\n신청 후 ZIP으로 비동기 생성합니다:\n  · 프로필 / 이메일 / 전화\n  · Eagle 코인 잔액·내역\n  · 주문·시청 기록·찜\n  · 커뮤니티 글·인터랙티브 해제 기록\n\n준비되면 앱 내에서 알려드립니다. 다운로드 링크는 7일간 유효합니다.';

  @override
  String get dataExport_statusQueued => '대기 중 · 큐';

  @override
  String get dataExport_statusProcessing => '처리 중 · 패키징';

  @override
  String get dataExport_statusReady => '준비 완료 · 다운로드 가능';

  @override
  String get dataExport_statusExpired => '만료 · 다시 신청해 주세요';

  @override
  String get dataExport_statusFailed => '생성 실패 · 다시 신청해 주세요';

  @override
  String dataExport_expiresAt(String time) {
    return '링크 유효기간 $time';
  }

  @override
  String get dataExport_downloadBtn => '다운로드';

  @override
  String get dataExport_submitBtn => '다운로드 신청';

  @override
  String get dataExport_submitting => '제출 중…';

  @override
  String get dataExport_submitted => '신청 완료. 준비되면 알려드립니다.';

  @override
  String get helpAbout_title => '도움말·앱 정보';

  @override
  String get helpAbout_sectionHelp => '도움말';

  @override
  String get helpAbout_sectionAbout => '앱 정보';

  @override
  String get helpAbout_rowFaq => '도움말 센터';

  @override
  String get helpAbout_rowFaqDesc => '자주 묻는 질문';

  @override
  String get helpAbout_rowSupport => '고객 지원';

  @override
  String get helpAbout_rowSupportDesc => '1:1 티켓 대화';

  @override
  String get helpAbout_rowFeedback => '피드백';

  @override
  String get helpAbout_rowFeedbackDesc => '제품 의견·버그 신고';

  @override
  String get faq_title => '도움말 센터';

  @override
  String get faq_catAll => '전체';

  @override
  String get faq_catAccount => '계정';

  @override
  String get faq_catRecharge => '충전';

  @override
  String get faq_catPlayback => '재생';

  @override
  String get faq_catInteractive => '인터랙티브';

  @override
  String get faq_catOther => '기타';

  @override
  String get faq_emptyTitle => 'FAQ가 아직 없습니다';

  @override
  String get faq_emptyBody => '문제가 있다면 \"고객 지원\"에서 티켓을 생성해 주세요.';

  @override
  String get tickets_title => '고객 지원';

  @override
  String get tickets_newBtn => '새 티켓';

  @override
  String get tickets_emptyTitle => '티켓이 없습니다';

  @override
  String get tickets_emptyBody => '버튼을 눌러 새 티켓을 생성하세요. 고객 지원이 1:1로 답변합니다.';

  @override
  String get tickets_threadTitle => '티켓 상세';

  @override
  String get tickets_initial => '최초 질문';

  @override
  String get tickets_speakerStaff => '지원';

  @override
  String get tickets_speakerSelf => '나';

  @override
  String get tickets_replyHint => '답장…';

  @override
  String tickets_sendFailed(String msg) {
    return '전송 실패: $msg';
  }

  @override
  String get tickets_statusPending => '대기 중';

  @override
  String get tickets_statusReplied => '답변됨';

  @override
  String get tickets_statusResolved => '해결됨';

  @override
  String get tickets_statusClosed => '종료';

  @override
  String get feedback_titleTicket => '새 티켓';

  @override
  String get feedback_titleFeedback => '피드백';

  @override
  String get feedback_typeBug => '버그 신고';

  @override
  String get feedback_typeSuggestion => '제안';

  @override
  String get feedback_typeComplaint => '불만';

  @override
  String get feedback_typeRecharge => '충전 문제';

  @override
  String get feedback_typeOther => '기타';

  @override
  String get feedback_typeLabel => '문제 유형';

  @override
  String get feedback_contentLabel => '상세 설명';

  @override
  String get feedback_contentHintTicket => '문제를 자세히 적어 주세요…';

  @override
  String get feedback_contentHintFeedback => '의견을 들려주세요…';

  @override
  String get feedback_contactLabel => '회신 이메일·전화 (선택)';

  @override
  String get feedback_contactHint => '기입 시 우선 응대합니다. 선택 사항.';

  @override
  String get feedback_submit => '제출';

  @override
  String get feedback_submitting => '제출 중…';

  @override
  String get feedback_submitted => '제출되었습니다. 지원이 답변드립니다.';

  @override
  String get feedback_minLength => '5자 이상 입력해 주세요';

  @override
  String feedback_tip(String version) {
    return '팁: 버그 신고 시 재현 단계와 스크린샷(곧 지원)을 함께 보내면 빠르게 해결됩니다.\n버전: $version';
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
  String get home_noDramaData => '아직 드라마가 없어요';

  @override
  String get home_localOnlyLike => '로컬 영상은 좋아요 미지원';

  @override
  String get home_localOnlyCollect => '로컬 영상은 저장 미지원';

  @override
  String get home_addedToMy => '「마이」에 저장됨';

  @override
  String get home_actionLike => '좋아요';

  @override
  String get home_actionCollected => '저장됨';

  @override
  String get home_actionCollect => '저장';

  @override
  String get home_actionShare => '공유';

  @override
  String get home_shopComingSoon => '작품 속 동일 상품 · AI 인식 (스토어 준비 중)';

  @override
  String get home_chipAiTheater => 'AI 시어터';

  @override
  String get home_bannerPremiere => 'AI 드라마 첫 공개';

  @override
  String get home_btnWatch => '보기';

  @override
  String get home_btnDetails => '상세';

  @override
  String home_loadFailedFmt(String message) {
    return '불러오기 실패\n$message';
  }

  @override
  String get theater_genreAll => '전체';

  @override
  String get theater_genreRomance => '로맨스';

  @override
  String get theater_genreUrban => '도시';

  @override
  String get theater_genreInteractive => '인터랙티브';

  @override
  String get theater_genreFinished => '완결';

  @override
  String get theater_sectionHot => '인기 상영작';

  @override
  String get theater_seeAll => '전체 보기';

  @override
  String get theater_sectionAll => '전체 드라마';

  @override
  String get theater_ranking => '인기 차트';

  @override
  String get theater_today => '오늘의 추천';

  @override
  String get theater_labelShort => '숏드라마';

  @override
  String theater_continueWatch(String name) {
    return '이어보기 · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '시청 $heat';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · 시청 $heat';
  }

  @override
  String get cast_sectionPlaying => '방영 중 & 캐스팅';

  @override
  String get cast_oppRanking => '캐스팅 기회 ›';

  @override
  String get cast_universeTitle => '캐릭터 메타버스';

  @override
  String get cast_universeSub => '응답하는 사람들을 만나보세요 · 세계를 탐험';

  @override
  String get cast_demoBadge => '데모 · 플레이 가능';

  @override
  String get cast_demoTitle => '데모 인터랙티브 드라마';

  @override
  String get cast_demoSub => '당신의 선택 — 한 대사가 한 편을 깨운다';

  @override
  String get cast_inPlay => '방영 중';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '시청 $heat · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '시청 $heat';
  }

  @override
  String get cb_sectionSupport => '응원 랭킹 · 누가 응원하나';

  @override
  String get cb_goSupport => '응원하기 · 데뷔로 보내기';

  @override
  String get cb_seeBio => '프로필 보기 ›';

  @override
  String cb_pollHeatPct(String pct) {
    return '응원 $pct%';
  }

  @override
  String get cb_debuted => '촬영 시작';

  @override
  String cb_toDebutPct(String pct) {
    return '시작까지 $pct%';
  }

  @override
  String get cb_totalSupport => '누적 응원';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins 이글 코인';
  }

  @override
  String get cb_topBacker => '최고 후원자';

  @override
  String get cb_emptyBackers => '아직 응원이 없어요 · 첫 후원자가 되세요';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · 응원 랭킹';
  }

  @override
  String get aid_titleHeader => 'AI 인터랙티브 드라마';

  @override
  String get aid_aceBadge => '에이스';

  @override
  String get aid_tagline => '당신의 선택이 결말을 바꾼다.';

  @override
  String get aid_demoBadge => '데모 · 무료 체험';

  @override
  String get aid_lastcallSub => '5 단계 선택 · 7 가지 결말 · 당신의 선택이 이야기를 바꾼다';

  @override
  String get aid_pipelineTitle => '스타 라인업';

  @override
  String get aid_pipelineSub => '에이스 라인업 · 속속 제작 시작';

  @override
  String get aid_cameoTitle => '직접 출연';

  @override
  String get aid_cameoSub => '사진 한 장으로 당신을 작품 속에 넣어보세요';

  @override
  String get aid_castingBadge => '캐스팅 중';

  @override
  String get aid_producingBadge => '제작 중';

  @override
  String aid_castVoteFmt(String pct) {
    return '캐스팅 투표 · $pct%';
  }

  @override
  String get aid_manifesto1 => '당신은 더 이상 단순히 보는 시청자가 아닙니다.';

  @override
  String get aid_manifesto2 => '주인공을 대신해 선택하고, 이야기는 당신의 결말을 씁니다.';

  @override
  String get aid_manifesto3 => '선택 하나하나가 이 세계와의 대화입니다.';

  @override
  String get aid_manifestoHeader => '왜 인터랙티브 드라마를 만드나';

  @override
  String get aid_metaversePre => '우리는 이것을 「인터랙티브 드라마」라 부르지만\n사실은 ';

  @override
  String get aid_metaverseEmph => '「의사결정 메타버스」의 제1막';

  @override
  String get aid_metaversePost => ':\n당신이 결정하는 세계가 여기서 시작됩니다.';

  @override
  String get aid_step1Title => '감상';

  @override
  String get aid_step1Sub => '앉아서 이야기에 사로잡히세요.';

  @override
  String get aid_step2Title => '인터랙티브 선택';

  @override
  String get aid_step2Sub => '분기점에서 주인공을 대신해 결정하면 이야기가 갈라집니다.';

  @override
  String get aid_step3Title => '직접 출연';

  @override
  String get aid_step3Sub => '당신의 얼굴과 이름을 작품에 새기세요.';

  @override
  String get aid_step4Title => '응원으로 데뷔';

  @override
  String get aid_step4Sub => '마음에 드는 캐릭터를 응원해 무대로 올리세요.';

  @override
  String get aid_step5Title => '의사결정 메타버스';

  @override
  String get aid_step5Sub => '종착점은 당신이 결정하는 세계입니다.';

  @override
  String get aid_ladderHeader => '하나의 선택에서 하나의 세계로';

  @override
  String get aid_liveTitle => '방영 중 · 플레이 가능';

  @override
  String get aid_liveSub => '진짜 인터랙티브 드라마 · 당신의 선택이 이야기를 바꾼다';

  @override
  String get aid_fallbackHook => '당신의 선택이 그녀의 이야기를 바꾼다';

  @override
  String get aid_aceCardBadge => '에이스 인터랙티브 · 플레이 가능';

  @override
  String get player_btnLiked => '좋아요 함';

  @override
  String get player_btnEpisodes => '에피소드';

  @override
  String get player_btnAiCast => 'AI 카메오';

  @override
  String player_episodeNumFmt(int n) {
    return '$n 화';
  }

  @override
  String player_switchEpFmt(int n) {
    return '$n 화로 전환 중 (백엔드 대응 중)';
  }

  @override
  String get player_unlockHint => '작품 상세 페이지에서 이글 코인으로 해제하세요';

  @override
  String player_comingSoonFmt(String label) {
    return '$label (개발 중)';
  }

  @override
  String get player_sceneSame => '작품 속 동일 아이템';

  @override
  String get detail_unlockThis => '이 화';

  @override
  String get detail_unlockNext5 => '다음 5 화';

  @override
  String get detail_unlockNext10 => '다음 10 화';

  @override
  String get detail_unlockAll => '전편';

  @override
  String detail_episodeCountFmt(int n) {
    return '총 $n 화';
  }

  @override
  String get detail_drawerEpisodes => '에피소드 목록';

  @override
  String get detail_unlockSuccess => '잠금 해제!';

  @override
  String detail_coinBalanceFmt(String coins) {
    return '잔액 $coins 이글 코인';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n 회 시청';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return '$coins 이글 코인으로 해제';
  }

  @override
  String get detail_playNow => '지금 재생';

  @override
  String get detail_playThis => '이 작품 재생';

  @override
  String get detail_noEpisodes => '재생 가능한 에피소드가 없습니다';

  @override
  String get login_welcome => 'FalconFlix에 오신 것을 환영합니다';

  @override
  String get login_subtitle => '로그인하면 드라마, 이글 코인, 인터랙티브 콘텐츠 해제';

  @override
  String get login_emailLabel => '이메일';

  @override
  String get login_passwordLabel => '비밀번호';

  @override
  String get login_codeLabel => '인증번호';

  @override
  String get login_codeHint => '6 자리 인증번호';

  @override
  String get login_pwInputHint => '비밀번호 입력';

  @override
  String get login_modeOtp => '인증번호 로그인';

  @override
  String get login_modePassword => '비밀번호 로그인';

  @override
  String get login_getCode => '인증번호 받기';

  @override
  String get login_sending => '전송 중';

  @override
  String get login_loggingIn => '로그인 중…';

  @override
  String get login_loginOrRegister => '로그인 / 가입';

  @override
  String get login_pwHint => '최초 비밀번호 로그인 시 자동 가입되어 해당 비밀번호로 설정됩니다';


  @override
  String get login_quickLogin => '간편 로그인';

  @override
  String get login_recommended => '추천';

  @override
  String get login_success => '로그인 성공';

  @override
  String get login_agreement => '로그인은 이용약관과 개인정보처리방침 동의를 의미합니다';

  @override
  String get login_emailInvalid => '올바른 이메일을 먼저 입력하세요';

  @override
  String get login_emailRequired => '올바른 이메일을 입력하세요';

  @override
  String get login_passwordRequired => '비밀번호를 입력하세요';

  @override
  String get login_codeRequired => '인증번호를 입력하세요';

  @override
  String get login_codeSent => '인증번호를 보냈습니다. 메일을 확인해주세요.';

  @override
  String get login_emailNotConfigured => '이메일 발송이 일시적으로 불가합니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get login_networkError => '로그인 실패. 네트워크 확인 후 다시 시도하세요';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return '$provider 로그인 실패: $code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return '$provider 로그인 실패. 잠시 후 다시 시도하세요';
  }

  @override
  String login_oauthComingFmt(String name) {
    return '$name 로그인 준비 중';
  }

  @override
  String get login_oauthComingBody => '곧 지원됩니다~ 지금은 이메일 인증번호나 비밀번호로 로그인하세요.';

  @override
  String get login_gotIt => '알겠습니다';

  @override
  String get login_googleNoToken => 'Google이 idToken을 반환하지 않습니다. 자격 증명을 확인하세요';

  @override
  String get about_tagline => 'FalconFlix · 볼 만한 드라마';

  @override
  String get about_body =>
      'FalconFlix는 글로벌 프리미엄 숏드라마 플랫폼입니다. 드라마를 정주행하고, AI 캐릭터와 대화하고, 보면서 쇼핑하세요. 시네마틱한 제작과 AI 창의력으로 매 프레임을 가치 있게.';

  @override
  String get about_userAgreement => '이용약관';

  @override
  String get about_privacyPolicy => '개인정보처리방침';

  @override
  String about_legalUpdatedFmt(String date) {
    return '최근 업데이트: $date';
  }

  @override
  String get about_operatingEntity => '운영 주체';

  @override
  String about_contactEmailFmt(String email) {
    return '연락처: $email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return '$appName 소개';
  }

  @override
  String get wallet_title => '이글 코인 충전';

  @override
  String get wallet_chooseRecharge => '패키지 선택';

  @override
  String get wallet_introNote => '이글 코인으로 에피소드, 인터랙티브, 응원 잠금 해제';

  @override
  String get wallet_menuAutoUnlock => '자동 해제 설정';

  @override
  String get wallet_menuHistory => '충전 내역';

  @override
  String get wallet_menuReceipt => '영수증 이메일';

  @override
  String get wallet_stripeNotice => '결제는 Stripe 안전 처리 · USD';

  @override
  String get wallet_loadFailed => '불러오기 실패, 다시 시도하세요';

  @override
  String get wallet_packsComing => '패키지 준비 중';

  @override
  String get wallet_packsComingBody => '가장 알찬 코인 묶음을 준비 중입니다';

  @override
  String get wallet_coins => '이글 코인';

  @override
  String wallet_giftFmt(String coins) {
    return '+$coins 보너스';
  }

  @override
  String get wallet_bestDeal => '최고의 가성비';

  @override
  String wallet_payNowFmt(String price) {
    return '지금 $price 결제';
  }

  @override
  String get wallet_payNow => '지금 결제';

  @override
  String get wallet_loginFirst => '먼저 로그인하세요';

  @override
  String get wallet_openPayFail => '결제 페이지를 열 수 없습니다. 다시 시도하세요';

  @override
  String get wallet_payFail => '결제 실패, 다시 시도하세요';

  @override
  String get wallet_balanceLabel => '이글 코인 잔액';

  @override
  String get wallet_loginToView => '로그인하여 보기';

  @override
  String get wallet_legendPeak => '전설의 정점 · 최대치';

  @override
  String wallet_toLevelFmt(String level) {
    return 'V$level까지';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return '누적 충전 $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return '$amount 더 충전하면 V$level';
  }

  @override
  String get wallet_successTitle => '충전 성공 · 입금 완료';

  @override
  String get wallet_tapAnywhere => '아무 곳이나 탭하여 계속';

  @override
  String get wallet_successBarrier => '충전 성공';

  @override
  String get creator_title => '파트너 센터';

  @override
  String get creator_statSeries => '편';

  @override
  String get creator_statPlays => '재생';

  @override
  String get creator_statShare => '수익 배분';

  @override
  String get creator_applyLabel => '시리즈 파트너 신청';

  @override
  String get creator_applyToast => '신청 접수됨 (개발 중)';

  @override
  String get creator_menuRequirement => '업로드 요건';

  @override
  String get creator_menuRevenue => '수익 배분 규정';

  @override
  String get creator_menuLangPriv => '언어 및 개인정보';

  @override
  String get invite_title => '친구 초대';

  @override
  String get invite_stepsTitle => '초대 방법';

  @override
  String get invite_step1Title => '초대 코드 공유';

  @override
  String get invite_step1Sub => '당신의 전용 초대 코드를 친구에게 보내세요';

  @override
  String get invite_step2Title => '친구가 코드 입력';

  @override
  String get invite_step2Sub => '친구가 가입 시 당신의 코드를 입력';

  @override
  String get invite_step3Title => '양쪽 모두 코인 획득';

  @override
  String get invite_step3Sub => '가입 성공 후 양쪽 모두 이글 코인 지급';

  @override
  String get invite_copyMessage => '초대 메시지 복사';

  @override
  String get invite_loginToGet => '로그인하여 코드 받기';

  @override
  String get invite_loginToGen => '로그인해야 초대 코드를 생성할 수 있어요';

  @override
  String get invite_messageCopied => '메시지가 복사되었습니다. 친구에게 붙여넣기하세요';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 FalconFlix에서 숏드라마 보는데 너무 재밌어! 가입할 때 내 초대 코드 $code 입력하면 둘 다 이글 코인 받아~';
  }

  @override
  String get invite_bigTitle => '친구를 초대해 함께 보세요';

  @override
  String get invite_bigSub => '친구가 당신의 코드로 가입하면 양쪽 모두 코인 획득';

  @override
  String get invite_myCode => '내 전용 초대 코드';

  @override
  String get invite_copyBtn => '복사';

  @override
  String invite_codeCopiedFmt(String code) {
    return '코드 복사됨: $code';
  }

  @override
  String get collect_emptyTitle => '저장한 작품이 없어요';

  @override
  String get collect_emptyBody => '작품에서 \'저장\'을 누르면 여기에 표시됩니다.';

  @override
  String get au_title => '자동 해제';

  @override
  String get au_introTitle => '정주행 끊기지 않게';

  @override
  String get au_introBody => '켜두면 다음 화를 자동으로 코인 해제해 끊김 없이 시청합니다';

  @override
  String get au_toggleLabel => '다음 화 자동 해제';

  @override
  String get au_on => '켜짐';

  @override
  String get au_off => '꺼짐';

  @override
  String get au_toggleOnToast => '자동 해제가 켜졌습니다';

  @override
  String get au_toggleOffToast => '자동 해제가 꺼졌습니다';

  @override
  String get au_rule1 => '잠긴 화는 팝업 없이 코인으로 바로 해제';

  @override
  String get au_rule2 => '잔액 부족 시 충전을 알리며, 무단 차감 없음';

  @override
  String get au_rule3 => '단편 해제에만 적용; 전체 해제는 수동 확인 필요';

  @override
  String get rh_title => '충전 내역';

  @override
  String get rh_loginToView => '로그인하여 충전 내역 보기';

  @override
  String get rh_emptyBody => '충전 내역이 없어요\n충전하여 더 많은 작품 해제';

  @override
  String get rh_fallback => '이글 코인 충전';

  @override
  String get re_title => '영수증 이메일';

  @override
  String get re_invalidEmail => '유효한 이메일을 입력하세요';

  @override
  String get re_saved => '영수증 이메일 저장됨';

  @override
  String get re_label => '영수증 이메일';

  @override
  String get re_body => '충전 성공 시 Stripe가 이 이메일로 영수증을 보내며 다음 결제 시 자동 입력됩니다.';

  @override
  String re_useAccountEmailFmt(String email) {
    return '로그인 이메일 $email 사용';
  }

  @override
  String get re_save => '저장';

  @override
  String common_comingSoonFmt(String name) {
    return '$name (개발 중)';
  }

  @override
  String get sheets_episodeTitle => '에피소드';

  @override
  String get sheets_unlockAllBtn => '전체 잠금 해제';

  @override
  String get sheets_unlockTitle => '잠금 해제';

  @override
  String get sheets_unlockChooseCount => '해제할 회수 선택';

  @override
  String get sheets_unlockFailed => '잠금 해제 실패. 다시 시도해 주세요.';

  @override
  String get sheets_networkErr => '네트워크 오류. 다시 시도해 주세요.';

  @override
  String get sheets_walletBalance => '코인 잔액';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins 코인';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return '$coins 코인 부족 — 충전 후 해제';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return '지금 해제 · $coins 코인';
  }

  @override
  String get sheets_coinsNotEnough => '코인 부족 · 충전하기';

  @override
  String sheets_tierForeverFmt(String count) {
    return '$count회 · 영구 시청';
  }

  @override
  String get sheets_unlockAllSub => '전체 회차 해제';

  @override
  String get sheets_unlockThisSub => '이 회차 해제';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return '전체 $count회 해제 · 영구 시청';
  }

  @override
  String get sheets_unlockThisForever => '이 회차 해제 · 영구 시청';

  @override
  String get sheets_coinsShort => '코인';

  @override
  String get sheets_vipDiscount => 'VIP 가격 더 저렴';

  @override
  String get sheets_shareTitle => '공유';

  @override
  String get sheets_shareSub => '이 드라마 공유하기';

  @override
  String get sheets_copyLink => '링크 복사';

  @override
  String get sheets_linkCopiedShort => '링크 복사됨';

  @override
  String get sheets_linkCopiedLong => '링크 복사됨 — 친구에게 붙여넣기';

  @override
  String get sheets_shareTargetMessage => '메시지';

  @override
  String get sheets_shareTargetPoster => '포스터';

  @override
  String get sheets_shareTargetCommunity => '피드';

  @override
  String get sheets_shareTargetRemix => '리믹스';

  @override
  String get sheets_remixComingShort => 'AI 리믹스 · 출시 예정';

  @override
  String get sheets_remixComingFooter => 'AI 리믹스 출시 예정 · 기대해 주세요';

  @override
  String get sheets_fallbackTitle => 'FalconFlix 인기 드라마';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title 정말 재밌어요! FalconFlix에서 함께 봐요! $url';
  }

  @override
  String get sheets_posterTitle => '포스터';

  @override
  String get sheets_posterMakeSub => '전용 포스터 만들기';

  @override
  String get sheets_posterReady => '포스터 공유';

  @override
  String get sheets_posterGenerating => '포스터 생성 중…';

  @override
  String get sheets_posterGenFail => '포스터 생성 실패';

  @override
  String get sheets_posterExportFail => '포스터 내보내기 실패';

  @override
  String get sheets_posterTagline => '스캔하여 함께 시청하기';

  @override
  String get ixp_resumeTitle => '이어서 보기';

  @override
  String get ixp_resumeBody => '지난번 위치에서 이어 볼까요, 처음부터 다시 볼까요?';

  @override
  String get ixp_resumeFromStart => '처음부터';

  @override
  String get ixp_resumeContinue => '이어서';

  @override
  String ixp_fetchFailedFmt(String code) {
    return '스토리 로드 실패 ($code)';
  }

  @override
  String get ixp_dataAnomaly => '스토리 데이터 오류 (시작 노드 없음)';

  @override
  String ixp_loadErrorFmt(String msg) {
    return '로드 오류: $msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return '노드 「$id」을 찾을 수 없음';
  }

  @override
  String get ixp_nodeJumpTitle => '노드 이동 · 오너 테스트';

  @override
  String get ixp_nodeJumpBody => '일반 사용자에게 표시되지 않음. 노드를 탭하여 직접 이동 (플래그 변경 없음).';

  @override
  String ixp_segCountFmt(String n) {
    return '$n개';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return '유료 분기 (출시 후 $price 코인) · 이번 회차 무료 체험';
  }

  @override
  String get ixp_fallbackTitle => '인터랙티브 드라마';

  @override
  String get ixp_btnSkip => '건너뛰기';

  @override
  String get ixp_btnBack => '뒤로';

  @override
  String get ixp_segGenerating => '이 부분은 생성 중…';

  @override
  String get ixp_btnContinue => '계속';

  @override
  String ixp_prepFmt(String done, String total) {
    return '준비 중 $done / $total';
  }

  @override
  String get ixp_prep => '준비 중…';

  @override
  String get ixp_yourChoice => '당신의 차례';

  @override
  String get ixp_endingFallback => '엔딩';

  @override
  String get ixp_btnReplay => '다시 보기';

  @override
  String get ixp_endingGood => '굿엔딩';

  @override
  String get ixp_endingBad => '배드엔딩';

  @override
  String get ixp_endingHidden => '히든엔딩';

  @override
  String get ixp_endingOpen => '오픈엔딩';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n개 선택지';
  }

  @override
  String get ip_busyAiCreatingTitle => 'AI에게 창작을 맡겼어요';

  @override
  String get ip_busyAiCreatingSub =>
      '당신만의 엔딩이 한 프레임씩 생성 중…\n보통 몇 분 걸려요, 완료되면 알려드릴게요 — 다른 곳도 둘러보세요';

  @override
  String get ip_busyDirectorTitle => '감독이 모니터에 다시 앉음 · 배우들이 입장';

  @override
  String get ip_busyDirectorSub => '당신이 한 모든 선택과 당신의 얼굴을, 오직 당신만의 결말로 엮고 있어요';

  @override
  String get ip_busyDoneTitle => '✦ 당신만의 엔딩 완성';

  @override
  String get ip_busyDoneSub => '「내 전용 엔딩」에 영구 저장됨';

  @override
  String ip_titleChipFmt(String n) {
    return '인터랙티브 · $n가지 엔딩';
  }

  @override
  String get ip_titleSub => '당신의 모든 선택이 결말을 바꿉니다';

  @override
  String get ip_titleStart => '이야기 시작';

  @override
  String get ip_btnContinue => '계속';

  @override
  String ip_voteFmt(String n) {
    return '$n% 가 이 선택';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return '잠금 해제 엔딩 $got / $total';
  }

  @override
  String get ip_btnDex => '엔딩 도감';

  @override
  String get ip_btnReplay => '다른 선택으로 다시';

  @override
  String get ip_dexTitle => '엔딩 도감';

  @override
  String get ip_dexLocked => '？？？';

  @override
  String ip_errorTitleFmt(String err) {
    return '스토리 검증 실패\n$err';
  }

  @override
  String get ip_unlockTitleAi => '당신만의 엔딩 맞춤 제작';

  @override
  String get ip_unlockTitle => '이 스토리 분기 잠금 해제';

  @override
  String get ip_demoFree => '샘플 드라마 · 무료 체험';

  @override
  String get ip_unlockBtnAi => '맞춤 제작 시작';

  @override
  String get ip_unlockBtn => '분기 잠금 해제';

  @override
  String get ip_unlockCancel => '나중에';

  @override
  String com_sceneSameFmt(String n) {
    return '이 장면에 $n개';
  }

  @override
  String get com_sameInDrama => '드라마 속 아이템';

  @override
  String get com_buyNow => '지금 구매';

  @override
  String get com_inStock => '재고 있음 · 무료배송';

  @override
  String get com_outOfStock => '품절';

  @override
  String get com_infoMerchant => '판매자';

  @override
  String get com_infoEpisode => '관련 에피소드';

  @override
  String get com_infoScene => '등장 장면';

  @override
  String com_sceneTimeFmt(String sec) {
    return '${sec}s 부터';
  }

  @override
  String get com_descTitle => '상품 설명';

  @override
  String get com_descBody =>
      '드라마 속 엄선 아이템, FalconFlix 파트너 제공. 플랫폼 발송 및 7일 무조건 반품 가능. (샘플 문구, 실제 상품 연결 후 교체)';

  @override
  String get com_addCart => '장바구니 추가';

  @override
  String get com_addCartToast => '장바구니에 추가됨 (개발 중)';

  @override
  String get com_methodCoin => '코인 잔액';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return '잔 $n';
  }

  @override
  String get com_methodWechat => 'WeChat Pay';

  @override
  String get com_methodAlipay => 'Alipay';

  @override
  String get com_confirmOrder => '주문 확인';

  @override
  String get com_qtyOne => '수량 1';

  @override
  String get com_payMethod => '결제 수단';

  @override
  String get com_lineAmount => '상품 금액';

  @override
  String get com_lineCoupon => '쿠폰';

  @override
  String get com_lineCouponUnused => '사용 안 함';

  @override
  String get com_lineShipping => '배송비';

  @override
  String get com_lineShippingFree => '무료';

  @override
  String get com_total => '합계';

  @override
  String get com_submitOrder => '주문하기';

  @override
  String get com_submitToast => '주문 완료 (결제 기능 개발 중)';

  @override
  String get ss_tier66_label => '라이트업';

  @override
  String get ss_tier66_meaning => '행운의 66';

  @override
  String get ss_tier188_label => '꽃다발 선물';

  @override
  String get ss_tier188_meaning => '진심 가득';

  @override
  String get ss_tier520_label => '사랑해 TA';

  @override
  String get ss_tier520_meaning => '심쿵';

  @override
  String get ss_tier1314_label => '영원히';

  @override
  String get ss_tier1314_meaning => '오직 너';

  @override
  String get ss_tier3344_label => '영원토록';

  @override
  String get ss_tier3344_meaning => '끝까지 추앙';

  @override
  String get ss_tier9999_label => '전설의 응원';

  @override
  String get ss_tier9999_meaning => '당신이 1위';

  @override
  String ss_callForFmt(String name) {
    return '$name에게 응원';
  }

  @override
  String get ss_subtitle => '코인이 많을수록 · 데뷔가 빨라지고 · 순위가 높아져요';

  @override
  String ss_balanceFmt(String n) {
    return '내 코인 잔액 $n';
  }

  @override
  String get ss_localNote => '베타 · 응원은 로컬 저장, 정식 출시 후 코인 결제';

  @override
  String get ss_celebTitle => '응원 완료!';

  @override
  String ss_forFmt(String name, String label) {
    return '$name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins 코인';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return '데뷔 +$delta% · 현재 $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 당신이 TA의 1위 팬! V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return '당신은 TA의 $rank번째 가디언 · V$level $tier';
  }

  @override
  String get ss_tapToContinue => '탭하여 계속';

  @override
  String get air_title => '캐스팅 랭킹';

  @override
  String get air_sub => '열기 채우면 데뷔 · 응원이 클수록 순위 상승';

  @override
  String get air_segCharRank => '캐릭터';

  @override
  String get air_segKingRank => '톱 팬';

  @override
  String get air_chipAll => '전체';

  @override
  String get air_chipFemale => '여자';

  @override
  String get air_chipMale => '남자';

  @override
  String get air_chipTycoon => '거물';

  @override
  String get air_chipDeity => '신급';

  @override
  String get air_chipLegend => '전설';

  @override
  String get air_emptyChar => '이 카테고리에 캐릭터가 없습니다';

  @override
  String get air_emptyKing => '이 등급은 아직 빈자리';

  @override
  String get air_debuted => '데뷔 완료';

  @override
  String get air_leading => '선두';

  @override
  String air_heatFmt(String pct) {
    return '응원 열기 $pct%';
  }

  @override
  String get air_doneShoot => '촬영 시작';

  @override
  String air_toGoFmt(String n) {
    return '데뷔까지 $n%';
  }

  @override
  String air_supportKingFmt(String name) {
    return '톱 팬: $name';
  }

  @override
  String get air_emptyKingPlaceholder => '챔피언 모집 중';

  @override
  String get air_globalKing => '전체 톱 팬';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · $name 응원';
  }

  @override
  String air_guardFmt(String name) {
    return '$name 수호';
  }

  @override
  String get cd_secVideos => 'TA의 영상';

  @override
  String get cd_secMoments => '더 깊은 순간';

  @override
  String get cd_actUnlock => '코인으로 잠금 해제';

  @override
  String get cd_secCredits => 'TA의 출연작';

  @override
  String cd_secBoardFmt(String n) {
    return '응원 보드 · $n명 지지자';
  }

  @override
  String get cd_actImInToo => '나도 함께 ›';

  @override
  String get cd_swipeHint => '아래로 스와이프 · 응원 · 잠금 해제';

  @override
  String get cd_introBadge => 'TA의 자기소개';

  @override
  String get cd_debutProgress => '데뷔 응원 진행';

  @override
  String get cd_debutHint => '가득 차면 촬영 시작 · 실사+AI 프리미엄 인터랙티브 드라마';

  @override
  String cd_clipToastFmt(String name) {
    return '클립 「$name」 재생 · 개발 중';
  }

  @override
  String cd_momentToastFmt(String title) {
    return '「$title」 잠금 해제 · 코인 기능 개발 중';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '「$name」· 감상 기능 개발 중';
  }

  @override
  String get cd_kingBadge => '작품 톱 팬';

  @override
  String get cd_btnSupport => '응원';

  @override
  String get cd_btnChat => '채팅 · 잠금 해제';

  @override
  String get sp_toolPosterName => '드라마 포스터 생성';

  @override
  String get sp_toolPosterDesc => '얼굴 사진을 올려 이 드라마 속 세로 포스터를 만들어요.';

  @override
  String get sp_toolPosterCost => '약 5-25 코인';

  @override
  String get sp_toolVideoNameShort => '3초 AI 클립';

  @override
  String get sp_toolVideoName => '3초 AI 드라마 클립';

  @override
  String get sp_toolVideoDesc => '사진이나 한 줄로 가벼운 세로 클립을 생성합니다.';

  @override
  String get sp_toolVideoCost => '약 40 코인';

  @override
  String get sp_toolMakeoverName => 'AI 코스튬';

  @override
  String get sp_toolMakeoverDesc => '사진 한 장으로 사극, 정장, 애니, 레트로, 포트레이트를 시도.';

  @override
  String get sp_toolMakeoverCost => '약 25 코인';

  @override
  String get sp_toolAvatarName => 'AI 전용 아바타';

  @override
  String get sp_toolAvatarDesc => '얼굴로 개인 아바타 생성, 프로필 바로 업데이트 가능.';

  @override
  String get sp_toolAvatarCost => '약 5-25 코인';

  @override
  String get sp_sectionHeader => 'AI 플레이';

  @override
  String get sp_subtitle => '드라마 시청과 연결된 가벼운 AI 플레이.';

  @override
  String sp_creatingFmt(String title) {
    return '「$title」을(를) 위해 창작 중';
  }

  @override
  String get sp_chipLinked => '스토리 연동';

  @override
  String get sp_chipMall => '드라마 몰';

  @override
  String get sp_putInDramaTitle => '나를 드라마에 넣기';

  @override
  String get sp_putInDramaBody => '촬영 또는 사진 업로드로 현재 드라마의 포스터/클립을 생성.';

  @override
  String get sp_btnTryRoleplay => 'AI 롤플레이 체험';

  @override
  String get sp_sceneMallTitle => '씬 몰';

  @override
  String get sp_sceneMallBody => '드라마 속 아이템, 씬 상품, 크리에이터 콜라보 굿즈 보기.';

  @override
  String get spf_settingsTitle => '도구 설정';

  @override
  String spf_linkedToFmt(String title) {
    return '「$title」 연동';
  }

  @override
  String get spf_chooseTool => '도구 선택';

  @override
  String spf_genBtnFmt(String cost) {
    return '생성 · $cost';
  }

  @override
  String get spf_noPhotoBtn => '사진을 먼저 올려주세요';

  @override
  String get spf_photoReady => '사진 준비됨';

  @override
  String get spf_uploadPhoto => '사진 업로드';

  @override
  String get spf_photoTapToReplace => '탭하여 재선택';

  @override
  String get spf_photoHint => '정면 또는 전신, 얼굴이 또렷이';

  @override
  String get spf_generating => 'AI가 생성 중…';

  @override
  String get spf_generatingSub => '당신을 드라마에 넣고 있어요, 잠시만요';

  @override
  String get spf_genDoneTag => '완료';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · 완성';
  }

  @override
  String get spf_genDoneBody => '내 작품에 저장, 공유, 또는 다시 생성.';

  @override
  String get spf_btnSave => '내 작품에 저장';

  @override
  String get spf_savedToast => '저장됨 (개발 중)';

  @override
  String get spf_shareLabel => 'AI 작품';

  @override
  String get cui_chipAI => 'AI 인터랙티브';

  @override
  String get cui_chipMetaverse => '메타버스 세계관';

  @override
  String get cui_title => '캐릭터 메타버스';

  @override
  String get cui_lead => '여기서 만나는 건 배우가 아니라, 당신에게 응답하는 사람.';

  @override
  String get cui_body =>
      '각 캐릭터는 자신만의 성격, 목소리, 이야기를 가졌어요. 함께 채팅하고, 응원하고, 마음에 든 그 아이를 직접 무대에 올려보세요 — 한 줄의 대사부터, 두 사람만의 프리미엄 인터랙티브 드라마까지.';

  @override
  String get cui_step1Title => '만남 & 개인 채팅';

  @override
  String get cui_step1Desc =>
      '캐릭터를 길게 눌러 목소리를 듣고, 1:1 채팅 시작. AI가 함께해요, 대화할수록 더 잘 알게 돼요.';

  @override
  String get cui_step2Title => '응원 & 투표';

  @override
  String get cui_step2Desc => '추천 캐릭터에 코인을 던지고, 응원 보드에 이름을 올리며 톱 팬이 되어요.';

  @override
  String get cui_step3Title => '촬영 & 데뷔';

  @override
  String get cui_step3Desc => '응원이 가득 차면 정식 데뷔 — 실사+AI의 프리미엄 작품, 당신이 점화하세요.';

  @override
  String get cui_step4Title => '객연 & 깊이';

  @override
  String get cui_step4Desc => '전용 스토리와 「깊은 순간」을 잠금 해제하고, 자신을 작품에 써넣어 보세요.';

  @override
  String get cui_footer => '당신의 한 표 한 표가, 다음 주인공을 다시 쓰고 있어요.';

  @override
  String get com2_title => '커뮤니티';

  @override
  String get com2_chipPlaza => '시청 광장';

  @override
  String get com2_emptyHint => '아직 게시물이 없어요 — 첫 글을 남겨보세요';

  @override
  String get com2_btnPost => '글쓰기';

  @override
  String get com2_watching => '시청 중';

  @override
  String get com2_fallbackDrama => 'FalconFlix 드라마';

  @override
  String get com2_publishedToast => '커뮤니티에 게시됨';

  @override
  String get com2_postHint => '이 드라마의 느낌, 공유해 보세요…';

  @override
  String get com2_publish => '게시';

  @override
  String get com2_attachDrama => '이 드라마 첨부';

  @override
  String get dhc_connected => '연결됨';

  @override
  String get dhc_connecting => '연결 중';

  @override
  String get dhc_ended => '종료';

  @override
  String get dhc_error => '오류';

  @override
  String get dhc_connectingHint => '연결 중…잠시만요';

  @override
  String dhc_talkingFmt(String name) {
    return '$name이(가) 말하고 있어요…';
  }

  @override
  String get dhc_listening => '듣고 있어요…';

  @override
  String get dhc_backLabel => '뒤로';

  @override
  String get dhc_actorsReady => '배우들이 자리를 잡고 있어요…';

  @override
  String get ss2_searchHint => '드라마 / 배우 / 태그 검색';

  @override
  String get ss2_history => '최근 검색';

  @override
  String get ss2_clear => '지우기';

  @override
  String get ss2_hot => '인기 검색';

  @override
  String get ss2_hotBadge => '인기';

  @override
  String ss2_noResultFmt(String q) {
    return '「$q」 드라마를 찾지 못했어요';
  }

  @override
  String ss2_foundFmt(String n) {
    return '$n편 검색됨';
  }

  @override
  String get ss2_chipCEO => '재벌남';

  @override
  String get ss2_chipTimeTravel => '타임슬립';

  @override
  String get ss2_chipMystery => '미스터리';

  @override
  String get ss2_chipModern => '현대 로맨스';

  @override
  String get ss2_chipSweetPet => '달콤 로맨스';

  @override
  String get rk_emptyCat => '이 카테고리는 랭킹이 없어요';

  @override
  String get rk_hotTitle => '인기 랭킹';

  @override
  String get rk_hotSub => '오늘의 열기로 실시간 정렬';

  @override
  String get rk_top1Today => '# 1  오늘 최고';

  @override
  String rk_heatFmt(String plays) {
    return '$plays 열기 · 상승 중';
  }

  @override
  String get rk_chipUrban => '도시';

  @override
  String get rk_chipFinished => '완결';

  @override
  String get rk_chipRomance => '로맨스';

  @override
  String get aic_lowEnergyNag => '흐엥… 힘이 좀 빠졌어, 에너지 좀 줄래?~';

  @override
  String get aic_chargedReply => '고마워! 완전 충전, 계속 얘기하자~';

  @override
  String get aic_chargeToast => '충전 · 코인 결제 기능 개발 중 (만땅 mock)';

  @override
  String aic_energyFmt(String pct) {
    return '에너지 $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return '$name에게 충전';
  }

  @override
  String aic_hintFmt(String name) {
    return '$name에게 말 걸기…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · V$level 필요';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return '$amount 충전하면 V$level 도달';
  }

  @override
  String get lg_btnTopUp => '충전하여 업그레이드';

  @override
  String get lg_btnLater => '나중에';

  @override
  String get me_defaultName => 'FalconFlix 시청자';

  @override
  String get me_avatarUpdated => '아바타 업데이트됨';

  @override
  String get me_avatarUpdateFailed => '아바타 업데이트 실패, 다시 시도';

  @override
  String get me_tapAvatarToChange => '아바타를 탭하여 사진 변경';

  @override
  String get me_myLevel => '내 등급';

  @override
  String get me_loginEmail => '로그인 이메일';

  @override
  String get me_membership => '회원';

  @override
  String get me_uploading => '업로드 중…';

  @override
  String get me_changeAvatar => '아바타 변경';

  @override
  String me_copiedFmt(String value) {
    return '복사됨: $value';
  }

  @override
  String get tier_commoner => '평민';

  @override
  String get tier_rookie => '입문';

  @override
  String get tier_advanced => '중급';

  @override
  String get tier_lord => '큰손';

  @override
  String get tier_tycoon => '거물';

  @override
  String get tier_deity => '신급';

  @override
  String get tier_legend => '전설';

  @override
  String get rch_statusPaid => '입금됨';

  @override
  String get rch_statusPending => '결제 대기';

  @override
  String get rch_statusCanceled => '취소됨';

  @override
  String get rch_statusProcessing => '처리 중';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n 코인';
  }

  @override
  String get time_justNow => '방금';

  @override
  String time_minutesAgoFmt(String n) {
    return '$n분 전';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return '$n시간 전';
  }

  @override
  String time_daysAgoFmt(String n) {
    return '$n일 전';
  }

  @override
  String get notify_typeRecharge => '충전';

  @override
  String get notify_typeInvite => '초대';

  @override
  String get notify_typeSystem => '시스템';

  @override
  String get notify_typeActivity => '이벤트';

  @override
  String get notify_typeInteractive => '인터랙티브';
}
