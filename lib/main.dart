import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config/theme.dart';
import 'config/admob_ids.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Mobile Ads SDK
  await MobileAds.instance.initialize();
  
  // Inicializar SharedPreferences
  await StorageService.init();
  
  // Verificar consentimiento GDPR
  await _requestConsent();
  
  // Inicializar AdService después del consentimiento
  await AdService.init();
  
  runApp(
    const ProviderScope(
      child: BlockRushApp(),
    ),
  );
}

Future<void> _requestConsent() async {
  try {
    final consentInfo = ConsentInformation.instance;

    await consentInfo.requestConsentInfoUpdate(
      const ConsentRequestParameters(),
      () {},
      (error) {
        throw Exception(error.message);
      },
    );

    if (await consentInfo.isConsentFormAvailable()) {
      final status = await consentInfo.getConsentStatus();

      if (status == ConsentStatus.required) {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) {
            throw Exception(error.message);
          }
        });
      }
    }

    final consentStatus = await consentInfo.getConsentStatus();
    await StorageService.setGdprConsent(consentStatus != ConsentStatus.denied);
  } catch (e) {
    // Si falla el consentimiento, continuamos sin personalización
    debugPrint('Error en consentimiento GDPR: $e');
    await StorageService.setGdprConsent(false);
  }
}

class BlockRushApp extends ConsumerStatefulWidget {
  const BlockRushApp({super.key});

  @override
  ConsumerState<BlockRushApp> createState() => _BlockRushAppState();
}

class _BlockRushAppState extends ConsumerState<BlockRushApp> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Configurar App Open Ad
    AdService.loadAppOpenAd();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // Mostrar App Open Ad cuando la app vuelve a primer plano
      AdService.showAppOpenAd();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockRush: Puzzle & Survive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
