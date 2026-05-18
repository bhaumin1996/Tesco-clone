import {
  ChangeDetectionStrategy, Component, computed, inject,
  OnInit, signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { debounceTime, distinctUntilChanged, Subject, switchMap, of } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { environment } from '../../../../environments/environment';
import { AdminPaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { extractApiError } from '../../../core/utils/api-error';

interface InventoryItem {
  productVariantId: number;
  productId: number;
  productName: string;
  sku: string;
  stockQuantity: number;
  lowStockThreshold: number;
  isLowStock: boolean;
  placedAndConfirmedCount: number;
  pendingOrderCount: number;
  remainingStock: number;
  variantName?: string;
}

interface ProductSearchResult {
  id: number;
  name: string;
  categoryName: string;
  basePrice: number;
  stockQuantity: number;
  isAvailable: boolean;
}

interface PagedResult<T> {
  items: T[];
  totalCount: number;
}

@Component({
  selector: 'app-admin-inventory',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, AdminPaginationComponent],
  templateUrl: './inventory.component.html',
  styleUrl: './inventory.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminInventoryComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  private get _base() { return `${environment.apiUrl}/admin`; }

  // ── Inventory list ──────────────────────────────────────────────
  protected items = signal<InventoryItem[]>([]);
  protected loading = signal(true);
  protected message = signal('');
  protected messageType = signal<'success' | 'error'>('success');

  protected searchQuery = signal('');
  protected readonly pageSize = 10;
  protected currentPage = signal(1);

  protected filteredItems = computed(() => {
    const q = this.searchQuery().toLowerCase();
    return q
      ? this.items().filter(i =>
          i.sku.toLowerCase().includes(q) || i.productName.toLowerCase().includes(q))
      : this.items();
  });
  protected totalPages = computed(() =>
    Math.max(1, Math.ceil(this.filteredItems().length / this.pageSize)));
  protected pagedItems = computed(() => {
    const s = (this.currentPage() - 1) * this.pageSize;
    return this.filteredItems().slice(s, s + this.pageSize);
  });
  protected pageNumbers = computed(() =>
    Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  // ── Per-row adjust ──────────────────────────────────────────────
  protected adjustTarget = signal<InventoryItem | null>(null);
  protected addTarget = signal<InventoryItem | null>(null);

  protected adjustForm = this._fb.group({
    quantity: [0, Validators.required],
    reason: ['', Validators.required]
  });

  protected addForm = this._fb.group({
    quantity: [null as number | null, [Validators.required, Validators.min(1)]],
    reason: ['Stock received']
  });

  // ── Global first-time add ───────────────────────────────────────
  protected globalAddOpen = signal(false);
  protected productSearch$ = new Subject<string>();
  protected productSearchTerm = signal('');
  protected productSearchResults = signal<ProductSearchResult[]>([]);
  protected productSearchLoading = signal(false);
  protected selectedProduct = signal<ProductSearchResult | null>(null);
  protected isSkuAuto = true;

  protected newVariantForm = this._fb.group({
    sku:               ['', [Validators.required, Validators.maxLength(100)]],
    variantName:       [''],
    barcode:           [''],
    initialQuantity:   [0, [Validators.required, Validators.min(0)]],
    lowStockThreshold: [10, [Validators.required, Validators.min(0)]]
  });

  constructor() {
    // Debounced product search
    this.productSearch$
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => {
          if (term.length < 2) { this.productSearchResults.set([]); return of(null); }
          this.productSearchLoading.set(true);
          return this._http.get<PagedResult<ProductSearchResult>>(
            `${this._base}/products`,
            { params: { search: term, pageSize: '8', pageNumber: '1' } }
          );
        }),
        takeUntilDestroyed()
      )
      .subscribe({
        next: result => {
          if (result) this.productSearchResults.set(result.items);
          this.productSearchLoading.set(false);
        },
        error: () => this.productSearchLoading.set(false)
      });

    // Auto SKU Listeners
    this.newVariantForm.get('variantName')?.valueChanges
      .pipe(takeUntilDestroyed())
      .subscribe(() => {
        if (this.isSkuAuto) {
          this.generateSku();
        }
      });

    this.newVariantForm.get('sku')?.valueChanges
      .pipe(takeUntilDestroyed())
      .subscribe(() => {
        this.isSkuAuto = false;
      });
  }

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<InventoryItem[]>(`${this._base}/inventory`).subscribe({
      next: r => { this.items.set(r); this.currentPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onSearch(term: string): void { this.searchQuery.set(term); this.currentPage.set(1); }
  protected goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page);
  }

  // ── Per-row actions ─────────────────────────────────────────────
  protected openAdd(item: InventoryItem): void {
    this.addTarget.set(item);
    this.adjustTarget.set(null);
    this.globalAddOpen.set(false);
    this.addForm.reset({ quantity: null, reason: 'Stock received' });
  }

  protected submitAdd(): void {
    if (this.addForm.invalid) { this.addForm.markAllAsTouched(); return; }
    const target = this.addTarget();
    if (!target) return;
    const { quantity, reason } = this.addForm.getRawValue();
    this._http.post(`${this._base}/inventory/adjust`, {
      productVariantId: target.productVariantId, quantity, reason: reason || 'Stock received'
    }).subscribe({
      next: () => {
        this.addTarget.set(null);
        this._load();
        this._showMsg(`Added ${quantity} units to ${target.productName}.`, 'success');
      },
      error: (err) => this._showMsg(extractApiError(err, 'Stock addition failed.'), 'error')
    });
  }

  protected openAdjust(item: InventoryItem): void {
    this.adjustTarget.set(item);
    this.addTarget.set(null);
    this.globalAddOpen.set(false);
    this.adjustForm.reset({ quantity: 0, reason: '' });
  }

  protected submitAdjust(): void {
    if (this.adjustForm.invalid) { this.adjustForm.markAllAsTouched(); return; }
    const target = this.adjustTarget();
    if (!target) return;
    this._http.post(`${this._base}/inventory/adjust`, {
      ...this.adjustForm.getRawValue(), productVariantId: target.productVariantId
    }).subscribe({
      next: () => {
        this.adjustTarget.set(null);
        this._load();
        this._showMsg('Inventory adjusted successfully.', 'success');
      },
      error: (err) => this._showMsg(extractApiError(err, 'Adjustment failed.'), 'error')
    });
  }

  // ── Global first-time add ───────────────────────────────────────
  protected openGlobalAdd(): void {
    this.globalAddOpen.set(true);
    this.addTarget.set(null);
    this.adjustTarget.set(null);
    this._resetGlobalAdd();
  }

  protected closeGlobalAdd(): void {
    this.globalAddOpen.set(false);
    this._resetGlobalAdd();
  }

  private _resetGlobalAdd(): void {
    this.productSearchTerm.set('');
    this.productSearchResults.set([]);
    this.selectedProduct.set(null);
    this.isSkuAuto = true;
    this.newVariantForm.reset({
      sku: '', variantName: '', barcode: '',
      initialQuantity: 0, lowStockThreshold: 10
    });
  }

  protected onProductSearchInput(term: string): void {
    this.productSearchTerm.set(term);
    this.selectedProduct.set(null);
    this.productSearch$.next(term);
  }

  protected selectProduct(product: ProductSearchResult): void {
    this.selectedProduct.set(product);
    this.productSearchTerm.set(product.name);
    this.productSearchResults.set([]);
    this.isSkuAuto = true;
    this.generateSku();
  }

  protected generateSku(force = false): void {
    const product = this.selectedProduct();
    if (!product) return;

    if (force) {
      this.isSkuAuto = true;
    }

    const variant = this.newVariantForm.get('variantName')?.value || '';
    const generated = this._createSku(product.name, product.categoryName, variant, product.id);
    this.newVariantForm.get('sku')?.setValue(generated, { emitEvent: false });
  }

  private _createSku(productName: string, categoryName: string, variantName: string, productId: number): string {
    // 1. Category code (3 chars)
    let catCode = 'GEN';
    if (categoryName) {
      const cleanCat = categoryName.replace(/[^a-zA-Z]/g, '').toUpperCase();
      if (cleanCat.length >= 3) {
        catCode = cleanCat.substring(0, 3);
      } else if (cleanCat.length > 0) {
        catCode = cleanCat.padEnd(3, 'X');
      }
    }

    // 2. Product code (4-5 chars)
    let prodCode = 'PROD';
    if (productName) {
      const words = productName.trim().split(/\s+/).filter(w => w.length > 0);
      if (words.length >= 2) {
        prodCode = words.map(w => w[0].replace(/[^a-zA-Z0-9]/g, '')).join('').toUpperCase();
        if (prodCode.length < 3) {
          const cleanProd = productName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
          prodCode = (prodCode + cleanProd).substring(0, 4);
        }
      } else {
        const cleanProd = productName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
        prodCode = cleanProd.substring(0, 4);
      }
    }
    if (prodCode.length < 3) {
      prodCode = prodCode.padEnd(4, 'X');
    }
    prodCode = prodCode.substring(0, 5);

    // 3. Variant code if exists (3 chars)
    let varCode = '';
    if (variantName) {
      const cleanVar = variantName.replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
      if (cleanVar.length >= 3) {
        varCode = '-' + cleanVar.substring(0, 3);
      } else if (cleanVar.length > 0) {
        varCode = '-' + cleanVar;
      }
    }

    // 4. Unique suffix (Product ID + random 3-digit)
    const randomSuffix = Math.floor(100 + Math.random() * 900);
    const suffix = `${productId}${randomSuffix}`;

    return `${catCode}-${prodCode}${varCode}-${suffix}`.toUpperCase();
  }

  protected clearProductSelection(): void {
    this.selectedProduct.set(null);
    this.productSearchTerm.set('');
    this.productSearchResults.set([]);
    this.newVariantForm.reset({
      sku: '', variantName: '', barcode: '',
      initialQuantity: 0, lowStockThreshold: 10
    });
  }

  protected submitNewVariant(): void {
    if (this.newVariantForm.invalid) { this.newVariantForm.markAllAsTouched(); return; }
    const product = this.selectedProduct();
    if (!product) return;

    const v = this.newVariantForm.getRawValue();
    const body = {
      productId:         product.id,
      sku:               v.sku,
      variantName:       v.variantName || null,
      barcode:           v.barcode || null,
      initialQuantity:   v.initialQuantity ?? 0,
      lowStockThreshold: v.lowStockThreshold ?? 10
    };

    this._http.post(`${this._base}/inventory`, body).subscribe({
      next: () => {
        this.closeGlobalAdd();
        this._load();
        this._showMsg(
          `Inventory created for "${product.name}" — SKU ${v.sku}, initial stock: ${v.initialQuantity}.`,
          'success'
        );
      },
      error: (err) => {
        const msg = extractApiError(err, 'Failed to create inventory record.');
        this._showMsg(msg, 'error');
      }
    });
  }

  private _showMsg(text: string, type: 'success' | 'error'): void {
    this.message.set(text);
    this.messageType.set(type);
    setTimeout(() => this.message.set(''), 5000);
  }
}
