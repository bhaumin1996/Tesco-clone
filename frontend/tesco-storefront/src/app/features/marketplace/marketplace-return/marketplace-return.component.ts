import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { MarketplaceService } from '../../../core/services/marketplace.service';
import { Order, OrderItem } from '../../../core/models/order.model';
import { MarketplaceReturn } from '../../../core/models/marketplace.model';

const RETURN_REASONS = [
  'Item not as described',
  'Item arrived damaged',
  'Item not received',
  'Wrong item sent',
  'Changed my mind',
  'Item is faulty',
  'Other'
] as const;

@Component({
  selector: 'app-marketplace-return',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule, BreadcrumbComponent, SpinnerComponent],
  templateUrl: './marketplace-return.component.html',
  styleUrl: './marketplace-return.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceReturnComponent implements OnInit {
  private readonly _marketplace = inject(MarketplaceService);
  private readonly _route = inject(ActivatedRoute);

  readonly orderId = signal<number>(0);
  readonly sellerId = signal<number | null>(null);
  readonly loading = signal(true);
  readonly submitting = signal(false);
  readonly submitted = signal(false);
  readonly order = signal<Order | null>(null);
  readonly error = signal<string | null>(null);
  readonly submitError = signal<string | null>(null);
  readonly existingReturns = signal<MarketplaceReturn[]>([]);

  readonly returnReasons = RETURN_REASONS;
  readonly selectedItemId = signal<number | null>(null);
  readonly selectedReason = signal<string>('');

  readonly breadcrumbs = computed(() => [
    { label: 'Home', url: '/' },
    { label: 'My Account', url: '/account' },
    { label: 'Marketplace Orders', url: '/account/orders/marketplace' },
    { label: 'Raise Return' }
  ]);

  readonly marketplaceItems = computed(() => {
    const sid = this.sellerId();
    const items = this.order()?.items ?? [];
    return sid
      ? items.filter(i => i.isMarketplace && i.sellerId === sid)
      : items.filter(i => i.isMarketplace);
  });

  readonly selectedItem = computed(() =>
    this.marketplaceItems().find(i => i.id === this.selectedItemId()) ?? null
  );

  readonly canSubmit = computed(() =>
    this.selectedItemId() !== null && this.selectedReason().length > 0 && !this.submitting()
  );

  ngOnInit(): void {
    const id = Number(this._route.snapshot.paramMap.get('id'));
    const sid = this._route.snapshot.queryParamMap.get('sellerId');
    this.orderId.set(id);
    if (sid) this.sellerId.set(Number(sid));

    this._marketplace.getMarketplaceOrderById(id).subscribe({
      next: order => {
        this.order.set(order);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Could not load order details.');
        this.loading.set(false);
      }
    });

    this._marketplace.getMyReturns().subscribe({
      next: returns => this.existingReturns.set(returns),
      error: () => {}
    });
  }

  getReturnForItem(itemId: number): MarketplaceReturn | undefined {
    return this.existingReturns().find(r => r.orderLineId === itemId);
  }

  selectItem(item: OrderItem): void {
    if (this.getReturnForItem(item.id)) return;
    this.selectedItemId.set(item.id);
  }

  submit(): void {
    const itemId = this.selectedItemId();
    const reason = this.selectedReason();
    if (!itemId || !reason) return;

    this.submitting.set(true);
    this.submitError.set(null);

    this._marketplace.raiseReturn(itemId, reason).subscribe({
      next: () => {
        this.submitting.set(false);
        this.submitted.set(true);
      },
      error: () => {
        this.submitting.set(false);
        this.submitError.set('Could not submit your return request. Please try again.');
      }
    });
  }

  getStatusStep(status: string): number {
    const steps: Record<string, number> = {
      'Requested': 1, 'Pending': 1,
      'SellerResponded': 2, 'Accepted': 2, 'Disputed': 2,
      'AdminReviewing': 2,
      'Resolved': 3, 'Refunded': 3
    };
    return steps[status] ?? 1;
  }
}
