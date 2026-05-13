import { ChangeDetectionStrategy, Component, Input, Output, EventEmitter, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ProductSummary } from '../../../core/models/catalogue.model';
import { CartService } from '../../../core/services/cart.service';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './product-card.component.html',
  styleUrl: './product-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductCardComponent {
  @Input({ required: true }) product!: ProductSummary;
  @Output() addedToCart = new EventEmitter<void>();

  private readonly _cart = inject(CartService);
  private readonly _notifications = inject(NotificationService);

  protected adding = false;

  protected addToCart(event: Event): void {
    event.preventDefault();
    event.stopPropagation();
    this.adding = true;
    this._cart.addItem({ productId: this.product.id, quantity: 1 }).subscribe({
      next: () => {
        this.adding = false;
        this._notifications.success(`${this.product.name} added to basket`);
        this.addedToCart.emit();
      },
      error: () => {
        this.adding = false;
        this._notifications.error('Could not add item to basket');
      }
    });
  }

  get displayPrice(): number {
    return this.product.clubcardPrice ?? this.product.price;
  }
}
