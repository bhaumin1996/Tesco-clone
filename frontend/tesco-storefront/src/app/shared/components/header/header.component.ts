import { ChangeDetectionStrategy, Component, computed, ElementRef, HostListener, inject, input, signal, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive, NavigationEnd } from '@angular/router';
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
export class HeaderComponent implements OnInit {
  private readonly _router = inject(Router);
  private readonly _elementRef = inject(ElementRef);
  protected readonly auth = inject(AuthService);
  protected readonly cart = inject(CartService);

  private readonly _currentUrl = signal(this._router.url);
  protected readonly isDashboard = computed(() => this._currentUrl() === '/');

  ngOnInit(): void {
    this._router.events.subscribe(event => {
      if (event instanceof NavigationEnd) {
        this._currentUrl.set(event.urlAfterRedirects);

        let route = this._router.routerState.root;
        while (route.firstChild) {
          route = route.firstChild;
        }
        const q = route.snapshot.queryParams['q'] || '';
        this.searchQuery.set(q);
      }
    });

    // Run initial sync on load
    let route = this._router.routerState.root;
    while (route.firstChild) {
      route = route.firstChild;
    }
    const q = route.snapshot.queryParams['q'] || '';
    this.searchQuery.set(q);
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent): void {
    const clickedInside = this._elementRef.nativeElement.contains(event.target);
    if (!clickedInside) {
      this.accountMenuOpen.set(false);
      this.mobileMenuOpen.set(false);
      this.moreMenuOpen.set(false);
    }
  }

  readonly minimal = input(false);

  protected searchQuery = signal('');
  protected mobileMenuOpen = signal(false);
  protected accountMenuOpen = signal(false);
  protected moreMenuOpen = signal(false);

  protected search(): void {
    const q = this.searchQuery().trim();
    if (q) {
      this._router.navigate(['/search'], { queryParams: { q } });
    } else {
      this._router.navigate(['/departments']);
    }
  }

  protected toggleMobileMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.mobileMenuOpen.update(v => !v);
  }

  protected toggleAccountMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.moreMenuOpen.set(false);
    this.accountMenuOpen.update(v => !v);
  }

  protected toggleMoreMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.accountMenuOpen.set(false);
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
