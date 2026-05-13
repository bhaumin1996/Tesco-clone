import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap, catchError, throwError } from 'rxjs';
import { AuthResponse, LoginRequest, RegisterRequest, UserProfile } from '../models/auth.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly _http = inject(HttpClient);
  private readonly _router = inject(Router);

  private readonly _user = signal<UserProfile | null>(this._loadUser());
  private readonly _accessToken = signal<string | null>(localStorage.getItem('access_token'));

  readonly user = this._user.asReadonly();
  readonly isAuthenticated = computed(() => this._user() !== null);

  private get baseUrl() { return `${environment.apiUrl}/auth`; }

  register(req: RegisterRequest) {
    return this._http.post<AuthResponse>(`${this.baseUrl}/register`, req).pipe(
      tap(r => this._storeSession(r))
    );
  }

  login(req: LoginRequest) {
    return this._http.post<AuthResponse>(`${this.baseUrl}/login`, req).pipe(
      tap(r => this._storeSession(r))
    );
  }

  logout() {
    const token = localStorage.getItem('refresh_token');
    if (token) {
      this._http.post(`${this.baseUrl}/revoke`, { refreshToken: token }).subscribe();
    }
    this._clearSession();
    this._router.navigate(['/auth/login']);
  }

  refreshToken() {
    const refreshToken = localStorage.getItem('refresh_token');
    const userId = parseInt(localStorage.getItem('user_id') ?? '0', 10);
    if (!refreshToken || !userId) return throwError(() => new Error('No refresh token'));
    return this._http.post<AuthResponse>(`${this.baseUrl}/refresh`, { userId, refreshToken }).pipe(
      tap(r => this._storeSession(r)),
      catchError(err => {
        this._clearSession();
        return throwError(() => err);
      })
    );
  }

  getAccessToken(): string | null { return this._accessToken(); }

  private _storeSession(r: AuthResponse): void {
    localStorage.setItem('access_token', r.token.accessToken);
    localStorage.setItem('refresh_token', r.token.refreshToken);
    localStorage.setItem('user_id', r.user.id.toString());
    localStorage.setItem('user', JSON.stringify(r.user));
    this._accessToken.set(r.token.accessToken);
    this._user.set(r.user);
  }

  private _clearSession(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_id');
    localStorage.removeItem('user');
    this._accessToken.set(null);
    this._user.set(null);
  }

  private _loadUser(): UserProfile | null {
    try {
      const raw = localStorage.getItem('user');
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }
}
