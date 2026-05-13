import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface SalesReport {
  period: string;
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  newCustomers: number;
  returningCustomers: number;
}

interface TopProduct {
  productName: string;
  unitsSold: number;
  revenue: number;
}

@Component({
  selector: 'app-admin-analytics',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './analytics.component.html',
  styleUrl: './analytics.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminAnalyticsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected report = signal<SalesReport | null>(null);
  protected topProducts = signal<TopProduct[]>([]);
  protected loading = signal(true);

  protected filterForm = this._fb.group({
    from: [new Date(Date.now() - 30 * 86400000).toISOString().substring(0, 10)],
    to: [new Date().toISOString().substring(0, 10)]
  });

  private get _base() { return `${environment.apiUrl}/admin/analytics`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    const { from, to } = this.filterForm.getRawValue();
    const params = { from: from ?? '', to: to ?? '' };
    this._http.get<SalesReport>(`${this._base}/sales`, { params }).subscribe({
      next: r => { this.report.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
    this._http.get<TopProduct[]>(`${this._base}/top-products`, { params }).subscribe({
      next: r => this.topProducts.set(r),
      error: () => {}
    });
  }

  protected applyFilter(): void { this._load(); }

  protected exportCsv(): void {
    const { from, to } = this.filterForm.getRawValue();
    window.open(`${this._base}/export?from=${from}&to=${to}`, '_blank');
  }
}
