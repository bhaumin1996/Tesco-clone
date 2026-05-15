import { Injectable, signal, computed, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs';
import { Cart, AddToCartRequest, UpdateCartItemRequest } from '../models/cart.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class CartService {
  private readonly _http = inject(HttpClient);

  private readonly _cart = signal<Cart | null>(null);

  readonly cart = this._cart.asReadonly();
  readonly itemCount = computed(() => this._cart()?.items?.reduce((sum, i) => sum + i.quantity, 0) ?? 0);
  readonly total = computed(() => this._cart()?.total ?? 0);

  private get baseUrl() { return `${environment.apiUrl}/cart`; }

  loadCart() {
    return this._http.get<Cart>(this.baseUrl).pipe(
      tap(c => this._cart.set(c))
    );
  }

  addItem(req: AddToCartRequest) {
    return this._http.post<Cart>(`${this.baseUrl}/items`, req).pipe(
      tap(c => this._cart.set(c))
    );
  }

  updateItem(req: UpdateCartItemRequest) {
    return this._http.put<Cart>(`${this.baseUrl}/items/${req.itemId}`, { quantity: req.quantity }).pipe(
      tap(c => this._cart.set(c))
    );
  }

  removeItem(itemId: number) {
    return this._http.delete<Cart>(`${this.baseUrl}/items/${itemId}`).pipe(
      tap(c => this._cart.set(c))
    );
  }

  clearCart() {
    return this._http.delete<void>(this.baseUrl).pipe(
      tap(() => this._cart.set(null))
    );
  }
}
