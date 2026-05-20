import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { SellerProfile, SellerPerformance, SellerDeliveryOption, MarketplaceReturn } from '../models/marketplace.model';
import { PagedResult, ProductSummary } from '../models/catalogue.model';
import { Order } from '../models/order.model';

@Injectable({ providedIn: 'root' })
export class MarketplaceService {
  private readonly _http = inject(HttpClient);
  private get base() { return environment.apiUrl; }

  getSellerProfile(sellerId: number) {
    return this._http.get<SellerProfile>(`${this.base}/marketplace/sellers/${sellerId}`);
  }

  getSellerPerformance(sellerId: number) {
    return this._http.get<SellerPerformance>(`${this.base}/marketplace/sellers/${sellerId}/performance`);
  }

  getSellerDeliveryOptions(sellerId: number) {
    return this._http.get<SellerDeliveryOption[]>(`${this.base}/marketplace/sellers/${sellerId}/delivery-options`);
  }

  searchMarketplace(
    searchTerm?: string,
    categoryId?: number,
    sellerId?: number,
    minPrice?: number,
    maxPrice?: number,
    sortBy?: string,
    pageNumber = 1,
    pageSize = 24
  ) {
    let params = new HttpParams()
      .set('includeMarketplace', 'true')
      .set('pageNumber', pageNumber)
      .set('pageSize', pageSize);

    if (searchTerm) params = params.set('searchTerm', searchTerm);
    if (categoryId) params = params.set('categoryId', categoryId);
    if (sellerId)   params = params.set('sellerId', sellerId);
    if (minPrice != null) params = params.set('minPrice', minPrice);
    if (maxPrice != null) params = params.set('maxPrice', maxPrice);
    if (sortBy)     params = params.set('sortBy', sortBy);

    return this._http.get<PagedResult<ProductSummary>>(`${this.base}/products`, { params });
  }

  getMarketplaceOrders(pageNumber = 1, pageSize = 20) {
    const params = new HttpParams()
      .set('pageNumber', pageNumber)
      .set('pageSize', pageSize);
    return this._http.get<PagedResult<Order>>(`${this.base}/orders`, { params });
  }

  getMarketplaceOrderById(orderId: number) {
    return this._http.get<Order>(`${this.base}/orders/${orderId}`);
  }

  raiseReturn(orderLineId: number, returnReason: string) {
    return this._http.post<{ returnId: number }>(
      `${this.base}/marketplace/returns`,
      { orderLineId, returnReason }
    );
  }

  getMyReturns() {
    return this._http.get<MarketplaceReturn[]>(`${this.base}/marketplace/returns/my`);
  }
}
