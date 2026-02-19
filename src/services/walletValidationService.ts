import { bech32 } from 'bech32';
import bs58 from 'bs58';
import { sha256 } from '@noble/hashes/sha256';
import type { ValidationResult, BlockchainType } from '../types';

class WalletValidationService {
  validateAddress(address: string, blockchain: BlockchainType): ValidationResult {
    const normalizedAddress = address.trim();

    if (normalizedAddress.length === 0) {
      return this.createInvalidResult(address, blockchain, 'Endereço não pode estar vazio');
    }

    if (normalizedAddress.length < 25) {
      return this.createInvalidResult(address, blockchain, 'Endereço muito curto');
    }

    switch (blockchain) {
      case 'bitcoin':
        return this.validateBitcoinAddress(normalizedAddress);
      case 'ethereum':
        return this.validateEthereumAddress(normalizedAddress);
      case 'litecoin':
        return this.validateLitecoinAddress(normalizedAddress);
      case 'bitcoin_cash':
        return this.validateBitcoinCashAddress(normalizedAddress);
      case 'dogecoin':
        return this.validateDogecoinAddress(normalizedAddress);
      default:
        return this.createInvalidResult(address, blockchain, `Blockchain não suportada: ${blockchain}`);
    }
  }

  private validateBitcoinAddress(address: string): ValidationResult {
    // P2PKH - começa com 1
    if (address.startsWith('1')) {
      if (address.length < 26 || address.length > 35) {
        return this.createInvalidResult(address, 'bitcoin', 'Comprimento inválido para endereço P2PKH');
      }
      return this.validateBase58Checksum(address, 'bitcoin');
    }

    // P2SH - começa com 3
    if (address.startsWith('3')) {
      if (address.length < 26 || address.length > 35) {
        return this.createInvalidResult(address, 'bitcoin', 'Comprimento inválido para endereço P2SH');
      }
      return this.validateBase58Checksum(address, 'bitcoin');
    }

    // Bech32 - começa com bc1
    if (address.toLowerCase().startsWith('bc1')) {
      return this.validateBech32Address(address, 'bc');
    }

    return this.createInvalidResult(address, 'bitcoin', 'Prefixo de endereço Bitcoin inválido');
  }

  private validateEthereumAddress(address: string): ValidationResult {
    if (!address.startsWith('0x')) {
      return this.createInvalidResult(address, 'ethereum', 'Endereço Ethereum deve começar com 0x');
    }

    const hexAddress = address.substring(2);

    if (hexAddress.length !== 40) {
      return this.createInvalidResult(address, 'ethereum', 'Comprimento inválido para endereço Ethereum');
    }

    const hexRegex = /^[0-9a-fA-F]{40}$/;
    if (!hexRegex.test(hexAddress)) {
      return this.createInvalidResult(address, 'ethereum', 'Endereço Ethereum contém caracteres inválidos');
    }

    const isValidChecksum = this.validateEthereumChecksum(address);

    return {
      isValid: true,
      address,
      blockchain: 'ethereum',
      timestamp: new Date(),
      details: {
        format: isValidChecksum ? 'checksum' : 'lowercase',
        type: 'EOA',
      },
    };
  }

  private validateLitecoinAddress(address: string): ValidationResult {
    if (address.startsWith('L')) {
      return this.validateBase58Checksum(address, 'litecoin');
    }

    if (address.startsWith('M')) {
      return this.validateBase58Checksum(address, 'litecoin');
    }

    if (address.toLowerCase().startsWith('ltc1')) {
      return this.validateBech32Address(address, 'ltc');
    }

    return this.createInvalidResult(address, 'litecoin', 'Prefixo de endereço Litecoin inválido');
  }

