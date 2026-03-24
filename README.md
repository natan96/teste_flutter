# ImobiBrasil - App de Imóveis Flutter

Aplicativo desenvolvido como teste técnico para a vaga de Desenvolvedor Flutter Pleno na ImobiBrasil.

## Funcionalidades Implementadas

### Requisitos Obrigatórios

- **Tela de Lista de Imóveis**
  - Cards com foto, título, cidade, preço e tipo (venda/aluguel)
  - Campo de busca por texto (título, cidade ou bairro)
  - Filtro por tipo: Todos, Venda, Aluguel
  - Estados de loading, erro e lista vazia
  - Pull-to-refresh

- **Tela de Detalhe do Imóvel**
  - Foto principal em destaque
  - Informações completas (título, descrição, preço, localização)
  - Características (quartos, banheiros, vagas, área)
  - Botão "Entrar em Contato" com dialog informativo
  - Botão para editar o imóvel

- **Tela de Edição do Imóvel**
  - Formulário com todos os campos editáveis
  - Validação de campos obrigatórios
  - Validação de valores numéricos
  - Atualização em tempo real na lista
  - Feedback visual ao salvar
  - Opção de cancelar

### Extras Implementados

- **Sistema de Login**
  - Tela de login com validação de email/senha
  - Credenciais fixas: `corretor@imobibrasil.com.br` / `imobi2026`
  - Persistência de sessão com SharedPreferences
  - Nome do usuário exibido na AppBar
  - Botão de logout
  - Proteção de rotas (sem login não acessa o app)

- **Cadastro de Novo Imóvel**
  - Botão flutuante para adicionar imóvel
  - Formulário completo com validações
  - Geração automática de ID incremental
  - Foto placeholder automática
  - Novo imóvel aparece imediatamente na lista

- **Persistência Local com SharedPreferences**
  - SharedPreferences para sessão do usuário
  - SharedPreferences + JSON para armazenamento de imóveis
  - Dados sobrevivem ao restart do app
  - Funciona perfeitamente em todas as plataformas (Web, Mobile, Desktop)
  - CRUD completo com persistência automática
  - Serialização/desserialização JSON eficiente

- **Firebase Analytics**
  - Integração completa com Firebase Analytics
  - Rastreamento de eventos e comportamento do usuário
  - Configuração multiplataforma (Android, iOS, Web)
  - Analytics habilitado automaticamente na inicialização do app
  - Preparado para métricas de negócio e análise de uso

## Arquitetura e Decisões Técnicas

### Gerenciamento de Estado: Riverpod

Escolhi **Riverpod** por ser:

- Mais moderno e type-safe que Provider
- Melhor performance e menos boilerplate que BLoC
- Excelente suporte a estados assíncronos
- Facilita injeção de dependências
- Recomendado pela própria comunidade Flutter

### Persistência de Dados: SharedPreferences + JSON

Escolhi **SharedPreferences com JSON** para persistência local por:

- **Confiabilidade no Web**: Funciona perfeitamente em navegadores (problema com Hive/IndexedDB)
- **Multiplataforma**: 100% compatível com Web, Mobile e Desktop
- **Simplicidade**: Não requer configuração complexa ou adapters
- **Leve**: Sem dependências nativas pesadas
- **Debugável**: JSON legível facilita debug
- **Performático**: Adequado para listas de até milhares de itens

**Implementação:**

- **StorageHelper** (`lib/database/storage_helper.dart`): Abstração para operações CRUD
- Serialização/desserialização JSON automática via `toJson()`/`fromJson()`
- Inicialização no `main()` antes do app com `await StorageHelper.init()`
- Dados persistem automaticamente entre sessões
- Flag `db_populated` para popular 6 imóveis iniciais apenas uma vez
- Logs de debug para rastrear operações de storage

### Estrutura de Pastas

```
lib/
├── models/              # Modelos de dados (Imovel, Usuario)
├── services/            # Camada de serviços/API (ImovelService, AuthService)
├── providers/           # Providers Riverpod (estado global)
├── screens/             # Telas do app
├── widgets/             # Widgets reutilizáveis
├── database/            # Camada de persistência (StorageHelper)
├── theme/               # Tema e cores da marca
└── main.dart            # Entry point e navegação
```

### Separação de Camadas

1. **Models**: Classes de domínio com serialização JSON
2. **Database**: Camada de persistência com SharedPreferences
3. **Services**: Lógica de negócio e acesso a dados
4. **Providers**: Gerenciamento de estado com Riverpod
5. **Screens**: Apenas apresentação e interação com usuário
6. **Widgets**: Componentes reutilizáveis

### Decisões de Design

