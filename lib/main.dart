import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/blockchain_remote_datasource.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'domain/repositories/wallet_repository.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/history_viewmodel.dart';
import 'presentation/viewmodels/wallet_validator_viewmodel.dart';
import 'presentation/views/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientação
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar tema da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const CoinWalletApp());
}

/// Aplicativo CoinWallet Validator
class CoinWalletApp extends StatelessWidget {
  const CoinWalletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configurar injeção de dependências (simplificada)
    final remoteDataSource = BlockchainRemoteDataSourceImpl();
    final walletRepository = WalletRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    
    return MultiProvider(
      providers: [
        Provider<WalletRepository>(
          create: (_) => walletRepository,
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardViewModel(
            repository: context.read<WalletRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WalletValidatorViewModel(
            repository: context.read<WalletRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(
            repository: context.read<WalletRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CoinWallet Validator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
      ),
    );
  }
}
