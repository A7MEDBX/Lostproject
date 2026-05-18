import { useEffect, useState, useMemo } from 'react';
import {
  Alert,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Link,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TextField,
  Tooltip,
  Box,
  Typography,
  alpha,
  useTheme,
  Avatar,
  Card,
  LinearProgress,
  InputBase,
} from '@mui/material';
import {
  RateReviewRounded as ReviewIcon,
  VerifiedUserRounded as VerifiedIcon,
  OpenInNewRounded as OpenIcon,
  ContactPageRounded as IDIcon,
  SearchRounded as SearchIcon,
  FileDownloadRounded as ExportIcon,
} from '@mui/icons-material';
import api from '../../api/axios';
import MotionPage from '../../components/MotionPage';

export default function Verification() {
  const [verifications, setVerifications] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [notes, setNotes] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const theme = useTheme();

  const fetchVerifications = async () => {
    try {
      const response = await api.get('/admin/verifications/pending', { params: { limit: 100, offset: 0 } });
      setVerifications(response.data?.verifications || []);
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Failed to load pending verifications.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVerifications();
  }, []);

  const filteredVerifications = useMemo(() => {
    return verifications.filter(user => {
      return user.name?.toLowerCase().includes(searchQuery.toLowerCase()) || 
             user.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
             user.national_id?.includes(searchQuery);
    });
  }, [verifications, searchQuery]);

  const handleExport = () => {
    const csvContent = "data:text/csv;charset=utf-8," 
      + ["Name,Email,National ID,Phone"].join(",") + "\n"
      + filteredVerifications.map(u => `"${u.name}","${u.email}","${u.national_id || 'N/A'}","${u.phone_number || 'N/A'}"`).join("\n");
    
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "finder_verifications_export.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const openReview = (user) => {
    setSelectedUser(user);
    setNotes('');
  };

  const reviewVerification = async (userId, action) => {
    setSaving(true);
    setError('');
    try {
      await api.post(`/admin/verifications/${userId}/${action}`, { notes });
      setVerifications((items) => items.filter((user) => user.id !== userId));
      setSelectedUser(null);
    } catch (err) {
      setError(err.response?.data?.message || err.message || `Failed to ${action} verification.`);
    } finally {
      setSaving(false);
    }
  };

  return (
    <MotionPage>
      <Box mb={6} position="relative">
        <Typography variant="h2" fontWeight={900} letterSpacing="-0.06em" mb={1}>
          Trust & Safety
        </Typography>
        <Typography variant="h6" color="text.secondary" fontWeight={500}>
          Review submitted identity documents to verify platform users.
        </Typography>


      </Box>

      {error && <Alert severity="error" sx={{ mb: 4, borderRadius: 3 }}>{error}</Alert>}

      <Card sx={{ overflow: 'hidden', p: 0 }}>
        <Box sx={{ p: 3, borderBottom: `1px solid ${theme.palette.divider}`, display: 'flex', gap: 2, alignItems: 'center' }}>
          <Box sx={{ 
            flexGrow: 1, 
            maxWidth: 400,
            px: 2, 
            py: 1, 
            borderRadius: '16px', 
            bgcolor: alpha(theme.palette.text.primary, 0.03), 
            display: 'flex', 
            alignItems: 'center', 
            gap: 1.5,
            border: `1px solid ${alpha(theme.palette.text.primary, 0.05)}`
          }}>
            <SearchIcon fontSize="small" color="disabled" />
            <InputBase 
              placeholder="Search by name, email or ID..." 
              fullWidth 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              sx={{ fontSize: '0.9rem', fontWeight: 600 }}
            />
          </Box>
          
          <Typography variant="caption" fontWeight={700} color="text.secondary" sx={{ ml: 'auto' }}>
            {filteredVerifications.length} Pending Approval
          </Typography>
        </Box>

        <Box sx={{ overflowX: 'auto' }}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: alpha(theme.palette.text.primary, 0.01) }}>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Applicant</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Identification Number</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Document Link</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Contact Info</TableCell>
                <TableCell align="right" sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <TableRow key={i}>
                    <TableCell colSpan={5}><LinearProgress sx={{ height: 2, opacity: 0.1 }} /></TableCell>
                  </TableRow>
                ))
              ) : filteredVerifications.map((user) => (
                <TableRow key={user.id} sx={{ '&:hover': { bgcolor: alpha(theme.palette.primary.main, 0.02) } }}>
                  <TableCell>
                    <Stack direction="row" spacing={2} alignItems="center">
                      <Avatar sx={{ width: 32, height: 32, bgcolor: alpha(theme.palette.primary.main, 0.1), color: 'primary.main', fontWeight: 800, fontSize: '0.8rem' }}>
                        {user.name?.charAt(0)}
                      </Avatar>
                      <Box>
                        <Typography variant="body2" fontWeight={700}>{user.name}</Typography>
                        <Typography variant="caption" color="text.secondary">{user.email}</Typography>
                      </Box>
                    </Stack>
                  </TableCell>
                  <TableCell>
                    <Stack direction="row" spacing={1} alignItems="center">
                      <IDIcon sx={{ fontSize: 16, color: 'text.secondary' }} />
                      <Typography variant="body2" fontWeight={600} sx={{ opacity: 0.8 }}>{user.national_id || 'Not Provided'}</Typography>
                    </Stack>
                  </TableCell>
                  <TableCell>
                    {user.id_image_url ? (
                      <Link 
                        href={user.id_image_url} 
                        target="_blank" 
                        rel="noreferrer"
                        sx={{ 
                          display: 'inline-flex', 
                          alignItems: 'center', 
                          gap: 0.5, 
                          fontWeight: 700, 
                          textDecoration: 'none',
                          color: 'secondary.main',
                          '&:hover': { textDecoration: 'underline' }
                        }}
                      >
                        Review Document <OpenIcon sx={{ fontSize: 14 }} />
                      </Link>
                    ) : (
                      <Typography variant="caption" color="text.disabled">No Attachment</Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <Typography variant="caption" fontWeight={600} color="text.secondary">{user.phone_number || 'No Phone'}</Typography>
                  </TableCell>
                  <TableCell align="right">
                    <Tooltip title="Start Review">
                      <IconButton onClick={() => openReview(user)} sx={{ color: 'text.secondary', '&:hover': { color: 'primary.main', bgcolor: alpha(theme.palette.primary.main, 0.1) } }}>
                        <ReviewIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Box>
      </Card>

      <Dialog 
        open={Boolean(selectedUser)} 
        onClose={() => setSelectedUser(null)} 
        fullWidth 
        maxWidth="sm"
        PaperProps={{
          sx: {
            borderRadius: '24px',
            bgcolor: alpha(theme.palette.background.paper, 0.8),
            backdropFilter: 'blur(20px)',
            border: `1px solid ${theme.palette.divider}`,
          }
        }}
      >
        <DialogTitle sx={{ fontWeight: 800, fontSize: '1.5rem', letterSpacing: '-0.02em' }}>
          Identity Audit
        </DialogTitle>
        <DialogContent>
          <Stack spacing={3} mt={2}>
            <Box sx={{ p: 2, borderRadius: '16px', bgcolor: alpha(theme.palette.text.primary, 0.03) }}>
              <Typography variant="caption" color="text.secondary" fontWeight={700} textTransform="uppercase">Applicant</Typography>
              <Typography variant="h6" fontWeight={800}>{selectedUser?.name}</Typography>
              <Typography variant="body2" color="text.secondary">{selectedUser?.email}</Typography>
            </Box>
            <TextField 
              label="Moderation Notes" 
              placeholder="Provide internal feedback on why this identity is being approved or rejected..."
              value={notes} 
              onChange={(event) => setNotes(event.target.value)} 
              fullWidth 
              multiline 
              minRows={4} 
            />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 4, pb: 4, pt: 2 }}>
          <Button onClick={() => setSelectedUser(null)} sx={{ color: 'text.secondary' }}>Cancel</Button>
          <Button 
            variant="outlined" 
            color="error" 
            disabled={saving} 
            onClick={() => reviewVerification(selectedUser.id, 'reject')}
            sx={{ borderRadius: '12px', px: 3 }}
          >
            Reject ID
          </Button>
          <Button 
            variant="contained" 
            color="success" 
            disabled={saving} 
            onClick={() => reviewVerification(selectedUser.id, 'approve')}
            sx={{ borderRadius: '12px', px: 3 }}
          >
            Approve ID
          </Button>
        </DialogActions>
      </Dialog>
    </MotionPage>
  );
}
