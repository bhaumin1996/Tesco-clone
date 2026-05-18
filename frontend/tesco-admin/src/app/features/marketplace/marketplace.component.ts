import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { AdminPaginationComponent } from '../../shared/components/pagination/pagination.component';
import { extractApiError } from '../../core/utils/api-error';

interface Seller {
  sellerId: number;
  businessName: string;
  email: string;
  status: string;
  totalListings: number;
  joinedOn: string;
}

interface Dispute {
  disputeId: number;
  orderId: number;
  sellerName: string;
  reason: string;
  status: string;
  createdOn: string;
}

@Component({
  selector: 'app-admin-marketplace',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, AdminPaginationComponent],
  templateUrl: './marketplace.component.html',
  styleUrl: './marketplace.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminMarketplaceComponent implements OnInit {
  private readonly _http = inject(HttpClient);

  protected sellers = signal<Seller[]>([]);
  protected disputes = signal<Dispute[]>([]);
  protected loading = signal(true);
  protected activeTab = signal<'sellers' | 'disputes'>('sellers');
  protected message = signal('');

  protected sellerSearch = signal('');
  protected disputeSearch = signal('');

  protected readonly pageSize = 10;
  protected sellerPage = signal(1);
  protected filteredSellers = computed(() => {
    const q = this.sellerSearch().toLowerCase();
    return q ? this.sellers().filter(s =>
      s.businessName.toLowerCase().includes(q) ||
      s.email.toLowerCase().includes(q)
    ) : this.sellers();
  });
  protected sellerTotalPages = computed(() => Math.max(1, Math.ceil(this.filteredSellers().length / this.pageSize)));
  protected pagedSellers = computed(() => { const s = (this.sellerPage() - 1) * this.pageSize; return this.filteredSellers().slice(s, s + this.pageSize); });
  protected sellerPageNumbers = computed(() => Array.from({ length: this.sellerTotalPages() }, (_, i) => i + 1));

  protected disputePage = signal(1);
  protected filteredDisputes = computed(() => {
    const q = this.disputeSearch().toLowerCase();
    return q ? this.disputes().filter(d =>
      d.sellerName.toLowerCase().includes(q) ||
      d.reason.toLowerCase().includes(q)
    ) : this.disputes();
  });
  protected disputeTotalPages = computed(() => Math.max(1, Math.ceil(this.filteredDisputes().length / this.pageSize)));
  protected pagedDisputes = computed(() => { const s = (this.disputePage() - 1) * this.pageSize; return this.filteredDisputes().slice(s, s + this.pageSize); });
  protected disputePageNumbers = computed(() => Array.from({ length: this.disputeTotalPages() }, (_, i) => i + 1));

  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<Seller[]>(`${this._base}/sellers`).subscribe({ next: r => { this.sellers.set(r); this.sellerPage.set(1); } });
    this._http.get<Dispute[]>(`${this._base}/disputes`).subscribe({
      next: r => { this.disputes.set(r); this.disputePage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onSellerSearch(term: string): void { this.sellerSearch.set(term); this.sellerPage.set(1); }
  protected onDisputeSearch(term: string): void { this.disputeSearch.set(term); this.disputePage.set(1); }

  protected goToSellerPage(page: number): void { if (page >= 1 && page <= this.sellerTotalPages()) this.sellerPage.set(page); }
  protected goToDisputePage(page: number): void { if (page >= 1 && page <= this.disputeTotalPages()) this.disputePage.set(page); }

  protected approveSeller(id: number): void {
    this._http.patch(`${this._base}/sellers/${id}/approve`, {}).subscribe({
      next: () => { this._load(); this.message.set('Seller approved.'); setTimeout(() => this.message.set(''), 3000); },
      error: (err) => this.message.set(extractApiError(err, 'Action failed.'))
    });
  }

  protected suspendSeller(id: number): void {
    this._http.patch(`${this._base}/sellers/${id}/suspend`, {}).subscribe({
      next: () => { this._load(); this.message.set('Seller suspended.'); setTimeout(() => this.message.set(''), 3000); },
      error: (err) => this.message.set(extractApiError(err, 'Action failed.'))
    });
  }

  protected resolveDispute(id: number, outcome: string): void {
    this._http.patch(`${this._base}/disputes/${id}/resolve`, { outcome }).subscribe({
      next: () => { this._load(); this.message.set('Dispute resolved.'); setTimeout(() => this.message.set(''), 3000); },
      error: (err) => this.message.set(extractApiError(err, 'Action failed.'))
    });
  }
}
