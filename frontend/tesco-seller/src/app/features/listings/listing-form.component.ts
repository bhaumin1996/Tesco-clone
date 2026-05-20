import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute, Router } from '@angular/router';
import { environment } from '../../../environments/environment';

interface MarketplaceCategory { id: number; name: string; }
interface ListingFormData {
  title: string; description: string; categoryId: number | null;
  ean: string; price: number; compareAtPrice: number | null;
  stockQuantity: number; weight: number | null; width: number | null;
  height: number | null; depth: number | null; sku: string;
  deliveryOptionId: number | null;
}

@Component({
  selector: 'app-listing-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './listing-form.component.html',
  styleUrl: './listing-form.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ListingFormComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _route = inject(ActivatedRoute);
  private readonly _router = inject(Router);

  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly message = signal('');
  readonly categories = signal<MarketplaceCategory[]>([]);
  readonly isEdit = signal(false);
  readonly listingId = signal<number | null>(null);

  readonly form = signal<ListingFormData>({
    title: '', description: '', categoryId: null, ean: '', price: 0,
    compareAtPrice: null, stockQuantity: 0, weight: null,
    width: null, height: null, depth: null, sku: '', deliveryOptionId: null
  });

  ngOnInit(): void {
    this._http.get<MarketplaceCategory[]>(`${environment.apiUrl}/marketplace/categories`).subscribe({
      next: cats => this.categories.set(cats)
    });

    const id = this._route.snapshot.paramMap.get('id');
    if (id) {
      this.isEdit.set(true);
      this.listingId.set(+id);
      this.loading.set(true);
      this._http.get<any>(`${environment.apiUrl}/marketplace/listings/${id}`).subscribe({
        next: l => { this.form.set({ ...this.form(), ...l }); this.loading.set(false); },
        error: () => this.loading.set(false)
      });
    }
  }

  update(changes: Partial<ListingFormData>): void {
    this.form.update(f => ({ ...f, ...changes }));
  }

  save(): void {
    this.saving.set(true);
    const id = this.listingId();
    const req = id
      ? this._http.put(`${environment.apiUrl}/marketplace/listings/${id}`, this.form())
      : this._http.post(`${environment.apiUrl}/marketplace/listings`, this.form());

    req.subscribe({
      next: () => {
        this.saving.set(false);
        this._router.navigate(['/listings']);
      },
      error: () => { this.saving.set(false); this.message.set('Failed to save. Please check your inputs.'); }
    });
  }

  cancel(): void { this._router.navigate(['/listings']); }
}
