import { useCallback, useEffect, useMemo, useState } from 'react';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import api from '../api/axios';
import { auth, firebaseConfigError } from '../config/firebase';
import toast from 'react-hot-toast';
import { AuthContext } from './authContext';

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(Boolean(auth));

  const logout = useCallback(async () => {
    if (auth) {
      await signOut(auth);
    }
    localStorage.removeItem('admin_token');
    setIsAdmin(false);
    setCurrentUser(null);
  }, []);

  useEffect(() => {
    if (!auth) {
      localStorage.removeItem('admin_token');
      return undefined;
    }

    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        try {
          const token = await firebaseUser.getIdToken();
          localStorage.setItem('admin_token', token);

          const response = await api.get('/user/me');
          const userProfile = response.data?.user || response.data || response;

          if (userProfile.role === 'admin') {
            setIsAdmin(true);
            setCurrentUser(userProfile);
          } else {
            toast.error('Unauthorized: Admin access required.');
            await logout();
          }
        } catch (error) {
          console.error('Auth validation failed:', error);
          toast.error('Authentication or role validation failed.');
          await logout();
        }
      } else {
        setIsAdmin(false);
        setCurrentUser(null);
        localStorage.removeItem('admin_token');
      }

      setLoading(false);
    });

    return unsubscribe;
  }, [logout]);

  const login = async (email, password) => {
    if (!auth) {
      throw new Error(firebaseConfigError || 'Firebase authentication is not configured.');
    }
    return signInWithEmailAndPassword(auth, email, password);
  };

  const value = useMemo(
    () => ({
      currentUser,
      isAdmin,
      loading,
      login,
      logout,
      authError: firebaseConfigError,
    }),
    [currentUser, isAdmin, loading, logout]
  );

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};
