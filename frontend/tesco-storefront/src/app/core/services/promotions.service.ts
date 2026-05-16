import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { PromotionsPagedResult } from '../models/promotions.model';

@Injectable({ providedIn: 'root' })
export class PromotionsService {
  private readonly _http = inject(HttpClient);
  private get _baseUrl() { return `${environment.apiUrl}/promotions`; }

  getActivePromotions(pageNumber = 1, pageSize = 20): Observable<PromotionsPagedResult> {
    const params = new HttpParams()
      .set('pageNumber', pageNumber)
      .set('pageSize', pageSize);
    return this._http.get<PromotionsPagedResult>(this._baseUrl, { params });
  }
}
