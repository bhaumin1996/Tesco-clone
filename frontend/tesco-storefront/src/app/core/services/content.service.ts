import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Page {
  id: number;
  title: string;
  slug: string;
  content: string;
  isPublished: boolean;
  createdOn: string;
  modifiedOn?: string;
}

export interface Banner {
  id: number;
  title: string;
  subTitle?: string;
  imageUrl?: string;
  linkUrl?: string;
  displayOrder: number;
  startsAt?: string;
  endsAt?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ContentService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/content`;

  getPageBySlug(slug: string): Observable<Page> {
    return this.http.get<Page>(`${this.apiUrl}/pages/${slug}`);
  }

  getActiveBanners(): Observable<Banner[]> {
    return this.http.get<Banner[]>(`${this.apiUrl}/banners`);
  }
}
