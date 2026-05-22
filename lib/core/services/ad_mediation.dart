// Mediation adapters register automatically when these packages are imported.
// See: https://developers.google.com/admob/flutter/mediation
// ignore_for_file: unused_import
import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
import 'package:gma_mediation_meta/gma_mediation_meta.dart';
import 'package:gma_mediation_mintegral/gma_mediation_mintegral.dart';

/// Ensures all AdMob mediation adapter packages are linked into the app.
///
/// Importing the packages above registers Meta Audience Network (bidding),
/// Liftoff Monetize, and Mintegral with the Google Mobile Ads SDK.
class AdMediation {
  AdMediation._();

  static const List<String> networks = [
    'Meta Audience Network (bidding)',
    'Liftoff Monetize',
    'Mintegral',
  ];
}
