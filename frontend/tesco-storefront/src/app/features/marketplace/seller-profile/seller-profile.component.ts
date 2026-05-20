import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { MarketplaceService } from '../../../core/services/marketplace.service';
import { SellerProfile, SellerPerformance } from '../../../core/models/marketplace.model';
import { ProductSummary, PagedResult } from '../../../core/models/catalogue.model';
import { ProductCardComponent } from '../../../shared/components/product-card/product-card.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-seller-profile',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCardComponent, BreadcrumbComponent, SpinnerComponent],
  templateUrl: './seller-profile.component.html',
  styleUrl: './seller-profile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerProfileComponent implements OnInit {
  private readonly _marketplace = inject(MarketplaceService);
  private readonly _route = inject(ActivatedRoute);

  protected loading = signal(true);
  protected seller = signal<SellerProfile | null>(null);
  protected performance = signal<SellerPerformance | null>(null);
  protected listings = signal<ProductSummary[]>([]);

  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'Marketplace', url: '/marketplace' },
    { label: 'Seller Profile' }
  ];

  ngOnInit(): void {
    const id = Number(this._route.snapshot.paramMap.get('id'));
    this._marketplace.getSellerProfile(id).subscribe({
      next: s => { this.seller.set(s); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
    this._marketplace.getSellerPerformance(id).subscribe({
      next: p => this.performance.set(p),
      error: () => {}
    });
    this._marketplace.searchMarketplace(undefined, undefined, id, undefined, undefined, 'relevance', 1, 8).subscribe({
      next: r => this.listings.set(r.items),
      error: () => {}
    });
  }

  protected stars(rating: number): string[] {
    return Array.from({ length: 5 }, (_, i) => i < Math.round(rating) ? '★' : '☆');
  }
}
