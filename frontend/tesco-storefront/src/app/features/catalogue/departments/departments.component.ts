import { ChangeDetectionStrategy, Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { Department } from '../../../core/models/catalogue.model';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

@Component({
  selector: 'app-departments',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, ImageUrlPipe],
  template: `
    <div class="page-container page-content departments-page">
      <app-breadcrumb [items]="[{ label: 'Home', url: '/' }, { label: 'All Departments' }]" />

      <!-- Premium Immersive Hero -->
      <header class="depts-hero animate-fade-in">
        <div class="depts-hero__content">
          <span class="depts-hero__badge">Tesco Shop</span>
          <h1 class="depts-hero__title">Explore All Departments</h1>
          <p class="depts-hero__subtitle">
            Browse through our wide selection of fresh food, bakery, household essentials, pet items, and much more. All gathered from trusted British farms and top brands.
          </p>

          <!-- Glassmorphic Search Bar -->
          <div class="search-container">
            <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
            <input 
              type="text" 
              class="search-input" 
              placeholder="Search departments (e.g. Fresh Food, Bakery...)"
              [value]="searchTerm()"
              (input)="onSearchInput($event)"
            />
            @if (searchTerm()) {
              <button class="search-clear" (click)="clearSearch()" title="Clear search">✕</button>
            }
          </div>
        </div>

        <!-- Glassmorphic Stats Overlay -->
        <div class="depts-hero__stats">
          <div class="stat-card">
            <span class="stat-num">{{ departments().length }}</span>
            <span class="stat-label">Departments</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-card">
            <span class="stat-num">{{ totalCategories() }}</span>
            <span class="stat-label">Active Categories</span>
          </div>
        </div>
      </header>

      @if (loading()) {
        <div class="spinner-container">
          <app-spinner />
        </div>
      } @else {
        <!-- Grid Section -->
        @if (filteredDepartments().length > 0) {
          <div class="depts-grid">
            @for (dept of filteredDepartments(); track dept.id; let i = $index) {
              <a [routerLink]="['/departments', dept.slug]" class="dept-card animate-slide-up" [style.animation-delay]="i * 40 + 'ms'">
                <div class="dept-card__img-container">
                  @if (dept.imageUrl) {
                    <img [src]="dept.imageUrl | imageUrl" [alt]="dept.name" loading="lazy" class="dept-card__img" />
                  } @else {
                    <div class="dept-card__fallback">
                      <span class="fallback-icon">🛒</span>
                    </div>
                  }
                  <div class="dept-card__overlay"></div>
                  <!-- Floating category badge -->
                  <span class="dept-card__badge">
                    {{ getCategoryCount(dept) }} {{ getCategoryCount(dept) === 1 ? 'Category' : 'Categories' }}
                  </span>
                </div>
                
                <div class="dept-card__body">
                  <div class="dept-card__info">
                    <h2 class="dept-card__name">{{ dept.name }}</h2>
                    <p class="dept-card__description">{{ getFeaturedCategories(dept.slug) }}</p>
                  </div>
                  
                  <div class="dept-card__footer">
                    <span class="dept-card__cta">
                      Explore Department 
                      <span class="cta-arrow">→</span>
                    </span>
                  </div>
                </div>
              </a>
            }
          </div>
        } @else {
          <!-- Empty State -->
          <div class="empty-state animate-fade-in">
            <div class="empty-state__icon">🔍</div>
            <h3 class="empty-state__title">No Departments Found</h3>
            <p class="empty-state__message">We couldn't find any department matching "{{ searchTerm() }}". Please check spelling or try a different term.</p>
            <button class="btn btn--primary" (click)="clearSearch()">Reset Search</button>
          </div>
        }
      }
    </div>
  `,
  styles: [`
    // Variables & Tokens
    :host {
      --primary: #005DAA;
      --primary-dark: #003f7d;
      --primary-light: #e8f2fc;
      --accent-red: #EE1C2E;
      --accent-red-dark: #b5122b;
      --clubcard-yellow: #ffdd00;
      --text-main: #1A1A1A;
      --text-muted: #555555;
      --radius-card: 20px;
      --shadow-card: 0 8px 30px rgba(0, 0, 0, 0.03);
      --shadow-hover: 0 20px 40px rgba(0, 93, 170, 0.08);
      --transition-main: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .departments-page {
      padding-bottom: 4rem;
    }

    // Hero Section
    .depts-hero {
      position: relative;
      margin: 1.5rem 0 3rem;
      padding: 3rem 2rem 4rem;
      border-radius: 24px;
      background: linear-gradient(135deg, #09152e 0%, #003f7d 50%, #005DAA 100%);
      color: #ffffff;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      box-shadow: 0 15px 35px rgba(0, 63, 125, 0.15);

      &::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: radial-gradient(circle, rgba(238, 28, 46, 0.08) 0%, rgba(0, 0, 0, 0) 60%);
        pointer-events: none;
      }
    }

    .depts-hero__content {
      position: relative;
      z-index: 2;
      max-width: 720px;
    }

    .depts-hero__badge {
      display: inline-block;
      background: rgba(255, 255, 255, 0.12);
      backdrop-filter: blur(10px);
      padding: 0.35rem 1rem;
      border-radius: 50px;
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      margin-bottom: 1.25rem;
      border: 1px solid rgba(255, 255, 255, 0.15);
      color: var(--clubcard-yellow);
    }

    .depts-hero__title {
      font-size: 2.25rem;
      font-weight: 850;
      letter-spacing: -0.02em;
      margin-bottom: 1rem;
      line-height: 1.2;
    }

    .depts-hero__subtitle {
      font-size: 0.95rem;
      line-height: 1.6;
      color: rgba(255, 255, 255, 0.85);
      margin-bottom: 2rem;
    }

    // Glassmorphic Search Bar
    .search-container {
      position: relative;
      width: 100%;
      max-width: 500px;
      margin: 0 auto;
      z-index: 5;
    }

    .search-icon {
      position: absolute;
      left: 1.25rem;
      top: 50%;
      transform: translateY(-50%);
      width: 1.15rem;
      height: 1.15rem;
      color: rgba(255, 255, 255, 0.6);
      pointer-events: none;
      transition: var(--transition-main);
    }

    .search-input {
      width: 100%;
      padding: 1.1rem 3.5rem 1.1rem 3.25rem;
      font-size: 0.95rem;
      background: rgba(255, 255, 255, 0.12);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1.5px solid rgba(255, 255, 255, 0.2);
      border-radius: 50px;
      color: #ffffff;
      transition: var(--transition-main);
      outline: none;

      &::placeholder {
        color: rgba(255, 255, 255, 0.6);
      }

      &:focus {
        background: rgba(255, 255, 255, 0.22);
        border-color: rgba(255, 255, 255, 0.45);
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15), 0 0 0 3px rgba(255, 221, 0, 0.3);
        
        + .search-icon {
          color: var(--clubcard-yellow);
          transform: translateY(-50%) scale(1.1);
        }
      }
    }

    .search-clear {
      position: absolute;
      right: 1.25rem;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(255, 255, 255, 0.25);
      border: none;
      width: 1.5rem;
      height: 1.5rem;
      border-radius: 50%;
      color: white;
      font-size: 0.75rem;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: var(--transition-main);

      &:hover {
        background: var(--accent-red);
        transform: translateY(-50%) scale(1.1);
      }
    }

    // Stats Banner
    .depts-hero__stats {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      background: rgba(255, 255, 255, 0.04);
      border-top: 1px solid rgba(255, 255, 255, 0.08);
      backdrop-filter: blur(8px);
      padding: 0.85rem 2rem;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 3rem;
    }

    .stat-card {
      display: flex;
      align-items: center;
      gap: 0.65rem;
    }

    .stat-num {
      font-size: 1.35rem;
      font-weight: 900;
      color: var(--clubcard-yellow);
    }

    .stat-label {
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: rgba(255, 255, 255, 0.75);
    }

    .stat-divider {
      width: 1px;
      height: 1.5rem;
      background: rgba(255, 255, 255, 0.12);
    }

    // Spinner Container
    .spinner-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 250px;
    }

    // Grid Layout
    .depts-grid {
      display: grid;
      grid-template-columns: repeat(1, 1fr);
      gap: 1.5rem;
      margin-top: 2rem;
    }

    @media (min-width: 580px) {
      .depts-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (min-width: 850px) {
      .depts-grid {
        grid-template-columns: repeat(3, 1fr);
        gap: 1.75rem;
      }
    }

    @media (min-width: 1200px) {
      .depts-grid {
        grid-template-columns: repeat(4, 1fr);
        gap: 2rem;
      }
    }

    // Premium Department Cards
    .dept-card {
      text-decoration: none;
      color: inherit;
      background: #ffffff;
      border-radius: var(--radius-card);
      border: 1px solid rgba(0, 0, 0, 0.05);
      display: flex;
      flex-direction: column;
      overflow: hidden;
      box-shadow: var(--shadow-card);
      transition: var(--transition-main);
      height: 100%;

      &:hover {
        transform: translateY(-8px);
        box-shadow: var(--shadow-hover);
        border-color: rgba(0, 93, 170, 0.2);

        .dept-card__img {
          transform: scale(1.08);
        }

        .dept-card__name {
          color: var(--primary);
        }

        .dept-card__cta {
          color: var(--accent-red);
          
          .cta-arrow {
            transform: translateX(6px);
          }
        }
      }
    }

    .dept-card__img-container {
      position: relative;
      aspect-ratio: 16/10;
      background: #f5f7fa;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }

    .dept-card__img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .dept-card__fallback {
      font-size: 3rem;
    }

    .dept-card__overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(to bottom, rgba(0,0,0,0) 50%, rgba(0,0,0,0.5) 100%);
      pointer-events: none;
    }

    .dept-card__badge {
      position: absolute;
      top: 1rem;
      right: 1rem;
      background: rgba(255, 255, 255, 0.9);
      backdrop-filter: blur(8px);
      -webkit-backdrop-filter: blur(8px);
      color: var(--primary-dark);
      padding: 0.3rem 0.85rem;
      border-radius: 50px;
      font-size: 0.75rem;
      font-weight: 750;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .dept-card__body {
      padding: 1.5rem;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      flex-grow: 1;
    }

    .dept-card__info {
      margin-bottom: 1.25rem;
    }

    .dept-card__name {
      font-size: 1.15rem;
      font-weight: 800;
      color: var(--text-main);
      margin-bottom: 0.45rem;
      line-height: 1.25;
      transition: var(--transition-main);
    }

    .dept-card__description {
      font-size: 0.825rem;
      color: var(--text-muted);
      line-height: 1.45;
    }

    .dept-card__footer {
      border-top: 1px solid rgba(0, 0, 0, 0.04);
      padding-top: 1rem;
      margin-top: auto;
    }

    .dept-card__cta {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      font-size: 0.825rem;
      font-weight: 750;
      color: var(--primary);
      transition: var(--transition-main);

      .cta-arrow {
        font-size: 1rem;
        transition: var(--transition-main);
      }
    }

    // Empty State Style
    .empty-state {
      background: #ffffff;
      border-radius: 20px;
      border: 1px solid rgba(0, 0, 0, 0.05);
      padding: 4rem 2rem;
      text-align: center;
      box-shadow: var(--shadow-card);
      max-width: 500px;
      margin: 3rem auto 0;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    .empty-state__icon {
      font-size: 3.5rem;
      margin-bottom: 1rem;
    }

    .empty-state__title {
      font-size: 1.25rem;
      font-weight: 800;
      color: var(--text-main);
      margin-bottom: 0.5rem;
    }

    .empty-state__message {
      font-size: 0.875rem;
      color: var(--text-muted);
      margin-bottom: 1.5rem;
      line-height: 1.5;
    }

    // Micro-Animations
    .animate-fade-in {
      animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    .animate-slide-up {
      animation: slideUp 0.7s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @keyframes slideUp {
      from { opacity: 0; transform: translateY(24px); }
      to { opacity: 1; transform: translateY(0); }
    }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DepartmentsComponent implements OnInit {
  private readonly _catalogue = inject(CatalogueService);
  protected departments = signal<Department[]>([]);
  protected loading = signal(true);

  // Search filter signals
  protected searchTerm = signal('');

  // Computed signals
  protected filteredDepartments = computed(() => {
    const term = this.searchTerm().toLowerCase().trim();
    if (!term) return this.departments();
    return this.departments().filter(d => 
      d.name.toLowerCase().includes(term) || 
      this.getFeaturedCategories(d.slug).toLowerCase().includes(term)
    );
  });

  protected totalCategories = computed(() => {
    return this.departments().reduce((acc, dept) => acc + this.getCategoryCount(dept), 0);
  });

  protected getCategoryCount(dept: Department): number {
    if (dept.categoryCount !== undefined && dept.categoryCount !== null && !isNaN(dept.categoryCount)) {
      return dept.categoryCount;
    }
    const maps: Record<string, number> = {
      'fresh-food': 10,
      'bakery': 6,
      'frozen-food': 8,
      'food-cupboard': 10,
      'drinks': 5,
      'beer-wine-spirits': 9,
      'baby-toddler': 6,
      'health-beauty': 11,
      'household': 7,
      'pets': 4,
      'home-garden': 8,
      'clothing': 7,
      'toys': 7,
      'entertainment': 4,
      'sports-leisure': 6,
      'technology': 7
    };
    return maps[dept.slug] || 0;
  }

  ngOnInit(): void {
    this._catalogue.getDepartments().subscribe({
      next: d => { 
        this.departments.set(d); 
        this.loading.set(false); 
      },
      error: () => this.loading.set(false)
    });
  }

  protected onSearchInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.searchTerm.set(value);
  }

  protected clearSearch(): void {
    this.searchTerm.set('');
  }

  protected getFeaturedCategories(slug: string): string {
    const maps: Record<string, string> = {
      'fresh-food': 'Fruit & Veg, Meat & Fish, Eggs & Dairy, Deli, Fresh Salads & Herbs...',
      'bakery': 'Sliced Bread, Morning Pastries, Bakery Rolls, Sweet Cakes & Biscuits...',
      'frozen-food': 'Ice Cream & Lollies, Frozen Pizza, Ready Meals, Veg & Crispy Sides...',
      'food-cupboard': 'Pasta & Basmati Rice, Baked Beans, Cereals, Rich Coffee & Tea...',
      'drinks': 'Fizzy Sodas, Squeezed Juices, Double Strength Squash, Mineral Water...',
      'beer-wine-spirits': 'Belgian Lager, Stout, Red & White Wine, Dry Gin, Premium Vodka...',
      'baby-toddler': 'Baby Formula, Sensitive Wipes, Nappies, Health & Toiletries...',
      'health-beauty': 'Hand Wash, Anti-Dandruff Shampoo, Dental, Skin Care, Grooming...',
      'household': 'Cleaning Sprays, Laundry Liquid, Bleach, Soft Toilet Tissue...',
      'pets': 'Dog & Cat Food, BOGO Pet Treats, Chews & Accessories...'
    };
    return maps[slug] || 'Browse all premium categories and products...';
  }
}

