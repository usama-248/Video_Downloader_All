// import 'package:flutter/foundation.dart';
// import 'package:gma_mediation_liftoffmonetize/gma_mediation_liftoffmonetize.dart';
// import 'package:gma_mediation_meta/gma_mediation_meta.dart';
// import 'package:gma_mediation_mintegral/gma_mediation_mintegral.dart';

// class AdMediation {
//   /// Register all mediation adapters for Android
//   static void registerAdapters() {
//     try {
//       // Initialize Meta Audience Network
//       // The package automatically registers itself when imported
//       debugPrint('[ADS] ✅ Meta Audience Network adapter ready');
      
//       // Initialize Liftoff Monetize (Vungle)
//       // The package automatically registers itself when imported
//       debugPrint('[ADS] ✅ Liftoff Monetize adapter ready');
      
//       // Initialize Mintegral
//       // The package automatically registers itself when imported
//       debugPrint('[ADS] ✅ Mintegral adapter ready');
      
//       debugPrint('[ADS] All mediation adapters registered for Android');
//     } catch (e) {
//       debugPrint('[ADS] ❌ Error with mediation adapters: $e');
//     }
//   }
  
//   /// Optional: Set CCPA status for Liftoff (for US users)
//   static void setLiftoffCcpaStatus(bool isOptedOut) {
//     try {
//       // Note: Check if your version supports this method
//       // GmaMediationLiftoffmonetize.setCcpaStatus(isOptedOut);
//       debugPrint('[ADS] Liftoff CCPA status would be set to: $isOptedOut');
//     } catch (e) {
//       debugPrint('[ADS] Error setting Liftoff CCPA: $e');
//     }
//   }
// }