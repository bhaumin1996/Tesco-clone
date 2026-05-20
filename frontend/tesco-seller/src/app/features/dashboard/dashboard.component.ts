import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface SellerDashboard {
  ordersToday: number;
  gmvThisMonth: number;
  pendingDispatches: number;
  openReturnRequests: number;
  performanceScore?: number;
  lowStockCount: number;
}

interface RecentOrder {
  sellerOrderId: number;
  orderNumber: string;
  statusName: string;
  sellerTotal: number;
  orderPlacedOn: string;
  lineCount: number;
}

@Component({
  selector: 'app-seller-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerDashboardComponent implements OnInit {
  private readonly _http = inject(HttpClient);

  readonly loading = signal(true);
  readonly kpis = signal<SellerDashboard | null>(null);
  readonly recentOrders = signal<RecentOrder[]>([]);

  ngOnInit(): void {
    this._http.get<{ kpis: SellerDashboard; recentOrders: RecentOrder[] }>(
      `${environment.apiUrl}/marketplace/dashboard`
    ).subscribe({
      next: r => { this.kpis.set(r.kpis); this.recentOrders.set(r.recentOrders ?? []); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
