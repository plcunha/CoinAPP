import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/wallet.dart';
import '../../viewmodels/wallet_validator_viewmodel.dart';
import '../shared/wallet_validation_result.dart';

/// Tela de Validação de Carteiras
class ValidatorScreen extends StatefulWidget {
  const ValidatorScreen({Key? key}) : super(key: key);

  @override
  State<ValidatorScreen> createState() => _ValidatorScreenState();
}

class _ValidatorScreenState extends State<ValidatorScreen> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocus = FocusNode();

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Validar Carteira'),
        elevation: 0,
      ),
      body: Consumer<WalletValidatorViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBlockchainSelector(viewModel),
                const SizedBox(height: 16),
                _buildAddressInput(viewModel),
                const SizedBox(height: 16),
                _buildValidateButton(viewModel),
                const SizedBox(height: 24),
                _buildResult(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              FontAwesomeIcons.magnifyingGlassDollar,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Validação de Carteira',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifique a validade de endereços de criptomoedas em múltiplas blockchains',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainSelector(WalletValidatorViewModel viewModel) {
    final blockchains = [
      {'id': 'bitcoin', 'name': 'Bitcoin', 'symbol': 'BTC', 'icon': FontAwesomeIcons.bitcoin},
      {'id': 'ethereum', 'name': 'Ethereum', 'symbol': 'ETH', 'icon': FontAwesomeIcons.ethereum},
      {'id': 'litecoin', 'name': 'Litecoin', 'symbol': 'LTC', 'icon': FontAwesomeIcons.coins},
      {'id': 'bitcoin_cash', 'name': 'Bitcoin Cash', 'symbol': 'BCH', 'icon': FontAwesomeIcons.moneyBill},
      {'id': 'dogecoin', 'name': 'Dogecoin', 'symbol': 'DOGE', 'icon': FontAwesomeIcons.dog},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione a Blockchain',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blockchains.length,
            itemBuilder: (context, index) {
              final blockchain = blockchains[index];
              final isSelected = viewModel.selectedBlockchain == blockchain['id'];

              return GestureDetector(
                onTap: () => viewModel.selectBlockchain(blockchain['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        blockchain['icon'] as IconData,
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        blockchain['symbol'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput(WalletValidatorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Endereço da Carteira',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          focusNode: _addressFocus,
          maxLines: 3,
          minLines: 1,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cole o endereço da carteira aqui...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(FontAwesomeIcons.wallet, color: Colors.grey[400]),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(FontAwesomeIcons.paste, color: Colors.grey[400]),
                  onPressed: _pasteFromClipboard,
                ),
                if (_addressController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(FontAwesomeIcons.xmark, color: Colors.grey[400]),
                    onPressed: () {
                      _addressController.clear();
                      viewModel.reset();
                    },
                  ),
              ],
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildValidateButton(WalletValidatorViewModel viewModel) {
    final isLoading = viewModel.state is ValidatorLoading || 
                      viewModel.state is WalletInfoLoading;

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => viewModel.validateAddress(_addressController.text),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(FontAwesomeIcons.magnifyingGlass),
      label: Text(
        isLoading ? 'Validando...' : 'Validar Carteira',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildResult(WalletValidatorViewModel viewModel) {
    final state = viewModel.state;

    if (state is ValidatorInitial) {
      return const SizedBox.shrink();
    }

    if (state is ValidationSuccess) {
      return WalletValidationResult(
        isValid: state.result.isValid,
        address: state.result.address,
        blockchain: state.result.blockchain,
        errorMessage: state.result.errorMessage,
        walletInfo: state.walletInfo,
      );
    }

    if (state is WalletInfoLoaded) {
      return WalletValidationResult(
        isValid: true,
        address: state.wallet.address,
        blockchain: state.wallet.blockchain,
        walletInfo: state.wallet,
      );
    }

    if (state is ValidationError) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.circleExclamation,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _addressController.text = clipboardData!.text!;
      });
    }
  }
}
