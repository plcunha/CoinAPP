import type { Blockchain } from './index';

export const APP_NAME = 'CoinWallet Validator';
export const APP_VERSION = '2.0.0';

export const BLOCKCHAINS: Record<string, Blockchain> = {
  bitcoin: {
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'BTC',
    color: '#F7931A',
    decimals: 8,
    addressPrefixes: ['1', '3', 'bc1'],
    isEnabled: true,
    explorerUrl: 'https://blockchain.info',
  },
  ethereum: {
    id: 'ethereum',
    name: 'Ethereum',
    symbol: 'ETH',
    color: '#627EEA',
    decimals: 18,
    addressPrefixes: ['0x'],
    isEnabled: true,
    explorerUrl: 'https://etherscan.io',
  },
  litecoin: {
    id: 'litecoin',
    name: 'Litecoin',
    symbol: 'LTC',
    color: '#345D9D',
    decimals: 8,
    addressPrefixes: ['L', 'M', 'ltc1'],
    isEnabled: true,
    explorerUrl: 'https://blockchair.com/litecoin',
  },
  bitcoin_cash: {
    id: 'bitcoin_cash',
    name: 'Bitcoin Cash',
    symbol: 'BCH',
    color: '#8DC351',
    decimals: 8,
    addressPrefixes: ['bitcoincash:', '1', 'q'],
    isEnabled: true,
    explorerUrl: 'https://blockchair.com/bitcoin-cash',
  },
  dogecoin: {
    id: 'dogecoin',
    name: 'Dogecoin',
    symbol: 'DOGE',
    color: '#C2A633',
    decimals: 8,
    addressPrefixes: ['D'],
    isEnabled: true,
    explorerUrl: 'https://blockchair.com/dogecoin',
  },
};

export const API_ENDPOINTS = {
  bitcoin: 'https://blockchain.info',
  ethereum: 'https://api.etherscan.io/api',
  litecoin: 'https://api.blockcypher.com/v1/ltc/main',
  dogecoin: 'https://api.blockcypher.com/v1/doge/main',
  bitcoin_cash: 'https://api.blockchair.com/bitcoin-cash',
};

export const ETHERSCAN_API_KEY = import.meta.env.VITE_ETHERSCAN_API_KEY || '';
