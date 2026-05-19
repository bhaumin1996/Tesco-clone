import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { OrderService } from '../../../core/services/order.service';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { Order, OrderStatus } from '../../../core/models/order.model';
import { UserRatingStatus } from '../../../core/models/catalogue.model';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

@Component({
  selector: 'app-order-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, ImageUrlPipe],
  templateUrl: './order-detail.component.html',
  styleUrl: './order-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OrderDetailComponent implements OnInit {
  private readonly _orders = inject(OrderService);
  private readonly _catalogue = inject(CatalogueService);
  private readonly _route = inject(ActivatedRoute);
  private readonly _notifications = inject(NotificationService);

  protected order = signal<Order | null>(null);
  protected loading = signal(true);
  protected cancelling = signal(false);

  // productId → UserRatingStatus
  protected ratingStatuses = signal<Record<number, UserRatingStatus>>({});
  // productId → pending star value (1-5)
  protected pendingRatings = signal<Record<number, number>>({});
  // productId being submitted right now
  protected submittingFor = signal<number | null>(null);

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      this._orders.getOrderById(+p['id']).subscribe({
        next: o => {
          this.order.set(o);
          this.loading.set(false);
          if (o.status !== 'Cancelled') {
            this._loadRatingStatuses(o);
          }
        },
        error: () => this.loading.set(false)
      });
    });
  }

  private _loadRatingStatuses(order: Order): void {
    const seen = new Set<number>();
    order.items.forEach(item => {
      if (seen.has(item.productId)) return;
      seen.add(item.productId);
      this._catalogue.getUserRatingStatus(item.productId).subscribe({
        next: status => {
          this.ratingStatuses.update(map => ({ ...map, [item.productId]: status }));
        },
        error: () => { /* unauthenticated or network error — no rating widget shown */ }
      });
    });
  }

  protected setItemRating(productId: number, value: number): void {
    if (this.submittingFor() === productId) return;
    this.pendingRatings.update(map => ({ ...map, [productId]: value }));
    this.submitItemRating(productId);
  }

  protected submitItemRating(productId: number): void {
    const rating = this.pendingRatings()[productId];
    if (!rating) return;
    this.submittingFor.set(productId);
    this._catalogue.submitRating(productId, rating).subscribe({
      next: () => {
        this.submittingFor.set(null);
        this.ratingStatuses.update(map => ({
          ...map,
          [productId]: { canRate: true, hasRated: true, existingRating: rating }
        }));
        this._notifications.success('Thank you for your rating!');
      },
      error: () => {
        this.submittingFor.set(null);
        this._notifications.error('Could not submit rating. Please try again.');
      }
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

  protected canCancel(order: Order): boolean {
    return order.status === 'Placed';
  }

  protected statusClass(status: OrderStatus): string {
    const map: Record<OrderStatus, string> = {
      Placed: 'pending',
      Confirmed: 'confirmed',
      Picking: 'picking',
      Packed: 'packed',
      OutForDelivery: 'delivery',
      Delivered: 'delivered',
      Cancelled: 'cancelled'
    };
    return map[status] ?? 'pending';
  }

  protected addressLines(address: string): string[] {
    return address.split(', ').filter(l => l.trim().length > 0);
  }

  protected downloadInvoice(): void {
    const o = this.order();
    if (o?.invoiceUrl) {
      const url = this._orders.getInvoiceUrl(o.invoiceUrl);
      window.open(url, '_blank');
    }
  }
}
