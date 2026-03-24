import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/models/imovel.dart';
import 'package:teste_flutter/services/imovel_service.dart';

final imovelServiceProvider = Provider<ImovelService>((ref) => ImovelService());

final imoveisProvider = StateNotifierProvider<ImoveisNotifier, AsyncValue<List<Imovel>>>((ref) {
  return ImoveisNotifier(ref.watch(imovelServiceProvider));
});

// Provider para filtros
final filtroTipoProvider = StateProvider<String?>((ref) => null);
final filtroBuscaProvider = StateProvider<String>((ref) => '');

// Provider para lista filtrada
final imoveisFiltradosProvider = Provider<AsyncValue<List<Imovel>>>((ref) {
  final imoveisAsync = ref.watch(imoveisProvider);
  final filtroTipo = ref.watch(filtroTipoProvider);
  final filtroBusca = ref.watch(filtroBuscaProvider).toLowerCase();

  return imoveisAsync.whenData((imoveis) {
    var filtered = imoveis;

    // Filtrar por tipo
    if (filtroTipo != null) {
      filtered = filtered.where((i) => i.tipo == filtroTipo).toList();
    }

    // Filtrar por busca
    if (filtroBusca.isNotEmpty) {
      filtered = filtered.where((i) {
        return i.titulo.toLowerCase().contains(filtroBusca) ||
            i.cidade.toLowerCase().contains(filtroBusca) ||
            i.bairro.toLowerCase().contains(filtroBusca);
      }).toList();
    }

    return filtered;
  });
});

class ImoveisNotifier extends StateNotifier<AsyncValue<List<Imovel>>> {
  final ImovelService _service;

  ImoveisNotifier(this._service) : super(const AsyncValue.loading()) {
    loadImoveis();
  }

  Future<void> loadImoveis() async {
    state = const AsyncValue.loading();
    try {
      final imoveis = await _service.getImoveis();
      state = AsyncValue.data(imoveis);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> adicionarImovel(Imovel imovel) async {
    try {
      await _service.adicionarImovel(imovel);
      // Recarregar lista do banco
      await loadImoveis();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> atualizarImovel(Imovel imovelAtualizado) async {
    try {
      await _service.atualizarImovel(imovelAtualizado);
      // Recarregar lista do banco
      await loadImoveis();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  int getProximoId() {
    return state.when(
      data: (imoveis) => imoveis.isEmpty ? 1 : imoveis.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1,
      loading: () => 1,
      error: (error, stack) => 1,
    );
  }
}
