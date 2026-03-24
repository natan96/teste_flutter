import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/models/imovel.dart';
import 'package:teste_flutter/providers/imovel_provider.dart';

class CadastroImovelScreen extends ConsumerStatefulWidget {
  const CadastroImovelScreen({super.key});

  @override
  ConsumerState<CadastroImovelScreen> createState() => _CadastroImovelScreenState();
}

class _CadastroImovelScreenState extends ConsumerState<CadastroImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _cidadeController = TextEditingController(text: 'Presidente Prudente');
  final _bairroController = TextEditingController();
  final _quartosController = TextEditingController();
  final _banheirosController = TextEditingController();
  final _vagasController = TextEditingController();
  final _areaController = TextEditingController();
  String _tipoSelecionado = 'venda';

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _quartosController.dispose();
    _banheirosController.dispose();
    _vagasController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final proximoId = ref.read(imoveisProvider.notifier).getProximoId();

    final novoImovel = Imovel(
      id: proximoId,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      tipo: _tipoSelecionado,
      preco: double.parse(_precoController.text.replaceAll(',', '.')),
      cidade: _cidadeController.text.trim(),
      bairro: _bairroController.text.trim(),
      quartos: int.parse(_quartosController.text),
      banheiros: int.parse(_banheirosController.text),
      vagas: int.parse(_vagasController.text),
      areaM2: double.parse(_areaController.text.replaceAll(',', '.')),
      foto: 'https://picsum.photos/seed/novo$proximoId/600/400',
    );

    await ref.read(imoveisProvider.notifier).adicionarImovel(novoImovel);

    // Analytics: rastrear criação de imóvel
    await FirebaseAnalytics.instance.logEvent(
      name: 'criar_imovel',
      parameters: {
        'tipo': novoImovel.tipo,
        'cidade': novoImovel.cidade,
        'preco': novoImovel.preco,
        'quartos': novoImovel.quartos,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Imóvel cadastrado com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Imóvel'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Apartamento Centro',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o título do imóvel';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Descreva o imóvel...',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a descrição do imóvel';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<String>(
              initialValue: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo *',
              ),
              items: const [
                DropdownMenuItem(value: 'venda', child: Text('Venda')),
                DropdownMenuItem(value: 'aluguel', child: Text('Aluguel')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Preço
            TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: 'Preço (R\$) *',
                hintText: '0.00',
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o preço';
                }
                final preco = double.tryParse(value.replaceAll(',', '.'));
                if (preco == null || preco <= 0) {
                  return 'Digite um preço válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Cidade
            TextFormField(
              controller: _cidadeController,
              decoration: const InputDecoration(
                labelText: 'Cidade *',
                hintText: 'Ex: Presidente Prudente',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite a cidade';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bairro
            TextFormField(
              controller: _bairroController,
              decoration: const InputDecoration(
                labelText: 'Bairro *',
                hintText: 'Ex: Centro',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o bairro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Características
            Text(
              'Características',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quartosController,
                    decoration: const InputDecoration(
                      labelText: 'Quartos *',
                      prefixIcon: Icon(Icons.bed_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _banheirosController,
                    decoration: const InputDecoration(
                      labelText: 'Banheiros *',
                      prefixIcon: Icon(Icons.bathtub_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vagasController,
                    decoration: const InputDecoration(
                      labelText: 'Vagas *',
                      prefixIcon: Icon(Icons.directions_car_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _areaController,
                    decoration: const InputDecoration(
                      labelText: 'Área (m²) *',
                      prefixIcon: Icon(Icons.square_foot),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      final area = double.tryParse(value.replaceAll(',', '.'));
                      if (area == null || area <= 0) {
                        return 'Inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
