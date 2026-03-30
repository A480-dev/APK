import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blockrush/config/theme.dart';
import 'package:blockrush/config/constants.dart';
import 'package:blockrush/providers/player_provider.dart';
import 'package:blockrush/providers/ad_provider.dart';
import 'package:blockrush/widgets/coin_display.dart';
import 'package:blockrush/widgets/animated_button.dart';
import 'package:blockrush/widgets/ad_banner_widget.dart';
import 'package:blockrush/services/audio_service.dart';
import 'package:blockrush/services/haptic_service.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final playerData = ref.watch(playerProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(playerData.coins),
              
              // Tabs
              _buildTabs(),
              
              // Contenido
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPowerUpsTab(playerData),
                    _buildCoinsTab(playerData),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(int coins) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'Tienda',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const CoinDisplay(),
        ],
      ),
    );
  }
  
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.secondaryText,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.flash_on),
            text: 'Power-ups',
          ),
          Tab(
            icon: Icon(Icons.monetization_on),
            text: 'Monedas',
          ),
        ],
      ),
    );
  }
  
  Widget _buildPowerUpsTab(playerData) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1 - _slideController.value) * 50, 0),
          child: Opacity(
            opacity: _slideController.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Power-ups Disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bomba
                  _buildPowerUpItem(
                    icon: '💣',
                    name: 'Bomba',
                    description: 'Elimina un área 3x3 del tablero',
                    price: GameConstants.bombPrice,
                    owned: playerData.getPowerUpQuantity('bomb'),
                    canAfford: playerData.coins >= GameConstants.bombPrice,
                    onBuy: () => _buyPowerUp('bomb', GameConstants.bombPrice),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Shuffle
                  _buildPowerUpItem(
                    icon: '🔀',
                    name: 'Shuffle',
                    description: 'Genera nuevas piezas para usar',
                    price: GameConstants.shufflePrice,
                    owned: playerData.getPowerUpQuantity('shuffle'),
                    canAfford: playerData.coins >= GameConstants.shufflePrice,
                    onBuy: () => _buyPowerUp('shuffle', GameConstants.shufflePrice),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Deshacer
                  _buildPowerUpItem(
                    icon: '↩️',
                    name: 'Deshacer',
                    description: 'Deshace la última pieza colocada',
                    price: GameConstants.undoPrice,
                    owned: playerData.getPowerUpQuantity('undo'),
                    canAfford: playerData.coins >= GameConstants.undoPrice,
                    onBuy: () => _buyPowerUp('undo', GameConstants.undoPrice),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Comodín
                  _buildPowerUpItem(
                    icon: '✨',
                    name: 'Comodín',
                    description: 'Pieza 1x1 del color que necesites',
                    price: GameConstants.wildcardPrice,
                    owned: playerData.getPowerUpQuantity('wildcard'),
                    canAfford: playerData.coins >= GameConstants.wildcardPrice,
                    onBuy: () => _buyPowerUp('wildcard', GameConstants.wildcardPrice),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPowerUpItem({
    required String icon,
    required String name,
    required String description,
    required int price,
    required int owned,
    required bool canAfford,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canAfford 
              ? AppTheme.primaryAccent.withOpacity(0.3)
              : AppTheme.secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono del power-up
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: canAfford 
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [Colors.grey[400]!, Colors.grey[600]!],
                    ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (owned > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x$owned',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          // Precio y botón de compra
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford 
                      ? const Color(0xFFFFD700).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: canAfford 
                        ? const Color(0xFFFFD700)
                        : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: canAfford 
                          ? const Color(0xFFFFD700)
                          : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      price.toString(),
                      style: TextStyle(
                        color: canAfford 
                            ? const Color(0xFFFFD700)
                            : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: canAfford ? onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? AppTheme.primaryAccent : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'COMPRAR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCoinsTab(playerData) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1 - _slideController.value) * 50, 0),
          child: Opacity(
            opacity: _slideController.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Obtén más monedas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ve anuncios para obtener monedas gratis',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pack Starter
                  _buildCoinPack(
                    name: 'Pack Starter',
                    coins: 100,
                    ads: 1,
                    color: const Color(0xFF4CAF50),
                    onBuy: () => _watchAdsForCoins(1, 100),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Pack Medium
                  _buildCoinPack(
                    name: 'Pack Medium',
                    coins: 250,
                    ads: 2,
                    color: const Color(0xFF2196F3),
                    onBuy: () => _watchAdsForCoins(2, 250),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Pack Large
                  _buildCoinPack(
                    name: 'Pack Large',
                    coins: 500,
                    ads: 3,
                    color: const Color(0xFF9C27B0),
                    onBuy: () => _watchAdsForCoins(3, 500),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Banner de anuncios
                  const AdBannerWidget(
                    showReloadButton: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCoinPack({
    required String name,
    required int coins,
    required int ads,
    required Color color,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono de monedas
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ver $ads ${ads == 1 ? "anuncio" : "anuncios"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Monedas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _buyPowerUp(String powerUpType, int price) async {
    final success = await ref.read(playerProvider.notifier).buyPowerUp(powerUpType, price);
    
    if (success) {
      await HapticService.success();
      await AudioService.playCoinCollect();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡$powerUpType comprado con éxito!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      await HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes suficientes monedas'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }
  
  Future<void> _watchAdsForCoins(int adCount, int coins) async {
    bool allAdsWatched = true;
    
    for (int i = 0; i < adCount; i++) {
      final success = await ref.read(adProvider.notifier).showRewardedAd(
        onUserEarnedReward: () async {
          await HapticService.coinCollected();
        },
        onAdDismissed: () {
          // Continuar con el siguiente anuncio o finalizar
        },
      );
      
      if (!success) {
        allAdsWatched = false;
        break;
      }
      
      // Pequeña pausa entre anuncios
      if (i < adCount - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    if (allAdsWatched) {
      await ref.read(playerProvider.notifier).addCoins(coins);
      await AudioService.playCoinCollect();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡+$coins monedas obtenidas!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron mostrar todos los anuncios'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }
}
