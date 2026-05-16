import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Address, AddAddressRequest, UpdateAddressRequest } from '../models/address.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AddressService {
  private readonly _http = inject(HttpClient);

  private get baseUrl() { return `${environment.apiUrl}/addresses`; }

  getAddresses() {
    return this._http.get<Address[]>(this.baseUrl);
  }

  addAddress(address: Partial<Address>) {
    return this._http.post<void>(this.baseUrl, address);
  }

  updateAddress(id: number, address: Partial<Address>) {
    return this._http.put<void>(`${this.baseUrl}/${id}`, address);
  }

  deleteAddress(id: number) {
    return this._http.delete<void>(`${this.baseUrl}/${id}`);
  }

  setDefaultAddress(id: number) {
    return this._http.post<void>(`${this.baseUrl}/${id}/default`, {});
  }

  importFromOrders() {
    return this._http.post<void>(`${this.baseUrl}/import`, {});
  }
}
