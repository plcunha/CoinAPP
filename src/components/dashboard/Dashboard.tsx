import { useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Container,
  Grid,
  Typography,
  IconButton,
  Chip,
  Skeleton,
} from '@mui/material';
import {
  Wallet as WalletIcon,
  Favorite as FavoriteIcon,
  AccountBalance as BalanceIcon,
  TrendingUp as TrendingIcon,
} from '@mui/icons-material';
import { useWalletStore } from '../../store/walletStore';
import { WalletCard } from '../shared/WalletCard';
import { EmptyState } from '../shared/EmptyState';

export const Dashboard: React.FC = () => {
  const { recentValidations, favorites, wallets, isLoading } = useWalletStore();

  const favoriteWallets = wallets.filter(w => favorites.includes(w.id));

  const stats = [
    {
      icon: <WalletIcon sx={{ fontSize: 32, color: 'primary.main' }} />,
      value: wallets.length,
      label: 'Carteiras',
    },
    {
      icon: <FavoriteIcon sx={{ fontSize: 32, color: 'error.main' }} />,
      value: favoriteWallets.length,
      label: 'Favoritos',
    },
    {
      icon: <BalanceIcon sx={{ fontSize: 32, color: 'success.main' }} />,
      value: new Set(wallets.map(w => w.blockchain)).size,
      label: 'Blockchains',
    },
    {
      icon: <TrendingIcon sx={{ fontSize: 32, color: 'info.main' }} />,
      value: recentValidations.length,
      label: 'Validações',
    },
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
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <Box>
              <Typography variant="h4" fontWeight="bold" gutterBottom>
                CoinWallet
              </Typography>
              <Typography variant="body1" sx={{ opacity: 0.8 }}>
                Validador Profissional
              </Typography>
            </Box>
            <Box
              sx={{
                bgcolor: 'rgba(255,255,255,0.2)',
                borderRadius: 3,
                p: 1.5,
              }}
            >
              <WalletIcon sx={{ fontSize: 32 }} />
            </Box>
          </Box>

          {/* Stats */}
          <Grid container spacing={2} sx={{ mt: 4 }}>
            {stats.map((stat, index) => (
              <Grid item xs={6} sm={3} key={index}>
                <Card
                  sx={{
                    bgcolor: 'rgba(255,255,255,0.15)',
                    color: 'white',
                    textAlign: 'center',
                    backdropFilter: 'blur(10px)',
                  }}
                >
                  <CardContent>
                    <Box sx={{ mb: 1 }}>{stat.icon}</Box>
                    <Typography variant="h4" fontWeight="bold">
                      {isLoading ? <Skeleton width={40} /> : stat.value}
                    </Typography>
                    <Typography variant="body2" sx={{ opacity: 0.8 }}>
                      {stat.label}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Container>
      </Box>

      {/* Content */}
      <Container maxWidth="lg" sx={{ mt: -2, pb: 4 }}>
        {/* Favorites */}
        <Typography variant="h6" fontWeight="bold" sx={{ mb: 2, mt: 4 }}>
          Favoritos
        </Typography>
        {favoriteWallets.length === 0 ? (
          <EmptyState
            icon={<FavoriteIcon sx={{ fontSize: 48, color: 'text.secondary' }} />}
            title="Nenhum favorito ainda"
            message="Adicione carteiras aos favoritos para vê-las aqui"
          />
        ) : (
          favoriteWallets.map((wallet) => (
            <WalletCard key={wallet.id} wallet={wallet} />
          ))
        )}

        {/* Recent */}
        <Typography variant="h6" fontWeight="bold" sx={{ mb: 2, mt: 4 }}>
          Recentes
        </Typography>
        {recentValidations.length === 0 ? (
          <EmptyState
            icon={<WalletIcon sx={{ fontSize: 48, color: 'text.secondary' }} />}
            title="Nenhuma validação recente"
            message="Valide uma carteira para começar"
          />
        ) : (
          recentValidations.slice(0, 5).map((wallet) => (
            <WalletCard key={wallet.id} wallet={wallet} />
          ))
        )}
      </Container>
    </Box>
  );
};
