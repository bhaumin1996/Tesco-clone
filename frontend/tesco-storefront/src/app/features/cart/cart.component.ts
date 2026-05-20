import { ChangeDetectionStrategy, Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CartService } from '../../core/services/cart.service';
import { NotificationService } from '../../core/services/notification.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { QuantityStepperComponent } from '../../shared/components/quantity-stepper/quantity-stepper.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { CartItem } from '../../core/models/cart.model';
import { ImageUrlPipe } from '../../shared/pipes/image-url.pipe';
import { extractApiError } from '../../core/utils/api-error';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, QuantityStepperComponent, BreadcrumbComponent, ImageUrlPipe],
  templateUrl: './cart.component.html',
  styleUrl: './cart.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CartComponent implements OnInit {
  protected readonly cartService = inject(CartService);
  private readonly _notifications = inject(NotificationService);
  protected loading = signal(true);

  readonly marketplaceSellerGroups = computed(() => {
    const items = this.cartService.cart()?.items ?? [];
    const map = new Map<number, { sellerId: number; sellerName: string; items: CartItem[]; lineTotal: number; deliveryCharge?: number; freeThreshold?: number }>();
    for (const item of items) {
      if (!item.isMarketplace || !item.sellerId) continue;
      if (!map.has(item.sellerId)) {
        map.set(item.sellerId, {
          sellerId: item.sellerId,
          sellerName: item.sellerName ?? 'Marketplace Seller',
          items: [],
          lineTotal: 0,
          deliveryCharge: item.marketplaceDeliveryCharge,
          freeThreshold: item.marketplaceFreeDeliveryThreshold
        });
      }
      const g = map.get(item.sellerId)!;
      g.items.push(item);
      g.lineTotal += item.lineTotal;
    }
    return Array.from(map.values());
  });

  readonly hasMarketplaceItems = computed(() => this.marketplaceSellerGroups().length > 0);

  readonly nonMarketplaceItems = computed(() =>
    (this.cartService.cart()?.items ?? []).filter(i => !i.isMarketplace)
  );

  ngOnInit(): void {
    this.cartService.loadCart().subscribe({
      next: () => this.loading.set(false),
      error: () => this.loading.set(false)
    });
  }

  protected updateQuantity(item: CartItem, qty: number): void {
    if (qty === 0) {
      this.removeItem(item.productId);
    } else {
      this.cartService.updateItem({ itemId: item.productId, quantity: qty }).subscribe({
        error: (err) => this._notifications.error(extractApiError(err, 'Could not update item quantity'))
      });
    }
  }

  protected removeItem(productId: number): void {
    this.cartService.removeItem(productId).subscribe({
      error: (err) => this._notifications.error(extractApiError(err, 'Could not remove item from basket'))
    });
  }
}
