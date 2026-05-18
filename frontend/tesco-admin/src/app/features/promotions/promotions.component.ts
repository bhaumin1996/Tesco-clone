import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { AdminPaginationComponent } from '../../shared/components/pagination/pagination.component';

interface Promotion {
  id: number;
  name: string;
  typeName: string;
  discountValue: number | null;
  discountPercent: number | null;
  minQuantity: number | null;
  startsAt: string | null;
  endsAt: string | null;
  isActive: boolean;
}

interface PagedResponse<T> {
  items: T[];
  totalCount: number;
}

@Component({
  selector: 'app-admin-promotions',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, AdminPaginationComponent],
  templateUrl: './promotions.component.html',
  styleUrl: './promotions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminPromotionsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected promotions = signal<Promotion[]>([]);
  protected loading = signal(true);
  protected showForm = signal(false);
  protected editId = signal<number | null>(null);
  protected message = signal('');
  protected messageType = signal<'success' | 'error'>('success');

  protected searchQuery = signal('');

  protected readonly pageSize = 10;
  protected currentPage = signal(1);
  protected filteredPromotions = computed(() => {
    const q = this.searchQuery().toLowerCase();
    return q
      ? this.promotions().filter(p => p.name.toLowerCase().includes(q) || p.typeName.toLowerCase().includes(q))
      : this.promotions();
  });
  protected totalPages = computed(() => Math.max(1, Math.ceil(this.filteredPromotions().length / this.pageSize)));
  protected pagedPromotions = computed(() => {
    const s = (this.currentPage() - 1) * this.pageSize;
    return this.filteredPromotions().slice(s, s + this.pageSize);
  });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  readonly promotionTypes = [
    { id: 1, label: 'Percentage Discount' },
    { id: 2, label: 'Fixed Amount Discount' },
    { id: 3, label: 'Buy X Get Y' },
    { id: 4, label: 'Multi Buy' },
    { id: 5, label: 'Clubcard Price' },
  ];

  protected form = this._fb.group({
    name: ['', Validators.required],
    promotionTypeId: [1, Validators.required],
    discountValue: [null as number | null],
    discountPercent: [null as number | null],
    minQuantity: [null as number | null],
    startsAt: [null as string | null],
    endsAt: [null as string | null],
    isActive: [true],
  });

  private get _base() { return `${environment.apiUrl}/admin/promotions`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<PagedResponse<Promotion>>(`${this._base}?pageNumber=1&pageSize=500`).subscribe({
      next: r => { this.promotions.set(r.items); this.currentPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  private _showMessage(text: string, type: 'success' | 'error'): void {
    this.message.set(text);
    this.messageType.set(type);
    setTimeout(() => this.message.set(''), 3000);
  }

  protected onSearch(term: string): void { this.searchQuery.set(term); this.currentPage.set(1); }

  protected goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page);
  }

  protected openCreate(): void {
    this.editId.set(null);
    this.form.reset({ promotionTypeId: 1, isActive: true });
    this.showForm.set(true);
  }

  protected openEdit(p: Promotion): void {
    this.editId.set(p.id);
    this.form.patchValue({
      name: p.name,
      discountValue: p.discountValue,
      discountPercent: p.discountPercent,
      minQuantity: p.minQuantity,
      startsAt: p.startsAt ? p.startsAt.substring(0, 10) : null,
      endsAt: p.endsAt ? p.endsAt.substring(0, 10) : null,
      isActive: p.isActive,
    });
    this.showForm.set(true);
  }

  protected save(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const v = this.form.getRawValue();
    const id = this.editId();
    const req = id
      ? this._http.put(`${this._base}/${id}`, {
          name: v.name,
          discountValue: v.discountValue || null,
          discountPercent: v.discountPercent || null,
          minQuantity: v.minQuantity || null,
          startsAt: v.startsAt || null,
          endsAt: v.endsAt || null,
          isActive: v.isActive,
        })
      : this._http.post(this._base, {
          name: v.name,
          promotionTypeId: Number(v.promotionTypeId),
          discountValue: v.discountValue || null,
          discountPercent: v.discountPercent || null,
          minQuantity: v.minQuantity || null,
          startsAt: v.startsAt || null,
          endsAt: v.endsAt || null,
        });
    req.subscribe({
      next: () => { this.showForm.set(false); this._load(); this._showMessage('Promotion saved.', 'success'); },
      error: () => this._showMessage('Save failed.', 'error')
    });
  }

  protected toggleActive(p: Promotion): void {
    const activate = !p.isActive;
    if (!activate && !confirm('Deactivate this promotion?')) return;
    this._http.put(`${this._base}/${p.id}`, {
      name: p.name,
      discountValue: p.discountValue,
      discountPercent: p.discountPercent,
      minQuantity: p.minQuantity,
      startsAt: p.startsAt,
      endsAt: p.endsAt,
      isActive: activate,
    }).subscribe({
      next: () => { this._load(); this._showMessage(activate ? 'Promotion activated.' : 'Promotion deactivated.', 'success'); },
      error: () => this._showMessage('Action failed.', 'error')
    });
  }

  protected delete(id: number): void {
    if (!confirm('Permanently delete this promotion?')) return;
    this._http.delete(`${this._base}/${id}`).subscribe({
      next: () => { this._load(); this._showMessage('Promotion deleted.', 'success'); },
      error: () => this._showMessage('Delete failed.', 'error')
    });
  }
}
