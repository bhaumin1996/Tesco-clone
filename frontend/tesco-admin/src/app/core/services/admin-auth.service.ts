import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface AdminUser {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
}

// Matches AdminLoginResultDto from the backend
interface AdminLoginApiResponse {
  userId: number;
  twoFactorToken: string;
}

// Matches AuthResultDto from the backend
interface VerifyTwoFactorApiResponse {
  user: {
    id: number;
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string | null;
    roles: string[];
  };
  token: {
    accessToken: string;
    refreshToken: string;
    expiresAt: string;
  };
}

@Injectable({ providedIn: 'root' })
export class AdminAuthService {
  private readonly _http = inject(HttpClient);
  private readonly _router = inject(Router);

  private readonly _user = signal<AdminUser | null>(this._loadUser());
  private readonly _token = signal<string | null>(localStorage.getItem('admin_token'));
  private _pendingUserId = 0;

  readonly user = this._user.asReadonly();
  readonly isAuthenticated = computed(() => this._user() !== null);

  private get baseUrl() { return `${environment.apiUrl}/admin`; }

  login(email: string, password: string) {
    return this._http.post<AdminLoginApiResponse>(`${this.baseUrl}/auth/login`, { email, password }).pipe(
      tap(r => { this._pendingUserId = r.userId; })
    );
  }

  verifyTwoFactor(code: string) {
    return this._http.post<VerifyTwoFactorApiResponse>(
      `${this.baseUrl}/auth/verify-2fa`,
      { userId: this._pendingUserId, code }
    ).pipe(
      tap(r => {
        const adminUser: AdminUser = {
          id: r.user.id,
          firstName: r.user.firstName,
          lastName: r.user.lastName,
          email: r.user.email,
          role: r.user.roles.includes('SuperAdmin') ? 'SuperAdmin' : (r.user.roles[0] ?? 'Admin')
        };
        this._storeSession(r.token.accessToken, r.token.refreshToken, adminUser);
      })
    );
  }

  requestPasswordReset(email: string) {
    return this._http.post<void>(`${this.baseUrl}/auth/forgot-password`, { email });
  }

  resetPassword(email: string, code: string, newPassword: string) {
    return this._http.post<void>(`${this.baseUrl}/auth/reset-password`, { email, code, newPassword });
  }

  logout() {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_refresh');
    localStorage.removeItem('admin_user');
    this._token.set(null);
    this._user.set(null);
    this._router.navigate(['/auth/login']);
  }

  getToken(): string | null { return this._token(); }

  private _storeSession(token: string, refresh: string, user: AdminUser): void {
    localStorage.setItem('admin_token', token);
    localStorage.setItem('admin_refresh', refresh);
    localStorage.setItem('admin_user', JSON.stringify(user));
    this._token.set(token);
    this._user.set(user);
  }

  private _loadUser(): AdminUser | null {
    try { const r = localStorage.getItem('admin_user'); return r ? JSON.parse(r) : null; }
    catch { return null; }
  }
}
