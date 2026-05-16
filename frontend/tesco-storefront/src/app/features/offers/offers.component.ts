import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PromotionsService } from '../../core/services/promotions.service';
import { Promotion, PromotionsPagedResult } from '../../core/models/promotions.model';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { PaginationComponent } from '../../shared/components/pagination/pagination.component';

type FilterTab = 'All' | 'Percentage Discount' | 'Fixed Amount Discount' | 'Buy X Get Y' | 'Multi Buy' | 'Clubcard Price';
type SortOption = 'default' | 'biggest-saving' | 'ending-soon' | 'newest';

@Component({
  selector: 'app-offers',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, PaginationComponent],
  templateUrl: './offers.component.html',
  styleUrl: './offers.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OffersComponent implements OnInit {
  private readonly _promotions = inject(PromotionsService);

  protected loading = signal(true);
  protected result = signal<PromotionsPagedResult | null>(null);
  protected currentPage = signal(1);
  protected activeFilter = signal<FilterTab>('All');
  protected sortBy = signal<SortOption>('default');

  readonly pageSize = 20;

  readonly filterTabs: { id: FilterTab; icon: string; short: string }[] = [
    { id: 'All',                   icon: 'bi-grid-3x3-gap-fill',          short: 'All offers' },
    { id: 'Percentage Discount',   icon: 'bi-percent',                     short: '% Off' },
    { id: 'Fixed Amount Discount', icon: 'bi-cash-stack',                  short: '£ Off' },
    { id: 'Buy X Get Y',           icon: 'bi-gift-fill',                   short: 'Buy X Get Y' },
    { id: 'Multi Buy',             icon: 'bi-bag-plus-fill',               short: 'Multi Buy' },
    { id: 'Clubcard Price',        icon: 'bi-credit-card-2-front-fill',    short: 'Clubcard' },
  ];

  readonly sortOptions: { value: SortOption; label: string }[] = [
    { value: 'default',        label: 'Featured' },
    { value: 'biggest-saving', label: 'Biggest saving' },
    { value: 'ending-soon',    label: 'Ending soon' },
    { value: 'newest',         label: 'Newest first' },
  ];

  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'Offers' }
  ];

  protected displayItems = computed<Promotion[]>(() => {
    const items = this.result()?.items ?? [];
    const f = this.activeFilter();
    const s = this.sortBy();
    let filtered = f === 'All' ? [...items] : items.filter(p => p.typeName === f);

    if (s === 'biggest-saving') {
      filtered.sort((a, b) => {
        const aVal = a.discountPercent ?? a.discountValue ?? 0;
        const bVal = b.discountPercent ?? b.discountValue ?? 0;
        return bVal - aVal;
      });
    } else if (s === 'ending-soon') {
      filtered.sort((a, b) => {
        if (!a.endsAt) return 1;
        if (!b.endsAt) return -1;
        return new Date(a.endsAt).getTime() - new Date(b.endsAt).getTime();
      });
    } else if (s === 'newest') {
      filtered.sort((a, b) => {
        if (!a.startsAt) return 1;
        if (!b.startsAt) return -1;
        return new Date(b.startsAt).getTime() - new Date(a.startsAt).getTime();
      });
    }

    return filtered;
  });

  protected typeCounts = computed<Record<string, number>>(() => {
    const items = this.result()?.items ?? [];
    const counts: Record<string, number> = { All: items.length };
    for (const tab of this.filterTabs.slice(1)) {
      counts[tab.id] = items.filter(p => p.typeName === tab.id).length;
    }
    return counts;
  });

  protected totalPages = computed(() => this.result()?.totalPages ?? 1);

  ngOnInit(): void {
    this._load();
  }

  private _load(): void {
    this.loading.set(true);
    this._promotions.getActivePromotions(this.currentPage(), this.pageSize).subscribe({
      next: r => { this.result.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected setFilter(tab: FilterTab): void {
    this.activeFilter.set(tab);
  }

  protected setSortBy(sort: SortOption): void {
    this.sortBy.set(sort);
  }

  protected onPageChange(page: number): void {
    this.currentPage.set(page);
    this._load();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  protected typeKey(typeName: string): string {
    const map: Record<string, string> = {
      'Percentage Discount':   'percent',
      'Fixed Amount Discount': 'fixed',
      'Buy X Get Y':           'bxgy',
      'Multi Buy':             'multibuy',
      'Clubcard Price':        'clubcard',
    };
    return map[typeName] ?? 'default';
  }

  protected discountMain(p: Promotion): string {
    if (p.discountPercent) return `${p.discountPercent}%`;
    if (p.discountValue)   return `£${p.discountValue.toFixed(2)}`;
    if (p.typeName === 'Buy X Get Y' && p.minQuantity) return `${p.minQuantity}`;
    if (p.typeName === 'Multi Buy')      return 'MULTI';
    if (p.typeName === 'Clubcard Price') return 'CC';
    return '';
  }

  protected discountSub(p: Promotion): string {
    if (p.discountPercent)               return 'OFF';
    if (p.discountValue)                 return 'OFF';
    if (p.typeName === 'Buy X Get Y')    return 'FOR 1';
    if (p.typeName === 'Multi Buy')      return 'DEAL';
    if (p.typeName === 'Clubcard Price') return 'PRICE';
    return '';
  }

  protected daysRemaining(p: Promotion): number | null {
    if (!p.endsAt) return null;
    const days = Math.ceil((new Date(p.endsAt).getTime() - Date.now()) / 86_400_000);
    return days >= 0 ? days : null;
  }

  protected isNew(p: Promotion): boolean {
    if (!p.startsAt) return false;
    return Math.floor((Date.now() - new Date(p.startsAt).getTime()) / 86_400_000) <= 7;
  }

  protected urgencyLabel(p: Promotion): string | null {
    const days = this.daysRemaining(p);
    if (days === null)  return null;
    if (days === 0)     return 'Ends today';
    if (days === 1)     return 'Ends tomorrow';
    if (days <= 3)      return `${days} days left`;
    return null;
  }
}
