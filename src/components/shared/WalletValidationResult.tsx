import { Card, CardContent, Box, Typography, Button, Chip } from '@mui/material';
import { CheckCircle as CheckIcon, Error as ErrorIcon } from '@mui/icons-material';
import type { ValidationResult } from '../../types';
import { BLOCKCHAINS } from '../../utils/constants';

interface WalletValidationResultProps {
  result: ValidationResult;
}

export const WalletValidationResult: React.FC<WalletValidationResultProps> = ({ result }) => {
  const blockchain = BLOCKCHAINS[result.blockchain as keyof typeof BLOCKCHAINS];
  const color = result.isValid ? 'success' : 'error';
  const gradient = result.isValid
    ? 'linear-gradient(135deg, #10B981 0%, #34D399 100%)'
    : 'linear-gradient(135deg, #EF4444 0%, #F87171 100%)';

  return (
    <Card
      sx={{
        background: gradient,
        color: 'white',
        borderRadius: 3,
        boxShadow: `0 8px 24px ${result.isValid ? '#10B98140' : '#EF444440'}`,
      }}
    >
      <CardContent sx={{ p: 3 }}>
        {/* Header */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
          <Box
            sx={{
              width: 56,
              height: 56,
              borderRadius: '50%',
              bgcolor: 'rgba(255,255,255,0.2)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {result.isValid ? (
              <CheckIcon sx={{ fontSize: 32 }} />
            ) : (
              <ErrorIcon sx={{ fontSize: 32 }} />
            )}
          </Box>
          <Box>
            <Typography variant="h5" fontWeight="bold">
              {result.isValid ? 'Endereço Válido' : 'Endereço Inválido'}
            </Typography>
            <Typography variant="body1" sx={{ opacity: 0.8 }}>
              {blockchain?.name || result.blockchain}
            </Typography>
          </Box>
        </Box>

        {/* Error Message */}
        {!result.isValid && result.errorMessage && (
          <Box
            sx={{
              bgcolor: 'rgba(255,255,255,0.15)',
              borderRadius: 2,
              p: 2,
              mb: 2,
            }}
          >
            <Typography variant="body2">{result.errorMessage}</Typography>
          </Box>
        )}

        {/* Address */}
        {result.isValid && (
          <Box
            sx={{
              bgcolor: 'rgba(255,255,255,0.15)',
              borderRadius: 2,
              p: 2,
              mb: 2,
            }}
          >
            <Typography
              variant="body2"
              sx={{
                fontFamily: 'monospace',
                letterSpacing: 0.5,
                wordBreak: 'break-all',
              }}
            >
              {result.address}
            </Typography>
          </Box>
        )}

        {/* Details */}
        {result.isValid && result.details && (
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            {Object.entries(result.details).map(([key, value]) => (
              <Chip
                key={key}
                label={`${key}: ${value}`}
                size="small"
                sx={{
                  bgcolor: 'rgba(255,255,255,0.2)',
                  color: 'white',
                  textTransform: 'capitalize',
                }}
              />
            ))}
          </Box>
        )}

        {/* Timestamp */}
        <Typography variant="caption" sx={{ opacity: 0.7, mt: 2, display: 'block' }}>
          Validado em: {result.timestamp.toLocaleString()}
        </Typography>
      </CardContent>
    </Card>
  );
};
