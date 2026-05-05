import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Downloader'**
  String get appTitle;

  /// No description provided for @browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browser;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @enterUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a URL to start browsing'**
  String get enterUrl;

  /// No description provided for @videosDetected.
  ///
  /// In en, this message translates to:
  /// **'Videos will be detected automatically'**
  String get videosDetected;

  /// No description provided for @selectQuality.
  ///
  /// In en, this message translates to:
  /// **'Select Quality and then Download'**
  String get selectQuality;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'💡 Tip:'**
  String get tip;

  /// No description provided for @tipText.
  ///
  /// In en, this message translates to:
  /// **'Try Facebook.com/videos'**
  String get tipText;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideos;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your link here....'**
  String get searchHint;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChanged;

  /// No description provided for @restartMessage.
  ///
  /// In en, this message translates to:
  /// **'Restart the app for changes to take full effect'**
  String get restartMessage;

  /// No description provided for @topFeatures.
  ///
  /// In en, this message translates to:
  /// **'Top Features'**
  String get topFeatures;

  /// No description provided for @downloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download Video'**
  String get downloadVideo;

  /// No description provided for @downloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download your favourite files'**
  String get downloadSubtitle;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// No description provided for @watchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch trending videos'**
  String get watchSubtitle;

  /// No description provided for @savedVideos.
  ///
  /// In en, this message translates to:
  /// **'Saved videos'**
  String get savedVideos;

  /// No description provided for @savedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open Downloaded Videos'**
  String get savedSubtitle;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @languagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your languages'**
  String get languagesSubtitle;
  

  /// No description provided for @communications.
  ///
  /// In en, this message translates to:
  /// **'Communications'**
  String get communications;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share Video Downloader with others'**
  String get shareSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open app privacy policy'**
  String get privacySubtitle;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your Subscription'**
  String get subscriptionSubtitle;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contents are protected by copyright'**
  String get disclaimerSubtitle;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'Contents are protected by copyright. All videos downloaded are for personal use only. Please respect intellectual property rights and do not distribute copyrighted content without permission.'**
  String get disclaimerContent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get get_started;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Effortless Video Management'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_desc_1.
  ///
  /// In en, this message translates to:
  /// **'An all-in-one solution for organizing and managing your downloaded video collection with intuitive ease. Take control'**
  String get onboarding_desc_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Explore Facebook Videos'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_desc_2.
  ///
  /// In en, this message translates to:
  /// **'Dive into a diverse range of content with a seamless and engaging experience for discovering, watching, and downloading'**
  String get onboarding_desc_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Download with Ease'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_desc_3.
  ///
  /// In en, this message translates to:
  /// **'Hassle-free video downloader with a simple and modern interface: Just paste the video link, and within seconds, you\'ll'**
  String get onboarding_desc_3;

  /// No description provided for @art_design_video.
  ///
  /// In en, this message translates to:
  /// **'Process of art design.mp4'**
  String get art_design_video;

  /// No description provided for @historical_place_video.
  ///
  /// In en, this message translates to:
  /// **'Historical Place.mp4'**
  String get historical_place_video;

  /// No description provided for @science_speech_video.
  ///
  /// In en, this message translates to:
  /// **'Speech of Science.mp4'**
  String get science_speech_video;

  /// No description provided for @programming_course_video.
  ///
  /// In en, this message translates to:
  /// **'Programming course.mp4'**
  String get programming_course_video;

  /// No description provided for @video_download.
  ///
  /// In en, this message translates to:
  /// **'Video Download'**
  String get video_download;

  /// No description provided for @tap_to_download.
  ///
  /// In en, this message translates to:
  /// **'Tap to download your favorite videos'**
  String get tap_to_download;

  /// No description provided for @video_detected.
  ///
  /// In en, this message translates to:
  /// **'Video Detected! Tap to Download'**
  String get video_detected;

  /// No description provided for @downloading_video.
  ///
  /// In en, this message translates to:
  /// **'Downloading Video'**
  String get downloading_video;

  /// No description provided for @extracting_audio.
  ///
  /// In en, this message translates to:
  /// **'Extracting audio from video...'**
  String get extracting_audio;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @extracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting audio...'**
  String get extracting;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @download_options.
  ///
  /// In en, this message translates to:
  /// **'Download Options'**
  String get download_options;

  /// No description provided for @video_quality.
  ///
  /// In en, this message translates to:
  /// **'VIDEO QUALITY'**
  String get video_quality;

  /// No description provided for @audio_only.
  ///
  /// In en, this message translates to:
  /// **'AUDIO ONLY'**
  String get audio_only;

  /// No description provided for @video_detected_message.
  ///
  /// In en, this message translates to:
  /// **'Video detected! Choose download option'**
  String get video_detected_message;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @high_quality.
  ///
  /// In en, this message translates to:
  /// **'High Quality'**
  String get high_quality;

  /// No description provided for @medium_quality.
  ///
  /// In en, this message translates to:
  /// **'Medium Quality'**
  String get medium_quality;

  /// No description provided for @low_quality.
  ///
  /// In en, this message translates to:
  /// **'Low Quality'**
  String get low_quality;

  /// No description provided for @audio_only_title.
  ///
  /// In en, this message translates to:
  /// **'Audio Only'**
  String get audio_only_title;

  /// No description provided for @extract_audio.
  ///
  /// In en, this message translates to:
  /// **'Extract'**
  String get extract_audio;

  /// No description provided for @download_success_video.
  ///
  /// In en, this message translates to:
  /// **'Download Complete!'**
  String get download_success_video;

  /// No description provided for @download_success_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio Extracted!'**
  String get download_success_audio;

  /// No description provided for @saved_to_movies.
  ///
  /// In en, this message translates to:
  /// **'Saved to Movies'**
  String get saved_to_movies;

  /// No description provided for @saved_to_music.
  ///
  /// In en, this message translates to:
  /// **'Saved to Music'**
  String get saved_to_music;

  /// No description provided for @view_in_history.
  ///
  /// In en, this message translates to:
  /// **'View in History'**
  String get view_in_history;

  /// No description provided for @download_failed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get download_failed;

  /// No description provided for @download_720p.
  ///
  /// In en, this message translates to:
  /// **'Download 720p'**
  String get download_720p;

  /// No description provided for @loading_video_player.
  ///
  /// In en, this message translates to:
  /// **'Loading video player...'**
  String get loading_video_player;

  /// No description provided for @video_ready.
  ///
  /// In en, this message translates to:
  /// **'Video ready! Tap Download to save.'**
  String get video_ready;

  /// No description provided for @processing_link.
  ///
  /// In en, this message translates to:
  /// **'Processing link...'**
  String get processing_link;

  /// No description provided for @paste_valid_url.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get paste_valid_url;

  /// No description provided for @extract_video_id_error.
  ///
  /// In en, this message translates to:
  /// **'Could not extract video ID. Make sure it\'s a valid Facebook video link.'**
  String get extract_video_id_error;

  /// No description provided for @storage_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required'**
  String get storage_permission_required;

  /// No description provided for @please_enter_url.
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL first'**
  String get please_enter_url;

  /// No description provided for @please_paste_link.
  ///
  /// In en, this message translates to:
  /// **'Please paste a link first'**
  String get please_paste_link;

  /// No description provided for @get_video.
  ///
  /// In en, this message translates to:
  /// **'Get Video'**
  String get get_video;

  /// No description provided for @paste_link.
  ///
  /// In en, this message translates to:
  /// **'Paste Link'**
  String get paste_link;

  /// No description provided for @how_to_download.
  ///
  /// In en, this message translates to:
  /// **'How to download?'**
  String get how_to_download;

  /// No description provided for @step_1.
  ///
  /// In en, this message translates to:
  /// **'Open Facebook and copy video link'**
  String get step_1;

  /// No description provided for @step_2.
  ///
  /// In en, this message translates to:
  /// **'Paste link in the app and tap Get Video'**
  String get step_2;

  /// No description provided for @step_3.
  ///
  /// In en, this message translates to:
  /// **'Tap Download to open video and save'**
  String get step_3;

  /// No description provided for @open_facebook.
  ///
  /// In en, this message translates to:
  /// **'Open Facebook'**
  String get open_facebook;

  /// No description provided for @how_to_download_videos.
  ///
  /// In en, this message translates to:
  /// **'How to download videos?'**
  String get how_to_download_videos;

  /// No description provided for @got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get got_it;

  /// No description provided for @watch_videos.
  ///
  /// In en, this message translates to:
  /// **'Watch Videos'**
  String get watch_videos;

  /// No description provided for @watch_facebook_videos.
  ///
  /// In en, this message translates to:
  /// **'Watch Facebook Videos'**
  String get watch_facebook_videos;

  /// No description provided for @tap_below_to_open_facebook.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to open Facebook and browse videos'**
  String get tap_below_to_open_facebook;

  /// No description provided for @tip_find_video.
  ///
  /// In en, this message translates to:
  /// **'Tip: Find a video, tap share, then copy link'**
  String get tip_find_video;

  /// No description provided for @tip_paste_link.
  ///
  /// In en, this message translates to:
  /// **'Then go to Home tab and paste the link'**
  String get tip_paste_link;

  /// No description provided for @facebook_video.
  ///
  /// In en, this message translates to:
  /// **'Facebook Video'**
  String get facebook_video;

  /// No description provided for @full_hd_best_quality.
  ///
  /// In en, this message translates to:
  /// **'Full HD • Best Quality'**
  String get full_hd_best_quality;

  /// No description provided for @hd_ready.
  ///
  /// In en, this message translates to:
  /// **'HD Ready'**
  String get hd_ready;

  /// No description provided for @standard_quality.
  ///
  /// In en, this message translates to:
  /// **'Standard Quality'**
  String get standard_quality;

  /// No description provided for @small_size.
  ///
  /// In en, this message translates to:
  /// **'Small Size'**
  String get small_size;

  /// No description provided for @mp3_128kbps.
  ///
  /// In en, this message translates to:
  /// **'128 kbps'**
  String get mp3_128kbps;

  /// No description provided for @extract_audio_from_video.
  ///
  /// In en, this message translates to:
  /// **'Extract audio from video'**
  String get extract_audio_from_video;

  /// No description provided for @processing_video.
  ///
  /// In en, this message translates to:
  /// **'Processing link...'**
  String get processing_video;

  /// No description provided for @browserTab.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browserTab;

  /// No description provided for @watchTab.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchTab;
    /// No description provided for @need_help.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get need_help;

  /// No description provided for @savedTab.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTab;

  /// Premium Feature Getters
  String get featureUnlimited;
  String get featureHD;
  String get featureFast;
  String get featureTrending;
  String get featureAnything;
  String get startLikeAPro;
  String get unlockFeatures;
  String get premiumTitle;
  String get freeTrial;
  String get noPayment;

  String get pro_badge;
  String get not_available;
  String get not_available_message;
  String get seamlessExperience;
  String get adsFreeExperience;

  // History Screen Getters
  String get historyTitle;
  String get noDownloads;
  String get historyHint;

  String get day;
  String get days;
  String get hour;
  String get hours;
  String get minute;
  String get minutes;
  String get ago;
  String get just_now;
  String get unknown_date;
  String get delete_video;
  String get delete_video_confirm;
  String get delete;
  String get deleted;
  String get clear_all;
  String get clear_all_confirm;
  String get delete_all;
  String get all_videos_deleted;

  // Settings Screen Getters

  String get shareAppLink;
  String get shareAPKFile;
  String get shareQRCode;
  String get shareViaQRCode;
  String get scanToDownload;
  String get shareLink;
  String get close;
  String get aboutApp;
  String get version;
  String get appDescription;
  String get giveUsReview;
  String get supportUsWithReview;
  String get moreApps;
  String get discoverOurApps;
  String get termsOfUse;
  String get readTermsConditions;
  // Additional Settings Screen Getters
  String get shareAppLinkMessage;

  String get downloadNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

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
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
