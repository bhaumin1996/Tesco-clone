import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface InventoryItem {
  productVariantId: number;
  productId: number;
  productName: string;
  sku: string;
  stockQuantity: number;
  lowStockThreshold: number;
  isLowStock: boolean;
}

@Component({
  selector: 'app-admin-inventory',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './inventory.component.html',
  styleUrl: './inventory.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminInventoryComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected items = signal<InventoryItem[]>([]);
  protected loading = signal(true);
  protected adjustTarget = signal<InventoryItem | null>(null);
  protected message = signal('');

  protected searchQuery = signal('');

  protected readonly pageSize = 10;
  protected currentPage = signal(1);
  protected filteredItems = computed(() => {
    const q = this.searchQuery().toLowerCase();
    return q ? this.items().filter(i =>
      i.sku.toLowerCase().includes(q) ||
      i.productName.toLowerCase().includes(q)
    ) : this.items();
  });
  protected totalPages = computed(() => Math.max(1, Math.ceil(this.filteredItems().length / this.pageSize)));
  protected pagedItems = computed(() => { const s = (this.currentPage() - 1) * this.pageSize; return this.filteredItems().slice(s, s + this.pageSize); });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  protected addTarget = signal<InventoryItem | null>(null);

  protected adjustForm = this._fb.group({
    quantity: [0, [Validators.required]],
    reason: ['', Validators.required]
  });

  protected addForm = this._fb.group({
    quantity: [null as number | null, [Validators.required, Validators.min(1)]],
    reason: ['Stock received']
  });

  private get _base() { return `${environment.apiUrl}/admin/inventory`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<InventoryItem[]>(this._base).subscribe({
      next: r => { this.items.set(r); this.currentPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onSearch(term: string): void { this.searchQuery.set(term); this.currentPage.set(1); }

  protected goToPage(page: number): void { if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page); }

  protected openAdd(item: InventoryItem): void {
    this.addTarget.set(item);
    this.adjustTarget.set(null);
    this.addForm.reset({ quantity: null, reason: 'Stock received' });
  }

  protected submitAdd(): void {
    if (this.addForm.invalid) { this.addForm.markAllAsTouched(); return; }
    const target = this.addTarget();
    if (!target) return;
    const { quantity, reason } = this.addForm.getRawValue();
    const body = { productVariantId: target.productVariantId, quantity, reason: reason || 'Stock received' };
    this._http.post(`${this._base}/adjust`, body).subscribe({
      next: () => {
        this.addTarget.set(null);
        this._load();
        this.message.set(`Added ${quantity} units to ${target.productName}.`);
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.message.set('Stock addition failed.')
    });
  }

  protected openAdjust(item: InventoryItem): void {
    this.adjustTarget.set(item);
    this.addTarget.set(null);
    this.adjustForm.reset({ quantity: 0, reason: '' });
  }

  protected submitAdjust(): void {
    if (this.adjustForm.invalid) { this.adjustForm.markAllAsTouched(); return; }
    const target = this.adjustTarget();
    if (!target) return;
    const body = { ...this.adjustForm.getRawValue(), productVariantId: target.productVariantId };
    this._http.post(`${this._base}/adjust`, body).subscribe({
      next: () => {
        this.adjustTarget.set(null);
        this._load();
        this.message.set('Inventory adjusted successfully.');
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.message.set('Adjustment failed.')
    });
  }
}
