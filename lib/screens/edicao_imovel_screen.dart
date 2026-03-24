import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/models/imovel.dart';
import 'package:teste_flutter/providers/imovel_provider.dart';

class EdicaoImovelScreen extends ConsumerStatefulWidget {
  final Imovel imovel;

  const EdicaoImovelScreen({super.key, required this.imovel});

  @override
  ConsumerState<EdicaoImovelScreen> createState() => _EdicaoImovelScreenState();
}

class _EdicaoImovelScreenState extends ConsumerState<EdicaoImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _cidadeController;
  late TextEditingController _bairroController;
  late TextEditingController _quartosController;
  late TextEditingController _banheirosController;
  late TextEditingController _vagasController;
  late TextEditingController _areaController;
  late String _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.imovel.titulo);
    _descricaoController = TextEditingController(text: widget.imovel.descricao);
    _precoController = TextEditingController(text: widget.imovel.preco.toStringAsFixed(2));
    _cidadeController = TextEditingController(text: widget.imovel.cidade);
    _bairroController = TextEditingController(text: widget.imovel.bairro);
    _quartosController = TextEditingController(text: widget.imovel.quartos.toString());
    _banheirosController = TextEditingController(text: widget.imovel.banheiros.toString());
    _vagasController = TextEditingController(text: widget.imovel.vagas.toString());
    _areaController = TextEditingController(text: widget.imovel.areaM2.toStringAsFixed(0));
    _tipoSelecionado = widget.imovel.tipo;
  }

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

    final imovelAtualizado = widget.imovel.copyWith(
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
    );

    await ref.read(imoveisProvider.notifier).atualizarImovel(imovelAtualizado);

    // Analytics: rastrear edição de imóvel
    await FirebaseAnalytics.instance.logEvent(
      name: 'editar_imovel',
      parameters: {
        'imovel_id': imovelAtualizado.id,
        'tipo': imovelAtualizado.tipo,
        'cidade': imovelAtualizado.cidade,
        'preco': imovelAtualizado.preco,
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Imóvel atualizado com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop(); // Voltar para a tela de detalhe
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Imóvel'),
      ),
      body: Form(
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
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
