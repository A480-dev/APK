import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/services/ad_service.dart';

// Estado de los anuncios
class AdState {
  final bool isAppOpenAdLoaded;
  final bool isInterstitialAdLoaded;
  final bool isRewardedAdLoaded;
  final bool isBannerAdLoaded;
  final int gamesSinceLastAd;
  final bool isShowingAd;
  
  const AdState({
    this.isAppOpenAdLoaded = false,
    this.isInterstitialAdLoaded = false,
    this.isRewardedAdLoaded = false,
    this.isBannerAdLoaded = false,
    this.gamesSinceLastAd = 0,
    this.isShowingAd = false,
  });
  
  AdState copyWith({
    bool? isAppOpenAdLoaded,
    bool? isInterstitialAdLoaded,
    bool? isRewardedAdLoaded,
    bool? isBannerAdLoaded,
    int? gamesSinceLastAd,
    bool? isShowingAd,
  }) {
    return AdState(
      isAppOpenAdLoaded: isAppOpenAdLoaded ?? this.isAppOpenAdLoaded,
      isInterstitialAdLoaded: isInterstitialAdLoaded ?? this.isInterstitialAdLoaded,
      isRewardedAdLoaded: isRewardedAdLoaded ?? this.isRewardedAdLoaded,
      isBannerAdLoaded: isBannerAdLoaded ?? this.isBannerAdLoaded,
      gamesSinceLastAd: gamesSinceLastAd ?? this.gamesSinceLastAd,
      isShowingAd: isShowingAd ?? this.isShowingAd,
    );
  }
}

class AdProvider extends StateNotifier<AdState> {
  AdProvider() : super(const AdState()) {
    _initializeAds();
  }
  
  // Inicializar anuncios
  Future<void> _initializeAds() async {
    await AdService.init();
    _updateAdStatus();
  }
  
  // Actualizar estado de los anuncios
  void _updateAdStatus() {
    state = state.copyWith(
      isRewardedAdLoaded: AdService.isRewardedAdAvailable(),
    );
  }
  
  // Mostrar App Open Ad
  Future<void> showAppOpenAd() async {
    if (state.isShowingAd) return;
    
    state = state.copyWith(isShowingAd: true);
    await AdService.showAppOpenAd();
    state = state.copyWith(isShowingAd: false);
  }
  
  // Mostrar Interstitial Ad
  Future<bool> showInterstitialAd() async {
    if (state.isShowingAd) return false;
    
    state = state.copyWith(isShowingAd: true);
    final result = await AdService.showInterstitialAd();
    state = state.copyWith(isShowingAd: false);
    
    if (result) {
      state = state.copyWith(gamesSinceLastAd: 0);
    }
    
    return result;
  }
  
  // Verificar si mostrar interstitial
  bool shouldShowInterstitialAd() {
    final shouldShow = AdService.shouldShowInterstitialAd();
    if (shouldShow) {
      state = state.copyWith(gamesSinceLastAd: 0);
    } else {
      state = state.copyWith(gamesSinceLastAd: state.gamesSinceLastAd + 1);
    }
    return shouldShow;
  }
  
  // Mostrar Rewarded Ad
  Future<bool> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) async {
    if (state.isShowingAd) return false;
    
    state = state.copyWith(isShowingAd: true);
    
    final result = await AdService.showRewardedAd(
      onUserEarnedReward: () {
        onUserEarnedReward();
        _updateAdStatus();
      },
      onAdDismissed: () {
        onAdDismissed();
        state = state.copyWith(isShowingAd: false);
        _updateAdStatus();
      },
    );
    
    if (!result) {
      state = state.copyWith(isShowingAd: false);
    }
    
    return result;
  }
  
  // Verificar si hay anuncio rewarded disponible
  bool isRewardedAdAvailable() {
    return AdService.isRewardedAdAvailable();
  }
  
  // Cargar Banner Ad
  void loadBannerAd() {
    AdService.loadBannerAd();
    state = state.copyWith(isBannerAdLoaded: true);
  }
  
  // Obtener Banner Ad widget
  Future<void> refreshAds() async {
    await AdService.reloadAllAds();
    _updateAdStatus();
  }
  
  // Liberar todos los anuncios
  Future<void> disposeAll() async {
    await AdService.disposeAll();
    state = const AdState();
  }
  
  // Obtener información de anuncios
  AdInfo getAdInfo() {
    return AdInfo(
      isAppOpenAdLoaded: state.isAppOpenAdLoaded,
      isInterstitialAdLoaded: state.isInterstitialAdLoaded,
      isRewardedAdLoaded: state.isRewardedAdLoaded,
      isBannerAdLoaded: state.isBannerAdLoaded,
      gamesSinceLastAd: state.gamesSinceLastAd,
      isShowingAd: state.isShowingAd,
      canShowInterstitial: shouldShowInterstitialAd(),
    );
  }
}

// Información de anuncios
class AdInfo {
  final bool isAppOpenAdLoaded;
  final bool isInterstitialAdLoaded;
  final bool isRewardedAdLoaded;
  final bool isBannerAdLoaded;
  final int gamesSinceLastAd;
  final bool isShowingAd;
  final bool canShowInterstitial;
  
  const AdInfo({
    required this.isAppOpenAdLoaded,
    required this.isInterstitialAdLoaded,
    required this.isRewardedAdLoaded,
    required this.isBannerAdLoaded,
    required this.gamesSinceLastAd,
    required this.isShowingAd,
    required this.canShowInterstitial,
  });
}

// Provider de anuncios
final adProvider = StateNotifierProvider<AdProvider, AdState>((ref) {
  return AdProvider();
});

// Provider de información de anuncios
final adInfoProvider = Provider<AdInfo>((ref) {
  return ref.watch(adProvider.notifier).getAdInfo();
});

// Provider para verificar si hay anuncio rewarded disponible
final rewardedAdAvailableProvider = Provider<bool>((ref) {
  return ref.watch(adProvider.select((state) => state.isRewardedAdLoaded));
});

// Provider para verificar si se debe mostrar interstitial
final shouldShowInterstitialProvider = Provider<bool>((ref) {
  return ref.watch(adProvider.select((state) => state.gamesSinceLastAd >= 3));
});
