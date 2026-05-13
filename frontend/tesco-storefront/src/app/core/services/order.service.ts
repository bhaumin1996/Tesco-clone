import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Order, PlaceOrderRequest } from '../models/order.model';
import { PagedResult } from '../models/catalogue.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class OrderService {
  private readonly _http = inject(HttpClient);

  private get baseUrl() { return `${environment.apiUrl}/orders`; }

  getMyOrders(pageNumber = 1, pageSize = 10) {
    const params = new HttpParams().set('pageNumber', pageNumber).set('pageSize', pageSize);
    return this._http.get<PagedResult<Order>>(this.baseUrl, { params });
  }

  getOrderById(id: number) {
    return this._http.get<Order>(`${this.baseUrl}/${id}`);
  }

  placeOrder(req: PlaceOrderRequest) {
    return this._http.post<Order>(this.baseUrl, req);
  }

  cancelOrder(id: number) {
    return this._http.post<void>(`${this.baseUrl}/${id}/cancel`, {});
  }
}
