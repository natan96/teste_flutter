import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/providers/auth_provider.dart';
import 'package:teste_flutter/providers/imovel_provider.dart';
import 'package:teste_flutter/screens/cadastro_imovel_screen.dart';
import 'package:teste_flutter/screens/login_screen.dart';
import 'package:teste_flutter/widgets/imovel_card.dart';

class ListaImoveisScreen extends ConsumerStatefulWidget {
  const ListaImoveisScreen({super.key});

  @override
  ConsumerState<ListaImoveisScreen> createState() => _ListaImoveisScreenState();
}

class _ListaImoveisScreenState extends ConsumerState<ListaImoveisScreen> {
  final _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await ref.read(usuarioProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imoveisAsync = ref.watch(imoveisFiltradosProvider);
    final filtroTipo = ref.watch(filtroTipoProvider);
    final usuario = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/icone-original-imobibrasil.png',
          height: 32,
        ),
        actions: [
          // Nome do usuário
          usuario.when(
            data: (user) => user != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Text(
                        user.nome.split(' ').first,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          
          // Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Color(0xFF212121)),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Campo de busca com largura limitada
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextField(
                      controller: _buscaController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por título ou cidade...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _buscaController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _buscaController.clear();
                                  ref.read(filtroBuscaProvider.notifier).state = '';
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        ref.read(filtroBuscaProvider.notifier).state = value;
                        
                        // Analytics: rastrear busca (apenas se tiver 3+ caracteres)
                        if (value.length >= 3) {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'buscar_imovel',
                            parameters: {'termo_busca': value},
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filtros de tipo
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: filtroTipo == null,
                        onSelected: (selected) {
                          ref.read(filtroTipoProvider.notifier).state = null;
                          FirebaseAnalytics.instance.logEvent(
                            name: 'filtrar_tipo',
                            parameters: {'filtro': 'todos'},
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Venda'),
                        selected: filtroTipo == 'venda',
                        onSelected: (selected) {
                          ref.read(filtroTipoProvider.notifier).state = 
                              selected ? 'venda' : null;
                          FirebaseAnalytics.instance.logEvent(
                            name: 'filtrar_tipo',
                            parameters: {'filtro': selected ? 'venda' : 'todos'},
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Aluguel'),
                        selected: filtroTipo == 'aluguel',
                        onSelected: (selected) {
                          ref.read(filtroTipoProvider.notifier).state = 
                              selected ? 'aluguel' : null;
                          FirebaseAnalytics.instance.logEvent(
                            name: 'filtrar_tipo',
                            parameters: {'filtro': selected ? 'aluguel' : 'todos'},
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de imóveis
          Expanded(
            child: imoveisAsync.when(
              data: (imoveis) {
                if (imoveis.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum imóvel encontrado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tente ajustar os filtros',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(imoveisProvider.notifier).loadImoveis();
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: imoveis.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ImovelCard(imovel: imoveis[index]),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar imóveis',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(imoveisProvider.notifier).loadImoveis();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CadastroImovelScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
