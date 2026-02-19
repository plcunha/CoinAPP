import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/wallet.dart';

/// Card de exibição de carteira
class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  const WalletCard({
    Key? key,
    required this.wallet,
    this.onTap,
    this.onFavorite,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBlockchainIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getBlockchainName(wallet.blockchain),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatAddress(wallet.address),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          wallet.isFavorite
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          color: wallet.isFavorite
                              ? AppTheme.errorColor
                              : Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: onFavorite,
                      ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
              if (wallet.balance != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${wallet.balance?.toStringAsFixed(8) ?? '0.00000000'} ${wallet.balanceSymbol ?? wallet.blockchain.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (wallet.transactionCount != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transações',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${wallet.transactionCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockchainIcon() {
    final colors = {
      'bitcoin': const Color(0xFFF7931A),
      'ethereum': const Color(0xFF627EEA),
      'litecoin': const Color(0xFF345D9D),
      'bitcoin_cash': const Color(0xFF8DC351),
      'dogecoin': const Color(0xFFC2A633),
    };

    final icons = {
      'bitcoin': FontAwesomeIcons.bitcoin,
      'ethereum': FontAwesomeIcons.ethereum,
      'litecoin': FontAwesomeIcons.coins,
      'bitcoin_cash': FontAwesomeIcons.moneyBill,
      'dogecoin': FontAwesomeIcons.dog,
    };

    final color = colors[wallet.blockchain.toLowerCase()] ?? AppTheme.primaryColor;
    final icon = icons[wallet.blockchain.toLowerCase()] ?? FontAwesomeIcons.wallet;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  String _getBlockchainName(String blockchain) {
    final names = {
      'bitcoin': 'Bitcoin',
      'ethereum': 'Ethereum',
      'litecoin': 'Litecoin',
      'bitcoin_cash': 'Bitcoin Cash',
      'dogecoin': 'Dogecoin',
    };
    return names[blockchain.toLowerCase()] ?? blockchain;
  }

  String _formatAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }
}
