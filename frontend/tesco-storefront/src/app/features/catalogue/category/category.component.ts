import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute, Router } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { ProductCardComponent } from '../../../shared/components/product-card/product-card.component';
import { PaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { BasketSidebarComponent } from '../../../shared/components/basket-sidebar/basket-sidebar.component';
import { ProductSummary, PagedResult, Category } from '../../../core/models/catalogue.model';

interface FilterSection {
  title: string;
  open: boolean;
  options: string[];
  selected: string[];
}

@Component({
  selector: 'app-category',
  standalone: true,
  imports: [
    CommonModule,
    RouterLink,
    ProductCardComponent,
    PaginationComponent,
    SpinnerComponent,
    BreadcrumbComponent,
    BasketSidebarComponent
  ],
  templateUrl: './category.component.html',
  styleUrl: './category.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CategoryComponent implements OnInit {
  private readonly _catalogue = inject(CatalogueService);
  private readonly _route = inject(ActivatedRoute);
  private readonly _router = inject(Router);

  protected categoryId = signal<number>(0);
  protected departmentSlug = signal('');
  protected departmentName = signal('');
  protected categoryName = signal('');
  protected categories = signal<Category[]>([]);
  protected result = signal<PagedResult<ProductSummary> | null>(null);
  protected loading = signal(true);
  protected currentPage = signal(1);
  protected sortBy = signal('relevance');
  protected filterOpen = signal(false);

  protected filterSections = signal<FilterSection[]>([
    {
      title: 'Price range',
      open: true,
      options: ['Under £5', '£5 – £10', '£10 – £20', 'Over £20'],
      selected: []
    },
    {
      title: 'Offers',
      open: false,
      options: ['Clubcard prices only', 'Special offers', 'Everyday low prices'],
      selected: []
    },
    {
      title: 'Dietary',
      open: false,
      options: ['Vegan', 'Vegetarian', 'Gluten Free', 'Organic', 'Dairy Free'],
      selected: []
    },
    {
      title: 'Brand',
      open: false,
      options: ['Tesco', 'Tesco Finest', 'Warburtons', 'Hovis', 'Kingsmill'],
      selected: []
    }
  ]);

  readonly sortOptions = [
    { value: 'relevance', label: 'Relevance' },
    { value: 'price', label: 'Price: Low to High' },
    { value: 'price_desc', label: 'Price: High to Low' },
    { value: 'rating', label: 'Customer Rating' }
  ];

  ngOnInit(): void {
    this._route.params.subscribe(p => {
      const deptSlug = p['deptSlug'] ?? '';
      const categorySlug = p['categorySlug'] ?? '';
      this.departmentSlug.set(deptSlug);
      this.categoryName.set(this._toTitle(categorySlug || deptSlug));
      this._loadSiblingCategories(deptSlug);
    });

    this._route.queryParams.subscribe(q => {
      this.categoryId.set(+(q['categoryId'] ?? 0));
      this.currentPage.set(1);
      this.loadProducts();
    });
  }

  private _toTitle(slug: string): string {
    return slug.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }

  private _loadSiblingCategories(deptSlug: string): void {
    this._catalogue.getDepartments().subscribe(depts => {
      const dept = depts.find(d => d.slug === deptSlug);
      if (!dept) return;
      this.departmentName.set(dept.name);
      this._catalogue.getCategories(dept.id).subscribe(cats => {
        this.categories.set(cats);
        // If no category is selected, select the first one by default
        if (this.categoryId() === 0 && cats.length > 0) {
          this.selectCategory(cats[0]);
        }
      });
    });
  }

  protected loadProducts(): void {
    if (!this.categoryId()) {
      this.loading.set(false);
      return;
    }
    this.loading.set(true);

    const filters = this._getFilterParams();
    
    this._catalogue.getProducts(this.categoryId(), this.currentPage(), 24, filters).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  private _getFilterParams(): any {
    const sortVal = this.sortBy();
    const params: any = {
      sortBy: sortVal.includes('_') ? sortVal.split('_')[0] : sortVal,
      sortDirection: sortVal.includes('_desc') ? 'desc' : 'asc'
    };

    // Map Price Range
    const priceSection = this.filterSections().find(s => s.title === 'Price range');
    if (priceSection && priceSection.selected.length > 0) {
      const selected = priceSection.selected;
      let min: number | undefined;
      let max: number | undefined;

      if (selected.includes('Under £5')) max = 5;
      if (selected.includes('£5 – £10')) {
        min = min === undefined ? 5 : Math.min(min, 5);
        max = max === undefined ? 10 : Math.max(max, 10);
      }
      if (selected.includes('£10 – £20')) {
        min = min === undefined ? 10 : Math.min(min, 10);
        max = max === undefined ? 20 : Math.max(max, 20);
      }
      if (selected.includes('Over £20')) {
        min = min === undefined ? 20 : Math.min(min, 20);
      }

      if (min !== undefined) params.minPrice = min;
      if (max !== undefined) params.maxPrice = max;
    }

    // Map Offers (Clubcard / Special offers)
    const offersSection = this.filterSections().find(s => s.title === 'Offers');
    if (offersSection && offersSection.selected.length > 0) {
       // Both "Clubcard prices only" and "Special offers" currently map to clubcardPrice filter
       if (offersSection.selected.some(o => o === 'Clubcard prices only' || o === 'Special offers')) {
         params.clubcardOnly = true;
       }
    }

    // Map Dietary
    const dietarySection = this.filterSections().find(s => s.title === 'Dietary');
    if (dietarySection && dietarySection.selected.length > 0) {
      params.dietary = dietarySection.selected;
    }

    // Map Brand
    const brandSection = this.filterSections().find(s => s.title === 'Brand');
    if (brandSection && brandSection.selected.length > 0) {
      params.brands = brandSection.selected;
    }

    return params;
  }

  protected applyFilters(): void {
    this.filterOpen.set(false);
    this.currentPage.set(1);
    this.loadProducts();
  }

  protected selectCategory(cat: Category): void {
    this._router.navigate(
      ['/departments', this.departmentSlug(), cat.slug],
      { queryParams: { categoryId: cat.id } }
    );
  }

  protected onPageChange(page: number): void {
    this.currentPage.set(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
    this.loadProducts();
  }

  protected onSortChange(value: string): void {
    this.sortBy.set(value);
    this.currentPage.set(1);
    this.loadProducts();
  }

  protected toggleFilterSection(index: number): void {
    this.filterSections.update(sections =>
      sections.map((s, i) => i === index ? { ...s, open: !s.open } : s)
    );
  }

  protected toggleFilterOption(sectionIndex: number, option: string): void {
    this.filterSections.update(sections =>
      sections.map((s, i) => {
        if (i !== sectionIndex) return s;
        const selected = s.selected.includes(option)
          ? s.selected.filter(o => o !== option)
          : [...s.selected, option];
        return { ...s, selected };
      })
    );
  }

  protected clearFilters(): void {
    this.filterSections.update(sections => sections.map(s => ({ ...s, selected: [] })));
  }

  protected get fromItem(): number {
    return (this.currentPage() - 1) * 24 + 1;
  }

  protected get toItem(): number {
    const total = this.result()?.totalCount ?? 0;
    return Math.min(this.currentPage() * 24, total);
  }

  protected get activeFilterCount(): number {
    return this.filterSections().reduce((sum, s) => sum + s.selected.length, 0);
  }

  get breadcrumb() {
    return [
      { label: 'Home', url: '/' },
      {
        label: this.departmentName() || this._toTitle(this.departmentSlug()),
        url: `/departments/${this.departmentSlug()}`
      },
      { label: this.categoryName() }
    ];
  }
}
