import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MarketplaceService } from '../../../core/services/marketplace.service';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { ProductSummary, PagedResult, Category } from '../../../core/models/catalogue.model';
import { ProductCardComponent } from '../../../shared/components/product-card/product-card.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-marketplace-landing',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCardComponent, BreadcrumbComponent, SpinnerComponent],
  templateUrl: './marketplace-landing.component.html',
  styleUrl: './marketplace-landing.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceLandingComponent implements OnInit {
  private readonly _marketplace = inject(MarketplaceService);
  private readonly _catalogue = inject(CatalogueService);

  protected loading = signal(true);
  protected trendingProducts = signal<ProductSummary[]>([]);
  protected categories = signal<Category[]>([]);

  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'Marketplace' }
  ];

  readonly trustBadges = [
    { icon: '🛒', title: 'Earn Clubcard Points', desc: '1 point per £1 spent on marketplace' },
    { icon: '🔒', title: 'Tesco Guarantee', desc: "If it's wrong, we'll make it right" },
    { icon: '↩️', title: 'Easy Returns', desc: '30-day hassle-free returns' },
    { icon: '⭐', title: 'Trusted Sellers', desc: 'Verified and rated by customers' },
  ];

  ngOnInit(): void {
    this._marketplace.searchMarketplace(undefined, undefined, undefined, undefined, undefined, 'relevance', 1, 8).subscribe({
      next: r => { this.trendingProducts.set(r.items); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
    this._catalogue.getCategories().subscribe({
      next: cats => this.categories.set(cats.slice(0, 8)),
      error: () => {}
    });
  }
}
