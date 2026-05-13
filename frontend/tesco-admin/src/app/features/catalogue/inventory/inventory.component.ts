import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface InventoryItem {
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

  protected adjustForm = this._fb.group({
    quantity: [0, [Validators.required]],
    reason: ['', Validators.required]
  });

  private get _base() { return `${environment.apiUrl}/admin/inventory`; }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<InventoryItem[]>(this._base).subscribe({
      next: r => { this.items.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected openAdjust(item: InventoryItem): void {
    this.adjustTarget.set(item);
    this.adjustForm.reset({ quantity: 0, reason: '' });
  }

  protected submitAdjust(): void {
    if (this.adjustForm.invalid) { this.adjustForm.markAllAsTouched(); return; }
    const target = this.adjustTarget();
    if (!target) return;
    const body = { ...this.adjustForm.getRawValue(), productId: target.productId };
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
