# CoinWallet Validator - React + TypeScript

Sistema profissional de validação e verificação de carteiras de criptomoedas, agora em React com TypeScript!

## 🚀 Tecnologias

- **React 18** - Biblioteca UI
- **TypeScript** - Tipagem estática
- **Vite** - Build tool ultrarrápido
- **Material-UI (MUI)** - Componentes de UI
- **Zustand** - Gerenciamento de estado
- **Axios** - Cliente HTTP

## 📦 Instalação

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente (opcional)
cp .env.example .env
# Edite .env e adicione sua chave Etherscan se desejar
```

## 🖥️ Como Rodar

### Modo Desenvolvimento
```bash
npm run dev
```
Acesse: http://localhost:3000

### Build para Produção
```bash
npm run build
```
Os arquivos estáticos ficarão em `dist/`

### Preview do Build
```bash
npm run preview
```

## 🌐 Deploy

### Vercel (Recomendado)
```bash
npm i -g vercel
vercel
```

### Netlify
```bash
npm run build
# Arraste a pasta dist/ para o Netlify
```

### GitHub Pages
```bash
npm run build
# Configure o GitHub Actions para deploy automático
```

## ⚠️ CORS

Como o app faz requisições para APIs blockchain, você pode encontrar problemas de CORS em produção.

**Soluções:**
1. Use um proxy CORS (ex: `https://cors-anywhere.herokuapp.com/`)
2. Configure um backend próprio para fazer as requisições
3. Use extensão de navegador para desabilitar CORS (apenas desenvolvimento)

## 📱 Funcionalidades

✅ Validação de endereços (Bitcoin, Ethereum, Litecoin, BCH, DOGE)
✅ Consulta de saldo na blockchain
✅ Histórico de validações
✅ Favoritos
✅ Busca e filtros
✅ Design responsivo
✅ PWA-ready

## 📁 Estrutura

```
src/
├── components/     # Componentes React
├── services/       # Serviços de API e validação
├── store/          # Estado global (Zustand)
├── theme/          # Tema Material-UI
├── types/          # Tipos TypeScript
└── utils/          # Constantes e utilitários
```

## 🔧 Comandos

| Comando | Descrição |
|---------|-----------|
| `npm run dev` | Inicia servidor de desenvolvimento |
| `npm run build` | Cria build de produção |
| `npm run preview` | Preview do build |
| `npm run lint` | Executa ESLint |

## 📝 Licença

MIT
