import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Box, CssBaseline, ThemeProvider, createTheme } from '@mui/material';
import { Dashboard } from './components/dashboard/Dashboard';
import { Validator } from './components/validator/Validator';
import { History } from './components/history/History';
import { Navigation } from './components/shared/Navigation';
import { theme } from './theme';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Box sx={{ pb: 8 }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/validate" element={<Validator />} />
            <Route path="/history" element={<History />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Box>
        <Navigation />
      </Router>
    </ThemeProvider>
  );
}

export default App;
