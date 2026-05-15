import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { OrderService } from '../../../core/services/order.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { PaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { Order, OrderStatus } from '../../../core/models/order.model';
import { PagedResult } from '../../../core/models/catalogue.model';

@Component({
  selector: 'app-order-list',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, PaginationComponent],
  templateUrl: './order-list.component.html',
  styleUrl: './order-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OrderListComponent implements OnInit {
  private readonly _orders = inject(OrderService);

  protected result = signal<PagedResult<Order> | null>(null);
  protected loading = signal(true);
  protected currentPage = signal(1);

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._orders.getMyOrders(this.currentPage()).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onPageChange(p: number): void { this.currentPage.set(p); this._load(); }

  protected statusClass(status: OrderStatus): string {
    const map: Record<OrderStatus, string> = {
      Pending: 'pending',
      Confirmed: 'confirmed',
      Picking: 'picking',
      Packed: 'packed',
      OutForDelivery: 'delivery',
      Delivered: 'delivered',
      Cancelled: 'cancelled'
    };
    return map[status] ?? 'pending';
  }
}
