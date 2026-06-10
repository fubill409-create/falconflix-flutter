// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabTheater => 'المسرح';

  @override
  String get tabInteractive => 'تفاعلي';

  @override
  String get tabCharacter => 'الشخصيات';

  @override
  String get tabMe => 'حسابي';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_loading => 'جارٍ التحميل…';

  @override
  String get common_more => 'المزيد';

  @override
  String get common_yes => 'نعم';

  @override
  String get common_no => 'لا';

  @override
  String get common_free => 'مجاني';

  @override
  String get common_login => 'تسجيل الدخول';

  @override
  String get common_logout => 'تسجيل الخروج';

  @override
  String get common_loadFailed => 'فشل التحميل';

  @override
  String get common_pleaseLogin => 'يرجى تسجيل الدخول أولاً';

  @override
  String get common_done => 'تم';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_send => 'إرسال';

  @override
  String get me_title => 'حسابي';

  @override
  String get me_loginPrompt => 'تسجيل الدخول / إنشاء حساب';

  @override
  String get me_loginSubtitle =>
      'سجّل الدخول للوصول إلى مكتبتك ومحفظتك والدراما التفاعلية';

  @override
  String get me_membershipNormal => 'عضو';

  @override
  String get me_membershipVip => 'VIP';

  @override
  String get me_inviteCode => 'رمز الدعوة';

  @override
  String get me_statEagleCoins => 'عملات Eagle';

  @override
  String get me_statBoughtEpisodes => 'تم الشراء';

  @override
  String get me_statCollections => 'المحفوظات';

  @override
  String get me_sectionMyContent => 'المحتوى';

  @override
  String get me_sectionWallet => 'المحفظة';

  @override
  String get me_sectionCommunity => 'المجتمع';

  @override
  String get me_sectionCreator => 'المُبدع';

  @override
  String get me_sectionSettings => 'الإعدادات';

  @override
  String get me_sectionHelpAbout => 'المساعدة وحول التطبيق';

  @override
  String get me_rowCollections => 'محفوظاتي';

  @override
  String get me_rowHistory => 'سجل المشاهدة';

  @override
  String get me_rowCommunity => 'ساحة المجتمع';

  @override
  String get me_rowWallet => 'المحفظة والعضوية';

  @override
  String get me_rowOrders => 'طلباتي';

  @override
  String get me_rowInvite => 'دعوة الأصدقاء';

  @override
  String get me_rowPartner => 'شريك المُبدع';

  @override
  String get me_rowNotifications => 'الإشعارات';

  @override
  String get me_rowSettings => 'الإعدادات';

  @override
  String get me_rowHelpAbout => 'المساعدة وحول التطبيق';

  @override
  String get me_rowAbout => 'حول FalconFlix';

  @override
  String get me_logoutConfirm => 'تسجيل الخروج من الحساب؟';

  @override
  String get history_title => 'سجل المشاهدة';

  @override
  String get history_emptyTitle => 'لا يوجد سجل مشاهدة';

  @override
  String get history_emptyBody =>
      'ستظهر هنا الحلقات التي شاهدتها لتعود إليها بسهولة.';

  @override
  String get history_loginBody => 'سجّل الدخول لعرض ما شاهدته.';

  @override
  String get history_actionDelSelected => 'حذف المحدد';

  @override
  String get history_actionClearAll => 'مسح الكل';

  @override
  String get history_episodeFallback => 'المسلسل كاملاً';

  @override
  String get history_unknown => '(عنوان غير معروف)';

  @override
  String history_selectedCount(int n) {
    return 'تم تحديد $n';
  }

  @override
  String history_delConfirmTitle(int n) {
    return 'حذف $n سجل؟';
  }

  @override
  String get history_delConfirmBody =>
      'لا يمكن التراجع. لن يتأثر المسلسل، وسيُنشأ سجل جديد عند التشغيل التالي.';

  @override
  String get history_clearConfirmTitle => 'مسح كل سجل المشاهدة؟';

  @override
  String get history_clearConfirmBody =>
      'لا يمكن التراجع. ستُنشأ السجلات مجدداً عند التشغيل.';

  @override
  String history_toastDeleted(int n) {
    return 'تم حذف $n';
  }

  @override
  String get history_toastCleared => 'تم المسح';

  @override
  String get orders_title => 'طلباتي';

  @override
  String get orders_tabFull => 'مسلسل';

  @override
  String get orders_tabEpisode => 'حلقة';

  @override
  String get orders_tabRecharge => 'الشحن';

  @override
  String get orders_emptyFull => 'لا توجد طلبات مسلسلات';

  @override
  String get orders_emptyEpisode => 'لا توجد طلبات حلقات';

  @override
  String get orders_emptyBody =>
      'تظهر هنا الدرامات التي فتحتها، مفيد للفواتير والدعم.';

  @override
  String get orders_emptyRecharge => 'لا يوجد سجل شحن';

  @override
  String get orders_emptyRechargeBody => 'سيظهر هنا أول شحن لك.';

  @override
  String get orders_loginBodyOrders => 'سجّل الدخول لعرض طلباتك.';

  @override
  String get orders_loginBodyRecharge => 'سجّل الدخول لعرض سجل الشحن.';

  @override
  String get orders_kvAmount => 'المبلغ';

  @override
  String get orders_kvPayMethod => 'طريقة الدفع';

  @override
  String get orders_kvTime => 'الوقت';

  @override
  String orders_orderCopied(String orderNo) {
    return 'تم نسخ رقم الطلب · $orderNo';
  }

  @override
  String get orders_paid => 'مدفوع';

  @override
  String get orders_pending => 'قيد الانتظار';

  @override
  String get orders_payEagle => 'عملات Eagle';

  @override
  String get orders_unknownTitle => '(عنوان غير معروف)';

  @override
  String get orders_rechargeFallback => 'شحن عملات Eagle';

  @override
  String get inbox_title => 'الإشعارات';

  @override
  String get inbox_tabAll => 'الكل';

  @override
  String get inbox_tabRecharge => 'شحن';

  @override
  String get inbox_tabInvite => 'دعوات';

  @override
  String get inbox_tabSystem => 'النظام';

  @override
  String get inbox_tabActivity => 'عروض';

  @override
  String get inbox_tabInteractive => 'تفاعلي';

  @override
  String get inbox_emptyTitle => 'لا توجد رسائل';

  @override
  String get inbox_emptyBody =>
      'ستظهر هنا إيصالات الشحن، ومكافآت الدعوة، والعروض، وإشعارات النظام.';

  @override
  String get inbox_loginBody => 'سجّل الدخول لعرض الإشعارات.';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_sectionNotificationPlayback => 'الإشعارات والتشغيل';

  @override
  String get settings_sectionAccount => 'الحساب';

  @override
  String get settings_sectionUIStorage => 'الواجهة والتخزين';

  @override
  String get settings_rowNotifyPrefs => 'تفضيلات الإشعارات';

  @override
  String get settings_rowPlayPrefs => 'التشغيل والتنزيلات';

  @override
  String get settings_rowAccountSecurity => 'الحساب والأمان';

  @override
  String get settings_rowPrivacy => 'الخصوصية';

  @override
  String get settings_rowLanguage => 'اللغة';

  @override
  String get settings_rowClearCache => 'مسح الذاكرة المؤقتة';

  @override
  String get settings_clearCacheTitle => 'مسح الذاكرة المؤقتة؟';

  @override
  String get settings_clearCacheBody =>
      'يمسح فيديوهات الدراما التفاعلية المنزّلة وذاكرة الصور. لن تتأثر مشترياتك ولا تسجيل دخولك ولا إعداداتك.';

  @override
  String get settings_clearCacheAction => 'مسح الآن';

  @override
  String settings_clearCacheDone(String size) {
    return 'تم تحرير $size';
  }

  @override
  String get notifyPrefs_title => 'تفضيلات الإشعارات';

  @override
  String get notifyPrefs_pushMaster => 'المفتاح الرئيسي للإشعارات';

  @override
  String get notifyPrefs_pushMasterDesc =>
      'الإيقاف يوقف جميع الإشعارات. يبقى صندوق الرسائل داخل التطبيق يصل.';

  @override
  String get notifyPrefs_recharge => 'تأكيدات الشحن';

  @override
  String get notifyPrefs_rechargeDesc => 'نجاح الشحن / إيداع عملات Eagle';

  @override
  String get notifyPrefs_invite => 'مكافآت الدعوة';

  @override
  String get notifyPrefs_inviteDesc =>
      'تسجيل الأصدقاء المدعوين / وصول المكافآت';

  @override
  String get notifyPrefs_system => 'إشعارات النظام';

  @override
  String get notifyPrefs_systemDesc => 'أمان الحساب / تغييرات مهمة';

  @override
  String get notifyPrefs_activity => 'العروض';

  @override
  String get notifyPrefs_activityDesc => 'إطلاقات دراما جديدة / عروض شحن';

  @override
  String get notifyPrefs_interactive => 'تحديثات الدراما التفاعلية';

  @override
  String get notifyPrefs_interactiveDesc => 'حلقات جديدة / فتح نهايات';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return 'فشل الحفظ: $msg';
  }

  @override
  String get playPrefs_title => 'التشغيل والتنزيلات';

  @override
  String get playPrefs_autoplay => 'تشغيل تلقائي للتالي';

  @override
  String get playPrefs_autoplayDesc =>
      'تشغيل الفيديو التالي تلقائياً بعد انتهاء واحد';

  @override
  String get playPrefs_wifiOnlyAutoplay => 'تشغيل تلقائي عبر Wi-Fi فقط';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc =>
      'لا يشغّل تلقائياً على بيانات الجوال لتوفير البيانات';

  @override
  String get playPrefs_quality => 'الجودة الافتراضية';

  @override
  String get playPrefs_qualityAuto => 'تلقائي (حسب الشبكة)';

  @override
  String get playPrefs_quality480 => 'SD 480p';

  @override
  String get playPrefs_quality720 => 'HD 720p';

  @override
  String get playPrefs_quality1080 => 'Full HD 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => 'التنزيل عبر Wi-Fi فقط';

  @override
  String get playPrefs_wifiOnlyDownloadDesc =>
      'الفيديوهات التفاعلية والذاكرة المؤقتة دون اتصال فقط عبر Wi-Fi';

  @override
  String get accountSec_title => 'الحساب والأمان';

  @override
  String get accountSec_sectionLogin => 'تسجيل الدخول';

  @override
  String get accountSec_sectionDeletion => 'حذف الحساب';

  @override
  String get accountSec_rowChangePwd => 'تغيير كلمة المرور';

  @override
  String get accountSec_rowChangePwdDesc => 'كلمة المرور الحالية مطلوبة';

  @override
  String get accountSec_rowDelete => 'حذف الحساب';

  @override
  String get accountSec_rowDeleteDesc =>
      'فترة تهدئة 7 أيام، يمكنك الإلغاء بتسجيل الدخول';

  @override
  String get accountSec_oldPwHint => 'كلمة المرور الحالية';

  @override
  String get accountSec_newPwHint => 'كلمة المرور الجديدة (8 أحرف على الأقل)';

  @override
  String get accountSec_confirmPwHint => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get accountSec_errMinLen =>
      'يجب أن تكون كلمة المرور الجديدة 8 أحرف على الأقل';

  @override
  String get accountSec_errMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountSec_saveNewPw => 'حفظ كلمة المرور الجديدة';

  @override
  String get accountSec_saving => 'جارٍ الحفظ…';

  @override
  String get accountSec_pwUpdated => 'تم تحديث كلمة المرور';

  @override
  String get privacyPrefs_title => 'الخصوصية';

  @override
  String get privacyPrefs_sectionData => 'بياناتي';

  @override
  String get privacyPrefs_sectionLegal => 'الشروط والسياسة';

  @override
  String get privacyPrefs_rowExport => 'تنزيل بياناتي';

  @override
  String get privacyPrefs_rowExportDesc =>
      'GDPR / CCPA: اطلب حزمة كاملة لبياناتك';

  @override
  String get privacyPrefs_rowPolicy => 'سياسة الخصوصية';

  @override
  String get deleteAcc_title => 'حذف الحساب';

  @override
  String get deleteAcc_inProgress => 'طلب حذف الحساب قيد التنفيذ';

  @override
  String deleteAcc_scheduledAt(String time) {
    return 'موعد التنفيذ: $time';
  }

  @override
  String get deleteAcc_pendingHint =>
      'سجّل الدخول في أي وقت خلال فترة تهدئة 7 أيام لإلغاء الحذف.';

  @override
  String get deleteAcc_cancelBtn => 'إلغاء الحذف، متابعة الاستخدام';

  @override
  String get deleteAcc_willDelete => 'حذف الحساب سيزيل ما يلي';

  @override
  String get deleteAcc_bullet1 =>
      'الملف الشخصي، اللقب، الصورة، البريد، الهاتف المرتبط';

  @override
  String get deleteAcc_bullet2 =>
      'رصيد المحفظة (عملات Eagle غير قابلة للاسترداد)، VIP / المستوى';

  @override
  String get deleteAcc_bullet3 => 'الدرامات المشتراة وفتحات الدراما التفاعلية';

  @override
  String get deleteAcc_bullet4 =>
      'سجل المشاهدة، المحفوظات، منشورات المجتمع، حفظ التفاعلي';

  @override
  String get deleteAcc_bullet5 =>
      'علاقات الدعوة (تبقى السجلات على جانب المدعو)';

  @override
  String get deleteAcc_coolingHint =>
      'بعد الإرسال تبدأ فترة تهدئة 7 أيام. سجّل الدخول خلالها للإلغاء. بعد انقضائها يُحذف الحساب نهائياً.';

  @override
  String get deleteAcc_reasonLabel => 'سبب الحذف (اختياري، لتحسين المنتج)';

  @override
  String get deleteAcc_reasonHint => 'أخبرنا بما لا يعجبك (اختياري)';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return 'اكتب «$phrase» للتأكيد';
  }

  @override
  String get deleteAcc_confirmPhrase => 'احذف حسابي';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return 'يرجى كتابة «$phrase» بدقة';
  }

  @override
  String get deleteAcc_submit => 'إرسال طلب الحذف';

  @override
  String get deleteAcc_finalTitle => 'التأكيد النهائي';

  @override
  String get deleteAcc_finalBody =>
      'ستبدأ فترة تهدئة 7 أيام. سجّل الدخول خلالها للإلغاء.\n\nبعد الانقضاء، تُحذف البيانات نهائياً ولا يمكن استرجاعها.';

  @override
  String get deleteAcc_finalSubmit => 'إرسال الحذف';

  @override
  String get deleteAcc_submitted => 'تم إرسال طلب الحذف، التنفيذ بعد 7 أيام';

  @override
  String get deleteAcc_cancelled => 'تم إلغاء طلب الحذف';

  @override
  String get deleteAcc_thinkAgain => 'ليس بعد، عودة';

  @override
  String get dataExport_title => 'تنزيل بياناتي';

  @override
  String get dataExport_introTitle => 'احصل على نسخة من بياناتك';

  @override
  String get dataExport_introBody =>
      'بموجب GDPR المادة 15 (الاتحاد الأوروبي) و CCPA (كاليفورنيا)، يحق لك الحصول على كل البيانات الشخصية التي نحتفظ بها عنك.\n\nبعد الإرسال، سننشئ ملف zip بشكل غير متزامن يحتوي على:\n  · الملف الشخصي / البريد / الهاتف\n  · رصيد عملات Eagle والمعاملات\n  · الطلبات وسجل المشاهدة والمحفوظات\n  · منشورات المجتمع وفتحات الدراما التفاعلية\n\nسنبلغك داخل التطبيق عند الجاهزية. رابط التنزيل صالح لمدة 7 أيام.';

  @override
  String get dataExport_statusQueued => 'قيد الانتظار · في الطابور';

  @override
  String get dataExport_statusProcessing => 'قيد التنفيذ · تحزيم';

  @override
  String get dataExport_statusReady => 'جاهز · يمكن التنزيل';

  @override
  String get dataExport_statusExpired => 'منتهي · أعد الطلب';

  @override
  String get dataExport_statusFailed => 'فشل · أعد الطلب';

  @override
  String dataExport_expiresAt(String time) {
    return 'ينتهي الرابط في $time';
  }

  @override
  String get dataExport_downloadBtn => 'تنزيل';

  @override
  String get dataExport_submitBtn => 'طلب التنزيل';

  @override
  String get dataExport_submitting => 'جارٍ الإرسال…';

  @override
  String get dataExport_submitted => 'تم إرسال الطلب، سنبلغك عند الجاهزية';

  @override
  String get helpAbout_title => 'المساعدة وحول التطبيق';

  @override
  String get helpAbout_sectionHelp => 'المساعدة';

  @override
  String get helpAbout_sectionAbout => 'حول التطبيق';

  @override
  String get helpAbout_rowFaq => 'مركز المساعدة';

  @override
  String get helpAbout_rowFaqDesc => 'الأسئلة الشائعة';

  @override
  String get helpAbout_rowSupport => 'التواصل مع الدعم';

  @override
  String get helpAbout_rowSupportDesc => 'محادثة تذكرة 1 إلى 1';

  @override
  String get helpAbout_rowFeedback => 'إرسال ملاحظات';

  @override
  String get helpAbout_rowFeedbackDesc => 'أفكار المنتج / تقارير الأخطاء';

  @override
  String get faq_title => 'مركز المساعدة';

  @override
  String get faq_catAll => 'الكل';

  @override
  String get faq_catAccount => 'الحساب';

  @override
  String get faq_catRecharge => 'الشحن';

  @override
  String get faq_catPlayback => 'التشغيل';

  @override
  String get faq_catInteractive => 'تفاعلي';

  @override
  String get faq_catOther => 'أخرى';

  @override
  String get faq_emptyTitle => 'لا توجد أسئلة شائعة بعد';

  @override
  String get faq_emptyBody => 'إذا واجهتك مشكلة، يرجى فتح تذكرة دعم.';

  @override
  String get tickets_title => 'التواصل مع الدعم';

  @override
  String get tickets_newBtn => 'تذكرة جديدة';

  @override
  String get tickets_emptyTitle => 'لا توجد تذاكر';

  @override
  String get tickets_emptyBody =>
      'اضغط الزر لإنشاء تذكرة جديدة. سيرد الدعم 1 إلى 1.';

  @override
  String get tickets_threadTitle => 'تفاصيل التذكرة';

  @override
  String get tickets_initial => 'المشكلة الأولى';

  @override
  String get tickets_speakerStaff => 'الدعم';

  @override
  String get tickets_speakerSelf => 'أنا';

  @override
  String get tickets_replyHint => 'الرد…';

  @override
  String tickets_sendFailed(String msg) {
    return 'فشل الإرسال: $msg';
  }

  @override
  String get tickets_statusPending => 'قيد الانتظار';

  @override
  String get tickets_statusReplied => 'تم الرد';

  @override
  String get tickets_statusResolved => 'تم الحل';

  @override
  String get tickets_statusClosed => 'مغلقة';

  @override
  String get feedback_titleTicket => 'تذكرة جديدة';

  @override
  String get feedback_titleFeedback => 'إرسال ملاحظات';

  @override
  String get feedback_typeBug => 'تقرير خطأ';

  @override
  String get feedback_typeSuggestion => 'اقتراح';

  @override
  String get feedback_typeComplaint => 'شكوى';

  @override
  String get feedback_typeRecharge => 'مشكلة شحن';

  @override
  String get feedback_typeOther => 'أخرى';

  @override
  String get feedback_typeLabel => 'نوع المشكلة';

  @override
  String get feedback_contentLabel => 'التفاصيل';

  @override
  String get feedback_contentHintTicket => 'اشرح المشكلة بالتفصيل لتسريع الحل…';

  @override
  String get feedback_contentHintFeedback => 'أخبرنا بما تفكر…';

  @override
  String get feedback_contactLabel => 'بريد / هاتف للرد (اختياري)';

  @override
  String get feedback_contactHint => 'سنعطي الأولوية للرد. اختياري.';

  @override
  String get feedback_submit => 'إرسال';

  @override
  String get feedback_submitting => 'جارٍ الإرسال…';

  @override
  String get feedback_submitted => 'تم الإرسال، سيرد الدعم';

  @override
  String get feedback_minLength => 'يرجى كتابة 5 أحرف على الأقل';

  @override
  String feedback_tip(String version) {
    return 'نصيحة: لتقارير الأخطاء، أرفق خطوات إعادة الإنتاج + لقطات الشاشة (قريباً) لتسريع الفرز.\nالإصدار: $version';
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
  String get home_noDramaData => 'لا توجد دراما حتى الآن';

  @override
  String get home_localOnlyLike => 'المصدر المحلي لا يدعم الإعجاب';

  @override
  String get home_localOnlyCollect => 'المصدر المحلي لا يدعم الحفظ';

  @override
  String get home_addedToMy => 'تم الحفظ في «حسابي»';

  @override
  String get home_actionLike => 'إعجاب';

  @override
  String get home_actionCollected => 'محفوظ';

  @override
  String get home_actionCollect => 'حفظ';

  @override
  String get home_actionShare => 'مشاركة';

  @override
  String get home_shopComingSoon =>
      'منتج من المسلسل · تعرّف بالذكاء الاصطناعي (المتجر قيد التطوير)';

  @override
  String get home_chipAiTheater => 'مسرح الذكاء الاصطناعي';

  @override
  String get home_bannerPremiere => 'افتتاحية دراما الذكاء الاصطناعي';

  @override
  String get home_btnWatch => 'شاهد';

  @override
  String get home_btnDetails => 'التفاصيل';

  @override
  String home_loadFailedFmt(String message) {
    return 'فشل التحميل\n$message';
  }

  @override
  String get theater_genreAll => 'الكل';

  @override
  String get theater_genreRomance => 'رومانسي';

  @override
  String get theater_genreUrban => 'حضري';

  @override
  String get theater_genreInteractive => 'تفاعلي';

  @override
  String get theater_genreFinished => 'مكتمل';

  @override
  String get theater_sectionHot => 'الأكثر مشاهدة';

  @override
  String get theater_seeAll => 'عرض الكل';

  @override
  String get theater_sectionAll => 'كل المسلسلات';

  @override
  String get theater_ranking => 'الأكثر رواجاً';

  @override
  String get theater_today => 'اختيار اليوم';

  @override
  String get theater_labelShort => 'دراما قصيرة';

  @override
  String theater_continueWatch(String name) {
    return 'تابع · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '$heat مشاهدة';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · $heat مشاهدة';
  }

  @override
  String get cast_sectionPlaying => 'البث الجاري والتجارب';

  @override
  String get cast_oppRanking => 'فرص الأدوار ›';

  @override
  String get cast_universeTitle => 'عالم الشخصيات الافتراضي';

  @override
  String get cast_universeSub => 'لقاء شخصيات تردّ عليك · اكتشف هذا العالم';

  @override
  String get cast_demoBadge => 'تجريبي · قابل للعب';

  @override
  String get cast_demoTitle => 'الدراما التفاعلية التجريبية';

  @override
  String get cast_demoSub => 'اختيارك — جملة واحدة تشعل دراما كاملة';

  @override
  String get cast_inPlay => 'يُبثّ الآن';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '$heat مشاهدة · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '$heat مشاهدة';
  }

  @override
  String get cb_sectionSupport => 'لوحة الدعم · مَن يدعمهم';

  @override
  String get cb_goSupport => 'ادعم · ساعدهم للبدء';

  @override
  String get cb_seeBio => 'عرض السيرة ›';

  @override
  String cb_pollHeatPct(String pct) {
    return 'الدعم $pct%';
  }

  @override
  String get cb_debuted => 'بدأ التصوير';

  @override
  String cb_toDebutPct(String pct) {
    return 'باقي $pct% للبدء';
  }

  @override
  String get cb_totalSupport => 'إجمالي الدعم';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins عملة نسر';
  }

  @override
  String get cb_topBacker => 'الداعم الأول';

  @override
  String get cb_emptyBackers => 'لا داعمين بعد · كن أول الداعمين';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · لوحة الدعم';
  }

  @override
  String get aid_titleHeader => 'دراما تفاعلية بالذكاء الاصطناعي';

  @override
  String get aid_aceBadge => 'البطل';

  @override
  String get aid_tagline => 'خياراتك تعيد كتابة النهاية.';

  @override
  String get aid_demoBadge => 'تجريبي · مجاني';

  @override
  String get aid_lastcallSub =>
      '5 طبقات اختيار · 7 نهايات · اختيارك يعيد كتابة القصة';

  @override
  String get aid_pipelineTitle => 'ستوديو النجوم';

  @override
  String get aid_pipelineSub => 'قائمة البطل · إنتاجات قيد الانطلاق';

  @override
  String get aid_cameoTitle => 'اختر نفسك بطلًا';

  @override
  String get aid_cameoSub => 'حمّل صورة، واكتب نفسك داخل القصة';

  @override
  String get aid_castingBadge => 'اختيار الأدوار';

  @override
  String get aid_producingBadge => 'قيد الإنتاج';

  @override
  String aid_castVoteFmt(String pct) {
    return 'صوّت للممثلين · $pct%';
  }

  @override
  String get aid_manifesto1 => 'أنت لم تعد مجرد مشاهد للقصص.';

  @override
  String get aid_manifesto2 =>
      'تختار بدلًا من البطل، فتعيد القصة كتابة نهايتك.';

  @override
  String get aid_manifesto3 => 'كل اختيار هو حوار بينك وبين هذا العالم.';

  @override
  String get aid_manifestoHeader => 'لماذا نصنع الدراما التفاعلية';

  @override
  String get aid_metaversePre => 'نسميها «دراما تفاعلية» —\nلكنها في الحقيقة ';

  @override
  String get aid_metaverseEmph => 'الفصل الأول من «ميتافيرس القرار»';

  @override
  String get aid_metaversePost => ':\nعالم تحكم فيه أنت، يبدأ من هنا.';

  @override
  String get aid_step1Title => 'شاهد';

  @override
  String get aid_step1Sub => 'اجلس ودع القصة تأسرك.';

  @override
  String get aid_step2Title => 'اختيار تفاعلي';

  @override
  String get aid_step2Sub => 'عند كل مفترق، قرّر بدلًا من البطل؛ تتفرّع القصة.';

  @override
  String get aid_step3Title => 'اختر نفسك بطلًا';

  @override
  String get aid_step3Sub => 'ضع وجهك واسمك في هذا العمل.';

  @override
  String get aid_step4Title => 'ادعم حتى يصعد للنجومية';

  @override
  String get aid_step4Sub => 'ادعم الشخصية التي تحبها وادفعها إلى المسرح.';

  @override
  String get aid_step5Title => 'ميتافيرس القرار';

  @override
  String get aid_step5Sub => 'الوجهة: عالم تحكم فيه أنت.';

  @override
  String get aid_ladderHeader => 'من اختيار واحد إلى عالم كامل';

  @override
  String get aid_liveTitle => 'متاحة الآن · قابلة للعب';

  @override
  String get aid_liveSub => 'دراما تفاعلية حقيقية · خياراتك تعيد كتابة القصة';

  @override
  String get aid_fallbackHook => 'خياراتك تعيد كتابة قصتها';

  @override
  String get aid_aceCardBadge => 'البطل التفاعلي · قابل للعب';

  @override
  String get player_btnLiked => 'تم الإعجاب';

  @override
  String get player_btnEpisodes => 'الحلقات';

  @override
  String get player_btnAiCast => 'ظهور AI';

  @override
  String player_episodeNumFmt(int n) {
    return 'الحلقة $n';
  }

  @override
  String player_switchEpFmt(int n) {
    return 'التبديل إلى الحلقة $n (الواجهة الخلفية قيد التطوير)';
  }

  @override
  String get player_unlockHint => 'فُكّ القفل بعملة النسر من صفحة المسلسل';

  @override
  String player_comingSoonFmt(String label) {
    return '$label (قيد التطوير)';
  }

  @override
  String get player_sceneSame => 'منتج من المشهد';

  @override
  String get detail_unlockThis => 'هذه الحلقة';

  @override
  String get detail_unlockNext5 => 'الحلقات الـ 5 التالية';

  @override
  String get detail_unlockNext10 => 'الحلقات الـ 10 التالية';

  @override
  String get detail_unlockAll => 'المسلسل كاملًا';

  @override
  String detail_episodeCountFmt(int n) {
    return '$n حلقة';
  }

  @override
  String get detail_drawerEpisodes => 'قائمة الحلقات';

  @override
  String get detail_unlockSuccess => 'تم فك القفل!';

  @override
  String detail_coinBalanceFmt(String coins) {
    return 'الرصيد $coins عملة نسر';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n مشاهدة';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return 'فك القفل بـ $coins عملة نسر';
  }

  @override
  String get detail_playNow => 'تشغيل الآن';

  @override
  String get detail_playThis => 'تشغيل هذا المسلسل';

  @override
  String get detail_noEpisodes => 'لا توجد حلقات متاحة';

  @override
  String get login_welcome => 'مرحبًا بك في FalconFlix';

  @override
  String get login_subtitle =>
      'سجّل دخولك لفتح المسلسلات وعملة النسر والدراما التفاعلية';

  @override
  String get login_emailLabel => 'البريد الإلكتروني';

  @override
  String get login_passwordLabel => 'كلمة المرور';

  @override
  String get login_codeLabel => 'رمز التحقق';

  @override
  String get login_codeHint => 'رمز من 6 أرقام';

  @override
  String get login_pwInputHint => 'أدخل كلمة المرور';

  @override
  String get login_modeOtp => 'الدخول برمز';

  @override
  String get login_modePassword => 'الدخول بكلمة المرور';

  @override
  String get login_getCode => 'إرسال الرمز';

  @override
  String get login_sending => 'جارٍ الإرسال';

  @override
  String get login_loggingIn => 'جارٍ تسجيل الدخول…';

  @override
  String get login_loginOrRegister => 'تسجيل دخول / إنشاء حساب';

  @override
  String get login_pwHint =>
      'أول تسجيل دخول بكلمة مرور يُنشئ الحساب تلقائيًا بهذه الكلمة';


  @override
  String get login_quickLogin => 'دخول سريع';

  @override
  String get login_recommended => 'موصى به';

  @override
  String get login_success => 'تم تسجيل الدخول';

  @override
  String get login_agreement =>
      'تسجيل الدخول يعني الموافقة على شروط الخدمة وسياسة الخصوصية';

  @override
  String get login_emailInvalid => 'يرجى إدخال بريد إلكتروني صحيح أولًا';

  @override
  String get login_emailRequired => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get login_passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get login_codeRequired => 'يرجى إدخال رمز التحقق';

  @override
  String get login_codeSent => 'تم إرسال الرمز. يرجى مراجعة البريد.';

  @override
  String get login_emailNotConfigured =>
      'خدمة البريد الإلكتروني غير متاحة مؤقتًا. يرجى المحاولة لاحقًا.';

  @override
  String get login_networkError =>
      'فشل تسجيل الدخول؛ يرجى التحقق من الشبكة وإعادة المحاولة';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return 'فشل تسجيل الدخول بـ $provider: $code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return 'فشل تسجيل الدخول بـ $provider؛ أعد المحاولة لاحقًا';
  }

  @override
  String login_oauthComingFmt(String name) {
    return 'تسجيل الدخول بـ $name قيد التطوير';
  }

  @override
  String get login_oauthComingBody =>
      'قريبًا — يمكنك الآن الدخول برمز البريد أو كلمة المرور.';

  @override
  String get login_gotIt => 'حسنًا';

  @override
  String get login_googleNoToken =>
      'Google لم يُرجع idToken؛ يرجى التحقق من بيانات الاعتماد';

  @override
  String get about_tagline => 'FalconFlix · دراما تستحق المشاهدة';

  @override
  String get about_body =>
      'FalconFlix منصة عالمية للدراما القصيرة المميزة — شاهد الدراما، تحدّث مع شخصيات الذكاء الاصطناعي، وتسوق أثناء المشاهدة. إنتاج بمستوى سينمائي وإبداع ذكاء اصطناعي يجعل كل لقطة جديرة بالبقاء.';

  @override
  String get about_userAgreement => 'شروط الخدمة';

  @override
  String get about_privacyPolicy => 'سياسة الخصوصية';

  @override
  String about_legalUpdatedFmt(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get about_operatingEntity => 'الجهة المشغّلة';

  @override
  String about_contactEmailFmt(String email) {
    return 'للتواصل: $email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return 'حول $appName';
  }

  @override
  String get wallet_title => 'شحن عملة النسر';

  @override
  String get wallet_chooseRecharge => 'اختر باقة';

  @override
  String get wallet_introNote =>
      'عملة النسر تفتح الحلقات والميزات التفاعلية والدعم';

  @override
  String get wallet_menuAutoUnlock => 'إعدادات الفتح التلقائي';

  @override
  String get wallet_menuHistory => 'سجل الشحن';

  @override
  String get wallet_menuReceipt => 'بريد الإيصال';

  @override
  String get wallet_stripeNotice => 'الدفع مؤمَّن عبر Stripe · بالدولار';

  @override
  String get wallet_appStoreNotice => 'دفع آمن عبر App Store';

  @override
  String get wallet_loadFailed => 'فشل التحميل، يرجى إعادة المحاولة';

  @override
  String get wallet_packsComing => 'الباقات قريبًا';

  @override
  String get wallet_packsComingBody => 'نُعدّ لك أفضل باقات عملة النسر';

  @override
  String get wallet_coins => 'عملة النسر';

  @override
  String wallet_giftFmt(String coins) {
    return '+$coins مكافأة';
  }

  @override
  String get wallet_bestDeal => 'الأفضل قيمةً';

  @override
  String wallet_payNowFmt(String price) {
    return 'ادفع $price الآن';
  }

  @override
  String get wallet_payNow => 'ادفع الآن';

  @override
  String get wallet_loginFirst => 'يرجى تسجيل الدخول أولًا';

  @override
  String get wallet_openPayFail => 'تعذّر فتح صفحة الدفع، يرجى إعادة المحاولة';

  @override
  String get wallet_payFail => 'فشل الدفع، يرجى إعادة المحاولة';

  @override
  String get wallet_iapUnavailable => 'تعذّر الاتصال بـ App Store، يرجى إعادة المحاولة';

  @override
  String get wallet_iapVerifyFail => 'فشل تأكيد الدفع، ستتم إعادة المحاولة عند التشغيل القادم';

  @override
  String get wallet_balanceLabel => 'رصيد عملة النسر';

  @override
  String get wallet_loginToView => 'سجّل الدخول للعرض';

  @override
  String get wallet_legendPeak => 'قمة أسطورية · الحد الأقصى';

  @override
  String wallet_toLevelFmt(String level) {
    return 'إلى V$level';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return 'إجمالي الشحن $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return 'اشحن $amount للوصول إلى V$level';
  }

  @override
  String get wallet_successTitle => 'نجح الشحن · تم الإيداع';

  @override
  String get wallet_tapAnywhere => 'اضغط في أي مكان للمتابعة';

  @override
  String get wallet_successBarrier => 'نجح الشحن';

  @override
  String get creator_title => 'مركز الشركاء';

  @override
  String get creator_statSeries => 'مسلسل';

  @override
  String get creator_statPlays => 'مشاهدة';

  @override
  String get creator_statShare => 'حصة';

  @override
  String get creator_applyLabel => 'تقديم طلب شريك مسلسلات';

  @override
  String get creator_applyToast => 'تم إرسال الطلب (قيد التطوير)';

  @override
  String get creator_menuRequirement => 'متطلبات الرفع';

  @override
  String get creator_menuRevenue => 'قواعد الحصص';

  @override
  String get creator_menuLangPriv => 'اللغة والخصوصية';

  @override
  String get invite_title => 'ادعُ صديقًا';

  @override
  String get invite_stepsTitle => 'كيف يعمل';

  @override
  String get invite_step1Title => 'شارك رمز الدعوة';

  @override
  String get invite_step1Sub => 'أرسل رمز الدعوة الخاص بك إلى صديق';

  @override
  String get invite_step2Title => 'صديقك يسجل برمزك';

  @override
  String get invite_step2Sub => 'يدخل صديقك رمزك عند التسجيل';

  @override
  String get invite_step3Title => 'كلاكما تحصلان على عملات';

  @override
  String get invite_step3Sub => 'بعد التسجيل تحصلان معًا على عملة النسر';

  @override
  String get invite_copyMessage => 'نسخ رسالة الدعوة';

  @override
  String get invite_loginToGet => 'سجّل الدخول للحصول على الرمز';

  @override
  String get invite_loginToGen => 'سجّل الدخول لإنشاء رمز الدعوة الخاص بك';

  @override
  String get invite_messageCopied => 'تم نسخ الرسالة — أرسلها لصديقك';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 أشاهد FalconFlix وهي رائعة! استخدم رمز دعوتي $code عند التسجيل لنحصل كلانا على عملة النسر~';
  }

  @override
  String get invite_bigTitle => 'ادعُ أصدقاءك وشاهدوا معًا';

  @override
  String get invite_bigSub =>
      'عندما يسجّل صديقك برمزك، تحصلان معًا على عملة النسر';

  @override
  String get invite_myCode => 'رمز دعوتي الخاص';

  @override
  String get invite_copyBtn => 'نسخ';

  @override
  String invite_codeCopiedFmt(String code) {
    return 'تم نسخ الرمز: $code';
  }

  @override
  String get collect_emptyTitle => 'لا توجد دراما محفوظة بعد';

  @override
  String get collect_emptyBody =>
      'اضغط «حفظ» على أي دراما لتظهر هنا للوصول السريع.';

  @override
  String get au_title => 'الفتح التلقائي';

  @override
  String get au_introTitle => 'لا تقطع المشاهدة';

  @override
  String get au_introBody =>
      'عند التفعيل، تُفتح الحلقة التالية تلقائيًا بعملة النسر لتستمر بالمشاهدة';

  @override
  String get au_toggleLabel => 'فتح الحلقة التالية تلقائيًا';

  @override
  String get au_on => 'مفعّل';

  @override
  String get au_off => 'متوقف';

  @override
  String get au_toggleOnToast => 'تم تفعيل الفتح التلقائي';

  @override
  String get au_toggleOffToast => 'تم إيقاف الفتح التلقائي';

  @override
  String get au_rule1 => 'تُفتح الحلقات المقفلة بالعملات مباشرة دون نوافذ';

  @override
  String get au_rule2 => 'عند نقص الرصيد تُذكّرك بالشحن، دون خصم مفاجئ';

  @override
  String get au_rule3 =>
      'يسري فقط على فتح الحلقة المنفردة؛ فتح المسلسل كاملًا يحتاج تأكيدًا يدويًا';

  @override
  String get rh_title => 'سجل الشحن';

  @override
  String get rh_loginToView => 'سجّل الدخول لعرض سجل الشحن';

  @override
  String get rh_emptyBody =>
      'لا توجد عمليات شحن بعد\nاشحن عملة النسر لفتح المزيد من الدراما';

  @override
  String get rh_fallback => 'شحن عملة النسر';

  @override
  String get re_title => 'بريد الإيصال';

  @override
  String get re_invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get re_saved => 'تم حفظ بريد الإيصال';

  @override
  String get re_label => 'بريد الإيصال';

  @override
  String get re_body =>
      'بعد نجاح الشحن، يرسل Stripe الإيصال إلى هذا البريد، ويُملأ تلقائيًا في الشحن التالي.';

  @override
  String re_useAccountEmailFmt(String email) {
    return 'استخدم بريد الدخول $email';
  }

  @override
  String get re_save => 'حفظ';

  @override
  String common_comingSoonFmt(String name) {
    return '$name (قيد التطوير)';
  }

  @override
  String get sheets_episodeTitle => 'الحلقات';

  @override
  String get sheets_unlockAllBtn => 'فتح الكل';

  @override
  String get sheets_unlockTitle => 'فتح';

  @override
  String get sheets_unlockChooseCount => 'اختر عدد الحلقات لفتحها';

  @override
  String get sheets_unlockFailed => 'فشل الفتح، حاول مجددًا';

  @override
  String get sheets_networkErr => 'خطأ في الشبكة، حاول مجددًا';

  @override
  String get sheets_walletBalance => 'رصيد العملات';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins عملة';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return 'تحتاج $coins عملة إضافية — اشحن لفتحها';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return 'افتح الآن · $coins عملة';
  }

  @override
  String get sheets_coinsNotEnough => 'عملات غير كافية · اشحن';

  @override
  String sheets_tierForeverFmt(String count) {
    return '$count حلقات · للأبد';
  }

  @override
  String get sheets_unlockAllSub => 'فتح المسلسل كاملاً';

  @override
  String get sheets_unlockThisSub => 'فتح هذه الحلقة';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return 'فتح كل $count حلقات · للأبد';
  }

  @override
  String get sheets_unlockThisForever => 'فتح هذه الحلقة · للأبد';

  @override
  String get sheets_coinsShort => 'عملات';

  @override
  String get sheets_vipDiscount => 'سعر VIP أقل';

  @override
  String get sheets_shareTitle => 'مشاركة';

  @override
  String get sheets_shareSub => 'شارك هذا المسلسل';

  @override
  String get sheets_copyLink => 'نسخ الرابط';

  @override
  String get sheets_linkCopiedShort => 'تم نسخ الرابط';

  @override
  String get sheets_linkCopiedLong => 'تم نسخ الرابط — الصقه لصديقك';

  @override
  String get sheets_shareTargetMessage => 'رسالة';

  @override
  String get sheets_shareTargetPoster => 'ملصق';

  @override
  String get sheets_shareTargetCommunity => 'النشرة';

  @override
  String get sheets_shareTargetRemix => 'ريمكس';

  @override
  String get sheets_remixComingShort => 'ريمكس بالذكاء · قريبًا';

  @override
  String get sheets_remixComingFooter => 'ريمكس بالذكاء قريبًا · ترقّب';

  @override
  String get sheets_fallbackTitle => 'مسلسلات FalconFlix المميزة';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title رائع — شاهده معي على FalconFlix! $url';
  }

  @override
  String get sheets_posterTitle => 'ملصق';

  @override
  String get sheets_posterMakeSub => 'إنشاء ملصق خاص';

  @override
  String get sheets_posterReady => 'مشاركة الملصق';

  @override
  String get sheets_posterGenerating => 'جاري إنشاء الملصق…';

  @override
  String get sheets_posterGenFail => 'فشل إنشاء الملصق';

  @override
  String get sheets_posterExportFail => 'فشل تصدير الملصق';

  @override
  String get sheets_posterTagline => 'امسح الرمز للمشاهدة معًا';

  @override
  String get ixp_resumeTitle => 'تابع من حيث توقفت';

  @override
  String get ixp_resumeBody => 'هل تريد المتابعة من آخر مكان أم البدء من جديد؟';

  @override
  String get ixp_resumeFromStart => 'من البداية';

  @override
  String get ixp_resumeContinue => 'متابعة';

  @override
  String ixp_fetchFailedFmt(String code) {
    return 'فشل تحميل القصة ($code)';
  }

  @override
  String get ixp_dataAnomaly => 'بيانات القصة غير صالحة (لا توجد نقطة بداية)';

  @override
  String ixp_loadErrorFmt(String msg) {
    return 'خطأ في التحميل: $msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return 'العقدة «$id» غير موجودة';
  }

  @override
  String get ixp_nodeJumpTitle => 'الانتقال للعقدة · اختبار المالك';

  @override
  String get ixp_nodeJumpBody =>
      'مخفي عن المستخدمين العاديين. اضغط أي عقدة للانتقال مباشرة (دون تغيير الأعلام).';

  @override
  String ixp_segCountFmt(String n) {
    return '$n مقطع';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return 'فرع مدفوع (بعد الإطلاق $price عملة) · تجربة مجانية هذه المرة';
  }

  @override
  String get ixp_fallbackTitle => 'دراما تفاعلية';

  @override
  String get ixp_btnSkip => 'تخطي';

  @override
  String get ixp_btnBack => 'رجوع';

  @override
  String get ixp_segGenerating => 'هذا الجزء قيد الإنشاء…';

  @override
  String get ixp_btnContinue => 'متابعة';

  @override
  String ixp_prepFmt(String done, String total) {
    return 'جاري التحضير $done / $total';
  }

  @override
  String get ixp_prep => 'جاري التحضير…';

  @override
  String get ixp_yourChoice => 'دورك للاختيار';

  @override
  String get ixp_endingFallback => 'النهاية';

  @override
  String get ixp_btnReplay => 'إعادة المشاهدة';

  @override
  String get ixp_endingGood => 'نهاية جيدة';

  @override
  String get ixp_endingBad => 'نهاية سيئة';

  @override
  String get ixp_endingHidden => 'نهاية خفية';

  @override
  String get ixp_endingOpen => 'نهاية مفتوحة';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n خيار';
  }

  @override
  String get ip_busyAiCreatingTitle => 'تم تسليم الإبداع لـ AI من أجلك';

  @override
  String get ip_busyAiCreatingSub =>
      'نهايتك المخصصة قيد الإنشاء إطارًا بإطار…\nتستغرق عادةً بضع دقائق، سنخبرك عند الانتهاء — تجوّل بحرية';

  @override
  String get ip_busyDirectorTitle =>
      'المخرج يعود للشاشة · الممثلون يدخلون من أجلك';

  @override
  String get ip_busyDirectorSub =>
      'ننسج كل اختياراتك ووجهك في خاتمة خاصة بك وحدك';

  @override
  String get ip_busyDoneTitle => '✦ نهايتك المخصصة جاهزة';

  @override
  String get ip_busyDoneSub => 'محفوظة للأبد في «نهاياتي الخاصة»';

  @override
  String ip_titleChipFmt(String n) {
    return 'تفاعلي · $n نهاية';
  }

  @override
  String get ip_titleSub => 'كل اختيار يغير النهاية';

  @override
  String get ip_titleStart => 'ابدأ القصة';

  @override
  String get ip_btnContinue => 'متابعة';

  @override
  String ip_voteFmt(String n) {
    return '$n% يختارون هذا';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return 'النهايات المفتوحة $got / $total';
  }

  @override
  String get ip_btnDex => 'دليل النهايات';

  @override
  String get ip_btnReplay => 'جرّب اختيارًا آخر';

  @override
  String get ip_dexTitle => 'دليل النهايات';

  @override
  String get ip_dexLocked => '؟؟؟';

  @override
  String ip_errorTitleFmt(String err) {
    return 'فشل التحقق من القصة\n$err';
  }

  @override
  String get ip_unlockTitleAi => 'اصنع نهاية مخصصة لك';

  @override
  String get ip_unlockTitle => 'افتح هذا الفرع';

  @override
  String get ip_demoFree => 'دراما تجريبية · تجربة مجانية';

  @override
  String get ip_unlockBtnAi => 'ابدأ الصنع من أجلي';

  @override
  String get ip_unlockBtn => 'افتح الفرع';

  @override
  String get ip_unlockCancel => 'ربما لاحقًا';

  @override
  String com_sceneSameFmt(String n) {
    return 'في هذا المشهد $n منتجات';
  }

  @override
  String get com_sameInDrama => 'كما في الدراما';

  @override
  String get com_buyNow => 'اشترِ الآن';

  @override
  String get com_inStock => 'متوفر · شحن مجاني';

  @override
  String get com_outOfStock => 'غير متوفر';

  @override
  String get com_infoMerchant => 'البائع';

  @override
  String get com_infoEpisode => 'الحلقة المرتبطة';

  @override
  String get com_infoScene => 'يظهر في المشهد';

  @override
  String com_sceneTimeFmt(String sec) {
    return 'من ${sec}s';
  }

  @override
  String get com_descTitle => 'وصف المنتج';

  @override
  String get com_descBody =>
      'منتجات مختارة من الدراما، يوفرها شركاء FalconFlix. الشحن من المنصة وإمكانية الإرجاع خلال 7 أيام. (نص توضيحي، يستبدل عند ربط منتج فعلي.)';

  @override
  String get com_addCart => 'أضف للسلة';

  @override
  String get com_addCartToast => 'أضيف للسلة (قيد التطوير)';

  @override
  String get com_methodCoin => 'رصيد العملات';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return 'الرصيد $n';
  }

  @override
  String get com_methodWechat => 'WeChat Pay';

  @override
  String get com_methodAlipay => 'Alipay';

  @override
  String get com_confirmOrder => 'تأكيد الطلب';

  @override
  String get com_qtyOne => 'الكمية 1';

  @override
  String get com_payMethod => 'طريقة الدفع';

  @override
  String get com_lineAmount => 'مبلغ المنتج';

  @override
  String get com_lineCoupon => 'كوبون';

  @override
  String get com_lineCouponUnused => 'غير مستخدم';

  @override
  String get com_lineShipping => 'الشحن';

  @override
  String get com_lineShippingFree => 'مجاني';

  @override
  String get com_total => 'الإجمالي';

  @override
  String get com_submitOrder => 'تقديم الطلب';

  @override
  String get com_submitToast => 'تم تقديم الطلب (الدفع قيد التطوير)';

  @override
  String get ss_tier66_label => 'إضاءة';

  @override
  String get ss_tier66_meaning => 'حظ سعيد';

  @override
  String get ss_tier188_label => 'باقة ورد';

  @override
  String get ss_tier188_meaning => 'من القلب';

  @override
  String get ss_tier520_label => 'أحبه';

  @override
  String get ss_tier520_meaning => 'نبضات قلب';

  @override
  String get ss_tier1314_label => 'إلى الأبد';

  @override
  String get ss_tier1314_meaning => 'أنت فقط';

  @override
  String get ss_tier3344_label => 'أبد الآبدين';

  @override
  String get ss_tier3344_meaning => 'دلال حتى النهاية';

  @override
  String get ss_tier9999_label => 'دعم أسطوري';

  @override
  String get ss_tier9999_meaning => 'أنت رقم 1';

  @override
  String ss_callForFmt(String name) {
    return 'ادعم $name';
  }

  @override
  String get ss_subtitle => 'كلما زادت العملات · أسرعت ظهوره · ارتفع ترتيبك';

  @override
  String ss_balanceFmt(String n) {
    return 'رصيد العملات $n';
  }

  @override
  String get ss_localNote =>
      'تجريبي · الدعم محفوظ محليًا، التسوية بالعملات عند الإطلاق الرسمي';

  @override
  String get ss_celebTitle => 'تم الدعم!';

  @override
  String ss_forFmt(String name, String label) {
    return '$name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins عملة';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return 'الظهور +$delta% · حاليًا $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 أنت المعجب رقم 1 لـ TA! V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return 'أنت الحارس رقم $rank لـ TA · V$level $tier';
  }

  @override
  String get ss_tapToContinue => 'اضغط في أي مكان للمتابعة';

  @override
  String get air_title => 'ترتيب الاختيار';

  @override
  String get air_sub => 'تمتلئ الحرارة فتنطلق · كلما زاد الدعم ارتفع الترتيب';

  @override
  String get air_segCharRank => 'الشخصيات';

  @override
  String get air_segKingRank => 'كبار المعجبين';

  @override
  String get air_chipAll => 'الكل';

  @override
  String get air_chipFemale => 'إناث';

  @override
  String get air_chipMale => 'ذكور';

  @override
  String get air_chipTycoon => 'قطب';

  @override
  String get air_chipDeity => 'إلهي';

  @override
  String get air_chipLegend => 'أسطورة';

  @override
  String get air_emptyChar => 'لا شخصيات في هذا التصنيف بعد';

  @override
  String get air_emptyKing => 'هذه الرتبة لا تزال شاغرة';

  @override
  String get air_debuted => 'ظهر';

  @override
  String get air_leading => 'في المقدمة';

  @override
  String air_heatFmt(String pct) {
    return 'الحرارة $pct%';
  }

  @override
  String get air_doneShoot => 'بدأ التصوير';

  @override
  String air_toGoFmt(String n) {
    return '$n% للظهور';
  }

  @override
  String air_supportKingFmt(String name) {
    return 'كبير المعجبين: $name';
  }

  @override
  String get air_emptyKingPlaceholder => 'في انتظار بطل';

  @override
  String get air_globalKing => 'كبير المعجبين عالميًا';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · يدعم $name';
  }

  @override
  String air_guardFmt(String name) {
    return 'حارس $name';
  }

  @override
  String get cd_secVideos => 'فيديوهات TA';

  @override
  String get cd_secMoments => 'لحظات أعمق';

  @override
  String get cd_actUnlock => 'افتح بالعملات';

  @override
  String get cd_secCredits => 'أعمال TA';

  @override
  String cd_secBoardFmt(String n) {
    return 'لوحة الدعم · $n داعمًا';
  }

  @override
  String get cd_actImInToo => 'أنا أيضًا ›';

  @override
  String get cd_swipeHint => 'اسحب للأسفل · ادعم · افتح';

  @override
  String get cd_introBadge => 'تعريف TA';

  @override
  String get cd_debutProgress => 'حملة الظهور';

  @override
  String get cd_debutHint =>
      'املأ لتبدأ التصوير · ممثلون حقيقيون + AI دراما تفاعلية مميزة';

  @override
  String cd_clipToastFmt(String name) {
    return 'تشغيل المقطع «$name» · قيد التطوير';
  }

  @override
  String cd_momentToastFmt(String title) {
    return 'فتح «$title» · ميزة العملات قيد التطوير';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '«$name» · ميزة المشاهدة قيد التطوير';
  }

  @override
  String get cd_kingBadge => 'كبير مشجعي العمل';

  @override
  String get cd_btnSupport => 'ادعم';

  @override
  String get cd_btnChat => 'دردشة · افتح';

  @override
  String get sp_toolPosterName => 'ملصق الدراما';

  @override
  String get sp_toolPosterDesc =>
      'ارفع صورة وجهك لإنشاء ملصق رأسي لك في هذه الدراما.';

  @override
  String get sp_toolPosterCost => '~5-25 عملة';

  @override
  String get sp_toolVideoNameShort => 'مقطع AI 3 ثوان';

  @override
  String get sp_toolVideoName => 'مقطع دراما AI 3 ثوان';

  @override
  String get sp_toolVideoDesc => 'أنشئ مقطعًا رأسيًا خفيفًا من صورة أو جملة.';

  @override
  String get sp_toolVideoCost => '~40 عملة';

  @override
  String get sp_toolMakeoverName => 'تنكر AI';

  @override
  String get sp_toolMakeoverDesc =>
      'جرب التراثي، الرسمي، الأنمي، الريترو والبورتريه من صورة واحدة.';

  @override
  String get sp_toolMakeoverCost => '~25 عملة';

  @override
  String get sp_toolAvatarName => 'أفاتار AI خاص';

  @override
  String get sp_toolAvatarDesc => 'أنشئ أفاتار شخصي من وجهك، جاهز لتحديث ملفك.';

  @override
  String get sp_toolAvatarCost => '~5-25 عملة';

  @override
  String get sp_sectionHeader => 'ساحة AI';

  @override
  String get sp_subtitle => 'ألعاب AI خفيفة مرتبطة بمشاهدتك للدراما.';

  @override
  String sp_creatingFmt(String title) {
    return 'نُنشئ لـ «$title»';
  }

  @override
  String get sp_chipLinked => 'مرتبط بالقصة';

  @override
  String get sp_chipMall => 'متجر الدراما';

  @override
  String get sp_putInDramaTitle => 'ضع نفسك في الدراما';

  @override
  String get sp_putInDramaBody =>
      'التقط أو ارفع صورة لإنشاء ملصق أو مقطع قصير لهذه الدراما.';

  @override
  String get sp_btnTryRoleplay => 'جرب لعب الدور AI';

  @override
  String get sp_sceneMallTitle => 'متجر المشاهد';

  @override
  String get sp_sceneMallBody =>
      'تصفح أدوات الشاشة، منتجات المشاهد، تعاونات المبدعين.';

  @override
  String get spf_settingsTitle => 'إعدادات الأداة';

  @override
  String spf_linkedToFmt(String title) {
    return 'مرتبط بـ «$title»';
  }

  @override
  String get spf_chooseTool => 'اختر أداة';

  @override
  String spf_genBtnFmt(String cost) {
    return 'أنشئ · $cost';
  }

  @override
  String get spf_noPhotoBtn => 'ارفع صورة أولاً';

  @override
  String get spf_photoReady => 'الصورة جاهزة';

  @override
  String get spf_uploadPhoto => 'ارفع صورتك';

  @override
  String get spf_photoTapToReplace => 'اضغط للاستبدال';

  @override
  String get spf_photoHint => 'وجهك أو جسمك كاملاً، وجه واضح';

  @override
  String get spf_generating => 'AI ينشئ…';

  @override
  String get spf_generatingSub => 'نضعك في الدراما، انتظر قليلاً';

  @override
  String get spf_genDoneTag => 'تم';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · جاهز';
  }

  @override
  String get spf_genDoneBody => 'احفظ في أعمالك، شارك، أو أعد الإنشاء.';

  @override
  String get spf_btnSave => 'احفظ في أعمالي';

  @override
  String get spf_savedToast => 'تم الحفظ (قيد التطوير)';

  @override
  String get spf_shareLabel => 'إبداع AI';

  @override
  String get cui_chipAI => 'تفاعلي AI';

  @override
  String get cui_chipMetaverse => 'عالم الميتافيرس';

  @override
  String get cui_title => 'ميتافيرس الشخصيات';

  @override
  String get cui_lead => 'هنا، من تلتقي به ليس ممثلاً — بل شخص يستجيب لك.';

  @override
  String get cui_body =>
      'لكل شخصية شخصيتها وصوتها وقصتها. تحدث معهم، ادعمهم، ادفع من يخطف قلبك إلى المسرح — من جملة واحدة إلى دراما تفاعلية مميزة تخصكما معًا.';

  @override
  String get cui_step1Title => 'اللقاء & الدردشة';

  @override
  String get cui_step1Desc =>
      'اضغط مطولاً للاستماع، ثم ادخل دردشة فردية. رفقة AI تفهمك أكثر مع كل محادثة.';

  @override
  String get cui_step2Title => 'الدعم & التصويت';

  @override
  String get cui_step2Desc =>
      'أنفق عملاتك لمن تحب، اصعد إلى لوحة الدعم، كن المعجب الأول.';

  @override
  String get cui_step3Title => 'البدء & الظهور';

  @override
  String get cui_step3Desc =>
      'عندما تمتلئ الحملة، يظهرون رسميًا — دراما مميزة بممثلين حقيقيين + AI، تُشعلها أنت.';

  @override
  String get cui_step4Title => 'ضيف الشرف & التعمق';

  @override
  String get cui_step4Desc =>
      'افتح قصصًا خاصة و«لحظات عميقة» — حتى اكتب نفسك في الدراما.';

  @override
  String get cui_footer => 'كل صوت تدلي به، يعيد كتابة من سيكون البطل التالي.';

  @override
  String get com2_title => 'المجتمع';

  @override
  String get com2_chipPlaza => 'ساحة المشاهدة';

  @override
  String get com2_emptyHint => 'لا منشورات بعد — كن الأول';

  @override
  String get com2_btnPost => 'منشور جديد';

  @override
  String get com2_watching => 'أتابع';

  @override
  String get com2_fallbackDrama => 'دراما FalconFlix';

  @override
  String get com2_publishedToast => 'نُشر في المجتمع';

  @override
  String get com2_postHint => 'شارك انطباعك عن هذه الدراما…';

  @override
  String get com2_publish => 'نشر';

  @override
  String get com2_attachDrama => 'أرفق هذه الدراما';

  @override
  String get dhc_connected => 'متصل';

  @override
  String get dhc_connecting => 'جاري الاتصال';

  @override
  String get dhc_ended => 'انتهى';

  @override
  String get dhc_error => 'خطأ';

  @override
  String get dhc_connectingHint => 'جاري الاتصال…انتظر قليلاً';

  @override
  String dhc_talkingFmt(String name) {
    return '$name يتحدث…';
  }

  @override
  String get dhc_listening => 'أستمع إليك…';

  @override
  String get dhc_backLabel => 'رجوع';

  @override
  String get dhc_actorsReady => 'الممثلون يأخذون أماكنهم…';

  @override
  String get ss2_searchHint => 'ابحث عن دراما / ممثل / وسم';

  @override
  String get ss2_history => 'بحث سابق';

  @override
  String get ss2_clear => 'مسح';

  @override
  String get ss2_hot => 'البحث الرائج';

  @override
  String get ss2_hotBadge => 'رائج';

  @override
  String ss2_noResultFmt(String q) {
    return 'لم نجد دراما لـ «$q»';
  }

  @override
  String ss2_foundFmt(String n) {
    return 'وُجدت $n دراما';
  }

  @override
  String get ss2_chipCEO => 'الرئيس المتسلط';

  @override
  String get ss2_chipTimeTravel => 'السفر عبر الزمن';

  @override
  String get ss2_chipMystery => 'غموض';

  @override
  String get ss2_chipModern => 'رومانس حديث';

  @override
  String get ss2_chipSweetPet => 'حب لطيف';

  @override
  String get rk_emptyCat => 'لا ترتيب لهذا التصنيف بعد';

  @override
  String get rk_hotTitle => 'ترتيب الأكثر مشاهدة';

  @override
  String get rk_hotSub => 'ترتيب لحظي حسب حرارة اليوم';

  @override
  String get rk_top1Today => '# 1  الأكثر سخونة اليوم';

  @override
  String rk_heatFmt(String plays) {
    return '$plays حرارة · في صعود';
  }

  @override
  String get rk_chipUrban => 'المدينة';

  @override
  String get rk_chipFinished => 'مكتمل';

  @override
  String get rk_chipRomance => 'رومانسي';

  @override
  String get aic_lowEnergyNag => 'أُهي… الطاقة على وشك النفاد، اشحنني قليلاً؟~';

  @override
  String get aic_chargedReply => 'شكرًا! عاد كل شيء، لنكمل~';

  @override
  String get aic_chargeToast =>
      'شحن · ميزة فواتير العملات قيد التطوير (مملوء وهميًا)';

  @override
  String aic_energyFmt(String pct) {
    return 'الطاقة $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return 'اشحن لـ $name';
  }

  @override
  String aic_hintFmt(String name) {
    return 'قل شيئًا لـ $name…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · يحتاج V$level';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return 'اشحن $amount للوصول إلى V$level';
  }

  @override
  String get lg_btnTopUp => 'اشحن للترقية';

  @override
  String get lg_btnLater => 'لاحقًا';

  @override
  String get me_defaultName => 'مشاهد FalconFlix';

  @override
  String get me_avatarUpdated => 'تم تحديث الصورة الشخصية';

  @override
  String get me_avatarUpdateFailed => 'فشل التحديث، حاول مجددًا';

  @override
  String get me_tapAvatarToChange => 'اضغط على الصورة لتغييرها';

  @override
  String get me_myLevel => 'مستواي';

  @override
  String get me_loginEmail => 'بريد الدخول';

  @override
  String get me_membership => 'العضوية';

  @override
  String get me_uploading => 'جاري الرفع…';

  @override
  String get me_changeAvatar => 'تغيير الصورة';

  @override
  String me_copiedFmt(String value) {
    return 'تم النسخ: $value';
  }

  @override
  String get tier_commoner => 'عادي';

  @override
  String get tier_rookie => 'مبتدئ';

  @override
  String get tier_advanced => 'متقدم';

  @override
  String get tier_lord => 'كبير';

  @override
  String get tier_tycoon => 'قطب';

  @override
  String get tier_deity => 'إلهي';

  @override
  String get tier_legend => 'أسطورة';

  @override
  String get rch_statusPaid => 'تم الإيداع';

  @override
  String get rch_statusPending => 'بانتظار الدفع';

  @override
  String get rch_statusCanceled => 'ملغى';

  @override
  String get rch_statusProcessing => 'قيد المعالجة';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n عملة';
  }

  @override
  String get time_justNow => 'الآن';

  @override
  String time_minutesAgoFmt(String n) {
    return 'قبل $n د';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return 'قبل $n س';
  }

  @override
  String time_daysAgoFmt(String n) {
    return 'قبل $n يوم';
  }

  @override
  String get notify_typeRecharge => 'شحن';

  @override
  String get notify_typeInvite => 'دعوة';

  @override
  String get notify_typeSystem => 'النظام';

  @override
  String get notify_typeActivity => 'فعالية';

  @override
  String get notify_typeInteractive => 'تفاعلي';
}
