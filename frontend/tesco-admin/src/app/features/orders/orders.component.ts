import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface OrderRow {
  id: number;
  orderNumber: string;
  customerName: string;
  total: number;
  status: string;
  createdAt: string;
}

interface PagedResult<T> { items: T[]; totalPages: number; pageNumber: number; totalCount: number; }

@Component({
  selector: 'app-admin-orders',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminOrdersComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected orders = signal<OrderRow[]>([]);
  protected totalPages = signal(1);
  protected totalCount = signal(0);
  protected currentPage = signal(1);
  protected loading = signal(true);
  protected selectedOrder = signal<OrderRow | null>(null);
  protected message = signal('');

  protected readonly pageSize = 10;

  protected filterForm = this._fb.group({ search: [''] });

  protected readonly statuses = ['Placed', 'Confirmed', 'PickingInProgress', 'OutForDelivery', 'Delivered', 'Cancelled', 'Refunded'];

  protected sortBy = signal('createdAt');
  protected sortDirection = signal<'asc' | 'desc'>('desc');

  protected readonly statusLabels: Record<string, string> = {
    Placed: 'Placed',
    Confirmed: 'Confirmed',
    PickingInProgress: 'Picking',
    OutForDelivery: 'Out for delivery',
    Delivered: 'Delivered',
    Cancelled: 'Cancelled',
    Refunded: 'Refunded'
  };

  protected getStatusLabel(status: string): string {
    return (this.statusLabels as Record<string, string | undefined>)[status] ?? status;
  }

  protected statusBadgeClass(status: string): string {
    const map: Record<string, string> = {
      Placed: 'placed', Confirmed: 'confirmed', PickingInProgress: 'picking',
      OutForDelivery: 'delivery', Delivered: 'delivered',
      Cancelled: 'cancelled', Refunded: 'refunded'
    };
    return map[status] ?? 'placed';
  }

  private get _base() { return `${environment.apiUrl}/admin/orders`; }

  ngOnInit(): void {
    this._load();
    this.filterForm.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.currentPage.set(1); this._load();
    });
  }

  private _load(): void {
    this.loading.set(true);
    const { search } = this.filterForm.getRawValue();
    const params: Record<string, string> = {
      pageNumber: String(this.currentPage()),
      pageSize: '10',
      sortBy: this.sortBy(),
      sortDirection: this.sortDirection()
    };
    if (search) params['search'] = search;
    this._http.get<PagedResult<OrderRow>>(this._base, { params }).subscribe({
      next: r => { this.orders.set(r.items); this.totalPages.set(r.totalPages); this.totalCount.set(r.totalCount ?? 0); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected sort(col: string): void {
    if (this.sortBy() === col) {
      this.sortDirection.update(d => d === 'asc' ? 'desc' : 'asc');
    } else {
      this.sortBy.set(col);
      this.sortDirection.set('asc');
    }
    this.currentPage.set(1);
    this._load();
  }

  protected sortIcon(col: string): string {
    if (this.sortBy() !== col) return 'bi-arrow-down-up';
    return this.sortDirection() === 'asc' ? 'bi-sort-up' : 'bi-sort-down';
  }

  protected goTo(page: number): void { this.currentPage.set(page); this._load(); }

  protected readonly terminalStatuses = new Set(['Cancelled', 'Refunded']);

  protected updateStatus(orderId: number, status: string): void {
    const current = this.orders().find(o => o.id === orderId)?.status ?? '';
    if (this.terminalStatuses.has(current)) return;
    this._http.put(`${this._base}/${orderId}/status`, { newStatus: status }).subscribe({
      next: () => {
        this.orders.update(list => list.map(o => o.id === orderId ? { ...o, status } : o));
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

  protected startItem(): number { return Math.min((this.currentPage() - 1) * this.pageSize + 1, this.totalCount()); }
  protected endItem(): number   { return Math.min(this.currentPage() * this.pageSize, this.totalCount()); }

  protected visiblePages(): (number | null)[] {
    const total = this.totalPages();
    const cur   = this.currentPage();
    if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
    const pages: (number | null)[] = [1];
    if (cur > 3) pages.push(null);
    for (let p = Math.max(2, cur - 1); p <= Math.min(total - 1, cur + 1); p++) pages.push(p);
    if (cur < total - 2) pages.push(null);
    pages.push(total);
    return pages;
  }
}
