import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_flutter/models/imovel.dart';

class StorageHelper {
  static const String _keyImoveis = 'imobibrasil_imoveis_data';  // Prefixo único para evitar conflitos

  static Future<void> init() async {}

  // CRUD Operations
  static Future<List<Imovel>> getImoveis() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyImoveis);
    
    if (jsonString == null) {
      return [];
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    final imoveis = jsonList.map((json) => Imovel.fromJson(json)).toList();
    return imoveis;
  }

  static Future<Imovel?> getImovel(int id) async {
    final imoveis = await getImoveis();
    try {
      return imoveis.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> insertImovel(Imovel imovel) async {
    final imoveis = await getImoveis();
    imoveis.add(imovel);
    await _saveImoveis(imoveis);
  }

  static Future<void> updateImovel(Imovel imovel) async {
    final imoveis = await getImoveis();
    final index = imoveis.indexWhere((i) => i.id == imovel.id);
    if (index != -1) {
      imoveis[index] = imovel;
      await _saveImoveis(imoveis);
    }
  }

  static Future<void> deleteImovel(int id) async {
    final imoveis = await getImoveis();
    imoveis.removeWhere((i) => i.id == id);
    await _saveImoveis(imoveis);
  }

  static Future<void> insertImoveisIniciais(List<Imovel> imoveis) async {
    await _saveImoveis(imoveis);
  }

  static Future<void> _saveImoveis(List<Imovel> imoveis) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = imoveis.map((i) => i.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_keyImoveis, jsonString);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyImoveis);
  }

  static dynamic get box => throw UnimplementedError('Box não é usado com SharedPreferences');
}
