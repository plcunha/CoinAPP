import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { Wallet, ValidationResult, BlockchainType } from '../types';
import { walletValidationService } from '../services/walletValidationService';
import { blockchainService } from '../services/blockchainService';

interface WalletState {
  // Estado
  wallets: Wallet[];
  recentValidations: Wallet[];
  favorites: string[];
  isLoading: boolean;
  error: string | null;
  currentValidation: ValidationResult | null;
  selectedBlockchain: BlockchainType;

  // Ações
  validateAddress: (address: string, blockchain?: BlockchainType) => Promise<ValidationResult>;
  getWalletInfo: (address: string, blockchain: BlockchainType) => Promise<Wallet | null>;
  addToFavorites: (walletId: string) => void;
  removeFromFavorites: (walletId: string) => void;
  setSelectedBlockchain: (blockchain: BlockchainType) => void;
  deleteWallet: (walletId: string) => void;
  clearError: () => void;
  clearRecentValidations: () => void;
}

export const useWalletStore = create<WalletState>()(
  persist(
    (set, get) => ({
      wallets: [],
      recentValidations: [],
      favorites: [],
      isLoading: false,
      error: null,
      currentValidation: null,
      selectedBlockchain: 'bitcoin',

      validateAddress: async (address: string, blockchain?: BlockchainType) => {
        const bc = blockchain || get().selectedBlockchain;
        set({ isLoading: true, error: null });

        try {
          const result = walletValidationService.validateAddress(address, bc);
          set({ currentValidation: result, isLoading: false });

          if (result.isValid) {
            // Buscar informações adicionais
            const walletInfo = await get().getWalletInfo(address, bc);
            if (walletInfo) {
              set((state) => ({
                recentValidations: [walletInfo, ...state.recentValidations.slice(0, 49)],
              }));
            }
          }

          return result;
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
          set({ error: errorMessage, isLoading: false });
          throw error;
        }
      },

      getWalletInfo: async (address: string, blockchain: BlockchainType) => {
        set({ isLoading: true, error: null });

        try {
          const balanceData = await blockchainService.getWalletBalance(address, blockchain);
          
          const wallet: Wallet = {
            id: `${blockchain}_${address}`,
            address,
            blockchain,
            ...balanceData,
            validatedAt: new Date(),
            validationStatus: 'valid',
            isFavorite: get().favorites.includes(`${blockchain}_${address}`),
          };

          set((state) => ({
            wallets: [...state.wallets.filter(w => w.id !== wallet.id), wallet],
            isLoading: false,
          }));

          return wallet;
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
          set({ error: errorMessage, isLoading: false });
          return null;
        }
      },

      addToFavorites: (walletId: string) => {
        set((state) => ({
          favorites: [...state.favorites, walletId],
          wallets: state.wallets.map(w => 
            w.id === walletId ? { ...w, isFavorite: true } : w
          ),
        }));
      },

      removeFromFavorites: (walletId: string) => {
        set((state) => ({
          favorites: state.favorites.filter(id => id !== walletId),
          wallets: state.wallets.map(w => 
            w.id === walletId ? { ...w, isFavorite: false } : w
          ),
        }));
      },

      setSelectedBlockchain: (blockchain: BlockchainType) => {
        set({ selectedBlockchain: blockchain });
      },

      deleteWallet: (walletId: string) => {
        set((state) => ({
          wallets: state.wallets.filter(w => w.id !== walletId),
          recentValidations: state.recentValidations.filter(w => w.id !== walletId),
          favorites: state.favorites.filter(id => id !== walletId),
        }));
      },

      clearError: () => set({ error: null }),
      
      clearRecentValidations: () => set({ recentValidations: [] }),
    }),
    {
      name: 'wallet-storage',
      partialize: (state) => ({ 
        favorites: state.favorites, 
        recentValidations: state.recentValidations.slice(0, 50)
      }),
    }
  )
);
