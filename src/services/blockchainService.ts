import axios from 'axios';
import type { Wallet, Transaction, BlockchainType } from '../types';
import { API_ENDPOINTS, ETHERSCAN_API_KEY } from '../utils/constants';

export class BlockchainAPIError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public code?: string
  ) {
    super(message);
    this.name = 'BlockchainAPIError';
  }
}

class BlockchainService {
  private async makeRequest(url: string, config?: object) {
    try {
      const response = await axios.get(url, { timeout: 30000, ...config });
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.code === 'ECONNABORTED') {
          throw new BlockchainAPIError('Timeout na requisição', 408, 'TIMEOUT');
        }
        throw new BlockchainAPIError(
          error.message,
          error.response?.status,
          error.code
        );
      }
      throw error;
    }
  }

  async getWalletBalance(address: string, blockchain: BlockchainType): Promise<Partial<Wallet>> {
    switch (blockchain) {
      case 'bitcoin':
        return this.getBitcoinBalance(address);
      case 'ethereum':
        return this.getEthereumBalance(address);
      case 'litecoin':
        return this.getLitecoinBalance(address);
      case 'bitcoin_cash':
        return this.getBitcoinCashBalance(address);
      case 'dogecoin':
        return this.getDogecoinBalance(address);
      default:
        throw new BlockchainAPIError(`Blockchain não suportada: ${blockchain}`);
    }
  }

  private async getBitcoinBalance(address: string): Promise<Partial<Wallet>> {
    try {
      const data = await this.makeRequest(`${API_ENDPOINTS.bitcoin}/rawaddr/${address}`);
      
      return {
        balance: (data.final_balance || 0) / 100000000,
        balanceSymbol: 'BTC',
        transactionCount: data.n_tx || 0,
      };
    } catch (error) {
      console.error('Erro ao buscar saldo Bitcoin:', error);
      return { balance: 0, balanceSymbol: 'BTC', transactionCount: 0 };
    }
  }

  private async getEthereumBalance(address: string): Promise<Partial<Wallet>> {
    try {
      const balanceData = await this.makeRequest(
        `${API_ENDPOINTS.ethereum}?module=account&action=balance&address=${address}&tag=latest&apikey=${ETHERSCAN_API_KEY}`
      );

      if (balanceData.status !== '1') {
        throw new BlockchainAPIError(balanceData.message || 'Erro na API Etherscan');
      }

      const balanceWei = BigInt(balanceData.result);
      const balanceEth = Number(balanceWei) / 1e18;

      // Buscar contagem de transações
      const txData = await this.makeRequest(
        `${API_ENDPOINTS.ethereum}?module=account&action=txlist&address=${address}&startblock=0&endblock=99999999&page=1&offset=1&apikey=${ETHERSCAN_API_KEY}`
      );

      return {
        balance: balanceEth,
        balanceSymbol: 'ETH',
        transactionCount: txData.status === '1' && Array.isArray(txData.result) ? txData.result.length : 0,
      };
    } catch (error) {
      console.error('Erro ao buscar saldo Ethereum:', error);
      return { balance: 0, balanceSymbol: 'ETH', transactionCount: 0 };
    }
  }

  private async getLitecoinBalance(address: string): Promise<Partial<Wallet>> {
    try {
      const data = await this.makeRequest(`${API_ENDPOINTS.litecoin}/addrs/${address}/balance`);
      
      return {
        balance: (data.balance || 0) / 100000000,
        balanceSymbol: 'LTC',
        transactionCount: data.n_tx || 0,
      };
    } catch (error) {
      console.error('Erro ao buscar saldo Litecoin:', error);
      return { balance: 0, balanceSymbol: 'LTC', transactionCount: 0 };
    }
  }

  private async getBitcoinCashBalance(address: string): Promise<Partial<Wallet>> {
    try {
      const data = await this.makeRequest(`${API_ENDPOINTS.bitcoin_cash}/dashboards/address/${address}`);
      const addressData = data.data?.[address];
      
      if (addressData) {
        return {
          balance: (addressData.address?.balance || 0) / 100000000,
          balanceSymbol: 'BCH',
          transactionCount: addressData.address?.transaction_count || 0,
        };
      }
      
      return { balance: 0, balanceSymbol: 'BCH', transactionCount: 0 };
    } catch (error) {
      console.error('Erro ao buscar saldo Bitcoin Cash:', error);
      return { balance: 0, balanceSymbol: 'BCH', transactionCount: 0 };
    }
  }

  private async getDogecoinBalance(address: string): Promise<Partial<Wallet>> {
    try {
      const data = await this.makeRequest(`${API_ENDPOINTS.dogecoin}/addrs/${address}/balance`);
      
      return {
        balance: (data.balance || 0) / 100000000,
        balanceSymbol: 'DOGE',
        transactionCount: data.n_tx || 0,
      };
    } catch (error) {
      console.error('Erro ao buscar saldo Dogecoin:', error);
      return { balance: 0, balanceSymbol: 'DOGE', transactionCount: 0 };
    }
  }

  async getTransactions(
    address: string,
    blockchain: BlockchainType,
    limit: number = 20,
    offset: number = 0
  ): Promise<Transaction[]> {
    switch (blockchain) {
      case 'bitcoin':
        return this.getBitcoinTransactions(address, limit, offset);
      case 'ethereum':
        return this.getEthereumTransactions(address, limit, offset);
      default:
        return [];
    }
  }

  private async getBitcoinTransactions(
    address: string,
    limit: number,
    offset: number
  ): Promise<Transaction[]> {
    try {
      const data = await this.makeRequest(
        `${API_ENDPOINTS.bitcoin}/rawaddr/${address}?limit=${limit}&offset=${offset}`
      );

      const txs = data.txs || [];
      return txs.map((tx: any) => ({
        id: tx.hash,
        walletAddress: address,
        blockchain: 'bitcoin',
        type: tx.result > 0 ? 'incoming' : 'outgoing',
        amount: Math.abs(tx.result || 0) / 100000000,
        symbol: 'BTC',
        timestamp: new Date(tx.time * 1000),
        confirmations: tx.block_height ? data.height - tx.block_height + 1 : 0,
        status: tx.block_height ? 'confirmed' : 'pending',
        fee: (tx.fee || 0) / 100000000,
        hash: tx.hash,
      }));
    } catch (error) {
      console.error('Erro ao buscar transações Bitcoin:', error);
      return [];
    }
  }

  private async getEthereumTransactions(
    address: string,
    limit: number,
    offset: number
  ): Promise<Transaction[]> {
    try {
      const data = await this.makeRequest(
        `${API_ENDPOINTS.ethereum}?module=account&action=txlist&address=${address}&startblock=0&endblock=99999999&page=${Math.floor(offset / limit) + 1}&offset=${limit}&sort=desc&apikey=${ETHERSCAN_API_KEY}`
      );

      if (data.status !== '1') {
        return [];
      }

      const txs = data.result || [];
      return txs.map((tx: any) => ({
        id: tx.hash,
        walletAddress: address,
        blockchain: 'ethereum',
        type: tx.to.toLowerCase() === address.toLowerCase() ? 'incoming' : 'outgoing',
        amount: Number(tx.value) / 1e18,
        symbol: 'ETH',
        timestamp: new Date(parseInt(tx.timeStamp) * 1000),
        confirmations: parseInt(tx.confirmations),
        status: parseInt(tx.confirmations) > 6 ? 'confirmed' : 'pending',
        fee: (Number(tx.gasPrice) * Number(tx.gasUsed)) / 1e18,
        hash: tx.hash,
        fromAddress: tx.from,
        toAddress: tx.to,
      }));
    } catch (error) {
      console.error('Erro ao buscar transações Ethereum:', error);
      return [];
    }
  }
}

export const blockchainService = new BlockchainService();
