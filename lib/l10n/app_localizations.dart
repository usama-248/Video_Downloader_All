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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur')
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
  /// **'Enter URL or search term'**
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

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'پریمیم'**
  String get premiumTitle;

  /// No description provided for @startLikeAPro.
  ///
  /// In en, this message translates to:
  /// **'پرو کی طرح شروع کریں'**
  String get startLikeAPro;

  /// No description provided for @unlockFeatures.
  ///
  /// In en, this message translates to:
  /// **'تمام فیچرز کھولیں'**
  String get unlockFeatures;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'بنیادی'**
  String get basic;

  /// No description provided for @downloadNow.
  ///
  /// In en, this message translates to:
  /// **'ابھی ڈاؤن لوڈ کریں'**
  String get downloadNow;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'خصوصیات'**
  String get featuresTitle;

  /// No description provided for @featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'لامحدود ویڈیو ڈاؤن لوڈ'**
  String get featureUnlimited;

  /// No description provided for @featureHD.
  ///
  /// In en, this message translates to:
  /// **'ایچ ڈی کوالٹی میں ڈاؤن لوڈ کریں'**
  String get featureHD;

  /// No description provided for @featureFast.
  ///
  /// In en, this message translates to:
  /// **'تیز ترین ڈاؤن لوڈ سپیڈ'**
  String get featureFast;

  /// No description provided for @featureTrending.
  ///
  /// In en, this message translates to:
  /// **'ٹرینڈنگ دیکھیں'**
  String get featureTrending;

  /// No description provided for @featureAnything.
  ///
  /// In en, this message translates to:
  /// **'کچھ بھی ڈاؤن لوڈ کریں'**
  String get featureAnything;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'مفت ٹرائل شروع کریں'**
  String get freeTrial;

  /// No description provided for @noPayment.
  ///
  /// In en, this message translates to:
  /// **'ابھی کوئی ادائیگی نہیں'**
  String get noPayment;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'۱۲:۲۸'**
  String get time;

  /// No description provided for @browserTab.
  ///
  /// In en, this message translates to:
  /// **'براؤزر'**
  String get browserTab;

  /// No description provided for @watchTab.
  ///
  /// In en, this message translates to:
  /// **'دیکھیں'**
  String get watchTab;

  /// No description provided for @savedTab.
  ///
  /// In en, this message translates to:
  /// **'محفوظ'**
  String get savedTab;

  /// No description provided for @allImages.
  ///
  /// In en, this message translates to:
  /// **'تمام تصاویر'**
  String get allImages;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'سائن ان کریں'**
  String get signIn;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'ڈاؤن لوڈ ہسٹری'**
  String get historyTitle;

  /// No description provided for @noDownloads.
  ///
  /// In en, this message translates to:
  /// **'ابھی تک کوئی ڈاؤن لوڈ نہیں'**
  String get noDownloads;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'براؤزر سے ویڈیوز ڈاؤن لوڈ کریں'**
  String get historyHint;

  String? translate(String s) {}
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
