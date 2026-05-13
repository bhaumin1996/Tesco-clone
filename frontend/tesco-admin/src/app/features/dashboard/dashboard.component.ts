import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface DashboardStats {
  totalOrdersToday: number;
  totalRevenueToday: number;
  newCustomersToday: number;
  pendingOrders: number;
  lowStockProducts: number;
  openDisputes: number;
}

interface RecentOrder {
  orderId: number;
  customerName: string;
  total: number;
  status: string;
  createdOn: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DashboardComponent implements OnInit {
  private readonly _http = inject(HttpClient);

  protected stats = signal<DashboardStats | null>(null);
  protected recentOrders = signal<RecentOrder[]>([]);
  protected loading = signal(true);

  ngOnInit(): void {
    this._http.get<DashboardStats>(`${environment.apiUrl}/admin/dashboard/stats`).subscribe({
      next: s => { this.stats.set(s); this.loading.set(false); },
      error: () => {
        this.stats.set({ totalOrdersToday: 0, totalRevenueToday: 0, newCustomersToday: 0, pendingOrders: 0, lowStockProducts: 0, openDisputes: 0 });
        this.loading.set(false);
      }
    });
    this._http.get<RecentOrder[]>(`${environment.apiUrl}/admin/orders?pageSize=5&pageNumber=1`).subscribe({
      next: r => this.recentOrders.set((r as any).items ?? r),
      error: () => {}
    });
  }
}
