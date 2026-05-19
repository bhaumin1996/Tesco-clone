import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs';
import { Favourite, FavouriteStatus } from '../models/catalogue.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class FavouritesService {
  private readonly _http = inject(HttpClient);

  private readonly _favourites = signal<Favourite[]>([]);
  private readonly _favouriteProductIds = signal<Set<number>>(new Set());

  readonly favourites = this._favourites.asReadonly();
  readonly count = computed(() => this._favourites().length);

  private get baseUrl() { return `${environment.apiUrl}/products`; }

  isFavourited(productId: number): boolean {
    return this._favouriteProductIds().has(productId);
  }

  loadFavourites() {
    return this._http.get<Favourite[]>(`${this.baseUrl}/favourites`).pipe(
      tap(items => {
        this._favourites.set(items);
        this._favouriteProductIds.set(new Set(items.map(f => f.productId)));
      })
    );
  }

  getFavouriteStatus(productId: number) {
    return this._http.get<FavouriteStatus>(`${this.baseUrl}/${productId}/favourites/status`);
  }

  addFavourite(productId: number) {
    return this._http.post<{ favouriteId: number }>(`${this.baseUrl}/${productId}/favourites`, {}).pipe(
      tap(() => {
        this._favouriteProductIds.update(ids => new Set([...ids, productId]));
      })
    );
  }

  removeFavourite(productId: number) {
    return this._http.delete<void>(`${this.baseUrl}/${productId}/favourites`).pipe(
      tap(() => {
        this._favourites.update(list => list.filter(f => f.productId !== productId));
        this._favouriteProductIds.update(ids => {
          const next = new Set(ids);
          next.delete(productId);
          return next;
        });
      })
    );
  }
}
