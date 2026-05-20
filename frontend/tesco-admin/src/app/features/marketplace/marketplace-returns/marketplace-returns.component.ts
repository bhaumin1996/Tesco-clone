import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface MarketplaceReturn {
  id: number;
  orderId: number;
  orderNumber: string;
  customerName: string;
  sellerName: string;
  returnReason: string;
  statusName: string;
  slaDeadline: string;
  refundAmount?: number;
  createdOn: string;
  sellerResponse?: string;
}

interface PagedResult<T> {
  items: T[];
}

@Component({
  selector: 'app-marketplace-returns',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './marketplace-returns.component.html',
  styleUrl: './marketplace-returns.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceReturnsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  readonly loading = signal(true);
  readonly returns = signal<MarketplaceReturn[]>([]);
  readonly message = signal('');
  readonly statusFilter = signal<string>('all');
  readonly selectedReturn = signal<MarketplaceReturn | null>(null);
  readonly resolution = signal('');
  readonly submitting = signal(false);

  readonly filtered = computed(() => {
    const sf = this.statusFilter();
    const list = this.returns();
    return sf === 'all' ? list : list.filter(r => r.statusName.toLowerCase() === sf.toLowerCase());
  });

  readonly slaOverdue = computed(() =>
    this.returns().filter(r => new Date(r.slaDeadline) < new Date() && r.statusName !== 'Resolved')
  );

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<MarketplaceReturn[] | PagedResult<MarketplaceReturn>>(`${this._base}/returns`).subscribe({
      next: r => {
        const returns = Array.isArray(r) ? r : (r?.items ?? []);
        this.returns.set(returns);
        this.loading.set(false);
      },
      error: () => this.loading.set(false)
    });
  }

  openReturn(ret: MarketplaceReturn): void {
    this.selectedReturn.set(ret);
    this.resolution.set('');
  }

  closeDetail(): void { this.selectedReturn.set(null); }

  resolve(id: number): void {
    const res = this.resolution().trim();
    if (!res) return;
    this.submitting.set(true);
    this._http.post(`${this._base}/returns/${id}/resolve`, { resolution: res }).subscribe({
      next: () => {
        this.submitting.set(false);
        this.closeDetail();
        this._load();
        this.message.set('Return resolved.');
        setTimeout(() => this.message.set(''), 4000);
      },
      error: () => { this.submitting.set(false); this.message.set('Action failed.'); }
    });
  }

  isSlaBreached(sla: string): boolean {
    return new Date(sla) < new Date();
  }
}
