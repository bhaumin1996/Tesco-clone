import { ChangeDetectionStrategy, Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { DeliveryService } from '../../core/services/delivery.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { Store } from '../../core/models/delivery.model';

@Component({
  selector: 'app-store-locator',
  standalone: true,
  imports: [CommonModule, FormsModule, SpinnerComponent, BreadcrumbComponent],
  template: `
    <div class="store-locator-page">
      <div class="page-container page-content">
        <app-breadcrumb [items]="[{ label: 'Home', url: '/' }, { label: 'Store Locator' }]" />
        
        <div class="locator-layout">
          <!-- Left Side: Search and Results -->
          <div class="locator-sidebar">
            <h1 class="locator-title">Find a Tesco store</h1>
            
            <form class="store-search" (ngSubmit)="search()">
              <div class="search-input-group">
                <input
                  type="text"
                  class="form-control"
                  placeholder="Enter postcode (e.g. SW1A 1AA)"
                  [(ngModel)]="postcode"
                  name="postcode"
                />
                <button type="submit" class="button button--primary" [disabled]="loading()">
                  @if (loading()) {
                    <span class="spinner-sm"></span>
                  } @else {
                    Find stores
                  }
                </button>
              </div>
            </form>

            <div class="results-container">
              @if (loading()) {
                <div class="loading-state">
                  <app-spinner />
                </div>
              } @else if (stores().length > 0) {
                <div class="store-list">
                  @for (store of stores(); track store.id) {
                    <div 
                      class="store-card-v2" 
                      [class.is-selected]="selectedStore()?.id === store.id"
                      (click)="selectStore(store)"
                    >
                      <div class="store-card-v2__content">
                        <div class="store-card-v2__header">
                          <h3 class="store-card-v2__name">{{ store.name }}</h3>
                          <div class="store-card-v2__badges">
                            <span class="badge badge--blue-soft">{{ store.type }}</span>
                            @if (store.isWhooshEnabled) { <span class="badge badge--red-soft">Whoosh</span> }
                          </div>
                        </div>
                        <p class="store-card-v2__address">{{ store.address }}, {{ store.postcode }}</p>
                        <p class="store-card-v2__hours">{{ store.openingHours }}</p>
                        
                        <div class="store-card-v2__footer">
                           <a [href]="'tel:' + store.phone" class="store-action-link" (click)="$event.stopPropagation()">
                             <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                             {{ store.phone }}
                           </a>
                        </div>
                      </div>
                    </div>
                  }
                </div>
              } @else if (searched()) {
                <div class="empty-state">
                  <p>No stores found near that postcode. Try a different search.</p>
                </div>
              } @else {
                <div class="initial-state">
                  <p>Enter your postcode above to find stores near you.</p>
                </div>
              }
            </div>
          </div>

          <!-- Right Side: Map -->
          <div class="locator-map-container">
            @if (mapUrl()) {
              <iframe
                [src]="mapUrl()"
                width="100%"
                height="100%"
                style="border:0;"
                allowfullscreen=""
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade"
              ></iframe>
            } @else {
              <div class="map-placeholder">
                <div class="map-placeholder__content">
                  <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#d8dde6" stroke-width="1.5">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/>
                  </svg>
                  <p>Select a store to view on map</p>
                </div>
              </div>
            }
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .store-locator-page { background: #f3f5f7; min-height: calc(100vh - 200px); }
    .locator-layout { display: flex; gap: 2rem; margin-top: 1.5rem; height: calc(100vh - 280px); min-height: 500px; }
    
    .locator-sidebar { flex: 0 0 400px; display: flex; flex-direction: column; background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; }
    .locator-title { padding: 1.5rem 1.5rem 0.5rem; font-size: 1.5rem; font-weight: 700; color: #00539f; }
    
    .store-search { padding: 1rem 1.5rem; border-bottom: 1px solid #eef0f2; }
    .search-input-group { display: flex; gap: 0.5rem; }
    .search-input-group input { flex: 1; border-radius: 8px; border: 1px solid #d8dde6; padding: 0.75rem; }
    .search-input-group input:focus { border-color: #00539f; box-shadow: 0 0 0 3px rgba(0,83,159,0.1); outline: none; }
    
    .results-container { flex: 1; overflow-y: auto; padding: 0; }
    .loading-state, .empty-state, .initial-state { padding: 3rem 1.5rem; text-align: center; color: #5f6368; }
    
    .store-list { display: flex; flex-direction: column; }
    .store-card-v2 { 
      padding: 1.25rem 1.5rem; 
      border-bottom: 1px solid #eef0f2; 
      cursor: pointer; 
      transition: all 0.2s ease;
      border-left: 4px solid transparent;
    }
    .store-card-v2:hover { background: #f8fafc; }
    .store-card-v2.is-selected { background: #f0f7ff; border-left-color: #00539f; }
    
    .store-card-v2__header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem; gap: 0.5rem; }
    .store-card-v2__name { font-size: 1rem; font-weight: 700; color: #1c1c1c; margin: 0; }
    .store-card-v2__badges { display: flex; gap: 0.25rem; flex-wrap: wrap; }
    
    .store-card-v2__address { font-size: 0.875rem; color: #5f6368; margin-bottom: 0.25rem; }
    .store-card-v2__hours { font-size: 0.8125rem; color: #808080; }
    
    .store-card-v2__footer { margin-top: 0.75rem; display: flex; align-items: center; }
    .store-action-link { display: flex; align-items: center; gap: 0.35rem; font-size: 0.8125rem; color: #00539f; text-decoration: none; font-weight: 600; }
    .store-action-link:hover { text-decoration: underline; }

    .locator-map-container { flex: 1; background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); overflow: hidden; position: relative; }
    .map-placeholder { height: 100%; display: flex; align-items: center; justify-content: center; background: #f8fafc; }
    .map-placeholder__content { text-align: center; color: #94a3b8; }
    .map-placeholder p { margin-top: 1rem; font-weight: 500; }

    .badge--blue-soft { background: #e0e7ff; color: #4338ca; font-size: 0.7rem; padding: 0.15rem 0.4rem; border-radius: 4px; font-weight: 600; text-transform: uppercase; }
    .badge--red-soft { background: #fee2e2; color: #b91c1c; font-size: 0.7rem; padding: 0.15rem 0.4rem; border-radius: 4px; font-weight: 600; text-transform: uppercase; }

    .spinner-sm { width: 1.25rem; height: 1.25rem; border: 2px solid rgba(255,255,255,0.3); border-top-color: white; border-radius: 50%; animation: spin 0.8s linear infinite; display: inline-block; }
    @keyframes spin { to { transform: rotate(360deg); } }

    @media (max-width: 992px) {
      .locator-layout { flex-direction: column; height: auto; }
      .locator-sidebar { flex: none; width: 100%; height: 500px; }
      .locator-map-container { height: 400px; }
    }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class StoreLocatorComponent {
  private readonly _delivery = inject(DeliveryService);
  private readonly _sanitizer = inject(DomSanitizer);

  protected postcode = '';
  protected stores = signal<Store[]>([]);
  protected loading = signal(false);
  protected searched = signal(false);
  protected selectedStore = signal<Store | null>(null);

  protected mapUrl = computed(() => {
    const store = this.selectedStore();
    if (!store) return null;
    
    // Using simple embed URL that doesn't strictly require an API key for basic view
    // Format: https://maps.google.com/maps?q=[lat],[lng]&z=15&output=embed
    const url = `https://maps.google.com/maps?q=${store.latitude},${store.longitude}&z=15&output=embed`;
    return this._sanitizer.bypassSecurityTrustResourceUrl(url);
  });

  protected search(): void {
    if (!this.postcode.trim()) return;
    this.loading.set(true);
    this.searched.set(false);
    this.selectedStore.set(null);
    
    this._delivery.getStores(this.postcode.trim()).subscribe({
      next: s => { 
        this.stores.set(s); 
        this.loading.set(false); 
        this.searched.set(true);
        if (s.length > 0) {
          this.selectedStore.set(s[0]);
        }
      },
      error: () => { 
        this.loading.set(false); 
        this.searched.set(true); 
      }
    });
  }

  protected selectStore(store: Store): void {
    this.selectedStore.set(store);
  }
}

