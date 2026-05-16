import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface UserCard {
  id: number;
  brand: string;
  last4: string;
  expiryMonth: number;
  expiryYear: number;
  isDefault: boolean;
  paymentMethodId: string;
}

@Injectable({ providedIn: 'root' })
export class PaymentService {
  private readonly _http = inject(HttpClient);
  private readonly _baseUrl = `${environment.apiUrl}/payments`;

  getCards(): Observable<UserCard[]> {
    return this._http.get<UserCard[]>(`${this._baseUrl}/cards`);
  }

  deleteCard(id: number): Observable<void> {
    return this._http.delete<void>(`${this._baseUrl}/cards/${id}`);
  }
}
