import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ClubcardBalance, PointsTransaction, Voucher, RedeemVoucherRequest } from '../models/loyalty.model';
import { PagedResult } from '../models/catalogue.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class LoyaltyService {
  private readonly _http = inject(HttpClient);

  private get baseUrl() { return `${environment.apiUrl}/clubcard`; }

  getBalance() {
    return this._http.get<ClubcardBalance>(`${this.baseUrl}/balance`);
  }

  getTransactions(pageNumber = 1, pageSize = 20) {
    return this._http.get<PagedResult<PointsTransaction>>(
      `${this.baseUrl}/transactions?pageNumber=${pageNumber}&pageSize=${pageSize}`
    );
  }

  getVouchers() {
    return this._http.get<Voucher[]>(`${this.baseUrl}/vouchers`);
  }

  redeemVoucher(req: RedeemVoucherRequest) {
    return this._http.post<void>(`${this.baseUrl}/vouchers/redeem`, req);
  }

  redeemPoints(points: number) {
    return this._http.post<void>(`${this.baseUrl}/points/redeem`, { points });
  }
}
