import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DeliveryService } from '../../core/services/delivery.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { Store } from '../../core/models/delivery.model';

@Component({
  selector: 'app-store-locator',
  standalone: true,
  imports: [CommonModule, FormsModule, SpinnerComponent, BreadcrumbComponent],
  template: `
    <div class="page-container page-content">
      <app-breadcrumb [items]="[{ label: 'Home', url: '/' }, { label: 'Store Locator' }]" />
      <h1 style="font-size: 1.5rem; margin-bottom: 1.5rem">Find a Tesco store</h1>

      <form class="store-search" (ngSubmit)="search()">
        <input
          type="text"
          class="form-control"
          placeholder="Enter postcode (e.g. SW1A 1AA)"
          [(ngModel)]="postcode"
          name="postcode"
          style="max-width: 300px"
        />
        <button type="submit" class="button button--primary" [disabled]="loading()">Find stores</button>
      </form>

      @if (loading()) {
        <app-spinner />
      } @else if (stores().length > 0) {
        <div class="store-grid">
          @for (store of stores(); track store.id) {
            <div class="store-card card">
              <div class="store-card__header">
                <h3 class="store-card__name">{{ store.name }}</h3>
                <span class="badge badge--blue">{{ store.type }}</span>
                @if (store.isWhooshEnabled) { <span class="badge badge--red">Whoosh</span> }
              </div>
              <div class="store-card__body">
                <p>{{ store.address }}, {{ store.postcode }}</p>
                <p>{{ store.phone }}</p>
                <p style="font-size:0.8125rem;color:#5f6368">{{ store.openingHours }}</p>
                @if (store.facilities.length > 0) {
                  <div style="display:flex;flex-wrap:wrap;gap:0.25rem;margin-top:0.5rem">
                    @for (f of store.facilities; track f) {
                      <span class="badge badge--grey">{{ f }}</span>
                    }
                  </div>
                }
                <a [href]="'https://maps.google.com?q=' + store.postcode" target="_blank" class="button button--ghost button--sm" style="margin-top:0.5rem;padding-left:0">
                  Get directions →
                </a>
              </div>
            </div>
          }
        </div>
      } @else if (searched()) {
        <p style="color:#5f6368;text-align:center;padding:2rem">No stores found near that postcode. Try a different search.</p>
      }
    </div>
  `,
  styles: [`
    .store-search { display: flex; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
    .store-grid { display: grid; gap: 1rem; grid-template-columns: 1fr; }
    @media (min-width: 768px) { .store-grid { grid-template-columns: repeat(2, 1fr); } }
    .store-card__header { padding: 0.75rem 1rem; border-bottom: 1px solid #d8dde6; display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
    .store-card__name { font-weight: 700; flex: 1; }
    .store-card__body { padding: 1rem; font-size: 0.875rem; display: flex; flex-direction: column; gap: 0.25rem; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class StoreLocatorComponent {
  private readonly _delivery = inject(DeliveryService);

  protected postcode = '';
  protected stores = signal<Store[]>([]);
  protected loading = signal(false);
  protected searched = signal(false);

  protected search(): void {
    if (!this.postcode.trim()) return;
    this.loading.set(true);
    this.searched.set(false);
    this._delivery.getStores(this.postcode.trim()).subscribe({
      next: s => { this.stores.set(s); this.loading.set(false); this.searched.set(true); },
      error: () => { this.loading.set(false); this.searched.set(true); }
    });
  }
}