- **Material 3**: Utilizei Material 3 (useMaterial3: true) para UI moderna
- **Cores ImobiBrasil**: Verde primário (#1B7A43), azul secundário (#1A73E8)
- **Cards** elevados para destacar imóveis
- **FilterChips** para filtros intuitivos
- **Hero animations** podem ser adicionadas facilmente entre lista e detalhe

## Dependências Utilizadas

- **flutter_riverpod** (2.6.1): Gerenciamento de estado
- **intl** (0.20.2): Formatação de valores (moeda, datas)
- **http** (1.2.2): Preparado para API real
- **flutter_svg** (2.0.16): Suporte a logos SVG da marca
- **shared_preferences** (2.3.3): Persistência local (sessão e dados)
- **firebase_core**: Inicialização do Firebase
- **firebase_analytics**: Analytics e rastreamento de eventos

## Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK 3.11.3 ou superior
- Dart SDK 3.11.3 ou superior
- Android Studio / Xcode (para emuladores)
- VS Code ou Android Studio (recomendado)

### Passos

1. Clone o repositório:

```bash
git clone <url-do-repositorio>
cd teste_flutter
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Execute o app:

```bash
flutter run
```

4. Ou execute em um dispositivo específico:

```bash
flutter devices  # Lista dispositivos disponíveis
flutter run -d <device-id>
```

### Credenciais de Teste

```
Email: corretor@imobibrasil.com.br
Senha: imobi2026
```

### Sobre a Persistência

Os dados são armazenados localmente usando **SharedPreferences + JSON**:

- **6 imóveis iniciais** são carregados automaticamente na primeira execução
- **Todos os imóveis adicionados/editados** são salvos automaticamente
- **Dados persistem** entre sessões (feche e abra o app novamente)
- **Funciona em todas as plataformas**: Web, Mobile e Desktop

#### Testando Persistência no Web

**IMPORTANTE**: `flutter run -d chrome` usa um perfil temporário do Chrome, então os dados **não persistem** entre execuções. Isso é comportamento esperado do Flutter durante desenvolvimento.

**Para testar persistência corretamente no Web:**

1. Faça o build de produção:

   ```bash
   flutter build web
   ```

2. Sirva localmente com servidor HTTP:

   ```bash
   cd build\web
   dart pub global activate dhttpd  # Apenas uma vez
   dhttpd --port 8080
   ```

3. Acesse `http://localhost:8080` no navegador

4. Adicione/edite imóveis, feche o navegador completamente, reabra - **os dados persistirão!**

**Storage por Plataforma:**

- **Web**: localStorage (navegador) - persiste entre sessões do navegador
- **Mobile**: Arquivo local (AppData/Documents) - persiste entre instalações
- **Desktop**: Arquivo local - persiste entre execuções

Para **limpar todos os dados**: Limpe o cache do app/navegador ou localStorage

## Funcionalidades em Destaque

### Busca e Filtros

- Busca em tempo real por título, cidade ou bairro
- Filtros por tipo (Venda/Aluguel)
- Limpeza rápida dos filtros

### Validações

- Campos obrigatórios
- Valores numéricos positivos
- Email válido no login
- Feedback visual de erros

### UX

- Loading states com CircularProgressIndicator
- Estados vazios com mensagens amigáveis
- Pull-to-refresh na lista
- SnackBars de confirmação
- Navegação intuitiva

### Persistência de Dados

- **StorageHelper**: Camada de abstração sobre SharedPreferences
- SharedPreferences + JSON para armazenamento local
- CRUD completo com persistência automática (Create, Read, Update, Delete)
- Funciona perfeitamente em todas as plataformas (Web, Mobile, Desktop)
- Dados sobrevivem ao restart do app (em build de produção)
- Serialização JSON eficiente via `toJson()`/`fromJson()`
- População inicial automática na primeira execução (6 imóveis)

## O Que Faria Diferente com Mais Tempo

### Funcionalidades

- [ ] CI/CD com GitHub Actions
- [ ] Firebase Crashlytics
- [ ] Hero animations nas transições
- [ ] Shimmer effect no loading
- [ ] Upload de fotos reais
- [ ] Mapa com localização dos imóveis

### Arquitetura

- [ ] Clean Architecture mais rigorosa
- [ ] Repository pattern mais explícito
- [ ] Use cases/interactors
- [ ] Abstração da camada de dados
- [ ] Testes mockados dos providers

### UI/UX

- [ ] Modo escuro
- [ ] Animações mais elaboradas
- [ ] Skeleton loading
- [ ] Infinite scroll/paginação
- [ ] Filtros avançados (faixa de preço, características)
- [ ] Ordenação (preço, área, data)

## Capturas de Tela

(Executar o app para visualizar)

## Observações

- O app foi desenvolvido seguindo as boas práticas Flutter
- Código limpo com nomes descritivos
- Componentização adequada
- Tratamento de erros e edge cases
- Formatação consistente (flutter format)
- Sem warnings ou erros de análise

## Autor

Desenvolvido por Natan como teste técnico para ImobiBrasil.

## Licença

Projeto de uso exclusivo para avaliação técnica.
