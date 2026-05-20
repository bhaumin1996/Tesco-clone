import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { MarketplaceService } from '../../../core/services/marketplace.service';
import { Order } from '../../../core/models/order.model';

@Component({
  selector: 'app-marketplace-orders',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent, SpinnerComponent],
  templateUrl: './marketplace-orders.component.html',
  styleUrl: './marketplace-orders.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceOrdersComponent implements OnInit {
  private readonly _marketplace = inject(MarketplaceService);

  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'My Account', url: '/account' },
    { label: 'Marketplace Orders' }
  ];

  readonly loading = signal(true);
  readonly allOrders = signal<Order[]>([]);
  readonly error = signal<string | null>(null);

  readonly marketplaceOrders = computed(() =>
    this.allOrders().filter(o => o.items?.some(i => i.isMarketplace))
  );

  ngOnInit(): void {
    this._marketplace.getMarketplaceOrders(1, 50).subscribe({
      next: res => {
        this.allOrders.set(res.items);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Could not load your marketplace orders. Please try again.');
        this.loading.set(false);
      }
    });
  }

  getMarketplaceItems(order: Order) {
    return order.items?.filter(i => i.isMarketplace) ?? [];
  }

  getSellerGroups(order: Order): { sellerId: number; sellerName: string; items: typeof order.items; trackingNumber?: string; carrierName?: string; sellerOrderStatus?: string }[] {
    const map = new Map<number, { sellerId: number; sellerName: string; items: typeof order.items; trackingNumber?: string; carrierName?: string; sellerOrderStatus?: string }>();
    for (const item of (order.items ?? [])) {
      if (!item.isMarketplace || !item.sellerId) continue;
      if (!map.has(item.sellerId)) {
        map.set(item.sellerId, {
          sellerId: item.sellerId,
          sellerName: item.sellerName ?? 'Marketplace Seller',
          items: [],
          trackingNumber: item.trackingNumber,
          carrierName: item.carrierName,
          sellerOrderStatus: item.sellerOrderStatus
        });
      }
      map.get(item.sellerId)!.items!.push(item);
    }
    return Array.from(map.values());
  }

  canRaiseReturn(order: Order): boolean {
    const placed = new Date(order.createdAt);
    const now = new Date();
    const daysDiff = (now.getTime() - placed.getTime()) / (1000 * 60 * 60 * 24);
    return order.status === 'Delivered' && daysDiff <= 30;
  }
}
