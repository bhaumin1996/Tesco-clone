import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { environment } from '../../../environments/environment';
import { SellerLoginRequest, SellerAuthResponse, SellerUser } from '../models/seller-auth.model';

const ACCESS_KEY = 'seller_token';
const REFRESH_KEY = 'seller_refresh';
const USER_KEY = 'seller_user';

@Injectable({ providedIn: 'root' })
export class SellerAuthService {
  private readonly _http = inject(HttpClient);
  private readonly _router = inject(Router);

  readonly user = signal<SellerUser | null>(this._loadUser());
  readonly isLoggedIn = signal(!!this._loadUser());

  private get _base() { return `${environment.apiUrl}`; }

  login(req: SellerLoginRequest) {
    return this._http.post<SellerAuthResponse>(`${this._base}/auth/login`, req).pipe(
      tap(res => {
        localStorage.setItem(ACCESS_KEY, res.token.accessToken);
        localStorage.setItem(REFRESH_KEY, res.token.refreshToken);
        const u: SellerUser = {
          id: res.user.id,
          name: `${res.user.firstName} ${res.user.lastName}`,
          email: res.user.email,
          roles: res.user.roles
        };
        localStorage.setItem(USER_KEY, JSON.stringify(u));
        this.user.set(u);
        this.isLoggedIn.set(true);
      })
    );
  }

  logout(): void {
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
    localStorage.removeItem(USER_KEY);
    this.user.set(null);
    this.isLoggedIn.set(false);
    this._router.navigate(['/auth/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(ACCESS_KEY);
  }

  private _loadUser(): SellerUser | null {
    try {
      const raw = localStorage.getItem(USER_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }
}
