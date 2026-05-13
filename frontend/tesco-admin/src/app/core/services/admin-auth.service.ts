import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap, catchError, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface AdminUser {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
}

export interface AdminLoginResponse {
  requiresTwoFactor: boolean;
  tempToken?: string;
  accessToken?: string;
  refreshToken?: string;
  user?: AdminUser;
}

@Injectable({ providedIn: 'root' })
export class AdminAuthService {
  private readonly _http = inject(HttpClient);
  private readonly _router = inject(Router);

  private readonly _user = signal<AdminUser | null>(this._loadUser());
  private readonly _token = signal<string | null>(localStorage.getItem('admin_token'));
  private _tempToken = '';

  readonly user = this._user.asReadonly();
  readonly isAuthenticated = computed(() => this._user() !== null);

  private get baseUrl() { return `${environment.apiUrl}/admin`; }

  login(email: string, password: string) {
    return this._http.post<AdminLoginResponse>(`${this.baseUrl}/auth/login`, { email, password }).pipe(
      tap(r => {
        if (!r.requiresTwoFactor && r.accessToken && r.user) {
          this._storeSession(r.accessToken, r.refreshToken ?? '', r.user);
        } else if (r.tempToken) {
          this._tempToken = r.tempToken;
        }
      })
    );
  }

  verifyTwoFactor(code: string) {
    return this._http.post<AdminLoginResponse>(`${this.baseUrl}/auth/verify-2fa`, { tempToken: this._tempToken, code }).pipe(
      tap(r => {
        if (r.accessToken && r.user) this._storeSession(r.accessToken, r.refreshToken ?? '', r.user);
      })
    );
  }

  logout() {
    localStorage.removeItem('admin_token');
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
