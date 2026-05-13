import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CartService } from '../../core/services/cart.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { QuantityStepperComponent } from '../../shared/components/quantity-stepper/quantity-stepper.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { CartItem } from '../../core/models/cart.model';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, QuantityStepperComponent, BreadcrumbComponent],
  templateUrl: './cart.component.html',
  styleUrl: './cart.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CartComponent implements OnInit {
  protected readonly cartService = inject(CartService);
  protected loading = signal(true);

  ngOnInit(): void {
    this.cartService.loadCart().subscribe({
      next: () => this.loading.set(false),
      error: () => this.loading.set(false)
    });
  }

  protected updateQuantity(item: CartItem, qty: number): void {
    if (qty === 0) {
      this.removeItem(item.id);
    } else {
      this.cartService.updateItem({ itemId: item.id, quantity: qty }).subscribe();
    }
  }

  protected removeItem(itemId: number): void {
    this.cartService.removeItem(itemId).subscribe();
  }
}
