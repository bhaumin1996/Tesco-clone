import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface InventoryItem { id: number; listingId: number; sku: string; title: string; stockQuantity: number; lowStockThreshold: number; statusName: string; }
interface AdjustmentReason { value: string; label: string; }

@Component({
  selector: 'app-seller-inventory',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './inventory.component.html',
  styleUrl: './inventory.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerInventoryComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly items = signal<InventoryItem[]>([]);
  readonly message = signal('');
  readonly adjustTarget = signal<InventoryItem | null>(null);
  readonly adjustQty = signal(0);
  readonly adjustReason = signal('restock');
  readonly adjustNote = signal('');
  readonly submitting = signal(false);
  readonly filterLowStock = signal(false);

  readonly reasons: AdjustmentReason[] = [
    { value: 'restock', label: 'Restock' },
    { value: 'damage', label: 'Damaged / Write-off' },
    { value: 'correction', label: 'Stock Count Correction' },
    { value: 'return', label: 'Customer Return' },
    { value: 'other', label: 'Other' }
  ];

  readonly displayed = computed(() => {
    const list = this.items();
    return this.filterLowStock() ? list.filter(i => i.stockQuantity <= i.lowStockThreshold) : list;
  });

  readonly lowStockCount = computed(() => this.items().filter(i => i.stockQuantity <= i.lowStockThreshold).length);

  ngOnInit(): void {
    this._load();
  }

  openAdjust(item: InventoryItem): void {
    this.adjustTarget.set(item);
    this.adjustQty.set(0);
    this.adjustReason.set('restock');
    this.adjustNote.set('');
  }

  closeAdjust(): void { this.adjustTarget.set(null); }

  submitAdjustment(): void {
    const item = this.adjustTarget();
    if (!item) return;
    this.submitting.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/inventory/${item.id}/adjust`, {
      quantity: this.adjustQty(),
      reason: this.adjustReason(),
      note: this.adjustNote()
    }).subscribe({
      next: () => {
        this.submitting.set(false);
        this.closeAdjust();
        this._load();
        this._notify('Stock adjusted.');
      },
      error: () => this.submitting.set(false)
    });
  }

  updateThreshold(item: InventoryItem, threshold: number): void {
    this._http.put(`${environment.apiUrl}/marketplace/inventory/${item.id}/threshold`, { lowStockThreshold: threshold }).subscribe({
      next: () => {
        this.items.update(list => list.map(i => i.id === item.id ? { ...i, lowStockThreshold: threshold } : i));
      }
    });
  }

  exportCsv(): void {
    const rows = [['SKU', 'Title', 'Stock', 'Low Stock Threshold', 'Status']];
    this.displayed().forEach(i => rows.push([i.sku, i.title, String(i.stockQuantity), String(i.lowStockThreshold), i.statusName]));
    const csv = rows.map(r => r.map(c => `"${c}"`).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'inventory.csv'; a.click();
    URL.revokeObjectURL(url);
  }

  private _load(): void {
    this._http.get<InventoryItem[]>(`${environment.apiUrl}/marketplace/inventory`).subscribe({
      next: items => { this.items.set(items); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  private _notify(msg: string): void { this.message.set(msg); setTimeout(() => this.message.set(''), 3000); }
}
