import { Card, CardContent, Box, Typography, IconButton, Chip, Tooltip } from '@mui/material';
import {
  Favorite as FavoriteIcon,
  FavoriteBorder as FavoriteBorderIcon,
  Delete as DeleteIcon,
  ContentCopy as CopyIcon,
} from '@mui/icons-material';
import { useWalletStore } from '../../store/walletStore';
import { BLOCKCHAINS } from '../../utils/constants';
import type { Wallet } from '../../types';

interface WalletCardProps {
  wallet: Wallet;
  onDelete?: () => void;
}

export const WalletCard: React.FC<WalletCardProps> = ({ wallet, onDelete }) => {
  const { favorites, addToFavorites, removeFromFavorites } = useWalletStore();
  const isFavorite = favorites.includes(wallet.id);

  const blockchain = BLOCKCHAINS[wallet.blockchain];
  const color = blockchain?.color || '#666';
  const symbol = blockchain?.symbol || wallet.blockchain.toUpperCase();

  const handleFavorite = () => {
    if (isFavorite) {
      removeFromFavorites(wallet.id);
    } else {
      addToFavorites(wallet.id);
    }
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(wallet.address);
  };

  const formatAddress = (addr: string) => {
    if (addr.length <= 20) return addr;
    return `${addr.substring(0, 10)}...${addr.substring(addr.length - 10)}`;
  };

  return (
    <Card sx={{ mb: 2, '&:hover': { boxShadow: 4 } }}>
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
          {/* Blockchain Icon */}
          <Box
            sx={{
              width: 48,
              height: 48,
              borderRadius: 2,
              bgcolor: color,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              fontWeight: 'bold',
              fontSize: '0.875rem',
              flexShrink: 0,
            }}
          >
            {symbol.slice(0, 2)}
          </Box>

          {/* Info */}
          <Box sx={{ flex: 1, minWidth: 0 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
              <Typography variant="h6" fontWeight="bold" noWrap>
                {blockchain?.name || wallet.blockchain}
              </Typography>
              <Chip
                label={symbol}
                size="small"
                sx={{
                  bgcolor: `${color}20`,
                  color: color,
                  fontWeight: 'bold',
                  height: 24,
                }}
              />
            </Box>

            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography
                variant="body2"
                color="text.secondary"
                sx={{ fontFamily: 'monospace', letterSpacing: 0.5 }}
              >
                {formatAddress(wallet.address)}
              </Typography>
              <Tooltip title="Copiar endereço">
                <IconButton size="small" onClick={handleCopy}>
                  <CopyIcon fontSize="small" />
                </IconButton>
              </Tooltip>
            </Box>

            {wallet.balance !== undefined && (
              <Box sx={{ mt: 1.5, pt: 1.5, borderTop: '1px solid #e0e0e0' }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Typography variant="body2" color="text.secondary">
                    Saldo
                  </Typography>
                  <Typography variant="h6" fontWeight="bold" color="success.main">
                    {wallet.balance.toFixed(8)} {symbol}
                  </Typography>
                </Box>
                {wallet.transactionCount !== undefined && (
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 0.5 }}>
                    <Typography variant="body2" color="text.secondary">
                      Transações
                    </Typography>
                    <Typography variant="body2" fontWeight="medium">
                      {wallet.transactionCount}
                    </Typography>
                  </Box>
                )}
              </Box>
            )}
          </Box>

          {/* Actions */}
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
            <IconButton onClick={handleFavorite} color={isFavorite ? 'error' : 'default'}>
              {isFavorite ? <FavoriteIcon /> : <FavoriteBorderIcon />}
            </IconButton>
            {onDelete && (
              <IconButton onClick={onDelete} color="error">
                <DeleteIcon />
              </IconButton>
            )}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
};
