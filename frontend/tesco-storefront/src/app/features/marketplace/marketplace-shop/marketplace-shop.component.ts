import { ChangeDetectionStrategy, Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MarketplaceService } from '../../../core/services/marketplace.service';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { ProductSummary, PagedResult } from '../../../core/models/catalogue.model';
import { ProductCardComponent } from '../../../shared/components/product-card/product-card.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { PaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-marketplace-shop',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule, ProductCardComponent, BreadcrumbComponent, PaginationComponent, SpinnerComponent],
  templateUrl: './marketplace-shop.component.html',
  styleUrl: './marketplace-shop.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceShopComponent implements OnInit {
  private readonly _marketplace = inject(MarketplaceService);
  private readonly _catalogue = inject(CatalogueService);
  private readonly _route = inject(ActivatedRoute);

  protected loading = signal(true);
  protected result = signal<PagedResult<ProductSummary> | null>(null);
  protected currentPage = signal(1);
  protected minPrice = signal<number | undefined>(undefined);
  protected maxPrice = signal<number | undefined>(undefined);
  protected sortBy = signal('relevance');
  protected categorySlug = signal<string | undefined>(undefined);

  readonly pageSize = 24;

  readonly sortOptions = [
    { value: 'relevance', label: 'Relevance' },
    { value: 'price',     label: 'Price: Low to High' },
    { value: 'name',      label: 'Name A-Z' },
    { value: 'rating',    label: 'Top Rated' },
  ];

  readonly breadcrumbs = computed(() => {
    const base = [{ label: 'Home', url: '/' }, { label: 'Marketplace', url: '/marketplace' }];
    const slug = this.categorySlug();
    if (slug) base.push({ label: slug.replace(/-/g, ' '), url: '' });
    return base;
  });

  readonly totalPages = computed(() => this.result()?.totalPages ?? 1);
  readonly totalCount = computed(() => this.result()?.totalCount ?? 0);

  ngOnInit(): void {
    this._route.paramMap.subscribe(params => {
      const slug = params.get('category');
      this.categorySlug.set(slug ?? undefined);
      this.currentPage.set(1);
      this._load();
    });
  }

  private _load(): void {
    this.loading.set(true);
    this._marketplace.searchMarketplace(
      undefined, undefined, undefined,
      this.minPrice(), this.maxPrice(),
      this.sortBy(), this.currentPage(), this.pageSize
    ).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected applyFilters(): void {
    this.currentPage.set(1);
    this._load();
  }

  protected onSortChange(value: string): void {
    this.sortBy.set(value);
    this._load();
  }

  protected onPageChange(page: number): void {
    this.currentPage.set(page);
    this._load();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}