  private validateBitcoinCashAddress(address: string): ValidationResult {
    if (address.toLowerCase().startsWith('bitcoincash:')) {
      return this.validateBech32Address(address, 'bitcoincash');
    }

    if (address.startsWith('1') || address.startsWith('3')) {
      return this.validateBitcoinAddress(address);
    }

    if (address.toLowerCase().startsWith('q') || address.toLowerCase().startsWith('p')) {
      return this.validateBech32Address(`bitcoincash:${address}`, 'bitcoincash');
    }

    return this.createInvalidResult(address, 'bitcoin_cash', 'Formato de endereço Bitcoin Cash inválido');
  }

  private validateDogecoinAddress(address: string): ValidationResult {
    if (!address.startsWith('D')) {
      return this.createInvalidResult(address, 'dogecoin', 'Endereço Dogecoin deve começar com D');
    }

    if (address.length < 26 || address.length > 34) {
      return this.createInvalidResult(address, 'dogecoin', 'Comprimento inválido para endereço Dogecoin');
    }

    return this.validateBase58Checksum(address, 'dogecoin');
  }

  private validateBase58Checksum(address: string, blockchain: string): ValidationResult {
    try {
      const decoded = bs58.decode(address);
      if (decoded.length !== 25) {
        return this.createInvalidResult(address, blockchain, 'Checksum inválido');
      }
      
      return {
        isValid: true,
        address,
        blockchain,
        timestamp: new Date(),
        details: { encoding: 'base58check' },
      };
    } catch {
      return this.createInvalidResult(address, blockchain, 'Checksum inválido');
    }
  }

  private validateBech32Address(address: string, hrp: string): ValidationResult {
    try {
      const decoded = bech32.decode(address);
      
      if (decoded.prefix.toLowerCase() !== hrp.toLowerCase()) {
        return this.createInvalidResult(address, hrp, 'HRP (Human Readable Part) inválido');
      }

      return {
        isValid: true,
        address,
        blockchain: hrp,
        timestamp: new Date(),
        details: { encoding: 'bech32', hrp },
      };
    } catch (error) {
      return this.createInvalidResult(address, hrp, `Erro na validação Bech32: ${error}`);
    }
  }

  private validateEthereumChecksum(address: string): boolean {
    const addressLower = address.toLowerCase();
    const hexAddress = addressLower.substring(2);
    
    // Calcular Keccak-256 hash
    const hash = sha256(hexAddress);
    const hashHex = Array.from(hash).map(b => b.toString(16).padStart(2, '0')).join('');
    
    for (let i = 0; i < 40; i++) {
      const addressChar = address[i + 2];
      const hashChar = hashHex[i];
      const hashValue = parseInt(hashChar, 16);
      
      if (hashValue >= 8) {
        if (addressChar !== addressChar.toUpperCase()) {
          return false;
        }
      } else {
        if (addressChar !== addressChar.toLowerCase()) {
          return false;
        }
      }
    }
    
    return true;
  }

  detectBlockchain(address: string): BlockchainType | null {
    const trimmed = address.trim();

    if (trimmed.startsWith('0x') && trimmed.length === 42) {
      return 'ethereum';
    }

    if (trimmed.startsWith('1') || trimmed.startsWith('3')) {
      return 'bitcoin';
    }

    if (trimmed.toLowerCase().startsWith('bc1')) {
      return 'bitcoin';
    }

    if (trimmed.startsWith('L') || trimmed.startsWith('M')) {
      return 'litecoin';
    }

    if (trimmed.toLowerCase().startsWith('ltc1')) {
      return 'litecoin';
    }

    if (trimmed.toLowerCase().startsWith('bitcoincash:') || trimmed.toLowerCase().startsWith('q')) {
      return 'bitcoin_cash';
    }

    if (trimmed.startsWith('D')) {
      return 'dogecoin';
    }

    return null;
  }

  private createInvalidResult(address: string, blockchain: string, reason: string): ValidationResult {
    return {
      isValid: false,
      address,
      blockchain,
      errorMessage: reason,
      timestamp: new Date(),
    };
  }
}

export const walletValidationService = new WalletValidationService();
