import { useEffect, useState, useMemo } from 'react';
import {
  Alert,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  LinearProgress,
  MenuItem,
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
  InputBase,
} from '@mui/material';
import {
  EditRounded as EditIcon,
  FilterListRounded as FilterIcon,
  SearchRounded as SearchIcon,
  FileDownloadRounded as ExportIcon,
} from '@mui/icons-material';
import api from '../../api/axios';
import MotionPage from '../../components/MotionPage';

const initialForm = {
  name: '',
  email: '',
  role: 'user',
  status: 'active',
  phone_number: '',
  verification_status: 'not_submitted',
  trust_score: 0,
};

function StatusPill({ value }) {
  const theme = useTheme();
  const getColors = (val) => {
    switch (val?.toLowerCase()) {
      case 'active': case 'approved': case 'admin': return theme.palette.success;
      case 'suspended': case 'pending': return theme.palette.warning;
      case 'banned': case 'rejected': return theme.palette.error;
      default: return theme.palette.text;
    }
  };
  const colors = getColors(value);
  return (
    <Box
      sx={{
        px: 1.5,
        py: 0.5,
        borderRadius: '10px',
        display: 'inline-flex',
        alignItems: 'center',
        fontSize: '0.75rem',
        fontWeight: 800,
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        bgcolor: alpha(colors.main || colors.secondary, 0.1),
        color: colors.main || colors.secondary,
        border: `1px solid ${alpha(colors.main || colors.secondary, 0.2)}`,
      }}
    >
      {value}
    </Box>
  );
}

