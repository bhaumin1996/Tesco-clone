import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Department, Category, Brand, ProductDetail, ProductVariant, PagedResult, ProductSummary, SearchRequest, Banner } from '../models/catalogue.model';
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

  getBrands() {
    return this._http.get<Brand[]>(`${this.baseUrl}/catalogue/brands`);
  }

  getBanners() {
    return this._http.get<Banner[]>(`${this.baseUrl}/content/banners`);
  }

  getProducts(categoryId: number, pageNumber = 1, pageSize = 24, filters: any = {}) {
    let params = new HttpParams()
      .set('categoryId', categoryId)
      .set('pageNumber', pageNumber)
      .set('pageSize', pageSize);

    if (filters.minPrice !== undefined) params = params.set('minPrice', filters.minPrice);
    if (filters.maxPrice !== undefined) params = params.set('maxPrice', filters.maxPrice);
    if (filters.sortBy) params = params.set('sortBy', filters.sortBy);
    if (filters.sortDirection) params = params.set('sortDirection', filters.sortDirection);
    if (filters.inStockOnly !== undefined) params = params.set('inStockOnly', filters.inStockOnly);
    if (filters.clubcardOnly !== undefined) params = params.set('clubcardOnly', filters.clubcardOnly);
    
    if (filters.brands && filters.brands.length > 0) {
      filters.brands.forEach((b: string) => params = params.append('brands', b));
    }
    
    if (filters.dietary && filters.dietary.length > 0) {
      filters.dietary.forEach((d: string) => params = params.append('dietary', d));
    }

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
      .set('searchTerm', req.query || '')
      .set('pageNumber', req.pageNumber)
      .set('pageSize', req.pageSize);
    if (req.departmentId) params = params.set('departmentId', req.departmentId);
    if (req.minPrice) params = params.set('minPrice', req.minPrice);
    if (req.maxPrice) params = params.set('maxPrice', req.maxPrice);
    if (req.brand) params = params.set('brands', req.brand);
    if (req.sortBy) params = params.set('sortBy', req.sortBy);
    if (req.sortDirection) params = params.set('sortDirection', req.sortDirection);
    return this._http.get<PagedResult<ProductSummary>>(`${this.baseUrl}/products/search`, { params });
  }
}
