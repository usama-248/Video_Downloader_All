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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Video Downloader'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

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

  /// No description provided for @videoDownloader.
  ///
  /// In en, this message translates to:
  /// **'Video Downloader'**
  String get videoDownloader;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pasteYourVideoLinkHere.
  ///
  /// In en, this message translates to:
  /// **'Paste your video link here'**
  String get pasteYourVideoLinkHere;

  /// No description provided for @pasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste Link'**
  String get pasteLink;

  /// No description provided for @fetchVideo.
  ///
  /// In en, this message translates to:
  /// **'Fetch Video'**
  String get fetchVideo;

  /// No description provided for @enterUrlAndTapFetchVideo.
  ///
  /// In en, this message translates to:
  /// **'Enter URL & tap Fetch Video'**
  String get enterUrlAndTapFetchVideo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @videoReady.
  ///
  /// In en, this message translates to:
  /// **'Video Ready'**
  String get videoReady;

  /// No description provided for @howToDownload.
  ///
  /// In en, this message translates to:
  /// **'How to Download'**
  String get howToDownload;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Open app and copy video link'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Paste the link in Fast Video Downloader and Fetch'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Select download quality and start download'**
  String get step3;

  /// No description provided for @tryVideosCom.
  ///
  /// In en, this message translates to:
  /// **'Try videos.com for more'**
  String get tryVideosCom;

  /// No description provided for @watchVideos.
  ///
  /// In en, this message translates to:
  /// **'Watch Videos'**
  String get watchVideos;

  /// No description provided for @tapBelowToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap Below to Open'**
  String get tapBelowToOpen;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open App'**
  String get openApp;

  /// No description provided for @howToDownloadVideos.
  ///
  /// In en, this message translates to:
  /// **'How to Download Videos'**
  String get howToDownloadVideos;

  /// No description provided for @findAndShare.
  ///
  /// In en, this message translates to:
  /// **'Find & Share'**
  String get findAndShare;

  /// No description provided for @watchVideosYouLike.
  ///
  /// In en, this message translates to:
  /// **'Watch videos which u like'**
  String get watchVideosYouLike;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Select \"Copy Link\" from the share options'**
  String get copyLinkDescription;

  /// No description provided for @pasteAndDownload.
  ///
  /// In en, this message translates to:
  /// **'Paste & Download'**
  String get pasteAndDownload;

  /// No description provided for @pasteAndDownloadDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste the link in Fast Video Downloader Fetch and Download it'**
  String get pasteAndDownloadDescription;

  /// No description provided for @proTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips for Best Results'**
  String get proTips;

  /// No description provided for @tipStableInternet.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have a stable internet connection'**
  String get tipStableInternet;

  /// No description provided for @tipSavedVideos.
  ///
  /// In en, this message translates to:
  /// **'Saved videos are stored in your gallery'**
  String get tipSavedVideos;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @openFacebook.
  ///
  /// In en, this message translates to:
  /// **'Open Facebook'**
  String get openFacebook;

  /// No description provided for @selectQuality.
  ///
  /// In en, this message translates to:
  /// **'Select quality'**
  String get selectQuality;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete!'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailed;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @fetchingVideo.
  ///
  /// In en, this message translates to:
  /// **'Fetching video...'**
  String get fetchingVideo;

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

  /// No description provided for @useBrowserToDownloadVideos.
  ///
  /// In en, this message translates to:
  /// **'Use the browser to download videos'**
  String get useBrowserToDownloadVideos;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watchVideo;

  /// No description provided for @savedVideos.
  ///
  /// In en, this message translates to:
  /// **'Saved Videos'**
  String get savedVideos;

  /// No description provided for @openDownloadedVideos.
  ///
  /// In en, this message translates to:
  /// **'Open Downloaded Videos'**
  String get openDownloadedVideos;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your Language'**
  String get chooseYourLanguage;

  /// No description provided for @communications.
  ///
  /// In en, this message translates to:
  /// **'Communications'**
  String get communications;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your Plan'**
  String get chooseYourPlan;

  /// No description provided for @giveUsReview.
  ///
  /// In en, this message translates to:
  /// **'Give Us Review'**
  String get giveUsReview;

  /// No description provided for @supportUsWithReview.
  ///
  /// In en, this message translates to:
  /// **'Support Us With Review'**
  String get supportUsWithReview;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share the App with Your Friends'**
  String get shareAppWithFriends;

  /// No description provided for @moreApps.
  ///
  /// In en, this message translates to:
  /// **'More Apps'**
  String get moreApps;

  /// No description provided for @discoverOurApps.
  ///
  /// In en, this message translates to:
  /// **'Discover Our Apps'**
  String get discoverOurApps;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @readTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Read Terms and Conditions'**
  String get readTermsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @readOurPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read Our Privacy Policy'**
  String get readOurPrivacyPolicy;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerApp.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer App'**
  String get disclaimerApp;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Please get the permissions from the owner before reposting videos. Any unauthorized actions (re-uploading or downloading of contents) and/or violations of intellectual property rights is the sole responsibility of the user'**
  String get disclaimerText;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @couldNotOpenPlayStoreForReview.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store for review'**
  String get couldNotOpenPlayStoreForReview;

  /// No description provided for @couldNotOpenMoreApps.
  ///
  /// In en, this message translates to:
  /// **'Could not open More Apps'**
  String get couldNotOpenMoreApps;

  /// No description provided for @couldNotOpenTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Could not open Terms of Use'**
  String get couldNotOpenTermsOfUse;

  /// No description provided for @couldNotOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not open Privacy Policy'**
  String get couldNotOpenPrivacyPolicy;

  /// No description provided for @couldNotOpenFacebook.
  ///
  /// In en, this message translates to:
  /// **'Could not open Facebook'**
  String get couldNotOpenFacebook;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Downloader'**
  String get appTitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast Video Downloader helps you download videos from social media platforms easily and quickly.'**
  String get appDescription;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

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
  /// **'Download Videos Easily'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_desc_1.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite videos from social media platforms with just one tap'**
  String get onboarding_desc_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'High Quality Downloads'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_desc_2.
  ///
  /// In en, this message translates to:
  /// **'Download videos in HD quality and watch them offline anytime'**
  String get onboarding_desc_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Fast & Secure'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_desc_3.
  ///
  /// In en, this message translates to:
  /// **'Experience lightning-fast downloads with secure encryption'**
  String get onboarding_desc_3;

  /// No description provided for @art_design_video.
  ///
  /// In en, this message translates to:
  /// **'Art Design.mp4'**
  String get art_design_video;

  /// No description provided for @historical_place_video.
  ///
  /// In en, this message translates to:
  /// **'Historical Place.mp4'**
  String get historical_place_video;

  /// No description provided for @science_speech_video.
  ///
  /// In en, this message translates to:
  /// **'Science Speech.mp4'**
  String get science_speech_video;

  /// No description provided for @programming_course_video.
  ///
  /// In en, this message translates to:
  /// **'Programming Course.mp4'**
  String get programming_course_video;

  /// No description provided for @video_download.
  ///
  /// In en, this message translates to:
  /// **'Video Download'**
  String get video_download;

  /// No description provided for @tap_to_download.
  ///
  /// In en, this message translates to:
  /// **'Tap to download'**
  String get tap_to_download;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'START LIKE A PRO'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Features'**
  String get premiumSubtitle;

  /// No description provided for @featureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Downloads'**
  String get featureUnlimited;

  /// No description provided for @featureHD.
  ///
  /// In en, this message translates to:
  /// **'HD Quality'**
  String get featureHD;

  /// No description provided for @featureFast.
  ///
  /// In en, this message translates to:
  /// **'Fast Download Speed'**
  String get featureFast;

  /// No description provided for @featureTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Content'**
  String get featureTrending;

  /// No description provided for @featureAnything.
  ///
  /// In en, this message translates to:
  /// **'Download Anything'**
  String get featureAnything;

  /// No description provided for @featureAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get featureAdFree;

  /// No description provided for @weeklyPremium.
  ///
  /// In en, this message translates to:
  /// **'Weekly Premium'**
  String get weeklyPremium;

  /// No description provided for @fullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full Access'**
  String get fullAccess;

  /// No description provided for @priceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Rs 4,200'**
  String get priceWeekly;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get perWeek;

  /// No description provided for @freeTrialIncluded.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Included'**
  String get freeTrialIncluded;

  /// No description provided for @freeTrialButton.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get freeTrialButton;

  /// No description provided for @noPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No Payment Now!'**
  String get noPaymentNow;

  /// No description provided for @premiumActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium Activated!'**
  String get premiumActivated;

  /// No description provided for @premiumSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You now have full access to all premium features!'**
  String get premiumSuccessMessage;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your video link here'**
  String get searchHint;

  /// No description provided for @selectInterests.
  ///
  /// In en, this message translates to:
  /// **'Select Interests'**
  String get selectInterests;

  /// No description provided for @whatsYourInterests.
  ///
  /// In en, this message translates to:
  /// **'What\'s your Interests?'**
  String get whatsYourInterests;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @selectAtLeastTwo.
  ///
  /// In en, this message translates to:
  /// **'Select At Least Two'**
  String get selectAtLeastTwo;

  /// No description provided for @deleteVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get deleteVideo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @oneDayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get oneDayAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get oneHourAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @oneMinuteAgo.
  ///
  /// In en, this message translates to:
  /// **'1 minute ago'**
  String get oneMinuteAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @historyRefreshed.
  ///
  /// In en, this message translates to:
  /// **'History refreshed'**
  String get historyRefreshed;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @downloadFromBrowser.
  ///
  /// In en, this message translates to:
  /// **'Download videos from the browser'**
  String get downloadFromBrowser;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @selectVideoQuality.
  ///
  /// In en, this message translates to:
  /// **'Select Video Quality'**
  String get selectVideoQuality;

  /// No description provided for @downloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download Now'**
  String get downloadNow;

  /// No description provided for @videoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video Quality'**
  String get videoQuality;

  /// No description provided for @disclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'This is a free trial. You will not be charged until the trial period ends. Cancel anytime before the trial ends to avoid charges.'**
  String get disclaimerContent;

  /// No description provided for @videoDownloaderBrowser.
  ///
  /// In en, this message translates to:
  /// **'Video Downloader Browser'**
  String get videoDownloaderBrowser;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @downloadOptions.
  ///
  /// In en, this message translates to:
  /// **'Download Options'**
  String get downloadOptions;

  /// No description provided for @loadingVideoPlayer.
  ///
  /// In en, this message translates to:
  /// **'Loading video player...'**
  String get loadingVideoPlayer;

  /// No description provided for @videoDetectedTapToDownload.
  ///
  /// In en, this message translates to:
  /// **'Video Detected! Tap to Download'**
  String get videoDetectedTapToDownload;

  /// No description provided for @downloadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Downloading Video'**
  String get downloadingVideo;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get languageSelected;
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
