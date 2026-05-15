import { ChangeDetectionStrategy, Component, ElementRef, HostListener, inject, signal } from '@angular/core';
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
  private readonly _elementRef = inject(ElementRef);
  protected readonly auth = inject(AuthService);
  protected readonly cart = inject(CartService);

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent): void {
    const clickedInside = this._elementRef.nativeElement.contains(event.target);
    if (!clickedInside) {
      this.accountMenuOpen.set(false);
      this.mobileMenuOpen.set(false);
      this.moreMenuOpen.set(false);
    }
  }

  protected searchQuery = signal('');
  protected mobileMenuOpen = signal(false);
  protected accountMenuOpen = signal(false);
  protected moreMenuOpen = signal(false);

  protected search(): void {
    const q = this.searchQuery().trim();
    if (q) this._router.navigate(['/search'], { queryParams: { q } });
  }

  protected toggleMobileMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.mobileMenuOpen.update(v => !v);
  }

  protected toggleAccountMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.accountMenuOpen.update(v => !v);
  }

  protected toggleMoreMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.moreMenuOpen.update(v => !v);
  }

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

  protected get visibleDepts() {
    return this.departments.slice(0, 5);
  }

  protected get moreDepts() {
    return this.departments.slice(5);
  }
}
