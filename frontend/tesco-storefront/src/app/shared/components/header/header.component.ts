import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { CartService } from '../../../core/services/cart.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, FormsModule],
  templateUrl: './header.component.html',
  styleUrl: './header.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HeaderComponent {
  private readonly _router = inject(Router);
  protected readonly auth = inject(AuthService);
  protected readonly cart = inject(CartService);

  protected searchQuery = signal('');
  protected mobileMenuOpen = signal(false);
  protected accountMenuOpen = signal(false);

  protected search(): void {
    const q = this.searchQuery().trim();
    if (q) this._router.navigate(['/search'], { queryParams: { q } });
  }

  protected toggleMobileMenu(): void { this.mobileMenuOpen.update(v => !v); }
  protected toggleAccountMenu(): void { this.accountMenuOpen.update(v => !v); }

  protected logout(): void {
    this.accountMenuOpen.set(false);
    this.auth.logout();
  }

  protected departments = [
    { name: 'Fresh Food', slug: 'fresh-food' },
    { name: 'Bakery', slug: 'bakery' },
    { name: 'Frozen', slug: 'frozen' },
    { name: 'Drinks', slug: 'drinks' },
    { name: 'Health & Beauty', slug: 'health-beauty' },
    { name: 'Household', slug: 'household' },
    { name: 'Baby & Toddler', slug: 'baby-toddler' },
    { name: 'Pets', slug: 'pets' },
    { name: 'Home', slug: 'home' },
    { name: 'Electronics', slug: 'electronics' }
  ];
}
