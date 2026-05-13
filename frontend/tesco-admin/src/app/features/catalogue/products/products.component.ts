import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface ProductRow {
  productId: number;
  name: string;
  sku: string;
  categoryName: string;
  price: number;
  stockQuantity: number;
  isActive: boolean;
}

interface PagedResult<T> {
  items: T[];
  pageNumber: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}

@Component({
  selector: 'app-admin-products',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './products.component.html',
  styleUrl: './products.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminProductsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected products = signal<ProductRow[]>([]);
  protected totalPages = signal(1);
  protected currentPage = signal(1);
  protected loading = signal(true);
  protected actionMessage = signal('');

  protected filterForm = this._fb.group({ search: [''], isActive: [''] });

  private get _base() { return `${environment.apiUrl}/admin/products`; }

  ngOnInit(): void {
    this._load();
    this.filterForm.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.currentPage.set(1);
      this._load();
    });
  }

  private _load(): void {
    this.loading.set(true);
    const { search, isActive } = this.filterForm.getRawValue();
    const params: Record<string, string> = {
      pageNumber: String(this.currentPage()),
      pageSize: '20'
    };
    if (search) params['search'] = search;
    if (isActive !== '') params['isActive'] = isActive ?? '';

    this._http.get<PagedResult<ProductRow>>(this._base, { params }).subscribe({
      next: r => { this.products.set(r.items); this.totalPages.set(r.totalPages); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected goTo(page: number): void { this.currentPage.set(page); this._load(); }

  protected toggleActive(product: ProductRow): void {
    const action = product.isActive ? 'deactivate' : 'activate';
    this._http.patch(`${this._base}/${product.productId}/${action}`, {}).subscribe({
      next: () => {
        this.products.update(list => list.map(p => p.productId === product.productId ? { ...p, isActive: !p.isActive } : p));
        this.actionMessage.set(`Product ${product.isActive ? 'deactivated' : 'activated'}.`);
        setTimeout(() => this.actionMessage.set(''), 3000);
      },
      error: () => this.actionMessage.set('Action failed. Please try again.')
    });
  }

  protected pages(): number[] {
    return Array.from({ length: this.totalPages() }, (_, i) => i + 1);
  }
}
