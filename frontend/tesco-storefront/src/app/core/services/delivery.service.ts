import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { DeliverySlot, SlotSearchRequest, Store } from '../models/delivery.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class DeliveryService {
  private readonly _http = inject(HttpClient);

  private get baseUrl() { return `${environment.apiUrl}/slots`; }

  searchSlots(req: SlotSearchRequest) {
    const params = new HttpParams()
      .set('postcode', req.postcode)
      .set('fromDate', req.fromDate)
      .set('toDate', req.toDate);
    return this._http.get<DeliverySlot[]>(`${this.baseUrl}/available`, { params });
  }

  bookSlot(slotId: number, addressId: number) {
    return this._http.post<void>(`${this.baseUrl}/${slotId}/book`, { addressId });
  }

  getStores(postcode?: string) {
    let params = new HttpParams();
    if (postcode) params = params.set('postcode', postcode);
    return this._http.get<Store[]>(`${environment.apiUrl}/stores`, { params });
  }
}
