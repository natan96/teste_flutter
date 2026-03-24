import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teste_flutter/models/imovel.dart';
import 'package:teste_flutter/screens/edicao_imovel_screen.dart';

class DetalheImovelScreen extends StatefulWidget {
  final Imovel imovel;

  const DetalheImovelScreen({super.key, required this.imovel});

  @override
  State<DetalheImovelScreen> createState() => _DetalheImovelScreenState();
}

class _DetalheImovelScreenState extends State<DetalheImovelScreen> {
  @override
  void initState() {
    super.initState();
    // Analytics: rastrear visualização de detalhe
    FirebaseAnalytics.instance.logEvent(
      name: 'visualizar_imovel',
      parameters: {
        'imovel_id': widget.imovel.id,
        'tipo': widget.imovel.tipo,
        'cidade': widget.imovel.cidade,
        'preco': widget.imovel.preco,
      },
    );
  }

  String _formatarPreco(double preco) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(preco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Imóvel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EdicaoImovelScreen(imovel: widget.imovel),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto principal
                Stack(
              children: [
                Image.network(
                  widget.imovel.foto,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.home, size: 100, color: Colors.grey),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 300,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
                // Badge de tipo
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.imovel.tipo == 'venda'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.imovel.tipo == 'venda' ? 'VENDA' : 'ALUGUEL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e preço
                  Text(
                    widget.imovel.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatarPreco(widget.imovel.preco),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Localização
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.imovel.bairro}, ${widget.imovel.cidade}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Características
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Características',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCaracteristica(
                                  context,
                                  Icons.bed_outlined,
                                  '${widget.imovel.quartos}',
                                  'Quartos',
                                ),
                              ),
                              Expanded(
                                child: _buildCaracteristica(
                                  context,
                                  Icons.bathtub_outlined,
                                  '${widget.imovel.banheiros}',
                                  'Banheiros',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCaracteristica(
                                  context,
                                  Icons.directions_car_outlined,
                                  '${widget.imovel.vagas}',
                                  'Vagas',
                                ),
                              ),
                              Expanded(
                                child: _buildCaracteristica(
                                  context,
                                  Icons.square_foot,
                                  '${widget.imovel.areaM2.toStringAsFixed(0)}m²',
                                  'Área',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descrição',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.imovel.descricao,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de contato
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Entrar em Contato'),
                                content: const Text(
                                  'Funcionalidade de contato está em desenvolvimento. '
                                  'Em breve você poderá entrar em contato com o corretor!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Entrar em Contato'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaracteristica(
    BuildContext context,
    IconData icon,
    String valor,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          valor,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
