import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { CartService } from '../../../core/services/cart.service';
import { FavouritesService } from '../../../core/services/favourites.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { QuantityStepperComponent } from '../../../shared/components/quantity-stepper/quantity-stepper.component';
import { ProductDetail, UserRatingStatus } from '../../../core/models/catalogue.model';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, QuantityStepperComponent, ImageUrlPipe],
  templateUrl: './product-detail.component.html',
  styleUrl: './product-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductDetailComponent implements OnInit {
  private readonly _route = inject(ActivatedRoute);
  private readonly _catalogue = inject(CatalogueService);
  private readonly _cart = inject(CartService);
  private readonly _favourites = inject(FavouritesService);
  private readonly _notifications = inject(NotificationService);

  protected product = signal<ProductDetail | null>(null);
  protected loading = signal(true);
  protected error = signal(false);
  protected quantity = signal(1);
  protected selectedImage = signal(0);
  protected selectedTab = signal<'description' | 'nutrition' | 'reviews'>('description');
  protected adding = signal(false);

  // Rating state
  protected ratingStatus = signal<UserRatingStatus | null>(null);
  protected pendingRating = signal(0);
  protected submittingRating = signal(false);

  // Favourite state
  protected isFavourited = signal(false);
  protected togglingFavourite = signal(false);

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      const id = +p['id'];
      this.loading.set(true);
      this.ratingStatus.set(null);
      this.isFavourited.set(false);
      this._catalogue.getProductById(id).subscribe({
        next: product => {
          this.product.set(product);
          this._catalogue.getVariants(id).subscribe({
            next: variants => {
              this.product.update(existing => existing ? { ...existing, variants } : null);
              this.loading.set(false);
            },
            error: () => this.loading.set(false)
          });
          // Load rating status (silently ignored if not authenticated)
          this._catalogue.getUserRatingStatus(id).subscribe({
            next: status => this.ratingStatus.set(status),
            error: () => { /* unauthenticated — no rating form shown */ }
          });
          // Load favourite status (silently ignored if not authenticated)
          this._favourites.getFavouriteStatus(id).subscribe({
            next: status => this.isFavourited.set(status.isFavourited),
            error: () => { /* unauthenticated — button still shows, will prompt login */ }
          });
        },
        error: () => { this.error.set(true); this.loading.set(false); }
      });
    });
  }

  protected setRating(value: number): void {
    this.pendingRating.set(value);
  }

  protected submitRating(): void {
    const product = this.product();
    const rating = this.pendingRating();
    if (!product || rating < 1 || rating > 5) return;
    this.submittingRating.set(true);
    this._catalogue.submitRating(product.id, rating).subscribe({
      next: () => {
        this.submittingRating.set(false);
        this.ratingStatus.set({ canRate: true, hasRated: true, existingRating: rating });
        this.product.update(p => p
          ? { ...p, reviewCount: p.reviewCount + 1 }
          : p);
        this._notifications.success('Thank you for your rating!');
      },
      error: () => {
        this.submittingRating.set(false);
        this._notifications.error('Could not submit your rating. Please try again.');
      }
    });
  }

  protected toggleFavourite(): void {
    const product = this.product();
    if (!product || this.togglingFavourite()) return;
    this.togglingFavourite.set(true);

    if (this.isFavourited()) {
      this._favourites.removeFavourite(product.id).subscribe({
        next: () => {
          this.isFavourited.set(false);
          this.togglingFavourite.set(false);
          this._notifications.success(`${product.name} removed from favourites`);
        },
        error: (err) => {
          this.togglingFavourite.set(false);
          if (err.status !== 401) this._notifications.error('Could not update favourites');
        }
      });
    } else {
      this._favourites.addFavourite(product.id).subscribe({
        next: () => {
          this.isFavourited.set(true);
          this.togglingFavourite.set(false);
          this._notifications.success(`${product.name} saved to favourites`);
        },
        error: (err) => {
          this.togglingFavourite.set(false);
          if (err.status !== 401) this._notifications.error('Could not update favourites');
        }
      });
    }
  }

  protected addToCart(): void {
    if (!this.product()) return;
    this.adding.set(true);
    this._cart.addItem({ productId: this.product()!.id, quantity: this.quantity() }).subscribe({
      next: () => {
        this.adding.set(false);
        this._notifications.success(`${this.product()!.name} added to basket`);
      },
      error: (err) => {
        this.adding.set(false);
        if (err.status !== 401) {
          this._notifications.error('Could not add to basket');
        }
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
