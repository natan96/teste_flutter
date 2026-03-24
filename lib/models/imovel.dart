class Imovel {
  final int id;
  final String titulo;
  final String descricao;
  final String tipo; // 'venda' ou 'aluguel'
  final double preco;
  final String cidade;
  final String bairro;
  final int quartos;
  final int banheiros;
  final int vagas;
  final double areaM2;
  final String foto;

  Imovel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.preco,
    required this.cidade,
    required this.bairro,
    required this.quartos,
    required this.banheiros,
    required this.vagas,
    required this.areaM2,
    required this.foto,
  });

  factory Imovel.fromJson(Map<String, dynamic> json) {
    return Imovel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      tipo: json['tipo'] as String,
      preco: (json['preco'] as num).toDouble(),
      cidade: json['cidade'] as String,
      bairro: json['bairro'] as String,
      quartos: json['quartos'] as int,
      banheiros: json['banheiros'] as int,
      vagas: json['vagas'] as int,
      areaM2: (json['area_m2'] as num).toDouble(),
      foto: json['foto'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'preco': preco,
      'cidade': cidade,
      'bairro': bairro,
      'quartos': quartos,
      'banheiros': banheiros,
      'vagas': vagas,
      'area_m2': areaM2,
      'foto': foto,
    };
  }

  Imovel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? tipo,
    double? preco,
    String? cidade,
    String? bairro,
    int? quartos,
    int? banheiros,
    int? vagas,
    double? areaM2,
    String? foto,
  }) {
    return Imovel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      preco: preco ?? this.preco,
      cidade: cidade ?? this.cidade,
      bairro: bairro ?? this.bairro,
      quartos: quartos ?? this.quartos,
      banheiros: banheiros ?? this.banheiros,
      vagas: vagas ?? this.vagas,
      areaM2: areaM2 ?? this.areaM2,
      foto: foto ?? this.foto,
    );
  }
}
