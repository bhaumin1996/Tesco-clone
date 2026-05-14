import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CartService } from '../../../core/services/cart.service';

@Component({
  selector: 'app-basket-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './basket-sidebar.component.html',
  styleUrl: './basket-sidebar.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class BasketSidebarComponent {
  protected readonly cart = inject(CartService);
}
