import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
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

  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<Seller[]>(`${this._base}/sellers`).subscribe({ next: r => this.sellers.set(r) });
    this._http.get<Dispute[]>(`${this._base}/disputes`).subscribe({
      next: r => { this.disputes.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

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
