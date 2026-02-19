import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../shared/empty_state.dart';
import '../shared/shimmer_loading.dart';
import '../shared/wallet_card.dart';

/// Tela de Histórico
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Histórico'),
        elevation: 0,
        actions: [
          Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              final state = viewModel.state;
              if (state is HistoryLoaded && state.wallets.isNotEmpty) {
                return IconButton(
                  icon: const Icon(FontAwesomeIcons.filter),
                  onPressed: () => _showFilterSheet(context, viewModel),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<HistoryViewModel>(
              builder: (context, viewModel, child) {
                final state = viewModel.state;

                if (state is HistoryLoading) {
                  return const ShimmerLoading();
                }

                if (state is HistoryError) {
                  return EmptyState(
                    icon: FontAwesomeIcons.circleExclamation,
                    title: 'Erro ao carregar',
                    message: state.message,
                    onAction: () => viewModel.loadHistory(),
                    actionLabel: 'Tentar novamente',
                  );
                }

                if (state is HistoryLoaded) {
                  if (state.filteredWallets.isEmpty) {
                    if (state.searchQuery != null || state.filterBlockchain != null) {
                      return EmptyState(
                        icon: FontAwesomeIcons.magnifyingGlass,
                        title: 'Nenhum resultado',
                        message: 'Tente ajustar seus filtros de busca',
                        onAction: () {
                          viewModel.clearFilters();
                          _searchController.clear();
                        },
                        actionLabel: 'Limpar filtros',
                      );
                    }
                    return const EmptyState(
                      icon: FontAwesomeIcons.clockRotateLeft,
                      title: 'Histórico vazio',
                      message: 'Suas validações aparecerão aqui',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredWallets.length,
                    itemBuilder: (context, index) {
                      final wallet = state.filteredWallets[index];
                      return WalletCard(
                        wallet: wallet,
                        onTap: () => _showWalletDetails(wallet),
                        onFavorite: () => viewModel.toggleFavorite(wallet.id),
                        onDelete: () => _confirmDelete(context, viewModel, wallet.id),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar carteiras...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.white.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(FontAwesomeIcons.xmark, color: Colors.white.withOpacity(0.7)),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HistoryViewModel>().search(null);
                  },
                )
              : null,
        ),
        onChanged: (value) {
          context.read<HistoryViewModel>().search(value);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, HistoryViewModel viewModel) {
    final blockchains = [
      {'id': 'bitcoin', 'name': 'Bitcoin', 'icon': FontAwesomeIcons.bitcoin},
      {'id': 'ethereum', 'name': 'Ethereum', 'icon': FontAwesomeIcons.ethereum},
      {'id': 'litecoin', 'name': 'Litecoin', 'icon': FontAwesomeIcons.coins},
      {'id': 'bitcoin_cash', 'name': 'Bitcoin Cash', 'icon': FontAwesomeIcons.moneyBill},
      {'id': 'dogecoin', 'name': 'Dogecoin', 'icon': FontAwesomeIcons.dog},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar por Blockchain',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...blockchains.map((blockchain) => ListTile(
                leading: Icon(blockchain['icon'] as IconData, color: AppTheme.primaryColor),
                title: Text(blockchain['name'] as String),
                onTap: () {
                  viewModel.filterByBlockchain(blockchain['id'] as String);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                leading: const Icon(FontAwesomeIcons.ban, color: Colors.grey),
                title: const Text('Limpar filtro'),
                onTap: () {
                  viewModel.filterByBlockchain(null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, HistoryViewModel viewModel, String walletId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja remover esta carteira do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.removeWallet(walletId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showWalletDetails(dynamic wallet) {
    // Navegar para detalhes
  }
}
