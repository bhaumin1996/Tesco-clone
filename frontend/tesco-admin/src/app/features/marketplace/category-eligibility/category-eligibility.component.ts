import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface CategoryEligibility {
  categoryId: number;
  categoryName: string;
  isMarketplaceEligible: boolean;
  commissionTierId?: number;
  commissionRate?: number;
}

@Component({
  selector: 'app-category-eligibility',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './category-eligibility.component.html',
  styleUrl: './category-eligibility.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CategoryEligibilityComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin`; }

  readonly loading = signal(true);
  readonly categories = signal<CategoryEligibility[]>([]);
  readonly message = signal('');
  readonly saving = signal<number | null>(null);

  ngOnInit(): void {
    this._http.get<CategoryEligibility[]>(`${this._base}/catalogue/categories/marketplace-eligibility`).subscribe({
      next: c => { this.categories.set(c); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  toggle(cat: CategoryEligibility): void {
    this.saving.set(cat.categoryId);
    this._http.put(`${this._base}/catalogue/categories/${cat.categoryId}/marketplace-eligibility`, {
      isEligible: !cat.isMarketplaceEligible
    }).subscribe({
      next: () => {
        this.categories.update(list =>
          list.map(c => c.categoryId === cat.categoryId
            ? { ...c, isMarketplaceEligible: !c.isMarketplaceEligible }
            : c
          )
        );
        this.saving.set(null);
        this.message.set('Saved.');
        setTimeout(() => this.message.set(''), 2500);
      },
      error: () => { this.saving.set(null); this.message.set('Save failed.'); }
    });
  }
}