export default function Users() {
  const [users, setUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [selectedUser, setSelectedUser] = useState(null);
  const [form, setForm] = useState(initialForm);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const theme = useTheme();

  const fetchUsers = async () => {
    try {
      const response = await api.get('/admin/users', { params: { limit: 100, offset: 0 } });
      setUsers(response.data?.users || []);
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Failed to load users.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const filteredUsers = useMemo(() => {
    return users.filter(user => {
      const matchesSearch = user.name?.toLowerCase().includes(searchQuery.toLowerCase()) || 
                           user.email?.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesRole = roleFilter === 'all' || user.role === roleFilter;
      return matchesSearch && matchesRole;
    });
  }, [users, searchQuery, roleFilter]);

  const handleExport = () => {
    const csvContent = "data:text/csv;charset=utf-8," 
      + ["Name,Email,Role,Trust Score,Status"].join(",") + "\n"
      + filteredUsers.map(u => `"${u.name}","${u.email}","${u.role}","${u.trust_score}","${u.status}"`).join("\n");
    
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "finder_users_export.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const openEditor = (user) => {
    setSelectedUser(user);
    setForm({
      name: user.name || '',
      email: user.email || '',
      role: user.role || 'user',
      status: user.status || 'active',
      phone_number: user.phone_number || '',
      verification_status: user.verification_status || 'not_submitted',
      trust_score: user.trust_score || 0,
    });
  };

  const updateForm = (field, value) => {
    setForm((current) => ({ ...current, [field]: value }));
  };

  const saveUser = async () => {
    setSaving(true);
    setError('');
    try {
      await api.put(`/admin/users/${selectedUser.id}`, form);
      setUsers((items) => items.map((user) => (user.id === selectedUser.id ? { ...user, ...form } : user)));
      setSelectedUser(null);
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Failed to update user.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <MotionPage>
      <Stack 
        direction={{ xs: 'column', sm: 'row' }} 
        justifyContent="space-between" 
        alignItems="flex-start" 
        spacing={2} 
        sx={{ mb: '6px' }}
      >
        <Box>
          <Typography variant="h2" fontWeight={900} letterSpacing="-0.06em" mb={1}>
            Users
          </Typography>
          <Typography variant="h6" color="text.secondary" fontWeight={500}>
            Manage user accounts, trust scores, and platform verification.
          </Typography>
        </Box>
      </Stack>

      {error && <Alert severity="error" sx={{ mb: 4, borderRadius: 3 }}>{error}</Alert>}

      <Card sx={{ overflow: 'hidden', p: 0 }}>
        <Box sx={{ p: 3, borderBottom: `1px solid ${theme.palette.divider}`, display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
          <Box sx={{ 
            flexGrow: 1, 
            minWidth: 280,
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
              placeholder="Search by name or email..." 
              fullWidth 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              sx={{ fontSize: '0.9rem', fontWeight: 600 }}
            />
          </Box>
          
          <TextField
            select
            size="small"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            sx={{ 
              minWidth: 140,
              '& .MuiOutlinedInput-root': { borderRadius: '14px', bgcolor: alpha(theme.palette.text.primary, 0.03) }
            }}
          >
            <MenuItem value="all">All Roles</MenuItem>
            <MenuItem value="user">Users</MenuItem>
            <MenuItem value="admin">Admins</MenuItem>
          </TextField>

          <IconButton sx={{ bgcolor: alpha(theme.palette.text.primary, 0.03), borderRadius: '12px' }}>
            <FilterIcon fontSize="small" />
          </IconButton>
          
          <Typography variant="caption" fontWeight={700} color="text.secondary" sx={{ ml: 'auto' }}>
            Showing {filteredUsers.length} of {users.length} Users
          </Typography>
        </Box>

        <Box sx={{ overflowX: 'auto' }}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: alpha(theme.palette.text.primary, 0.01) }}>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Identity</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Account Role</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Trust Score</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Verification</TableCell>
                <TableCell sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Status</TableCell>
                <TableCell align="right" sx={{ fontWeight: 800, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.1em' }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                [...Array(5)].map((_, i) => (
                  <TableRow key={i}>
                    <TableCell colSpan={6}><LinearProgress sx={{ height: 2, opacity: 0.1 }} /></TableCell>
                  </TableRow>
                ))
              ) : filteredUsers.map((user) => (
                <TableRow key={user.id} sx={{ '&:hover': { bgcolor: alpha(theme.palette.primary.main, 0.02) } }}>
                  <TableCell>
                    <Stack direction="row" spacing={2} alignItems="center">
                      <Avatar sx={{ width: 36, height: 36, bgcolor: alpha(theme.palette.primary.main, 0.1), color: 'primary.main', fontWeight: 800, fontSize: '0.9rem' }}>
                        {user.name?.charAt(0)}
                      </Avatar>
                      <Box>
                        <Typography variant="body2" fontWeight={700}>{user.name}</Typography>
                        <Typography variant="caption" color="text.secondary">{user.email}</Typography>
                      </Box>
                    </Stack>
                  </TableCell>
                  <TableCell><StatusPill value={user.role} /></TableCell>
                  <TableCell sx={{ minWidth: 140 }}>
                    <Box display="flex" alignItems="center" gap={1.5}>
                      <Typography variant="caption" fontWeight={800}>{user.trust_score || 0}%</Typography>
                      <LinearProgress
                        variant="determinate"
                        value={Math.min(100, Number(user.trust_score || 0))}
                        sx={{ flexGrow: 1, height: 6, borderRadius: 3, bgcolor: alpha(theme.palette.text.primary, 0.05) }}
                      />
                    </Box>
                  </TableCell>
                  <TableCell><StatusPill value={user.verification_status || (user.verified ? 'approved' : 'not_submitted')} /></TableCell>
                  <TableCell><StatusPill value={user.status || 'active'} /></TableCell>
                  <TableCell align="right">
                    <Tooltip title="Edit Profile">
                      <IconButton onClick={() => openEditor(user)} sx={{ color: 'text.secondary', '&:hover': { color: 'primary.main', bgcolor: alpha(theme.palette.primary.main, 0.1) } }}>
                        <EditIcon fontSize="small" />
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
          Edit User Profile
        </DialogTitle>
        <DialogContent>
          <Stack spacing={3} mt={2}>
            <TextField label="Full Name" value={form.name} onChange={(event) => updateForm('name', event.target.value)} fullWidth />
            <TextField label="Email Address" value={form.email} onChange={(event) => updateForm('email', event.target.value)} fullWidth />
            <Stack direction="row" spacing={2}>
              <TextField select label="Role" value={form.role} onChange={(event) => updateForm('role', event.target.value)} fullWidth>
                <MenuItem value="user">User</MenuItem>
                <MenuItem value="admin">Admin</MenuItem>
              </TextField>
              <TextField select label="Account Status" value={form.status} onChange={(event) => updateForm('status', event.target.value)} fullWidth>
                <MenuItem value="active">Active</MenuItem>
                <MenuItem value="suspended">Suspended</MenuItem>
                <MenuItem value="banned">Banned</MenuItem>
              </TextField>
            </Stack>
            <Stack direction="row" spacing={2}>
              <TextField label="Phone" value={form.phone_number} onChange={(event) => updateForm('phone_number', event.target.value)} fullWidth />
              <TextField label="Trust Score" type="number" value={form.trust_score} onChange={(event) => updateForm('trust_score', Number(event.target.value))} fullWidth />
            </Stack>
            <TextField select label="Verification Status" value={form.verification_status} onChange={(event) => updateForm('verification_status', event.target.value)} fullWidth>
              <MenuItem value="not_submitted">Not Submitted</MenuItem>
              <MenuItem value="pending">Pending Review</MenuItem>
              <MenuItem value="approved">Approved</MenuItem>
              <MenuItem value="rejected">Rejected</MenuItem>
            </TextField>
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 4, pb: 4, pt: 2 }}>
          <Button onClick={() => setSelectedUser(null)} sx={{ color: 'text.secondary' }}>Cancel</Button>
          <Button onClick={saveUser} variant="contained" disabled={saving} sx={{ borderRadius: '12px', px: 4 }}>
            {saving ? 'Updating...' : 'Save Changes'}
          </Button>
        </DialogActions>
      </Dialog>
    </MotionPage>
  );
}
