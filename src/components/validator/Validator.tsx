import { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  Container,
  Typography,
  TextField,
  Button,
  Grid,
  Chip,
  Alert,
  CircularProgress,
  Fade,
  InputAdornment,
  IconButton,
} from '@mui/material';
import {
  Search as SearchIcon,
  ContentPaste as PasteIcon,
  Clear as ClearIcon,
  CheckCircle as CheckIcon,
  Error as ErrorIcon,
} from '@mui/icons-material';
import { useWalletStore } from '../../store/walletStore';
import { WalletValidationResult } from '../shared/WalletValidationResult';
import { BLOCKCHAINS } from '../../utils/constants';
import type { BlockchainType } from '../../types';

export const Validator: React.FC = () => {
  const [address, setAddress] = useState('');
  const { 
    validateAddress, 
    isLoading, 
    currentValidation, 
    selectedBlockchain,
    setSelectedBlockchain 
  } = useWalletStore();

  const blockchains: { id: BlockchainType; name: string; symbol: string; color: string }[] = [
    { id: 'bitcoin', name: 'Bitcoin', symbol: 'BTC', color: '#F7931A' },
    { id: 'ethereum', name: 'Ethereum', symbol: 'ETH', color: '#627EEA' },
    { id: 'litecoin', name: 'Litecoin', symbol: 'LTC', color: '#345D9D' },
    { id: 'bitcoin_cash', name: 'Bitcoin Cash', symbol: 'BCH', color: '#8DC351' },
    { id: 'dogecoin', name: 'Dogecoin', symbol: 'DOGE', color: '#C2A633' },
  ];

  const handleValidate = async () => {
    if (!address.trim()) return;
    await validateAddress(address.trim());
  };

  const handlePaste = async () => {
    try {
      const text = await navigator.clipboard.readText();
      setAddress(text);
    } catch (err) {
      console.error('Erro ao colar:', err);
    }
  };

  const handleClear = () => {
    setAddress('');
  };

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
        <Container maxWidth="md" sx={{ pt: 4 }}>
          <Box
            sx={{
              bgcolor: 'rgba(255,255,255,0.15)',
              borderRadius: 3,
              p: 2,
              display: 'inline-flex',
              mb: 2,
            }}
          >
            <SearchIcon sx={{ fontSize: 32 }} />
          </Box>
          <Typography variant="h4" fontWeight="bold" gutterBottom>
            Validar Carteira
          </Typography>
          <Typography variant="body1" sx={{ opacity: 0.8 }}>
            Verifique a validade de endereços de criptomoedas em múltiplas blockchains
          </Typography>
        </Container>
      </Box>

      {/* Content */}
      <Container maxWidth="md" sx={{ mt: -2, pb: 4 }}>
        <Card sx={{ mb: 3 }}>
          <CardContent sx={{ p: 3 }}>
            {/* Blockchain Selection */}
            <Typography variant="subtitle1" fontWeight="600" gutterBottom>
              Selecione a Blockchain
            </Typography>
            <Grid container spacing={1} sx={{ mb: 3 }}>
              {blockchains.map((bc) => (
                <Grid item key={bc.id}>
                  <Chip
                    label={`${bc.name} (${bc.symbol})`}
                    onClick={() => setSelectedBlockchain(bc.id)}
                    sx={{
                      bgcolor: selectedBlockchain === bc.id ? bc.color : 'transparent',
                      color: selectedBlockchain === bc.id ? 'white' : 'text.primary',
                      border: `2px solid ${selectedBlockchain === bc.id ? bc.color : '#e0e0e0'}`,
                      fontWeight: selectedBlockchain === bc.id ? 'bold' : 'normal',
                      '&:hover': {
                        bgcolor: selectedBlockchain === bc.id ? bc.color : 'rgba(0,0,0,0.04)',
                      },
                    }}
                  />
                </Grid>
              ))}
            </Grid>

            {/* Address Input */}
            <Typography variant="subtitle1" fontWeight="600" gutterBottom>
              Endereço da Carteira
            </Typography>
            <TextField
              fullWidth
              multiline
              rows={2}
              placeholder="Cole o endereço da carteira aqui..."
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              sx={{ mb: 2 }}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon color="action" />
                  </InputAdornment>
                ),
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={handlePaste} edge="end" size="small">
                      <PasteIcon />
                    </IconButton>
                    {address && (
                      <IconButton onClick={handleClear} edge="end" size="small">
                        <ClearIcon />
                      </IconButton>
                    )}
                  </InputAdornment>
                ),
              }}
            />

            {/* Validate Button */}
            <Button
              fullWidth
              variant="contained"
              size="large"
              onClick={handleValidate}
              disabled={!address.trim() || isLoading}
              startIcon={isLoading ? <CircularProgress size={20} color="inherit" /> : <SearchIcon />}
              sx={{
                py: 1.5,
                background: 'linear-gradient(135deg, #1E3A8A 0%, #3B82F6 100%)',
              }}
            >
              {isLoading ? 'Validando...' : 'Validar Carteira'}
            </Button>
          </CardContent>
        </Card>

        {/* Validation Result */}
        {currentValidation && (
          <Fade in>
            <Box>
              <WalletValidationResult result={currentValidation} />
            </Box>
          </Fade>
        )}
      </Container>
    </Box>
  );
};
