import { ChangeDetectionStrategy, Component, inject, Input, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { ProductCardComponent } from '../../../shared/components/product-card/product-card.component';
import { PaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { ProductSummary, PagedResult } from '../../../core/models/catalogue.model';

@Component({
  selector: 'app-category',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCardComponent, PaginationComponent, SpinnerComponent, BreadcrumbComponent],
  templateUrl: './category.component.html',
  styleUrl: './category.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CategoryComponent implements OnInit {
  private readonly _catalogue = inject(CatalogueService);
  private readonly _route = inject(ActivatedRoute);

  protected categoryId = signal<number>(0);
  protected departmentSlug = signal('');
  protected categoryName = signal('');
  protected result = signal<PagedResult<ProductSummary> | null>(null);
  protected loading = signal(true);
  protected currentPage = signal(1);
  protected sortBy = signal('relevance');

  readonly sortOptions = [
    { value: 'relevance', label: 'Relevance' },
    { value: 'price', label: 'Price: Low to High' },
    { value: 'price_desc', label: 'Price: High to Low' },
    { value: 'rating', label: 'Customer Rating' }
  ];

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      this.departmentSlug.set(p['deptSlug'] ?? '');
      this.categoryName.set((p['categorySlug'] ?? '').replace(/-/g, ' '));
    });
    this._route.queryParams.subscribe(q => {
      this.categoryId.set(+(q['categoryId'] ?? 1));
      this.loadProducts();
    });
  }

  protected loadProducts(): void {
    this.loading.set(true);
    this._catalogue.getProducts(this.categoryId(), this.currentPage(), 24).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onPageChange(page: number): void {
    this.currentPage.set(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
    this.loadProducts();
  }

  get breadcrumb() {
    return [
      { label: 'Home', url: '/' },
      { label: 'All Departments', url: '/departments' },
      { label: this.departmentSlug(), url: `/departments/${this.departmentSlug()}` },
      { label: this.categoryName() }
    ];
  }
}
