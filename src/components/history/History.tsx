import { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  Container,
  Typography,
  TextField,
  IconButton,
  Chip,
  Grid,
  InputAdornment,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Button,
} from '@mui/material';
import {
  Search as SearchIcon,
  FilterList as FilterIcon,
  Delete as DeleteIcon,
  Clear as ClearIcon,
} from '@mui/icons-material';
import { useWalletStore } from '../../store/walletStore';
import { WalletCard } from '../shared/WalletCard';
import { EmptyState } from '../shared/EmptyState';
import { BLOCKCHAINS } from '../../utils/constants';
import type { BlockchainType } from '../../types';

export const History: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<BlockchainType | null>(null);
  const [walletToDelete, setWalletToDelete] = useState<string | null>(null);
  
  const { recentValidations, deleteWallet, clearRecentValidations } = useWalletStore();

  const filteredWallets = recentValidations.filter((wallet) => {
    const matchesSearch = 
      wallet.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
      wallet.label?.toLowerCase().includes(searchQuery.toLowerCase());
    
    const matchesFilter = selectedFilter ? wallet.blockchain === selectedFilter : true;
    
    return matchesSearch && matchesFilter;
  });

  const handleDelete = (walletId: string) => {
    setWalletToDelete(walletId);
  };

  const confirmDelete = () => {
    if (walletToDelete) {
      deleteWallet(walletToDelete);
      setWalletToDelete(null);
    }
  };

  const blockchains: { id: BlockchainType; name: string; color: string }[] = [
    { id: 'bitcoin', name: 'Bitcoin', color: '#F7931A' },
    { id: 'ethereum', name: 'Ethereum', color: '#627EEA' },
    { id: 'litecoin', name: 'Litecoin', color: '#345D9D' },
    { id: 'bitcoin_cash', name: 'Bitcoin Cash', color: '#8DC351' },
    { id: 'dogecoin', name: 'Dogecoin', color: '#C2A633' },
  ];

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: 'background.default' }}>
      {/* Header */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #1E3A8A 0%, #3B82F6 100%)',
          borderRadius: '0 0 32px 32px',
          color: 'white',
          pb: 4,
        }}
      >
        <Container maxWidth="lg" sx={{ pt: 4 }}>
          <Typography variant="h4" fontWeight="bold" gutterBottom>
            Histórico
          </Typography>
          <Typography variant="body1" sx={{ opacity: 0.8 }}>
            Suas validações anteriores
          </Typography>

          {/* Search */}
          <TextField
            fullWidth
            placeholder="Buscar carteiras..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            sx={{ mt: 3, bgcolor: 'rgba(255,255,255,0.15)', borderRadius: 2 }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon sx={{ color: 'rgba(255,255,255,0.7)' }} />
                </InputAdornment>
              ),
              endAdornment: searchQuery && (
                <InputAdornment position="end">
                  <IconButton 
                    onClick={() => setSearchQuery('')} 
                    edge="end"
                    sx={{ color: 'rgba(255,255,255,0.7)' }}
                  >
                    <ClearIcon />
                  </IconButton>
                </InputAdornment>
              ),
              sx: {
                color: 'white',
                '&::placeholder': { color: 'rgba(255,255,255,0.7)' },
              },
            }}
          />
        </Container>
      </Box>

      {/* Content */}
      <Container maxWidth="lg" sx={{ mt: -2, pb: 4 }}>
        {/* Filters */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <FilterIcon color="action" />
              <Typography variant="subtitle2" fontWeight="600">
                Filtrar por Blockchain
              </Typography>
            </Box>
            <Grid container spacing={1}>
              {blockchains.map((bc) => (
                <Grid item key={bc.id}>
                  <Chip
                    label={bc.name}
                    onClick={() => setSelectedFilter(selectedFilter === bc.id ? null : bc.id)}
                    sx={{
                      bgcolor: selectedFilter === bc.id ? bc.color : 'transparent',
                      color: selectedFilter === bc.id ? 'white' : 'text.primary',
                      border: `2px solid ${selectedFilter === bc.id ? bc.color : '#e0e0e0'}`,
                    }}
                  />
                </Grid>
              ))}
              {selectedFilter && (
                <Grid item>
                  <Chip
                    label="Limpar filtro"
                    onClick={() => setSelectedFilter(null)}
                    variant="outlined"
                    color="error"
                  />
                </Grid>
              )}
            </Grid>
          </CardContent>
        </Card>

        {/* Results */}
        {filteredWallets.length === 0 ? (
          <EmptyState
            icon={<SearchIcon sx={{ fontSize: 48, color: 'text.secondary' }} />}
            title={searchQuery || selectedFilter ? "Nenhum resultado" : "Histórico vazio"}
            message={
              searchQuery || selectedFilter
                ? "Tente ajustar seus filtros de busca"
                : "Suas validações aparecerão aqui"
            }
            action={
              recentValidations.length > 0
                ? { label: 'Limpar filtros', onClick: () => { setSearchQuery(''); setSelectedFilter(null); } }
                : undefined
            }
          />
        ) : (
          <>
            {filteredWallets.map((wallet) => (
              <WalletCard 
                key={wallet.id} 
                wallet={wallet} 
                onDelete={() => handleDelete(wallet.id)}
              />
            ))}
          </>
        )}
      </Container>

      {/* Delete Confirmation Dialog */}
      <Dialog open={!!walletToDelete} onClose={() => setWalletToDelete(null)}>
        <DialogTitle>Confirmar exclusão</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Deseja remover esta carteira do histórico?
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setWalletToDelete(null)}>Cancelar</Button>
          <Button onClick={confirmDelete} color="error" variant="contained">
            Remover
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
