import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/wallet.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../shared/wallet_card.dart';
import '../shared/empty_state.dart';
import '../shared/shimmer_loading.dart';

/// Tela do Dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CoinWallet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Validador Profissional',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildQuickStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final stats = viewModel.stats;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.wallet,
                value: '${stats['totalWallets'] ?? 0}',
                label: 'Carteiras',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.heart,
                value: '${stats['totalFavorites'] ?? 0}',
                label: 'Favoritos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.link,
                value: '${(stats['blockchainCounts'] as Map?)?.length ?? 0}',
                label: 'Blockchains',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is DashboardLoading) {
          return const SliverFillRemaining(
            child: ShimmerLoading(),
          );
        }

        if (state is DashboardError) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: FontAwesomeIcons.circleExclamation,
              title: 'Erro ao carregar',
              message: state.message,
              onAction: () => viewModel.loadDashboard(),
              actionLabel: 'Tentar novamente',
            ),
          );
        }

        if (state is DashboardLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Favoritos', FontAwesomeIcons.heart),
                const SizedBox(height: 12),
                if (state.favoriteWallets.isEmpty)
                  _buildEmptyFavorites()
                else
                  ...state.favoriteWallets.map((wallet) => WalletCard(
                    wallet: wallet,
                    onTap: () => _showWalletDetails(wallet),
                    onFavorite: () => viewModel.toggleFavorite(wallet.id),
                  )),
                const SizedBox(height: 24),
                _buildSectionTitle('Recentes', FontAwesomeIcons.clock),
                const SizedBox(height: 12),
                if (state.recentWallets.isEmpty)
                  _buildEmptyRecent()
                else
                  ...state.recentWallets.map((wallet) => WalletCard(
                    wallet: wallet,
                    onTap: () => _showWalletDetails(wallet),
                    onFavorite: () => viewModel.toggleFavorite(wallet.id),
                  )),
                const SizedBox(height: 32),
              ]),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFavorites() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.heart, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Nenhum favorito ainda',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.clock, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Nenhuma validação recente',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Valide uma carteira para começar',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showWalletDetails(Wallet wallet) {
    // Navegar para tela de detalhes
  }
}
