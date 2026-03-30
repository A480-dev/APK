import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:blockrush/config/admob_ids.dart';
import 'package:blockrush/config/constants.dart';

class AdService {
  static AppOpenAd? _appOpenAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static BannerAd? _bannerAd;
  
  static bool _isAppOpenAdLoaded = false;
  static bool _isInterstitialAdLoaded = false;
  static bool _isRewardedAdLoaded = false;
  static bool _isBannerAdLoaded = false;
  
  static int _gamesPlayedSinceLastAd = 0;
  
  // ===== APP OPEN ADS =====
  
  // Cargar App Open Ad
  static Future<void> loadAppOpenAd() async {
    if (_isAppOpenAdLoaded) return;
    
    try {
      await AppOpenAd.load(
        adUnitId: AdmobIds.appOpenId,
        orientation: AppOpenAd.orientationPortrait,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAppOpenAdLoaded = true;
            debugPrint('App Open Ad cargado exitosamente');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Error cargando App Open Ad: $error');
            _isAppOpenAdLoaded = false;
            // Reintentar después de un tiempo
            Timer(const Duration(minutes: 5), () => loadAppOpenAd());
          },
        ),
      );
    } catch (e) {
      debugPrint('Excepción cargando App Open Ad: $e');
    }
  }
  
  // Mostrar App Open Ad
  static Future<void> showAppOpenAd() async {
    if (!_isAppOpenAdLoaded || _appOpenAd == null) {
      // Cargar y mostrar la próxima vez
      loadAppOpenAd();
      return;
    }
    
    try {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('App Open Ad mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('App Open Ad cerrado');
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdLoaded = false;
          // Cargar siguiente anuncio
          loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Error mostrando App Open Ad: $error');
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdLoaded = false;
        },
      );
      
      await _appOpenAd!.show();
    } catch (e) {
      debugPrint('Excepción mostrando App Open Ad: $e');
    }
  }
  
  // ===== INTERSTITIAL ADS =====
  
  // Cargar Interstitial Ad
  static Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoaded) return;
    
    try {
      await InterstitialAd.load(
        adUnitId: AdmobIds.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            debugPrint('Interstitial Ad cargado exitosamente');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Error cargando Interstitial Ad: $error');
            _isInterstitialAdLoaded = false;
            // Reintentar después de un tiempo
            Timer(const Duration(minutes: 2), () => loadInterstitialAd());
          },
        ),
      );
    } catch (e) {
      debugPrint('Excepción cargando Interstitial Ad: $e');
    }
  }
  
  // Mostrar Interstitial Ad
  static Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      loadInterstitialAd();
      return false;
    }
    
    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad cerrado');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Cargar siguiente anuncio
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Error mostrando Interstitial Ad: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
        },
      );
      
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('Excepción mostrando Interstitial Ad: $e');
      return false;
    }
  }
  
  // Verificar si mostrar anuncio interstitial
  static bool shouldShowInterstitialAd() {
    _gamesPlayedSinceLastAd++;
    if (_gamesPlayedSinceLastAd >= GameConstants.gamesBetweenInterstitials) {
      _gamesPlayedSinceLastAd = 0;
      return true;
    }
    return false;
  }
  
  // ===== REWARDED ADS =====
  
  // Cargar Rewarded Ad
  static Future<void> loadRewardedAd() async {
    if (_isRewardedAdLoaded) return;
    
    try {
      await RewardedAd.load(
        adUnitId: AdmobIds.rewardedId,
        request: const AdRequest(),
        adLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            debugPrint('Rewarded Ad cargado exitosamente');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Error cargando Rewarded Ad: $error');
            _isRewardedAdLoaded = false;
            // Reintentar después de un tiempo
            Timer(const Duration(minutes: 2), () => loadRewardedAd());
          },
        ),
      );
    } catch (e) {
      debugPrint('Excepción cargando Rewarded Ad: $e');
    }
  }
  
  // Mostrar Rewarded Ad
  static Future<bool> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      loadRewardedAd();
      return false;
    }
    
    try {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded Ad mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded Ad cerrado');
          onAdDismissed();
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          // Cargar siguiente anuncio
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Error mostrando Rewarded Ad: $error');
          onAdDismissed();
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );
      
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('Usuario ganó recompensa: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
      return true;
    } catch (e) {
      debugPrint('Excepción mostrando Rewarded Ad: $e');
      onAdDismissed();
      return false;
    }
  }
  
  // Verificar si hay anuncio rewarded disponible
  static bool isRewardedAdAvailable() {
    return _isRewardedAdLoaded && _rewardedAd != null;
  }
  
  // ===== BANNER ADS =====
  
  // Crear Banner Ad
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdmobIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          _isBannerAdLoaded = true;
          debugPrint('Banner Ad cargado exitosamente');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error cargando Banner Ad: $error');
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
        },
        onAdOpened: (ad) => debugPrint('Banner Ad abierto'),
        onAdClosed: (ad) => debugPrint('Banner Ad cerrado'),
      ),
    );
  }
  
  // Obtener Banner Ad widget
  static Widget? getBannerAdWidget() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      return null;
    }
    return AdWidget(ad: _bannerAd!);
  }
  
  // Cargar Banner Ad
  static void loadBannerAd() {
    if (_isBannerAdLoaded) return;
    
    try {
      final bannerAd = createBannerAd();
      bannerAd.load();
    } catch (e) {
      debugPrint('Excepción cargando Banner Ad: $e');
    }
  }
  
  // ===== INICIALIZACIÓN =====
  
  // Inicializar todos los anuncios
  static Future<void> init() async {
    try {
      // Cargar anuncios en segundo plano
      loadAppOpenAd();
      loadInterstitialAd();
      loadRewardedAd();
      loadBannerAd();
      
      debugPrint('AdService inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando AdService: $e');
    }
  }
  
  // ===== UTILIDADES =====
  
  // Verificar si los anuncios están listos
  static bool get areAdsReady {
    return _isAppOpenAdLoaded || _isInterstitialAdLoaded || _isRewardedAdLoaded;
  }
  
  // Liberar todos los anuncios
  static Future<void> disposeAll() async {
    try {
      await _appOpenAd?.dispose();
      await _interstitialAd?.dispose();
      await _rewardedAd?.dispose();
      _bannerAd?.dispose();
      
      _appOpenAd = null;
      _interstitialAd = null;
      _rewardedAd = null;
      _bannerAd = null;
      
      _isAppOpenAdLoaded = false;
      _isInterstitialAdLoaded = false;
      _isRewardedAdLoaded = false;
      _isBannerAdLoaded = false;
      
      debugPrint('Todos los anuncios liberados');
    } catch (e) {
      debugPrint('Error liberando anuncios: $e');
    }
  }
  
  // Recargar anuncios (útil después de cambios de configuración)
  static Future<void> reloadAllAds() async {
    await disposeAll();
    await init();
  }
}
