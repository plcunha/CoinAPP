export type WalletValidationStatus = 'pending' | 'valid' | 'invalid' | 'validating' | 'error';

export interface Wallet {
  id: string;
  address: string;
  blockchain: string;
  label?: string;
  balance?: number;
  balanceSymbol?: string;
  balanceInUsd?: number;
  transactionCount?: number;
  lastTransactionDate?: Date;
  validatedAt?: Date;
  validationStatus: WalletValidationStatus;
  isFavorite: boolean;
  metadata?: Record<string, unknown>;
}

export interface Blockchain {
  id: string;
  name: string;
  symbol: string;
  logoUrl?: string;
  color: string;
  decimals: number;
  addressPrefixes: string[];
  isEnabled: boolean;
  explorerUrl?: string;
}

export interface ValidationResult {
  isValid: boolean;
  address: string;
  blockchain: string;
  errorMessage?: string;
  timestamp: Date;
  details?: Record<string, unknown>;
}

export interface Transaction {
  id: string;
  walletAddress: string;
  blockchain: string;
  type: 'incoming' | 'outgoing';
  amount: number;
  symbol: string;
  amountInUsd?: number;
  fromAddress?: string;
  toAddress?: string;
  timestamp: Date;
  confirmations: number;
  status: 'pending' | 'confirmed' | 'failed';
  fee?: number;
  hash?: string;
}

export type BlockchainType = 'bitcoin' | 'ethereum' | 'litecoin' | 'bitcoin_cash' | 'dogecoin';
