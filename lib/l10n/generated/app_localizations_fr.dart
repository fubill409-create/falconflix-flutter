// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FalconFlix';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabTheater => 'Théâtre';

  @override
  String get tabInteractive => 'Interactif';

  @override
  String get tabCharacter => 'Casting';

  @override
  String get tabMe => 'Moi';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_back => 'Retour';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_loading => 'Chargement…';

  @override
  String get common_more => 'Plus';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get common_free => 'Gratuit';

  @override
  String get common_login => 'Se connecter';

  @override
  String get common_logout => 'Se déconnecter';

  @override
  String get common_loadFailed => 'Échec du chargement';

  @override
  String get common_pleaseLogin => 'Veuillez vous connecter d\'abord';

  @override
  String get common_done => 'Terminé';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_send => 'Envoyer';

  @override
  String get me_title => 'Moi';

  @override
  String get me_loginPrompt => 'Se connecter / S\'inscrire';

  @override
  String get me_loginSubtitle =>
      'Connectez-vous pour accéder à votre bibliothèque, portefeuille et dramas interactifs';

  @override
  String get me_membershipNormal => 'Membre';

  @override
  String get me_membershipVip => 'VIP';

  @override
  String get me_inviteCode => 'Code d\'invitation';

  @override
  String get me_statEagleCoins => 'Eagle Coins';

  @override
  String get me_statBoughtEpisodes => 'Achetés';

  @override
  String get me_statCollections => 'Favoris';

  @override
  String get me_sectionMyContent => 'Mon contenu';

  @override
  String get me_sectionWallet => 'Portefeuille';

  @override
  String get me_sectionCommunity => 'Communauté';

  @override
  String get me_sectionCreator => 'Créateur';

  @override
  String get me_sectionSettings => 'Paramètres';

  @override
  String get me_sectionHelpAbout => 'Aide et À propos';

  @override
  String get me_rowCollections => 'Mes favoris';

  @override
  String get me_rowHistory => 'Historique';

  @override
  String get me_rowCommunity => 'Fil communauté';

  @override
  String get me_rowWallet => 'Portefeuille et abonnement';

  @override
  String get me_rowOrders => 'Mes commandes';

  @override
  String get me_rowInvite => 'Inviter des amis';

  @override
  String get me_rowPartner => 'Partenaire créateur';

  @override
  String get me_rowNotifications => 'Notifications';

  @override
  String get me_rowSettings => 'Paramètres';

  @override
  String get me_rowHelpAbout => 'Aide et À propos';

  @override
  String get me_rowAbout => 'À propos de FalconFlix';

  @override
  String get me_logoutConfirm => 'Se déconnecter du compte ?';

  @override
  String get history_title => 'Historique';

  @override
  String get history_emptyTitle => 'Aucun historique';

  @override
  String get history_emptyBody =>
      'Chaque épisode vu apparaîtra ici pour reprendre facilement où vous vous êtes arrêté.';

  @override
  String get history_loginBody =>
      'Connectez-vous pour voir ce que vous avez regardé.';

  @override
  String get history_actionDelSelected => 'Supprimer la sélection';

  @override
  String get history_actionClearAll => 'Tout effacer';

  @override
  String get history_episodeFallback => 'Série complète';

  @override
  String get history_unknown => '(Titre inconnu)';

  @override
  String history_selectedCount(int n) {
    return '$n sélectionnés';
  }

  @override
  String history_delConfirmTitle(int n) {
    return 'Supprimer $n enregistrement(s) ?';
  }

  @override
  String get history_delConfirmBody =>
      'Action irréversible. Le drama n\'est pas affecté — un nouvel enregistrement sera créé à la prochaine lecture.';

  @override
  String get history_clearConfirmTitle => 'Effacer tout l\'historique ?';

  @override
  String get history_clearConfirmBody =>
      'Action irréversible. De nouveaux enregistrements seront créés à la prochaine lecture.';

  @override
  String history_toastDeleted(int n) {
    return '$n supprimés';
  }

  @override
  String get history_toastCleared => 'Effacé';

  @override
  String get orders_title => 'Mes commandes';

  @override
  String get orders_tabFull => 'Série';

  @override
  String get orders_tabEpisode => 'Épisode';

  @override
  String get orders_tabRecharge => 'Recharges';

  @override
  String get orders_emptyFull => 'Aucune commande de série';

  @override
  String get orders_emptyEpisode => 'Aucune commande d\'épisode';

  @override
  String get orders_emptyBody =>
      'Les dramas débloqués apparaissent ici, utile pour les reçus et le support.';

  @override
  String get orders_emptyRecharge => 'Aucune recharge';

  @override
  String get orders_emptyRechargeBody =>
      'Votre première recharge apparaîtra ici.';

  @override
  String get orders_loginBodyOrders =>
      'Connectez-vous pour voir vos commandes.';

  @override
  String get orders_loginBodyRecharge =>
      'Connectez-vous pour voir l\'historique des recharges.';

  @override
  String get orders_kvAmount => 'Montant';

  @override
  String get orders_kvPayMethod => 'Méthode';

  @override
  String get orders_kvTime => 'Heure';

  @override
  String orders_orderCopied(String orderNo) {
    return 'N° de commande copié · $orderNo';
  }

  @override
  String get orders_paid => 'Payé';

  @override
  String get orders_pending => 'En attente';

  @override
  String get orders_payEagle => 'Eagle Coins';

  @override
  String get orders_unknownTitle => '(Titre inconnu)';

  @override
  String get orders_rechargeFallback => 'Recharge Eagle Coins';

  @override
  String get inbox_title => 'Notifications';

  @override
  String get inbox_tabAll => 'Tout';

  @override
  String get inbox_tabRecharge => 'Recharge';

  @override
  String get inbox_tabInvite => 'Invitations';

  @override
  String get inbox_tabSystem => 'Système';

  @override
  String get inbox_tabActivity => 'Promo';

  @override
  String get inbox_tabInteractive => 'Interactif';

  @override
  String get inbox_emptyTitle => 'Aucun message';

  @override
  String get inbox_emptyBody =>
      'Reçus de recharge, récompenses d\'invitation, promos et avis système apparaîtront ici.';

  @override
  String get inbox_loginBody => 'Connectez-vous pour voir vos notifications.';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_sectionNotificationPlayback => 'Notifications et lecture';

  @override
  String get settings_sectionAccount => 'Compte';

  @override
  String get settings_sectionUIStorage => 'Interface et stockage';

  @override
  String get settings_rowNotifyPrefs => 'Notifications';

  @override
  String get settings_rowPlayPrefs => 'Lecture et téléchargements';

  @override
  String get settings_rowAccountSecurity => 'Compte et sécurité';

  @override
  String get settings_rowPrivacy => 'Confidentialité';

  @override
  String get settings_rowLanguage => 'Langue';

  @override
  String get settings_rowClearCache => 'Vider le cache';

  @override
  String get settings_clearCacheTitle => 'Vider le cache ?';

  @override
  String get settings_clearCacheBody =>
      'Efface les vidéos interactives téléchargées et le cache d\'images. Vos achats, connexion et paramètres ne sont pas affectés.';

  @override
  String get settings_clearCacheAction => 'Vider maintenant';

  @override
  String settings_clearCacheDone(String size) {
    return '$size libérés';
  }

  @override
  String get notifyPrefs_title => 'Notifications';

  @override
  String get notifyPrefs_pushMaster => 'Interrupteur push principal';

  @override
  String get notifyPrefs_pushMasterDesc =>
      'Désactiver met en pause toutes les notifications push. La boîte de réception in-app reste active.';

  @override
  String get notifyPrefs_recharge => 'Confirmations de recharge';

  @override
  String get notifyPrefs_rechargeDesc =>
      'Recharge réussie / Eagle Coins crédités';

  @override
  String get notifyPrefs_invite => 'Récompenses d\'invitation';

  @override
  String get notifyPrefs_inviteDesc =>
      'Inscriptions d\'amis / récompenses reçues';

  @override
  String get notifyPrefs_system => 'Avis système';

  @override
  String get notifyPrefs_systemDesc =>
      'Sécurité du compte / changements importants';

  @override
  String get notifyPrefs_activity => 'Promotions';

  @override
  String get notifyPrefs_activityDesc => 'Nouveaux dramas / promos de recharge';

  @override
  String get notifyPrefs_interactive => 'Mises à jour interactives';

  @override
  String get notifyPrefs_interactiveDesc =>
      'Nouveaux épisodes / fins débloquées';

  @override
  String notifyPrefs_saveFailed(String msg) {
    return 'Échec de l\'enregistrement : $msg';
  }

  @override
  String get playPrefs_title => 'Lecture et téléchargements';

  @override
  String get playPrefs_autoplay => 'Lecture auto suivante';

  @override
  String get playPrefs_autoplayDesc => 'Lecture auto de la vidéo suivante';

  @override
  String get playPrefs_wifiOnlyAutoplay => 'Lecture auto en Wi-Fi uniquement';

  @override
  String get playPrefs_wifiOnlyAutoplayDesc =>
      'Pas de lecture auto en mobile, économisez les données';

  @override
  String get playPrefs_quality => 'Qualité par défaut';

  @override
  String get playPrefs_qualityAuto => 'Auto (selon le réseau)';

  @override
  String get playPrefs_quality480 => 'SD 480p';

  @override
  String get playPrefs_quality720 => 'HD 720p';

  @override
  String get playPrefs_quality1080 => 'Full HD 1080p';

  @override
  String get playPrefs_wifiOnlyDownload => 'Téléchargements Wi-Fi uniquement';

  @override
  String get playPrefs_wifiOnlyDownloadDesc =>
      'Vidéos interactives et cache hors ligne uniquement en Wi-Fi';

  @override
  String get accountSec_title => 'Compte et sécurité';

  @override
  String get accountSec_sectionLogin => 'Connexion';

  @override
  String get accountSec_sectionDeletion => 'Suppression du compte';

  @override
  String get accountSec_rowChangePwd => 'Changer le mot de passe';

  @override
  String get accountSec_rowChangePwdDesc => 'Le mot de passe actuel est requis';

  @override
  String get accountSec_rowDelete => 'Supprimer le compte';

  @override
  String get accountSec_rowDeleteDesc =>
      'Période de réflexion de 7 jours, connectez-vous pour annuler';

  @override
  String get accountSec_oldPwHint => 'Mot de passe actuel';

  @override
  String get accountSec_newPwHint => 'Nouveau mot de passe (8 caractères min.)';

  @override
  String get accountSec_confirmPwHint => 'Confirmer le nouveau mot de passe';

  @override
  String get accountSec_errMinLen =>
      'Le nouveau mot de passe doit faire au moins 8 caractères';

  @override
  String get accountSec_errMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get accountSec_saveNewPw => 'Enregistrer le nouveau mot de passe';

  @override
  String get accountSec_saving => 'Enregistrement…';

  @override
  String get accountSec_pwUpdated => 'Mot de passe mis à jour';

  @override
  String get privacyPrefs_title => 'Confidentialité';

  @override
  String get privacyPrefs_sectionData => 'Mes données';

  @override
  String get privacyPrefs_sectionLegal => 'Conditions et politique';

  @override
  String get privacyPrefs_rowExport => 'Télécharger mes données';

  @override
  String get privacyPrefs_rowExportDesc =>
      'GDPR / CCPA : demander un export complet de vos données';

  @override
  String get privacyPrefs_rowPolicy => 'Politique de confidentialité';

  @override
  String get deleteAcc_title => 'Supprimer le compte';

  @override
  String get deleteAcc_inProgress => 'Suppression en cours';

  @override
  String deleteAcc_scheduledAt(String time) {
    return 'Programmé : $time';
  }

  @override
  String get deleteAcc_pendingHint =>
      'Connectez-vous à tout moment pendant les 7 jours de réflexion pour annuler. Le compte reprendra normalement après annulation.';

  @override
  String get deleteAcc_cancelBtn => 'Annuler la suppression';

  @override
  String get deleteAcc_willDelete => 'La suppression effacera';

  @override
  String get deleteAcc_bullet1 => 'Profil, pseudo, avatar, email, téléphone';

  @override
  String get deleteAcc_bullet2 =>
      'Solde du portefeuille (Eagle Coins non remboursables), VIP / niveau';

  @override
  String get deleteAcc_bullet3 => 'Dramas achetés et débloquages interactifs';

  @override
  String get deleteAcc_bullet4 =>
      'Historique, favoris, posts communauté, sauvegardes interactives';

  @override
  String get deleteAcc_bullet5 =>
      'Invitations (les enregistrements côté invité sont conservés)';

  @override
  String get deleteAcc_coolingHint =>
      'La soumission lance 7 jours de réflexion. Connectez-vous pendant cette période pour annuler. À l\'expiration, le compte est supprimé définitivement.';

  @override
  String get deleteAcc_reasonLabel =>
      'Raison (optionnel, nous aide à améliorer)';

  @override
  String get deleteAcc_reasonHint => 'Dites-nous ce qui ne va pas (optionnel)';

  @override
  String deleteAcc_typeToConfirm(String phrase) {
    return 'Saisissez \"$phrase\" pour confirmer';
  }

  @override
  String get deleteAcc_confirmPhrase => 'SUPPRIMER MON COMPTE';

  @override
  String deleteAcc_typeMismatch(String phrase) {
    return 'Veuillez saisir \"$phrase\" exactement';
  }

  @override
  String get deleteAcc_submit => 'Soumettre la suppression';

  @override
  String get deleteAcc_finalTitle => 'Confirmation finale';

  @override
  String get deleteAcc_finalBody =>
      'Démarre 7 jours de réflexion. Connectez-vous pendant cette période pour annuler.\n\nÀ l\'expiration, les données sont supprimées définitivement.';

  @override
  String get deleteAcc_finalSubmit => 'Soumettre la suppression';

  @override
  String get deleteAcc_submitted =>
      'Demande de suppression envoyée — exécution dans 7 jours';

  @override
  String get deleteAcc_cancelled => 'Suppression annulée';

  @override
  String get deleteAcc_thinkAgain => 'Pas encore, revenir';

  @override
  String get dataExport_title => 'Télécharger mes données';

  @override
  String get dataExport_introTitle => 'Obtenir une copie de vos données';

  @override
  String get dataExport_introBody =>
      'Conformément au RGPD Article 15 (UE) et au CCPA (Californie), vous avez le droit de recevoir toutes les données personnelles que nous détenons sur vous.\n\nAprès soumission, nous générons un fichier zip de manière asynchrone :\n  · Profil / email / téléphone\n  · Solde et transactions Eagle Coins\n  · Commandes, historique, favoris\n  · Posts communauté, débloquages interactifs\n\nLorsque prêt, nous vous notifierons in-app. Le lien de téléchargement est valable 7 jours.';

  @override
  String get dataExport_statusQueued => 'En attente · file';

  @override
  String get dataExport_statusProcessing => 'En cours · création';

  @override
  String get dataExport_statusReady => 'Prêt · télécharger';

  @override
  String get dataExport_statusExpired => 'Expiré · refaire la demande';

  @override
  String get dataExport_statusFailed => 'Échec · refaire la demande';

  @override
  String dataExport_expiresAt(String time) {
    return 'Lien expire $time';
  }

  @override
  String get dataExport_downloadBtn => 'Télécharger';

  @override
  String get dataExport_submitBtn => 'Demander le téléchargement';

  @override
  String get dataExport_submitting => 'Envoi…';

  @override
  String get dataExport_submitted =>
      'Demande envoyée — nous vous notifierons quand prêt';

  @override
  String get helpAbout_title => 'Aide et À propos';

  @override
  String get helpAbout_sectionHelp => 'Aide';

  @override
  String get helpAbout_sectionAbout => 'À propos';

  @override
  String get helpAbout_rowFaq => 'Centre d\'aide';

  @override
  String get helpAbout_rowFaqDesc => 'Foire aux questions';

  @override
  String get helpAbout_rowSupport => 'Contacter le support';

  @override
  String get helpAbout_rowSupportDesc => 'Discussion 1-à-1 par ticket';

  @override
  String get helpAbout_rowFeedback => 'Envoyer un avis';

  @override
  String get helpAbout_rowFeedbackDesc => 'Idées produit / rapports de bug';

  @override
  String get faq_title => 'Centre d\'aide';

  @override
  String get faq_catAll => 'Tout';

  @override
  String get faq_catAccount => 'Compte';

  @override
  String get faq_catRecharge => 'Recharge';

  @override
  String get faq_catPlayback => 'Lecture';

  @override
  String get faq_catInteractive => 'Interactif';

  @override
  String get faq_catOther => 'Autre';

  @override
  String get faq_emptyTitle => 'Aucune FAQ';

  @override
  String get faq_emptyBody =>
      'En cas de problème, ouvrez un ticket de support.';

  @override
  String get tickets_title => 'Contacter le support';

  @override
  String get tickets_newBtn => 'Nouveau ticket';

  @override
  String get tickets_emptyTitle => 'Aucun ticket';

  @override
  String get tickets_emptyBody =>
      'Appuyez sur le bouton pour créer un nouveau ticket. Le support répond 1-à-1.';

  @override
  String get tickets_threadTitle => 'Détail du ticket';

  @override
  String get tickets_initial => 'Problème initial';

  @override
  String get tickets_speakerStaff => 'Support';

  @override
  String get tickets_speakerSelf => 'Moi';

  @override
  String get tickets_replyHint => 'Répondre…';

  @override
  String tickets_sendFailed(String msg) {
    return 'Échec d\'envoi : $msg';
  }

  @override
  String get tickets_statusPending => 'En attente';

  @override
  String get tickets_statusReplied => 'Répondu';

  @override
  String get tickets_statusResolved => 'Résolu';

  @override
  String get tickets_statusClosed => 'Fermé';

  @override
  String get feedback_titleTicket => 'Nouveau ticket';

  @override
  String get feedback_titleFeedback => 'Envoyer un avis';

  @override
  String get feedback_typeBug => 'Rapport de bug';

  @override
  String get feedback_typeSuggestion => 'Suggestion';

  @override
  String get feedback_typeComplaint => 'Plainte';

  @override
  String get feedback_typeRecharge => 'Problème de recharge';

  @override
  String get feedback_typeOther => 'Autre';

  @override
  String get feedback_typeLabel => 'Type de problème';

  @override
  String get feedback_contentLabel => 'Détails';

  @override
  String get feedback_contentHintTicket =>
      'Décrivez le problème en détail pour une aide plus rapide…';

  @override
  String get feedback_contentHintFeedback => 'Dites-nous ce que vous pensez…';

  @override
  String get feedback_contactLabel => 'Email / téléphone de retour (optionnel)';

  @override
  String get feedback_contactHint => 'Nous prioriserons la réponse. Optionnel.';

  @override
  String get feedback_submit => 'Envoyer';

  @override
  String get feedback_submitting => 'Envoi…';

  @override
  String get feedback_submitted => 'Envoyé — le support répondra';

  @override
  String get feedback_minLength => 'Veuillez écrire au moins 5 caractères';

  @override
  String feedback_tip(String version) {
    return 'Astuce : pour un bug, ajoutez les étapes de reproduction + captures (bientôt) pour un tri plus rapide.\nVersion : $version';
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
  String get home_noDramaData => 'Aucune série pour l\'instant';

  @override
  String get home_localOnlyLike => 'Source locale : like non pris en charge';

  @override
  String get home_localOnlyCollect =>
      'Source locale : enregistrement non pris en charge';

  @override
  String get home_addedToMy => 'Enregistré dans « Mon profil »';

  @override
  String get home_actionLike => 'J\'aime';

  @override
  String get home_actionCollected => 'Enregistré';

  @override
  String get home_actionCollect => 'Enregistrer';

  @override
  String get home_actionShare => 'Partager';

  @override
  String get home_shopComingSoon =>
      'Article vu dans la série · IA (boutique à venir)';

  @override
  String get home_chipAiTheater => 'Théâtre IA';

  @override
  String get home_bannerPremiere => 'Première : drama IA';

  @override
  String get home_btnWatch => 'Regarder';

  @override
  String get home_btnDetails => 'Détails';

  @override
  String home_loadFailedFmt(String message) {
    return 'Échec du chargement\n$message';
  }

  @override
  String get theater_genreAll => 'Tout';

  @override
  String get theater_genreRomance => 'Romance';

  @override
  String get theater_genreUrban => 'Urbain';

  @override
  String get theater_genreInteractive => 'Interactif';

  @override
  String get theater_genreFinished => 'Terminé';

  @override
  String get theater_sectionHot => 'Tendances';

  @override
  String get theater_seeAll => 'Tout voir';

  @override
  String get theater_sectionAll => 'Toutes les séries';

  @override
  String get theater_ranking => 'Classement';

  @override
  String get theater_today => 'Coup de cœur du jour';

  @override
  String get theater_labelShort => 'Mini-série';

  @override
  String theater_continueWatch(String name) {
    return 'Reprendre · $name';
  }

  @override
  String theater_heatFmt(String heat) {
    return '$heat vues';
  }

  @override
  String theater_genreHeatFmt(String tag, String heat) {
    return '$tag · $heat vues';
  }

  @override
  String get cast_sectionPlaying => 'À l\'écran & Castings';

  @override
  String get cast_oppRanking => 'Tableau d\'opportunités ›';

  @override
  String get cast_universeTitle => 'Métavers des personnages';

  @override
  String get cast_universeSub =>
      'Rencontrez ceux qui vous répondent · Découvrez ce monde';

  @override
  String get cast_demoBadge => 'Démo · Jouable';

  @override
  String get cast_demoTitle => 'Drama interactif (démo)';

  @override
  String get cast_demoSub =>
      'À vous de choisir — une réplique allume un drama entier';

  @override
  String get cast_inPlay => 'À l\'écran';

  @override
  String cast_heatTagFmt(String heat, String tag) {
    return '$heat vues · $tag';
  }

  @override
  String cast_heatOnlyFmt(String heat) {
    return '$heat vues';
  }

  @override
  String get cb_sectionSupport => 'Tableau des soutiens · Qui vote pour eux';

  @override
  String get cb_goSupport => 'Soutenir · Lancez leur carrière';

  @override
  String get cb_seeBio => 'Voir le profil ›';

  @override
  String cb_pollHeatPct(String pct) {
    return 'Soutien $pct%';
  }

  @override
  String get cb_debuted => 'En tournage';

  @override
  String cb_toDebutPct(String pct) {
    return '$pct% avant tournage';
  }

  @override
  String get cb_totalSupport => 'Soutien total';

  @override
  String cb_coinsFmt(String coins) {
    return '$coins Eagle Coins';
  }

  @override
  String get cb_topBacker => 'Premier soutien';

  @override
  String get cb_emptyBackers => 'Aucun soutien · Soyez le premier';

  @override
  String cb_titleSupportFmt(String name) {
    return '$name · Tableau des soutiens';
  }

  @override
  String get aid_titleHeader => 'Drama interactif IA';

  @override
  String get aid_aceBadge => 'Pépite';

  @override
  String get aid_tagline => 'Vos choix réécrivent la fin.';

  @override
  String get aid_demoBadge => 'Démo · Essai gratuit';

  @override
  String get aid_lastcallSub =>
      '5 niveaux de choix · 7 fins · Votre choix réécrit l\'histoire';

  @override
  String get aid_pipelineTitle => 'Studio des étoiles';

  @override
  String get aid_pipelineSub => 'Sélection signature · Productions en route';

  @override
  String get aid_cameoTitle => 'Se mettre en scène';

  @override
  String get aid_cameoSub => 'Envoyez une photo, entrez dans l\'histoire';

  @override
  String get aid_castingBadge => 'Casting en cours';

  @override
  String get aid_producingBadge => 'En production';

  @override
  String aid_castVoteFmt(String pct) {
    return 'Votez pour le casting · $pct%';
  }

  @override
  String get aid_manifesto1 =>
      'Vous ne regardez plus simplement des histoires.';

  @override
  String get aid_manifesto2 =>
      'Vous choisissez pour le héros, et l\'histoire réécrit la fin pour vous.';

  @override
  String get aid_manifesto3 =>
      'Chaque choix est un dialogue entre vous et ce monde.';

  @override
  String get aid_manifestoHeader => 'Pourquoi nous créons du drama interactif';

  @override
  String get aid_metaversePre =>
      'Nous l\'appelons « drama interactif » —\nmais c\'est en réalité ';

  @override
  String get aid_metaverseEmph =>
      'le premier acte du « Métavers de la décision »';

  @override
  String get aid_metaversePost =>
      ' :\nun monde où vous décidez, à partir d\'ici.';

  @override
  String get aid_step1Title => 'Regarder';

  @override
  String get aid_step1Sub => 'Asseyez-vous, laissez l\'histoire vous prendre.';

  @override
  String get aid_step2Title => 'Choix interactif';

  @override
  String get aid_step2Sub =>
      'À chaque carrefour, décidez pour le héros ; l\'histoire bifurque.';

  @override
  String get aid_step3Title => 'Se mettre en scène';

  @override
  String get aid_step3Sub => 'Votre visage, votre nom, dans cette histoire.';

  @override
  String get aid_step4Title => 'Soutenir leur ascension';

  @override
  String get aid_step4Sub =>
      'Soutenez le personnage que vous aimez, hissez-le sur scène.';

  @override
  String get aid_step5Title => 'Métavers de la décision';

  @override
  String get aid_step5Sub => 'Le but : un monde où vous décidez.';

  @override
  String get aid_ladderHeader => 'D\'un choix à un monde entier';

  @override
  String get aid_liveTitle => 'Disponible · Jouable';

  @override
  String get aid_liveSub =>
      'Vrai drama interactif · Vos choix réécrivent l\'histoire';

  @override
  String get aid_fallbackHook => 'Vos choix réécrivent son histoire';

  @override
  String get aid_aceCardBadge => 'Drama interactif signature · Jouable';

  @override
  String get player_btnLiked => 'Aimé';

  @override
  String get player_btnEpisodes => 'Épisodes';

  @override
  String get player_btnAiCast => 'Caméo IA';

  @override
  String player_episodeNumFmt(int n) {
    return 'Épisode $n';
  }

  @override
  String player_switchEpFmt(int n) {
    return 'Passage à l\'épisode $n (backend en cours)';
  }

  @override
  String get player_unlockHint =>
      'Débloquez en Eagle Coins sur la page de la série';

  @override
  String player_comingSoonFmt(String label) {
    return '$label (à venir)';
  }

  @override
  String get player_sceneSame => 'Vu dans la scène';

  @override
  String get detail_unlockThis => 'Cet épisode';

  @override
  String get detail_unlockNext5 => '5 épisodes suivants';

  @override
  String get detail_unlockNext10 => '10 épisodes suivants';

  @override
  String get detail_unlockAll => 'Série complète';

  @override
  String detail_episodeCountFmt(int n) {
    return '$n épisodes';
  }

  @override
  String get detail_drawerEpisodes => 'Liste des épisodes';

  @override
  String get detail_unlockSuccess => 'Débloqué !';

  @override
  String detail_coinBalanceFmt(String coins) {
    return 'Solde : $coins Eagle Coins';
  }

  @override
  String detail_playsCountFmt(String n) {
    return '$n vues';
  }

  @override
  String detail_priceUnlockFmt(String coins) {
    return 'Débloquer pour $coins Eagle Coins';
  }

  @override
  String get detail_playNow => 'Lire maintenant';

  @override
  String get detail_playThis => 'Lire cette série';

  @override
  String get detail_noEpisodes => 'Aucun épisode disponible';

  @override
  String get login_welcome => 'Bienvenue sur FalconFlix';

  @override
  String get login_subtitle =>
      'Connectez-vous pour débloquer séries, Eagle Coins, drama interactif';

  @override
  String get login_emailLabel => 'E-mail';

  @override
  String get login_passwordLabel => 'Mot de passe';

  @override
  String get login_codeLabel => 'Code de vérification';

  @override
  String get login_codeHint => 'Code à 6 chiffres';

  @override
  String get login_pwInputHint => 'Saisir le mot de passe';

  @override
  String get login_modeOtp => 'Code e-mail';

  @override
  String get login_modePassword => 'Mot de passe';

  @override
  String get login_getCode => 'Envoyer le code';

  @override
  String get login_sending => 'Envoi en cours';

  @override
  String get login_loggingIn => 'Connexion…';

  @override
  String get login_loginOrRegister => 'Connexion / Inscription';

  @override
  String get login_pwHint =>
      'La première connexion par mot de passe crée le compte avec ce mot de passe';

  @override
  String get login_devHint => 'Test : entrez 749301 pour passer';

  @override
  String get login_quickLogin => 'Connexion rapide';

  @override
  String get login_recommended => 'Recommandé';

  @override
  String get login_success => 'Connecté';

  @override
  String get login_agreement =>
      'En vous connectant, vous acceptez les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get login_emailInvalid => 'Veuillez d\'abord saisir un e-mail valide';

  @override
  String get login_emailRequired => 'Veuillez saisir un e-mail valide';

  @override
  String get login_passwordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get login_codeRequired => 'Veuillez saisir le code';

  @override
  String get login_codeSent => 'Code envoyé. Vérifiez votre boîte mail.';

  @override
  String get login_emailNotConfigured =>
      'Canal e-mail non configuré ; utilisez le code test 749301';

  @override
  String get login_networkError =>
      'Échec de connexion ; vérifiez le réseau et réessayez';

  @override
  String login_oauthErrorFmt(String provider, String code) {
    return 'Échec de connexion $provider : $code';
  }

  @override
  String login_oauthRetryFmt(String provider) {
    return 'Échec de connexion $provider ; veuillez réessayer plus tard';
  }

  @override
  String login_oauthComingFmt(String name) {
    return 'Connexion $name bientôt disponible';
  }

  @override
  String get login_oauthComingBody =>
      'Bientôt prêt — connectez-vous par code e-mail ou mot de passe pour l\'instant.';

  @override
  String get login_gotIt => 'Compris';

  @override
  String get login_googleNoToken =>
      'Google n\'a pas retourné d\'idToken ; vérifiez les identifiants';

  @override
  String get about_tagline => 'FalconFlix · Du drama à voir';

  @override
  String get about_body =>
      'FalconFlix est une plateforme mondiale de mini-séries premium — bingez, discutez avec des personnages IA, achetez en regardant. Production cinéma et créativité IA pour que chaque image vaille le coup.';

  @override
  String get about_userAgreement => 'Conditions d\'utilisation';

  @override
  String get about_privacyPolicy => 'Politique de confidentialité';

  @override
  String about_legalUpdatedFmt(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get about_operatingEntity => 'Entité exploitante';

  @override
  String about_contactEmailFmt(String email) {
    return 'Contact : $email';
  }

  @override
  String about_aboutTitleFmt(String appName) {
    return 'À propos de $appName';
  }

  @override
  String get wallet_title => 'Recharger Eagle Coins';

  @override
  String get wallet_chooseRecharge => 'Choisir un pack';

  @override
  String get wallet_introNote =>
      'Les Eagle Coins débloquent épisodes, jeux interactifs et soutiens';

  @override
  String get wallet_menuAutoUnlock => 'Réglage du déverrouillage auto';

  @override
  String get wallet_menuHistory => 'Historique des recharges';

  @override
  String get wallet_menuReceipt => 'E-mail du reçu';

  @override
  String get wallet_stripeNotice => 'Paiement sécurisé par Stripe · USD';

  @override
  String get wallet_loadFailed => 'Échec du chargement, veuillez réessayer';

  @override
  String get wallet_packsComing => 'Packs bientôt disponibles';

  @override
  String get wallet_packsComingBody =>
      'Nous préparons les meilleurs packs Eagle Coins pour vous';

  @override
  String get wallet_coins => 'Eagle Coins';

  @override
  String wallet_giftFmt(String coins) {
    return '+$coins bonus';
  }

  @override
  String get wallet_bestDeal => 'Meilleure valeur';

  @override
  String wallet_payNowFmt(String price) {
    return 'Payer $price maintenant';
  }

  @override
  String get wallet_payNow => 'Payer';

  @override
  String get wallet_loginFirst => 'Veuillez vous connecter d\'abord';

  @override
  String get wallet_openPayFail =>
      'Impossible d\'ouvrir la page de paiement, réessayez';

  @override
  String get wallet_payFail => 'Échec du paiement, veuillez réessayer';

  @override
  String get wallet_balanceLabel => 'Solde Eagle Coins';

  @override
  String get wallet_loginToView => 'Connectez-vous pour voir';

  @override
  String get wallet_legendPeak => 'Sommet légendaire · Au max';

  @override
  String wallet_toLevelFmt(String level) {
    return 'jusqu\'à V$level';
  }

  @override
  String wallet_paidUsdFmt(String amount) {
    return 'Total rechargé $amount';
  }

  @override
  String wallet_topUpToLevelFmt(String amount, String level) {
    return 'Rechargez $amount de plus pour V$level';
  }

  @override
  String get wallet_successTitle => 'Recharge réussie · Crédité';

  @override
  String get wallet_tapAnywhere => 'Appuyez n\'importe où pour continuer';

  @override
  String get wallet_successBarrier => 'Recharge réussie';

  @override
  String get creator_title => 'Centre Partenaires';

  @override
  String get creator_statSeries => 'Séries';

  @override
  String get creator_statPlays => 'Vues';

  @override
  String get creator_statShare => 'Partage';

  @override
  String get creator_applyLabel => 'Postuler comme partenaire série';

  @override
  String get creator_applyToast => 'Candidature envoyée (à venir)';

  @override
  String get creator_menuRequirement => 'Exigences d\'upload';

  @override
  String get creator_menuRevenue => 'Règles de partage';

  @override
  String get creator_menuLangPriv => 'Langues & confidentialité';

  @override
  String get invite_title => 'Inviter des amis';

  @override
  String get invite_stepsTitle => 'Comment ça marche';

  @override
  String get invite_step1Title => 'Partagez votre code';

  @override
  String get invite_step1Sub => 'Envoyez votre code d\'invitation à un ami';

  @override
  String get invite_step2Title => 'L\'ami s\'inscrit avec';

  @override
  String get invite_step2Sub => 'Il saisit votre code à l\'inscription';

  @override
  String get invite_step3Title => 'Vous gagnez tous les deux';

  @override
  String get invite_step3Sub =>
      'Une fois inscrit, vous recevez chacun des Eagle Coins';

  @override
  String get invite_copyMessage => 'Copier le message d\'invitation';

  @override
  String get invite_loginToGet => 'Connectez-vous pour obtenir votre code';

  @override
  String get invite_loginToGen => 'Connectez-vous pour générer votre code';

  @override
  String get invite_messageCopied => 'Message copié — collez-le pour votre ami';

  @override
  String invite_messageTemplateFmt(String code) {
    return '🦅 Je regarde FalconFlix, c\'est top ! Utilise mon code d\'invitation $code à l\'inscription, on gagne chacun des Eagle Coins~';
  }

  @override
  String get invite_bigTitle => 'Invitez des amis, regardez ensemble';

  @override
  String get invite_bigSub =>
      'Quand un ami s\'inscrit avec votre code, vous gagnez tous les deux';

  @override
  String get invite_myCode => 'Mon code d\'invitation';

  @override
  String get invite_copyBtn => 'Copier';

  @override
  String invite_codeCopiedFmt(String code) {
    return 'Code copié : $code';
  }

  @override
  String get collect_emptyTitle => 'Aucune série enregistrée';

  @override
  String get collect_emptyBody =>
      'Appuyez sur « Enregistrer » dans une série pour la retrouver ici.';

  @override
  String get au_title => 'Déverrouillage auto';

  @override
  String get au_introTitle => 'Ne coupez pas le binge';

  @override
  String get au_introBody =>
      'Activé, l\'épisode suivant se déverrouille automatiquement avec des Eagle Coins';

  @override
  String get au_toggleLabel => 'Déverrouiller automatiquement';

  @override
  String get au_on => 'Activé';

  @override
  String get au_off => 'Désactivé';

  @override
  String get au_toggleOnToast => 'Déverrouillage auto activé';

  @override
  String get au_toggleOffToast => 'Déverrouillage auto désactivé';

  @override
  String get au_rule1 =>
      'Les épisodes verrouillés se débloquent en coins, sans popup';

  @override
  String get au_rule2 =>
      'Si le solde est bas, on vous propose de recharger ; pas de débit surprise';

  @override
  String get au_rule3 =>
      'Épisodes uniquement ; le déverrouillage série entière nécessite confirmation manuelle';

  @override
  String get rh_title => 'Historique des recharges';

  @override
  String get rh_loginToView => 'Connectez-vous pour voir l\'historique';

  @override
  String get rh_emptyBody =>
      'Aucune recharge\nRechargez pour débloquer plus de séries';

  @override
  String get rh_fallback => 'Recharge Eagle Coins';

  @override
  String get re_title => 'E-mail du reçu';

  @override
  String get re_invalidEmail => 'Veuillez saisir un e-mail valide';

  @override
  String get re_saved => 'E-mail du reçu enregistré';

  @override
  String get re_label => 'E-mail du reçu';

  @override
  String get re_body =>
      'Après une recharge réussie, Stripe envoie le reçu à cet e-mail ; il sera pré-rempli au prochain paiement.';

  @override
  String re_useAccountEmailFmt(String email) {
    return 'Utiliser l\'e-mail de connexion $email';
  }

  @override
  String get re_save => 'Enregistrer';

  @override
  String common_comingSoonFmt(String name) {
    return '$name (à venir)';
  }

  @override
  String get sheets_episodeTitle => 'Épisodes';

  @override
  String get sheets_unlockAllBtn => 'Tout débloquer';

  @override
  String get sheets_unlockTitle => 'Débloquer';

  @override
  String get sheets_unlockChooseCount => 'Choisir combien débloquer';

  @override
  String get sheets_unlockFailed => 'Échec du déblocage. Réessayez.';

  @override
  String get sheets_networkErr => 'Erreur réseau. Réessayez.';

  @override
  String get sheets_walletBalance => 'Solde de pièces';

  @override
  String sheets_coinsFmt(String coins) {
    return '$coins pièces';
  }

  @override
  String sheets_unlockShortFmt(String coins) {
    return 'Il manque $coins pièces — rechargez pour débloquer';
  }

  @override
  String sheets_unlockNowFmt(String coins) {
    return 'Débloquer · $coins pièces';
  }

  @override
  String get sheets_coinsNotEnough => 'Pièces insuffisantes · Recharger';

  @override
  String sheets_tierForeverFmt(String count) {
    return '$count épisodes · pour toujours';
  }

  @override
  String get sheets_unlockAllSub => 'Débloquer la série';

  @override
  String get sheets_unlockThisSub => 'Débloquer cet épisode';

  @override
  String sheets_unlockAllForeverFmt(String count) {
    return 'Débloquer les $count épisodes · pour toujours';
  }

  @override
  String get sheets_unlockThisForever =>
      'Débloquer cet épisode · pour toujours';

  @override
  String get sheets_coinsShort => 'pièces';

  @override
  String get sheets_vipDiscount => 'Tarif VIP plus bas';

  @override
  String get sheets_shareTitle => 'Partager';

  @override
  String get sheets_shareSub => 'Partager ce drama';

  @override
  String get sheets_copyLink => 'Copier le lien';

  @override
  String get sheets_linkCopiedShort => 'Lien copié';

  @override
  String get sheets_linkCopiedLong => 'Lien copié — colle-le à ton ami';

  @override
  String get sheets_shareTargetMessage => 'Message';

  @override
  String get sheets_shareTargetPoster => 'Poster';

  @override
  String get sheets_shareTargetCommunity => 'Fil';

  @override
  String get sheets_shareTargetRemix => 'Remix';

  @override
  String get sheets_remixComingShort => 'Remix IA · bientôt';

  @override
  String get sheets_remixComingFooter =>
      'Remix IA arrive bientôt — restez connecté';

  @override
  String get sheets_fallbackTitle => 'Drama premium sur FalconFlix';

  @override
  String sheets_shareTextFmt(String title, String url) {
    return '$title est génial — viens regarder sur FalconFlix ! $url';
  }

  @override
  String get sheets_posterTitle => 'Poster';

  @override
  String get sheets_posterMakeSub => 'Créer un poster signature';

  @override
  String get sheets_posterReady => 'Partager le poster';

  @override
  String get sheets_posterGenerating => 'Génération du poster…';

  @override
  String get sheets_posterGenFail => 'Échec de génération du poster';

  @override
  String get sheets_posterExportFail => 'Échec d\'export du poster';

  @override
  String get sheets_posterTagline => 'Scanne pour regarder ensemble';

  @override
  String get ixp_resumeTitle => 'Reprends où tu t\'es arrêté';

  @override
  String get ixp_resumeBody =>
      'Reprendre depuis ta dernière position ou recommencer depuis le début ?';

  @override
  String get ixp_resumeFromStart => 'Recommencer';

  @override
  String get ixp_resumeContinue => 'Continuer';

  @override
  String ixp_fetchFailedFmt(String code) {
    return 'Échec du chargement ($code)';
  }

  @override
  String get ixp_dataAnomaly => 'Données invalides (pas de nœud de départ)';

  @override
  String ixp_loadErrorFmt(String msg) {
    return 'Erreur de chargement : $msg';
  }

  @override
  String ixp_nodeNotFoundFmt(String id) {
    return 'Nœud « $id » introuvable';
  }

  @override
  String get ixp_nodeJumpTitle => 'Saut de nœud · test owner';

  @override
  String get ixp_nodeJumpBody =>
      'Masqué pour les utilisateurs normaux. Touche un nœud pour y sauter directement (les flags restent inchangés).';

  @override
  String ixp_segCountFmt(String n) {
    return '$n segs';
  }

  @override
  String ixp_lockedToastFmt(String price) {
    return 'Branche payante (après lancement $price pièces) · gratuit cette fois';
  }

  @override
  String get ixp_fallbackTitle => 'Drama interactif';

  @override
  String get ixp_btnSkip => 'Passer';

  @override
  String get ixp_btnBack => 'Retour';

  @override
  String get ixp_segGenerating => 'Cette partie est en cours de génération…';

  @override
  String get ixp_btnContinue => 'Continuer';

  @override
  String ixp_prepFmt(String done, String total) {
    return 'Préparation $done / $total';
  }

  @override
  String get ixp_prep => 'Préparation…';

  @override
  String get ixp_yourChoice => 'À toi de choisir';

  @override
  String get ixp_endingFallback => 'Fin';

  @override
  String get ixp_btnReplay => 'Revoir';

  @override
  String get ixp_endingGood => 'Bonne fin';

  @override
  String get ixp_endingBad => 'Mauvaise fin';

  @override
  String get ixp_endingHidden => 'Fin cachée';

  @override
  String get ixp_endingOpen => 'Fin ouverte';

  @override
  String ixp_optionsCountFmt(String n) {
    return '$n options';
  }

  @override
  String get ip_busyAiCreatingTitle => 'L\'IA crée pour toi';

  @override
  String get ip_busyAiCreatingSub =>
      'Ta fin sur mesure se génère image par image…\nÇa prend quelques minutes, on te préviendra — explore autre chose en attendant';

  @override
  String get ip_busyDirectorTitle =>
      'Le réalisateur reprend sa place · La distribution entre pour toi';

  @override
  String get ip_busyDirectorSub =>
      'Tisser chacun de tes choix et ton visage dans une fin qui n\'appartient qu\'à toi';

  @override
  String get ip_busyDoneTitle => '✦ Ta fin personnalisée est prête';

  @override
  String get ip_busyDoneSub =>
      'Sauvegardée pour toujours dans « Mes fins exclusives »';

  @override
  String ip_titleChipFmt(String n) {
    return 'Interactif · $n fins';
  }

  @override
  String get ip_titleSub => 'Chaque choix réécrit la fin';

  @override
  String get ip_titleStart => 'Commencer l\'histoire';

  @override
  String get ip_btnContinue => 'Continuer';

  @override
  String ip_voteFmt(String n) {
    return '$n% choisissent ça';
  }

  @override
  String ip_endingProgressFmt(String got, String total) {
    return 'Fins débloquées $got / $total';
  }

  @override
  String get ip_btnDex => 'Dex des fins';

  @override
  String get ip_btnReplay => 'Essayer un autre choix';

  @override
  String get ip_dexTitle => 'Dex des fins';

  @override
  String get ip_dexLocked => '? ? ?';

  @override
  String ip_errorTitleFmt(String err) {
    return 'Validation de l\'histoire échouée\n$err';
  }

  @override
  String get ip_unlockTitleAi => 'Crée une fin rien qu\'à toi';

  @override
  String get ip_unlockTitle => 'Débloquer cette branche';

  @override
  String get ip_demoFree => 'Drama démo · essai gratuit';

  @override
  String get ip_unlockBtnAi => 'Commencer à créer pour moi';

  @override
  String get ip_unlockBtn => 'Débloquer la branche';

  @override
  String get ip_unlockCancel => 'Plus tard';

  @override
  String com_sceneSameFmt(String n) {
    return '$n articles dans cette scène';
  }

  @override
  String get com_sameInDrama => 'Vu dans la série';

  @override
  String get com_buyNow => 'Acheter';

  @override
  String get com_inStock => 'En stock · livraison offerte';

  @override
  String get com_outOfStock => 'Rupture';

  @override
  String get com_infoMerchant => 'Vendeur';

  @override
  String get com_infoEpisode => 'Épisode lié';

  @override
  String get com_infoScene => 'Apparaît dans la scène';

  @override
  String com_sceneTimeFmt(String sec) {
    return 'à partir de ${sec}s';
  }

  @override
  String get com_descTitle => 'Description';

  @override
  String get com_descBody =>
      'Articles vus à l\'écran, sélectionnés par les partenaires FalconFlix. Expédition par la plateforme, retours 7 jours sans question. (Texte d\'exemple, remplacé lors de la connexion produit réelle.)';

  @override
  String get com_addCart => 'Ajouter au panier';

  @override
  String get com_addCartToast => 'Ajouté au panier (à venir)';

  @override
  String get com_methodCoin => 'Solde de pièces';

  @override
  String com_methodCoinBalanceFmt(String n) {
    return 'Solde $n';
  }

  @override
  String get com_methodWechat => 'WeChat Pay';

  @override
  String get com_methodAlipay => 'Alipay';

  @override
  String get com_confirmOrder => 'Vérifier la commande';

  @override
  String get com_qtyOne => 'Qté 1';

  @override
  String get com_payMethod => 'Mode de paiement';

  @override
  String get com_lineAmount => 'Montant article';

  @override
  String get com_lineCoupon => 'Coupon';

  @override
  String get com_lineCouponUnused => 'Non utilisé';

  @override
  String get com_lineShipping => 'Livraison';

  @override
  String get com_lineShippingFree => 'Gratuite';

  @override
  String get com_total => 'Total';

  @override
  String get com_submitOrder => 'Valider la commande';

  @override
  String get com_submitToast => 'Commande validée (paiement à venir)';

  @override
  String get ss_tier66_label => 'Illuminer';

  @override
  String get ss_tier66_meaning => 'Porte-bonheur';

  @override
  String get ss_tier188_label => 'Bouquet';

  @override
  String get ss_tier188_meaning => 'Du cœur';

  @override
  String get ss_tier520_label => 'Je t\'aime';

  @override
  String get ss_tier520_meaning => 'Papillons';

  @override
  String get ss_tier1314_label => 'Pour toujours';

  @override
  String get ss_tier1314_meaning => 'Toi seule';

  @override
  String get ss_tier3344_label => 'Éternité';

  @override
  String get ss_tier3344_meaning => 'Chouchouter à fond';

  @override
  String get ss_tier9999_label => 'Légendaire';

  @override
  String get ss_tier9999_meaning => 'Tu es n°1';

  @override
  String ss_callForFmt(String name) {
    return 'Soutenir $name';
  }

  @override
  String get ss_subtitle =>
      'Plus de pièces · début plus rapide · meilleur classement';

  @override
  String ss_balanceFmt(String n) {
    return 'Mon solde $n';
  }

  @override
  String get ss_localNote =>
      'Beta · soutiens enregistrés localement, paiement en pièces au lancement';

  @override
  String get ss_celebTitle => 'Soutien envoyé !';

  @override
  String ss_forFmt(String name, String label) {
    return 'Pour $name · $label';
  }

  @override
  String ss_pillCoinsFmt(String coins) {
    return '+$coins pièces';
  }

  @override
  String ss_progressFmt(String delta, String now) {
    return 'Début +$delta% · maintenant $now%';
  }

  @override
  String ss_kingFmt(String level, String tier) {
    return '👑 Tu es le fan n°1 de TA ! V$level $tier';
  }

  @override
  String ss_guardianFmt(String rank, String level, String tier) {
    return 'Tu es le gardien n°$rank de TA · V$level $tier';
  }

  @override
  String get ss_tapToContinue => 'Touche n\'importe où pour continuer';

  @override
  String get air_title => 'Classement de casting';

  @override
  String get air_sub =>
      'Remplis la jauge pour débuter · plus de soutien, meilleur rang';

  @override
  String get air_segCharRank => 'Personnages';

  @override
  String get air_segKingRank => 'Top fans';

  @override
  String get air_chipAll => 'Tous';

  @override
  String get air_chipFemale => 'Filles';

  @override
  String get air_chipMale => 'Garçons';

  @override
  String get air_chipTycoon => 'Tycoon';

  @override
  String get air_chipDeity => 'Divin';

  @override
  String get air_chipLegend => 'Légende';

  @override
  String get air_emptyChar => 'Aucun personnage dans cette catégorie';

  @override
  String get air_emptyKing => 'Ce niveau est encore vacant';

  @override
  String get air_debuted => 'Débuté';

  @override
  String get air_leading => 'En tête';

  @override
  String air_heatFmt(String pct) {
    return 'Chaleur $pct%';
  }

  @override
  String get air_doneShoot => 'Tournage en cours';

  @override
  String air_toGoFmt(String n) {
    return '$n% avant débuts';
  }

  @override
  String air_supportKingFmt(String name) {
    return 'Top fan : $name';
  }

  @override
  String get air_emptyKingPlaceholder => 'Champion recherché';

  @override
  String get air_globalKing => 'Top fan global';

  @override
  String air_tierBackFmt(String tier, String name) {
    return '$tier · soutient $name';
  }

  @override
  String air_guardFmt(String name) {
    return 'Protège $name';
  }

  @override
  String get cd_secVideos => 'Vidéos de TA';

  @override
  String get cd_secMoments => 'Moments intimes';

  @override
  String get cd_actUnlock => 'Débloquer en pièces';

  @override
  String get cd_secCredits => 'Dramas de TA';

  @override
  String cd_secBoardFmt(String n) {
    return 'Board de soutien · $n supporters';
  }

  @override
  String get cd_actImInToo => 'Je participe ›';

  @override
  String get cd_swipeHint => 'Scroll pour découvrir · soutenir · débloquer';

  @override
  String get cd_introBadge => 'Présentation de TA';

  @override
  String get cd_debutProgress => 'Campagne de début';

  @override
  String get cd_debutHint =>
      'Remplir pour lancer le tournage · acteurs réels + IA, drama interactif premium';

  @override
  String cd_clipToastFmt(String name) {
    return 'Lire le clip « $name » · à venir';
  }

  @override
  String cd_momentToastFmt(String title) {
    return 'Débloquer « $title » · fonction pièces à venir';
  }

  @override
  String cd_creditToastFmt(String name) {
    return '« $name » · fonction de visionnage à venir';
  }

  @override
  String get cd_kingBadge => 'Top fan du drama';

  @override
  String get cd_btnSupport => 'Soutenir';

  @override
  String get cd_btnChat => 'Chat · débloquer';

  @override
  String get sp_toolPosterName => 'Poster du drama';

  @override
  String get sp_toolPosterDesc =>
      'Charge ton visage pour générer un poster vertical de toi dans ce drama.';

  @override
  String get sp_toolPosterCost => '~5-25 pièces';

  @override
  String get sp_toolVideoNameShort => 'Clip IA 3s';

  @override
  String get sp_toolVideoName => 'Clip drama IA 3s';

  @override
  String get sp_toolVideoDesc =>
      'Génère un clip vertical léger depuis une photo ou une ligne.';

  @override
  String get sp_toolVideoCost => '~40 pièces';

  @override
  String get sp_toolMakeoverName => 'Métamorphose IA';

  @override
  String get sp_toolMakeoverDesc =>
      'Essaye ancien, pro, anime, rétro et portrait depuis une seule photo.';

  @override
  String get sp_toolMakeoverCost => '~25 pièces';

  @override
  String get sp_toolAvatarName => 'Avatar IA exclusif';

  @override
  String get sp_toolAvatarDesc =>
      'Génère un avatar perso depuis ton visage, prêt à mettre sur ton profil.';

  @override
  String get sp_toolAvatarCost => '~5-25 pièces';

  @override
  String get sp_sectionHeader => 'Playground IA';

  @override
  String get sp_subtitle => 'Mini-jeux IA liés à ton drama préféré.';

  @override
  String sp_creatingFmt(String title) {
    return 'Création pour « $title »';
  }

  @override
  String get sp_chipLinked => 'Lié à l\'histoire';

  @override
  String get sp_chipMall => 'Mall drama';

  @override
  String get sp_putInDramaTitle => 'Mets-toi dans le drama';

  @override
  String get sp_putInDramaBody =>
      'Prends ou charge une photo pour générer un poster ou clip de ce drama.';

  @override
  String get sp_btnTryRoleplay => 'Tester le roleplay IA';

  @override
  String get sp_sceneMallTitle => 'Mall de scènes';

  @override
  String get sp_sceneMallBody =>
      'Parcours les articles à l\'écran, produits de scène et collabs créateurs.';

  @override
  String get spf_settingsTitle => 'Paramètres de l\'outil';

  @override
  String spf_linkedToFmt(String title) {
    return 'Lié à « $title »';
  }

  @override
  String get spf_chooseTool => 'Choisir un outil';

  @override
  String spf_genBtnFmt(String cost) {
    return 'Générer · $cost';
  }

  @override
  String get spf_noPhotoBtn => 'Charge d\'abord une photo';

  @override
  String get spf_photoReady => 'Photo prête';

  @override
  String get spf_uploadPhoto => 'Charge ta photo';

  @override
  String get spf_photoTapToReplace => 'Touche pour remplacer';

  @override
  String get spf_photoHint => 'De face ou corps entier, visage net';

  @override
  String get spf_generating => 'L\'IA génère…';

  @override
  String get spf_generatingSub => 'On te place dans le drama, patience';

  @override
  String get spf_genDoneTag => 'Terminé';

  @override
  String spf_genDoneTitleFmt(String tool) {
    return '$tool · prêt';
  }

  @override
  String get spf_genDoneBody => 'Sauve dans tes œuvres, partage, ou régénère.';

  @override
  String get spf_btnSave => 'Enregistrer dans mes œuvres';

  @override
  String get spf_savedToast => 'Enregistré (à venir)';

  @override
  String get spf_shareLabel => 'Création IA';

  @override
  String get cui_chipAI => 'Interactif IA';

  @override
  String get cui_chipMetaverse => 'Univers métavers';

  @override
  String get cui_title => 'Métavers des personnages';

  @override
  String get cui_lead =>
      'Ici, tu ne rencontres pas un acteur — mais quelqu\'un qui te répond.';

  @override
  String get cui_body =>
      'Chaque personnage a sa personnalité, sa voix, son histoire. Discute, soutiens, pousse celui qui te fait craquer sur scène — d\'une simple réplique à un drama interactif premium rien qu\'à vous deux.';

  @override
  String get cui_step1Title => 'Rencontre & DM';

  @override
  String get cui_step1Desc =>
      'Maintiens pour entendre sa voix, puis lance un chat 1-à-1. Compagnie IA qui te comprend mieux à chaque message.';

  @override
  String get cui_step2Title => 'Soutien & vote';

  @override
  String get cui_step2Desc =>
      'Dépense des pièces pour ton préféré, monte sur le board, deviens son top fan.';

  @override
  String get cui_step3Title => 'Greenlight & début';

  @override
  String get cui_step3Desc =>
      'Quand la campagne est pleine, ils débutent — drama premium acteurs réels + IA, allumé par toi.';

  @override
  String get cui_step4Title => 'Cameo & immersion';

  @override
  String get cui_step4Desc =>
      'Débloque des histoires privées et des « moments profonds » — écris-toi même dans le drama.';

  @override
  String get cui_footer =>
      'Chaque vote que tu lances réécrit qui sera le prochain protagoniste.';

  @override
  String get com2_title => 'Communauté';

  @override
  String get com2_chipPlaza => 'Place des dramas';

  @override
  String get com2_emptyHint => 'Aucun post pour l\'instant — sois le premier';

  @override
  String get com2_btnPost => 'Nouveau post';

  @override
  String get com2_watching => 'En train de regarder';

  @override
  String get com2_fallbackDrama => 'Drama FalconFlix';

  @override
  String get com2_publishedToast => 'Publié dans la communauté';

  @override
  String get com2_postHint =>
      'Partage ce que ce drama t\'a fait, recommande-le…';

  @override
  String get com2_publish => 'Publier';

  @override
  String get com2_attachDrama => 'Joindre ce drama';

  @override
  String get dhc_connected => 'Connecté';

  @override
  String get dhc_connecting => 'Connexion';

  @override
  String get dhc_ended => 'Terminé';

  @override
  String get dhc_error => 'Erreur';

  @override
  String get dhc_connectingHint => 'Connexion en cours…patiente';

  @override
  String dhc_talkingFmt(String name) {
    return '$name parle…';
  }

  @override
  String get dhc_listening => 'Je t\'écoute…';

  @override
  String get dhc_backLabel => 'Retour';

  @override
  String get dhc_actorsReady => 'Les acteurs prennent place…';

  @override
  String get ss2_searchHint => 'Cherche drama / acteur / tag';

  @override
  String get ss2_history => 'Recherches récentes';

  @override
  String get ss2_clear => 'Effacer';

  @override
  String get ss2_hot => 'Recherches tendance';

  @override
  String get ss2_hotBadge => 'Tendance';

  @override
  String ss2_noResultFmt(String q) {
    return 'Aucun drama trouvé pour « $q »';
  }

  @override
  String ss2_foundFmt(String n) {
    return '$n dramas trouvés';
  }

  @override
  String get ss2_chipCEO => 'Crush patron';

  @override
  String get ss2_chipTimeTravel => 'Voyage temporel';

  @override
  String get ss2_chipMystery => 'Mystère';

  @override
  String get ss2_chipModern => 'Romance moderne';

  @override
  String get ss2_chipSweetPet => 'Romance sucrée';

  @override
  String get rk_emptyCat => 'Pas de classement dans cette catégorie';

  @override
  String get rk_hotTitle => 'Classement tendance';

  @override
  String get rk_hotSub => 'Tri en direct selon la chaleur du jour';

  @override
  String get rk_top1Today => '# 1  le plus chaud aujourd\'hui';

  @override
  String rk_heatFmt(String plays) {
    return '$plays chaleur · en hausse';
  }

  @override
  String get rk_chipUrban => 'Urbain';

  @override
  String get rk_chipFinished => 'Terminé';

  @override
  String get rk_chipRomance => 'Romance';

  @override
  String get aic_lowEnergyNag =>
      'Oh… j\'ai un peu fatigué, recharge-moi s\'il te plaît~';

  @override
  String get aic_chargedReply => 'Merci ! Pleine forme, on continue~';

  @override
  String get aic_chargeToast =>
      'Recharge · facturation en pièces en cours (mock plein)';

  @override
  String aic_energyFmt(String pct) {
    return 'Énergie $pct%';
  }

  @override
  String aic_chargeBtnFmt(String name) {
    return 'Recharger pour $name';
  }

  @override
  String aic_hintFmt(String name) {
    return 'Dis quelque chose à $name…';
  }

  @override
  String lg_needLevelFmt(String name, String level) {
    return '$name · V$level requis';
  }

  @override
  String lg_topUpFmt(String amount, String level) {
    return 'Recharge $amount pour atteindre V$level';
  }

  @override
  String get lg_btnTopUp => 'Recharger pour upgrader';

  @override
  String get lg_btnLater => 'Plus tard';

  @override
  String get me_defaultName => 'Spectateur FalconFlix';

  @override
  String get me_avatarUpdated => 'Avatar mis à jour';

  @override
  String get me_avatarUpdateFailed => 'Échec de mise à jour, réessayez';

  @override
  String get me_tapAvatarToChange => 'Touche l\'avatar pour changer ta photo';

  @override
  String get me_myLevel => 'Mon niveau';

  @override
  String get me_loginEmail => 'E-mail de connexion';

  @override
  String get me_membership => 'Adhésion';

  @override
  String get me_uploading => 'Envoi…';

  @override
  String get me_changeAvatar => 'Changer l\'avatar';

  @override
  String me_copiedFmt(String value) {
    return 'Copié : $value';
  }

  @override
  String get tier_commoner => 'Roturier';

  @override
  String get tier_rookie => 'Débutant';

  @override
  String get tier_advanced => 'Avancé';

  @override
  String get tier_lord => 'Magnat';

  @override
  String get tier_tycoon => 'Tycoon';

  @override
  String get tier_deity => 'Divin';

  @override
  String get tier_legend => 'Légende';

  @override
  String get rch_statusPaid => 'Crédité';

  @override
  String get rch_statusPending => 'En attente';

  @override
  String get rch_statusCanceled => 'Annulé';

  @override
  String get rch_statusProcessing => 'En cours';

  @override
  String data_goodsCoinsFmt(String n) {
    return '$n pièces';
  }

  @override
  String get time_justNow => 'À l\'instant';

  @override
  String time_minutesAgoFmt(String n) {
    return 'il y a $n min';
  }

  @override
  String time_hoursAgoFmt(String n) {
    return 'il y a $n h';
  }

  @override
  String time_daysAgoFmt(String n) {
    return 'il y a $n j';
  }

  @override
  String get notify_typeRecharge => 'Recharge';

  @override
  String get notify_typeInvite => 'Invitation';

  @override
  String get notify_typeSystem => 'Système';

  @override
  String get notify_typeActivity => 'Événement';

  @override
  String get notify_typeInteractive => 'Interactif';
}
