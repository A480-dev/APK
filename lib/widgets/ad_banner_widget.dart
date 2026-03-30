import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/services/ad_service.dart';
import 'package:blockrush/config/theme.dart';

class AdBannerWidget extends ConsumerStatefulWidget {
  final bool showReloadButton;
  final double? height;
  
  const AdBannerWidget({
    super.key,
    this.showReloadButton = false,
    this.height,
  });
  
  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }
  
  void _loadBannerAd() {
    setState(() {
      _isLoading = true;
    });
    
    AdService.loadBannerAd();
    
    // Simular tiempo de carga
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  void _reloadAd() {
    ref.read(adProvider.notifier).refreshAds();
    _loadBannerAd();
  }
  
  @override
  Widget build(BuildContext context) {
    final adInfo = ref.watch(adInfoProvider);
    final bannerWidget = AdService.getBannerAdWidget();
    
    return Container(
      height: widget.height ?? 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Contenido del banner
          if (_isLoading)
            _buildLoadingWidget()
          else if (bannerWidget != null && adInfo.isBannerAdLoaded)
            Center(child: bannerWidget)
          else
            _buildPlaceholderWidget(),
          
          // Botón de recargar (opcional)
          if (widget.showReloadButton)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _reloadAd,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.secondaryText.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cargando anuncio...',
            style: TextStyle(
              color: AppTheme.secondaryText.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ad_units,
            color: AppTheme.secondaryText.withOpacity(0.3),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Espacio publicitario',
            style: TextStyle(
              color: AppTheme.secondaryText.withOpacity(0.3),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para banner en menú principal
class MenuAdBannerWidget extends StatelessWidget {
  const MenuAdBannerWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: const AdBannerWidget(
        showReloadButton: false,
      ),
    );
  }
}

// Widget para banner en pantalla de game over
class GameOverAdBannerWidget extends StatelessWidget {
  const GameOverAdBannerWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: const AdBannerWidget(
        showReloadButton: true,
      ),
    );
  }
}

// Widget para indicador de anuncio rewarded
class RewardedAdIndicator extends ConsumerWidget {
  final bool isAvailable;
  final VoidCallback? onTap;
  
  const RewardedAdIndicator({
    super.key,
    required this.isAvailable,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isAvailable
              ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[400]!,
                    Colors.grey[600]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAvailable ? Icons.play_circle : Icons.hourglass_empty,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isAvailable ? 'VER ANUNCIO' : 'SIN ANUNCIOS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para botón de anuncio rewarded
class RewardedAdButton extends ConsumerWidget {
  final String label;
  final String reward;
  final VoidCallback? onAdNotAvailable;
  final VoidCallback? onAdCompleted;
  final bool isLoading;
  
  const RewardedAdButton({
    super.key,
    required this.label,
    required this.reward,
    this.onAdNotAvailable,
    this.onAdCompleted,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adAvailable = ref.watch(rewardedAdAvailableProvider);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: (isLoading || !adAvailable) ? null : _handleAdPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: adAvailable 
              ? const Color(0xFF4CAF50)
              : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: adAvailable ? 8 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  void _handleAdPress() async {
    // Aquí se implementaría la lógica para mostrar el anuncio rewarded
    // Por ahora, solo llamamos al callback
    onAdCompleted?.call();
  }
}

// Widget para información de anuncios (debug)
class AdInfoWidget extends ConsumerWidget {
  const AdInfoWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adInfo = ref.watch(adInfoProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Anuncios',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('App Open Ad', adInfo.isAppOpenAdLoaded),
          _buildInfoRow('Interstitial Ad', adInfo.isInterstitialAdLoaded),
          _buildInfoRow('Rewarded Ad', adInfo.isRewardedAdLoaded),
          _buildInfoRow('Banner Ad', adInfo.isBannerAdLoaded),
          const SizedBox(height: 8),
          Text(
            'Partidas desde último anuncio: ${adInfo.gamesSinceLastAd}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, bool isLoaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isLoaded ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isLoaded ? AppTheme.successColor : AppTheme.dangerColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isLoaded ? AppTheme.primaryText : AppTheme.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
