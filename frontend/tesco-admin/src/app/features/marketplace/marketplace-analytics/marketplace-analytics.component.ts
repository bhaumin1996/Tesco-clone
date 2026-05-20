import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpParams } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface MarketplaceKpis {
  gmv: number;
  totalOrders: number;
  averageOrderValue: number;
  disputeRate: number;
  returnRate: number;
  newApplicationsCount: number;
}

interface TopSeller {
  sellerId: number;
  businessName: string;
  revenue: number;
  orderCount: number;
}

@Component({
  selector: 'app-marketplace-analytics',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './marketplace-analytics.component.html',
  styleUrl: './marketplace-analytics.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceAnalyticsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin`; }

  readonly loading = signal(true);
  readonly kpis = signal<MarketplaceKpis | null>(null);
  readonly topSellers = signal<TopSeller[]>([]);
  readonly dateFrom = signal(this._daysAgo(30));
  readonly dateTo = signal(this._today());

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    const params = new HttpParams().set('dateFrom', this.dateFrom()).set('dateTo', this.dateTo());
    this._http.get<{ kpis: MarketplaceKpis; topSellers: TopSeller[] }>(
      `${this._base}/analytics/marketplace`, { params }
    ).subscribe({
      next: r => { this.kpis.set(r.kpis); this.topSellers.set(r.topSellers ?? []); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  applyFilter(): void { this._load(); }

  private _today(): string { return new Date().toISOString().slice(0, 10); }
  private _daysAgo(n: number): string {
    const d = new Date(); d.setDate(d.getDate() - n); return d.toISOString().slice(0, 10);
  }
}
