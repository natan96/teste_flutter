import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_flutter/database/storage_helper.dart';
import 'package:teste_flutter/models/imovel.dart';

class ImovelService {
  static const String _keyDbPopulated = 'db_populated';

  // JSON simulado da API - usado apenas para popular o banco inicialmente
  static const String _mockData = '''
{
  "imoveis": [
    {
      "id": 1,
      "titulo": "Apartamento Centro",
      "descricao": "Apartamento de 2 quartos no centro da cidade, próximo ao comércio e transporte público. Reformado recentemente com acabamento moderno.",
      "tipo": "aluguel",
      "preco": 1800.0,
      "cidade": "Presidente Prudente",
      "bairro": "Centro",
      "quartos": 2,
      "banheiros": 1,
      "vagas": 1,
      "area_m2": 65,
      "foto": "https://picsum.photos/seed/apt1/600/400"
    },
    {
      "id": 2,
      "titulo": "Casa Jardim Bongiovani",
      "descricao": "Casa ampla com 3 quartos, quintal e churrasqueira. Rua tranquila em bairro residencial consolidado.",
      "tipo": "venda",
      "preco": 420000.0,
      "cidade": "Presidente Prudente",
      "bairro": "Jardim Bongiovani",
      "quartos": 3,
      "banheiros": 2,
      "vagas": 2,
      "area_m2": 150,
      "foto": "https://picsum.photos/seed/casa2/600/400"
    },
    {
      "id": 3,
      "titulo": "Kitnet Universitária",
      "descricao": "Kitnet mobiliada próxima à Unesp. Ideal para estudantes. Inclui água e internet no valor.",
      "tipo": "aluguel",
      "preco": 850.0,
      "cidade": "Presidente Prudente",
      "bairro": "Vila Santa Helena",
      "quartos": 1,
      "banheiros": 1,
      "vagas": 0,
      "area_m2": 28,
      "foto": "https://picsum.photos/seed/kit3/600/400"
    },
    {
      "id": 4,
      "titulo": "Sobrado Vila Marcondes",
      "descricao": "Sobrado comercial e residencial com 4 quartos e ponto comercial no térreo. Boa localização com alto fluxo.",
      "tipo": "venda",
      "preco": 580000.0,
      "cidade": "Presidente Prudente",
      "bairro": "Vila Marcondes",
      "quartos": 4,
      "banheiros": 3,
      "vagas": 2,
      "area_m2": 200,
      "foto": "https://picsum.photos/seed/sobrado4/600/400"
    },
    {
      "id": 5,
      "titulo": "Chácara Montalvão",
      "descricao": "Chácara de 2.000m² com piscina, pomar e casa sede de 3 quartos. Acesso pavimentado a 10 minutos do centro.",
      "tipo": "venda",
      "preco": 350000.0,
      "cidade": "Presidente Prudente",
      "bairro": "Montalvão",
      "quartos": 3,
      "banheiros": 2,
      "vagas": 4,
      "area_m2": 2000,
      "foto": "https://picsum.photos/seed/chacara5/600/400"
    },
    {
      "id": 6,
      "titulo": "Sala Comercial Ed. Corporate",
      "descricao": "Sala de 40m² no edifício Corporate, 8º andar. Ar-condicionado central, recepção e segurança 24h.",
      "tipo": "aluguel",
      "preco": 2200.0,
      "cidade": "Presidente Prudente",
      "bairro": "Centro",
      "quartos": 0,
      "banheiros": 1,
      "vagas": 1,
      "area_m2": 40,
      "foto": "https://picsum.photos/seed/sala6/600/400"
    }
  ]
}
''';

  Future<List<Imovel>> getImoveis() async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    // Verificar se já populamos o banco antes
    final prefs = await SharedPreferences.getInstance();
    final jaPopulado = prefs.getBool(_keyDbPopulated) ?? false;

    // Popular apenas na primeira vez
    if (!jaPopulado) {
      await _popularBancoInicial();
      await prefs.setBool(_keyDbPopulated, true);
    }

    // Carregar dados do Storage
    return await StorageHelper.getImoveis();
  }

  Future<void> _popularBancoInicial() async {
    final Map<String, dynamic> data = json.decode(_mockData);
    final List<dynamic> imoveisJson = data['imoveis'];
    final imoveis = imoveisJson.map((json) => Imovel.fromJson(json)).toList();
    
    await StorageHelper.insertImoveisIniciais(imoveis);
  }

  Future<void> adicionarImovel(Imovel imovel) async {
    await StorageHelper.insertImovel(imovel);
  }

  Future<void> atualizarImovel(Imovel imovel) async {
    await StorageHelper.updateImovel(imovel);
  }

  Future<void> deletarImovel(int id) async {
    await StorageHelper.deleteImovel(id);
  }
}

