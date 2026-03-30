class AdmobIds {
  // ⚠️ PRODUCCIÓN: Reemplaza estos IDs por los de tu cuenta AdMob
  // Obtén tu cuenta gratis en: https://admob.google.com
  // Los IDs de producción tienen formato: ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN
  
  static const bool kIsProduction = false;

  // App IDs
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String prodAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN'; // Reemplazar
  
  // Banner Ads
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String prodBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN'; // Reemplazar
  
  // Interstitial Ads
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String prodInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN'; // Reemplazar
  
  // Rewarded Ads
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String prodRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN'; // Reemplazar
  
  // App Open Ads
  static const String testAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String prodAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN'; // Reemplazar

  // Getters para obtener el ID correcto según el modo
  static String get appId => kIsProduction ? prodAppId : testAppId;
  static String get bannerId => kIsProduction ? prodBannerId : testBannerId;
  static String get interstitialId => kIsProduction ? prodInterstitialId : testInterstitialId;
  static String get rewardedId => kIsProduction ? prodRewardedId : testRewardedId;
  static String get appOpenId => kIsProduction ? prodAppOpenId : testAppOpenId;
}
