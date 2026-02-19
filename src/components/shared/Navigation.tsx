import { useState, useEffect } from 'react';
import { Paper, BottomNavigation, BottomNavigationAction, Box } from '@mui/material';
import { Home as HomeIcon, Search as SearchIcon, History as HistoryIcon } from '@mui/icons-material';
import { useLocation, useNavigate } from 'react-router-dom';

export const Navigation: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [value, setValue] = useState(0);

  useEffect(() => {
    const path = location.pathname;
    if (path === '/') setValue(0);
    else if (path === '/validate') setValue(1);
    else if (path === '/history') setValue(2);
  }, [location]);

  const handleChange = (_: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
    switch (newValue) {
      case 0:
        navigate('/');
        break;
      case 1:
        navigate('/validate');
        break;
      case 2:
        navigate('/history');
        break;
    }
  };

  return (
    <Paper
      sx={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 1000,
        borderRadius: '16px 16px 0 0',
        boxShadow: '0 -4px 12px rgba(0,0,0,0.1)',
      }}
      elevation={3}
    >
      <BottomNavigation value={value} onChange={handleChange} sx={{ height: 70 }}>
        <BottomNavigationAction
          label="Início"
          icon={<HomeIcon />}
          sx={{
            '&.Mui-selected': {
              color: 'primary.main',
            },
          }}
        />
        <BottomNavigationAction
          label="Validar"
          icon={<SearchIcon />}
          sx={{
            '&.Mui-selected': {
              color: 'primary.main',
            },
          }}
        />
        <BottomNavigationAction
          label="Histórico"
          icon={<HistoryIcon />}
          sx={{
            '&.Mui-selected': {
              color: 'primary.main',
            },
          }}
        />
      </BottomNavigation>
    </Paper>
  );
};
