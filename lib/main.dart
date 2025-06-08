import 'package:coin_aplication/data/coin_api_datasource.dart';
import 'package:coin_aplication/repository/coin_repository.dart';
import 'package:coin_aplication/view/home_page.dart';
import 'package:coin_aplication/viewmodel/coin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          CoinViewModel(CoinRepository(CoinApiDataSource()))..loadCryptos(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()),
    ),
  );
}
