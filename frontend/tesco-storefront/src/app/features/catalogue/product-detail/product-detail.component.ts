import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { CartService } from '../../../core/services/cart.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { QuantityStepperComponent } from '../../../shared/components/quantity-stepper/quantity-stepper.component';
import { ProductDetail } from '../../../core/models/catalogue.model';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, QuantityStepperComponent],
  templateUrl: './product-detail.component.html',
  styleUrl: './product-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductDetailComponent implements OnInit {
  private readonly _route = inject(ActivatedRoute);
  private readonly _catalogue = inject(CatalogueService);
  private readonly _cart = inject(CartService);
  private readonly _notifications = inject(NotificationService);

  protected product = signal<ProductDetail | null>(null);
  protected loading = signal(true);
  protected error = signal(false);
  protected quantity = signal(1);
  protected selectedImage = signal(0);
  protected selectedTab = signal<'description' | 'nutrition' | 'reviews'>('description');
  protected adding = signal(false);

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      this.loading.set(true);
      this._catalogue.getProductById(+p['id']).subscribe({
        next: p => { this.product.set(p); this.loading.set(false); },
        error: () => { this.error.set(true); this.loading.set(false); }
      });
    });
  }

  protected addToCart(): void {
    if (!this.product()) return;
    this.adding.set(true);
    this._cart.addItem({ productId: this.product()!.id, quantity: this.quantity() }).subscribe({
      next: () => {
        this.adding.set(false);
        this._notifications.success(`${this.product()!.name} added to basket`);
      },
      error: () => {
        this.adding.set(false);
        this._notifications.error('Could not add to basket');
      }
    });
  }

  get breadcrumb() {
    const p = this.product();
    return [
      { label: 'Home', url: '/' },
      { label: p?.categoryName ?? 'Products', url: '/departments' },
      { label: p?.name ?? '' }
    ];
  }
}
