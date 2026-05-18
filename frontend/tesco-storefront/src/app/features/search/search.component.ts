import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CatalogueService } from '../../core/services/catalogue.service';
import { ProductCardComponent } from '../../shared/components/product-card/product-card.component';
import { PaginationComponent } from '../../shared/components/pagination/pagination.component';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { PagedResult, ProductSummary } from '../../core/models/catalogue.model';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule, ProductCardComponent, PaginationComponent, SpinnerComponent],
  templateUrl: './search.component.html',
  styleUrl: './search.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SearchComponent implements OnInit {
  private readonly _route = inject(ActivatedRoute);
  private readonly _router = inject(Router);
  private readonly _catalogue = inject(CatalogueService);

  protected query = signal('');
  protected brandFilter = signal('');
  protected result = signal<PagedResult<ProductSummary> | null>(null);
  protected loading = signal(false);
  protected currentPage = signal(1);
  protected sortBy = signal('relevance');

  readonly sortOptions = [
    { value: 'relevance', label: 'Relevance' },
    { value: 'price', label: 'Price: Low to High' },
    { value: 'price_desc', label: 'Price: High to Low' },
    { value: 'rating', label: 'Customer Rating' }
  ];

  ngOnInit(): void {
    this._route.queryParams.subscribe(params => {
      const brand = params['brand'] ?? '';
      this.brandFilter.set(brand);
      const q = params['q'] ?? brand;
      this.query.set(q);
      this.currentPage.set(+(params['page'] ?? 1));
      if (q) {
        this._search();
      } else {
        this.result.set(null);
      }
    });
  }

  private _search(): void {
    this.loading.set(true);
    this._catalogue.search({
      query: this.query(),
      brand: this.brandFilter(),
      pageNumber: this.currentPage(),
      pageSize: 24,
      sortBy: this.sortBy()
    }).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onPageChange(page: number): void {
    this._router.navigate([], { queryParams: { q: this.query(), page }, queryParamsHandling: 'merge' });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  protected onSortChange(): void { this.currentPage.set(1); this._search(); }
}
