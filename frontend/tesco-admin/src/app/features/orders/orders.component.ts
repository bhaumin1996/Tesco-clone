import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface OrderRow {
  orderId: number;
  customerName: string;
  customerEmail: string;
  total: number;
  status: string;
  createdOn: string;
}

interface PagedResult<T> { items: T[]; totalPages: number; pageNumber: number; }

@Component({
  selector: 'app-admin-orders',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminOrdersComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected orders = signal<OrderRow[]>([]);
  protected totalPages = signal(1);
  protected currentPage = signal(1);
  protected loading = signal(true);
  protected selectedOrder = signal<OrderRow | null>(null);
  protected message = signal('');

  protected filterForm = this._fb.group({ status: [''], search: [''] });

  protected readonly statuses = ['Pending', 'Confirmed', 'Processing', 'Dispatched', 'Delivered', 'Cancelled', 'Refunded'];

  private get _base() { return `${environment.apiUrl}/admin/orders`; }

  ngOnInit(): void {
    this._load();
    this.filterForm.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.currentPage.set(1); this._load();
    });
  }

  private _load(): void {
    this.loading.set(true);
    const { status, search } = this.filterForm.getRawValue();
    const params: Record<string, string> = { pageNumber: String(this.currentPage()), pageSize: '20' };
    if (status) params['status'] = status;
    if (search) params['search'] = search;
    this._http.get<PagedResult<OrderRow>>(this._base, { params }).subscribe({
      next: r => { this.orders.set(r.items); this.totalPages.set(r.totalPages); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected goTo(page: number): void { this.currentPage.set(page); this._load(); }

  protected updateStatus(orderId: number, status: string): void {
    this._http.patch(`${this._base}/${orderId}/status`, { status }).subscribe({
      next: () => {
        this.orders.update(list => list.map(o => o.orderId === orderId ? { ...o, status } : o));
        this.message.set('Status updated.');
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.message.set('Update failed.')
    });
  }

  protected refund(orderId: number): void {
    if (!confirm('Issue a refund for this order?')) return;
    this._http.post(`${this._base}/${orderId}/refund`, {}).subscribe({
      next: () => { this._load(); this.message.set('Refund issued.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Refund failed.')
    });
  }

  protected pages(): number[] { return Array.from({ length: this.totalPages() }, (_, i) => i + 1); }
}
