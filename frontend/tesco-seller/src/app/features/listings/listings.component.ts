import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface Listing { id: number; title: string; sku?: string; price: number; stockQuantity: number; statusName: string; categoryName: string; }

@Component({
  selector: 'app-seller-listings',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="sp-page">
      <div class="sp-page__header">
        <h1>My Listings</h1>
        <button class="sp-btn sp-btn--primary" (click)="showCreateForm.set(true)">+ New Listing</button>
      </div>
      @if (loading()) { <p class="sp-loading">Loading…</p> }
      @else {
      <table class="sp-table">
        <thead><tr><th>Title</th><th>SKU</th><th>Price</th><th>Stock</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
          @for (l of listings(); track l.id) {
          <tr>
            <td>{{ l.title }}</td>
            <td>{{ l.sku ?? '—' }}</td>
            <td>£{{ l.price | number:'1.2-2' }}</td>
            <td [class.sp-low]="l.stockQuantity < 5">{{ l.stockQuantity }}</td>
            <td><span class="sp-badge sp-badge--{{ l.statusName | lowercase }}">{{ l.statusName }}</span></td>
            <td>
              <button class="sp-btn sp-btn--ghost sp-btn--sm" (click)="togglePublish(l)">
                {{ l.statusName === 'Published' ? 'Unpublish' : 'Publish' }}
              </button>
            </td>
          </tr>
          }
          @empty { <tr><td colspan="6" class="sp-empty">No listings found. Create your first listing above.</td></tr> }
        </tbody>
      </table>
      }
      @if (message()) { <div class="sp-msg">{{ message() }}</div> }
    </div>
  `,
  styles: [`
    .sp-page { h1 { font-size:1.4rem; font-weight:800; margin:0; } &__header { display:flex; align-items:center; justify-content:space-between; margin-bottom:1rem; } }
    .sp-loading, .sp-empty { color:#777; padding:2rem; text-align:center; }
    .sp-table { width:100%; border-collapse:collapse; font-size:.875rem; background:#fff; border:1px solid #e8ecf0; border-radius:8px; overflow:hidden;
      th { text-align:left; padding:.6rem .75rem; border-bottom:2px solid #e8ecf0; font-weight:600; color:#444; background:#f9fafc; }
      td { padding:.6rem .75rem; border-bottom:1px solid #f1f5f9; }
    }
    .sp-badge { display:inline-block; font-size:.72rem; font-weight:700; padding:.2rem .5rem; border-radius:4px;
      &--published { background:#e8f4e8; color:#1a6b2a; } &--draft { background:#f1f5f9; color:#64748b; } &--unpublished { background:#fff5e6; color:#b05700; }
    }
    .sp-low { color:#b00; font-weight:700; }
    .sp-btn { border:none; border-radius:5px; padding:.45rem 1rem; font-size:.85rem; font-weight:600; cursor:pointer;
      &--primary { background:#00539f; color:#fff; &:hover { background:#003a70; } }
      &--ghost { background:none; color:#00539f; border:1.5px solid #00539f; &:hover { background:#e8f0fb; } }
      &--sm { padding:.3rem .7rem; font-size:.78rem; }
    }
    .sp-msg { background:#e8f4e8; color:#1a6b2a; border-radius:6px; padding:.5rem 1rem; margin-top:1rem; font-size:.875rem; font-weight:600; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerListingsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly listings = signal<Listing[]>([]);
  readonly message = signal('');
  readonly showCreateForm = signal(false);

  ngOnInit(): void {
    this._http.get<Listing[]>(`${environment.apiUrl}/marketplace/listings`).subscribe({
      next: l => { this.listings.set(l); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  togglePublish(listing: Listing): void {
    const action = listing.statusName === 'Published' ? 'unpublish' : 'publish';
    this._http.put(`${environment.apiUrl}/marketplace/listings/${listing.id}/${action}`, {}).subscribe({
      next: () => {
        this.listings.update(list => list.map(l =>
          l.id === listing.id ? { ...l, statusName: action === 'publish' ? 'Published' : 'Unpublished' } : l
        ));
        this.message.set(`Listing ${action}ed.`);
        setTimeout(() => this.message.set(''), 3000);
      }
    });
  }
}
