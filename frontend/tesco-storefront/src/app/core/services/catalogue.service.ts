import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Department, Category, ProductDetail, ProductVariant, PagedResult, ProductSummary, SearchRequest } from '../models/catalogue.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class CatalogueService {
  private readonly _http = inject(HttpClient);

  private get baseUrl() { return environment.apiUrl; }

  getDepartments() {
    return this._http.get<Department[]>(`${this.baseUrl}/catalogue/departments`);
  }

  getCategories(departmentId?: number) {
    let params = new HttpParams();
    if (departmentId) params = params.set('departmentId', departmentId);
    return this._http.get<Category[]>(`${this.baseUrl}/catalogue/categories`, { params });
  }

  getProducts(categoryId: number, pageNumber = 1, pageSize = 24) {
    const params = new HttpParams()
      .set('categoryId', categoryId)
      .set('pageNumber', pageNumber)
      .set('pageSize', pageSize);
    return this._http.get<PagedResult<ProductSummary>>(`${this.baseUrl}/products`, { params });
  }

  getProductById(id: number) {
    return this._http.get<ProductDetail>(`${this.baseUrl}/products/${id}`);
  }

  getVariants(productId: number) {
    return this._http.get<ProductVariant[]>(`${this.baseUrl}/products/${productId}/variants`);
  }

  search(req: SearchRequest) {
    let params = new HttpParams()
      .set('query', req.query)
      .set('pageNumber', req.pageNumber)
      .set('pageSize', req.pageSize);
    if (req.departmentId) params = params.set('departmentId', req.departmentId);
    if (req.minPrice) params = params.set('minPrice', req.minPrice);
    if (req.maxPrice) params = params.set('maxPrice', req.maxPrice);
    if (req.brand) params = params.set('brand', req.brand);
    if (req.sortBy) params = params.set('sortBy', req.sortBy);
    if (req.sortDirection) params = params.set('sortDirection', req.sortDirection);
    return this._http.get<PagedResult<ProductSummary>>(`${this.baseUrl}/products/search`, { params });
  }
}
