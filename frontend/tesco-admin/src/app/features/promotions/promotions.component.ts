import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface Promotion {
  promotionId: number;
  name: string;
  type: string;
  discountValue: number;
  startDate: string;
  endDate: string;
  isActive: boolean;
}

@Component({
  selector: 'app-admin-promotions',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
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

  protected searchQuery = signal('');

  protected readonly pageSize = 10;
  protected currentPage = signal(1);
  protected filteredPromotions = computed(() => {
    const q = this.searchQuery().toLowerCase();
    return q ? this.promotions().filter(p =>
      p.name.toLowerCase().includes(q) ||
      p.type.toLowerCase().includes(q)
    ) : this.promotions();
  });
  protected totalPages = computed(() => Math.max(1, Math.ceil(this.filteredPromotions().length / this.pageSize)));
  protected pagedPromotions = computed(() => { const s = (this.currentPage() - 1) * this.pageSize; return this.filteredPromotions().slice(s, s + this.pageSize); });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  protected form = this._fb.group({
    name: ['', Validators.required],
    type: ['Percentage', Validators.required],
    discountValue: [0, [Validators.required, Validators.min(0)]],
    startDate: ['', Validators.required],
    endDate: ['', Validators.required]
  });

  readonly types = ['Percentage', 'FixedAmount', 'BuyXGetY', 'FreeShipping'];

  private get _base() { return `${environment.apiUrl}/admin/promotions`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<Promotion[]>(this._base).subscribe({
      next: r => { this.promotions.set(r); this.currentPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onSearch(term: string): void { this.searchQuery.set(term); this.currentPage.set(1); }

  protected goToPage(page: number): void { if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page); }

  protected openCreate(): void { this.editId.set(null); this.form.reset({ type: 'Percentage', discountValue: 0 }); this.showForm.set(true); }

  protected openEdit(p: Promotion): void {
    this.editId.set(p.promotionId);
    this.form.patchValue({ name: p.name, type: p.type, discountValue: p.discountValue, startDate: p.startDate.substring(0, 10), endDate: p.endDate.substring(0, 10) });
    this.showForm.set(true);
  }

  protected save(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const body = this.form.getRawValue();
    const req = this.editId()
      ? this._http.put(`${this._base}/${this.editId()}`, body)
      : this._http.post(this._base, body);
    req.subscribe({
      next: () => { this.showForm.set(false); this._load(); this.message.set('Promotion saved.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Save failed.')
    });
  }

  protected deactivate(id: number): void {
    this._http.delete(`${this._base}/${id}`).subscribe({
      next: () => { this._load(); this.message.set('Promotion deactivated.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Action failed.')
    });
  }
}
