import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { OrderService } from '../../../core/services/order.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { Order } from '../../../core/models/order.model';

@Component({
  selector: 'app-order-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent],
  templateUrl: './order-detail.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OrderDetailComponent implements OnInit {
  private readonly _orders = inject(OrderService);
  private readonly _route = inject(ActivatedRoute);
  private readonly _notifications = inject(NotificationService);

  protected order = signal<Order | null>(null);
  protected loading = signal(true);
  protected cancelling = signal(false);

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      this._orders.getOrderById(+p['id']).subscribe({
        next: o => { this.order.set(o); this.loading.set(false); },
        error: () => this.loading.set(false)
      });
    });
  }

  protected cancelOrder(): void {
    if (!this.order()) return;
    this.cancelling.set(true);
    this._orders.cancelOrder(this.order()!.id).subscribe({
      next: () => {
        this.cancelling.set(false);
        this._notifications.success('Order cancelled');
        this.order.update(o => o ? { ...o, status: 'Cancelled' } : o);
      },
      error: () => {
        this.cancelling.set(false);
        this._notifications.error('Could not cancel order');
      }
    });
  }
}
