import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';

/// Interface para cache local
abstract class LocalCacheDataSource {
  /// Salva dados no cache
  Future<void> cacheData(String key, dynamic data);
  
  /// Recupera dados do cache
  Future<dynamic> getCachedData(String key);
  
  /// Remove dados do cache
  Future<void> removeCachedData(String key);
  
  /// Limpa todo o cache
  Future<void> clearCache();
  
  /// Verifica se existe dados no cache
  Future<bool> hasCachedData(String key);
}

/// Implementação usando SharedPreferences
class LocalCacheDataSourceImpl implements LocalCacheDataSource {
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> cacheData(String key, dynamic data) async {
    try {
      final prefs = await _preferences;
      final jsonString = json.encode(data);
      await prefs.setString(key, jsonString);
    } catch (e) {
      throw CacheException('Erro ao salvar no cache: $e');
    }
  }

  @override
  Future<dynamic> getCachedData(String key) async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(key);
      
      if (jsonString == null) {
        return null;
      }
      
      return json.decode(jsonString);
    } catch (e) {
      throw CacheException('Erro ao recuperar do cache: $e');
    }
  }

  @override
  Future<void> removeCachedData(String key) async {
    try {
      final prefs = await _preferences;
      await prefs.remove(key);
    } catch (e) {
      throw CacheException('Erro ao remover do cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
    } catch (e) {
      throw CacheException('Erro ao limpar cache: $e');
    }
  }

  @override
  Future<bool> hasCachedData(String key) async {
    try {
      final prefs = await _preferences;
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
