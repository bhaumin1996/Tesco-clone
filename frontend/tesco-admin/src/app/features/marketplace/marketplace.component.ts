import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

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
  imports: [CommonModule, ReactiveFormsModule],
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

  protected readonly pageSize = 10;
  protected sellerPage = signal(1);
  protected sellerTotalPages = computed(() => Math.max(1, Math.ceil(this.sellers().length / this.pageSize)));
  protected pagedSellers = computed(() => { const s = (this.sellerPage() - 1) * this.pageSize; return this.sellers().slice(s, s + this.pageSize); });
  protected sellerPageNumbers = computed(() => Array.from({ length: this.sellerTotalPages() }, (_, i) => i + 1));

  protected disputePage = signal(1);
  protected disputeTotalPages = computed(() => Math.max(1, Math.ceil(this.disputes().length / this.pageSize)));
  protected pagedDisputes = computed(() => { const s = (this.disputePage() - 1) * this.pageSize; return this.disputes().slice(s, s + this.pageSize); });
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

  protected goToSellerPage(page: number): void { if (page >= 1 && page <= this.sellerTotalPages()) this.sellerPage.set(page); }
  protected goToDisputePage(page: number): void { if (page >= 1 && page <= this.disputeTotalPages()) this.disputePage.set(page); }

  protected approveSeller(id: number): void {
    this._http.patch(`${this._base}/sellers/${id}/approve`, {}).subscribe({
      next: () => { this._load(); this.message.set('Seller approved.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Action failed.')
    });
  }

  protected suspendSeller(id: number): void {
    this._http.patch(`${this._base}/sellers/${id}/suspend`, {}).subscribe({
      next: () => { this._load(); this.message.set('Seller suspended.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Action failed.')
    });
  }

  protected resolveDispute(id: number, outcome: string): void {
    this._http.patch(`${this._base}/disputes/${id}/resolve`, { outcome }).subscribe({
      next: () => { this._load(); this.message.set('Dispute resolved.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Action failed.')
    });
  }
}
