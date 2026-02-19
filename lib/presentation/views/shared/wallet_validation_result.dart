import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/wallet.dart';

/// Widget de exibição do resultado de validação
class WalletValidationResult extends StatelessWidget {
  final bool isValid;
  final String address;
  final String blockchain;
  final String? errorMessage;
  final Wallet? walletInfo;

  const WalletValidationResult({
    Key? key,
    required this.isValid,
    required this.address,
    required this.blockchain,
    this.errorMessage,
    this.walletInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isValid ? AppTheme.successGradient : AppTheme.errorGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isValid ? AppTheme.successColor : AppTheme.errorColor)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValid ? FontAwesomeIcons.check : FontAwesomeIcons.xmark,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isValid ? 'Endereço Válido' : 'Endereço Inválido',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBlockchainName(blockchain),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isValid && errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isValid) ...[
            const SizedBox(height: 16),
            _buildAddressBox(context),
          ],
          if (isValid && walletInfo != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildWalletInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              address,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.copy,
              color: Colors.white70,
              size: 18,
            ),
            onPressed: () {
              // Copiar para clipboard
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(BuildContext context) {
    return Column(
      children: [
        if (walletInfo?.balance != null)
          _buildInfoRow(
            'Saldo',
            '${walletInfo!.balance!.toStringAsFixed(8)} ${walletInfo!.balanceSymbol ?? blockchain.toUpperCase()}',
            FontAwesomeIcons.coins,
          ),
        if (walletInfo?.transactionCount != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            'Transações',
            '${walletInfo!.transactionCount}',
            FontAwesomeIcons.arrowRightArrowLeft,
          ),
        ],
        if (walletInfo?.validatedAt != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            'Validado em',
            _formatDate(walletInfo!.validatedAt!),
            FontAwesomeIcons.clock,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getBlockchainName(String blockchain) {
    final names = {
      'bitcoin': 'Bitcoin (BTC)',
      'ethereum': 'Ethereum (ETH)',
      'litecoin': 'Litecoin (LTC)',
      'bitcoin_cash': 'Bitcoin Cash (BCH)',
      'dogecoin': 'Dogecoin (DOGE)',
    };
    return names[blockchain.toLowerCase()] ?? blockchain.toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
