import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FavouritesService } from '../../../core/services/favourites.service';
import { CartService } from '../../../core/services/cart.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';
import { Favourite } from '../../../core/models/catalogue.model';

@Component({
  selector: 'app-favourites',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, ImageUrlPipe],
  templateUrl: './favourites.component.html',
  styleUrl: './favourites.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class FavouritesComponent implements OnInit {
  private readonly _favourites = inject(FavouritesService);
  private readonly _cart = inject(CartService);
  private readonly _notifications = inject(NotificationService);

  protected loading = signal(true);
  protected error = signal(false);
  protected removingId = signal<number | null>(null);
  protected addingToCartId = signal<number | null>(null);

  readonly favourites = this._favourites.favourites;
  readonly count = this._favourites.count;

  ngOnInit(): void {
    this._favourites.loadFavourites().subscribe({
      next: () => this.loading.set(false),
      error: () => { this.error.set(true); this.loading.set(false); }
    });
  }

  protected removeFromFavourites(fav: Favourite): void {
    this.removingId.set(fav.productId);
    this._favourites.removeFavourite(fav.productId).subscribe({
      next: () => {
        this.removingId.set(null);
        this._notifications.success(`${fav.name} removed from favourites`);
      },
      error: () => {
        this.removingId.set(null);
        this._notifications.error('Could not remove item. Please try again.');
      }
    });
  }

  protected addToCart(fav: Favourite): void {
    if (!fav.isInStock) return;
    this.addingToCartId.set(fav.productId);
    this._cart.addItem({ productId: fav.productId, quantity: 1 }).subscribe({
      next: () => {
        this.addingToCartId.set(null);
        this._notifications.success(`${fav.name} added to basket`);
      },
      error: (err) => {
        this.addingToCartId.set(null);
        if (err.status !== 401) {
          this._notifications.error('Could not add to basket');
        }
      }
    });
  }
}
