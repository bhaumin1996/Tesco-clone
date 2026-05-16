import {
  ChangeDetectionStrategy, Component, computed,
  inject, OnInit, signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { environment } from '../../../../environments/environment';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

interface ProductRow {
  id: number;
  categoryId: number;
  categoryName: string;
  brandId: number | null;
  brandName: string | null;
  name: string;
  slug: string;
  description: string | null;
  basePrice: number;
  clubcardPrice: number | null;
  imageUrl: string | null;
  isAvailable: boolean;
  stockQuantity: number;
  createdOn: string;
  modifiedOn: string | null;
}

interface PagedResult<T> {
  items: T[];
  pageNumber: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}

interface Department { departmentId: number; name: string; }
interface CategoryOption { categoryId: number; name: string; departmentId: number; }
interface BrandOption { brandId: number; name: string; }

@Component({
  selector: 'app-admin-products',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ImageUrlPipe],
  templateUrl: './products.component.html',
  styleUrl: './products.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminProductsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  private get _base() { return `${environment.apiUrl}/admin`; }

  // ── list state ─────────────────────────────────────────────────────────────
  protected products = signal<ProductRow[]>([]);
  protected totalPages = signal(1);
  protected currentPage = signal(1);
  protected loading = signal(true);

  // ── dropdown data ─────────────────────────────────────────────────────────
  protected departments = signal<Department[]>([]);
  protected allCategories = signal<CategoryOption[]>([]);
  protected brands = signal<BrandOption[]>([]);

  // ── form state ─────────────────────────────────────────────────────────────
  protected showForm = signal(false);
  protected editId = signal<number | null>(null);
  protected saving = signal(false);
  protected uploading = signal(false);
  protected message = signal('');
  protected messageType = signal<'success' | 'error'>('success');

  // ── image upload state ────────────────────────────────────────────────────
  protected selectedFile = signal<File | null>(null);
  protected previewUrl = signal<string | null>(null);
  protected existingImageUrl = signal<string | null>(null);

  // ── delete confirm state ──────────────────────────────────────────────────
  protected deleteConfirmId = signal<number | null>(null);

  // ── sort state ────────────────────────────────────────────────────────────
  protected sortBy = signal('createdOn');
  protected sortDirection = signal<'asc' | 'desc'>('desc');

  // ── filter form ────────────────────────────────────────────────────────────
  protected filterForm = this._fb.group({
    search: [''],
    departmentId: [''],
    categoryId: ['']
  });

  // ── product form ───────────────────────────────────────────────────────────
  protected form = this._fb.group({
    formDeptId: [0],
    categoryId: [0, [Validators.required, Validators.min(1)]],
    brandId: [null as number | null],
    name: ['', [Validators.required, Validators.maxLength(300)]],
    slug: ['', [Validators.required, Validators.maxLength(320), Validators.pattern(/^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/)]],
    description: [''],
    basePrice: [null as number | null, [Validators.required, Validators.min(0.01)]],
    clubcardPrice: [null as number | null],
    isAvailable: [true]
  });

  // ── computed: categories filtered by form department ───────────────────────
  protected formDeptId = signal(0);
  protected filteredFormCategories = computed(() => {
    const deptId = this.formDeptId();
    return deptId > 0
      ? this.allCategories().filter(c => c.departmentId === deptId)
      : this.allCategories();
  });

  // ── computed: categories filtered by list filter department ───────────────
  protected filterDeptId = signal(0);
  protected filteredFilterCategories = computed(() => {
    const deptId = this.filterDeptId();
    return deptId > 0
      ? this.allCategories().filter(c => c.departmentId === deptId)
      : this.allCategories();
  });

  ngOnInit(): void {
    this._loadDropdowns();
    this._load();

    this.filterForm.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.currentPage.set(1);
      this._load();
    });

    this.form.get('formDeptId')!.valueChanges.subscribe(v => {
      this.formDeptId.set(Number(v ?? 0));
      this.form.get('categoryId')!.setValue(0);
    });

    this.form.get('name')!.valueChanges.subscribe(v => {
      if (this.editId() === null) {
        this.form.get('slug')!.setValue(this._slugify(v ?? ''), { emitEvent: false });
      }
    });
  }

  private _loadDropdowns(): void {
    this._http.get<Department[]>(`${this._base}/departments`).subscribe({ next: d => this.departments.set(d) });
    this._http.get<CategoryOption[]>(`${this._base}/categories`).subscribe({ next: c => this.allCategories.set(c) });
    this._http.get<BrandOption[]>(`${this._base}/brands`).subscribe({ next: b => this.brands.set(b) });
  }

  private _load(): void {
    this.loading.set(true);
    const { search, departmentId, categoryId } = this.filterForm.getRawValue();
    const params: Record<string, string> = {
      pageNumber: String(this.currentPage()),
      pageSize: '20',
      sortBy: this.sortBy(),
      sortDirection: this.sortDirection()
    };
    if (search) params['search'] = search;
    if (departmentId) params['departmentId'] = departmentId;
    if (categoryId) params['categoryId'] = categoryId;

    this._http.get<PagedResult<ProductRow>>(`${this._base}/products`, { params }).subscribe({
      next: r => { this.products.set(r.items); this.totalPages.set(r.totalPages); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onFilterDeptChange(event: Event): void {
    const val = Number((event.target as HTMLSelectElement).value);
    this.filterDeptId.set(val);
    this.filterForm.get('categoryId')!.setValue('', { emitEvent: false });
    this.currentPage.set(1);
    this._load();
  }

  protected openCreate(): void {
    this.editId.set(null);
    this.formDeptId.set(0);
    this.form.reset({ formDeptId: 0, categoryId: 0, brandId: null, name: '', slug: '', description: '', basePrice: null, clubcardPrice: null, isAvailable: true });
    this._resetFileState();
    this.existingImageUrl.set(null);
    this.showForm.set(true);
  }

  protected openEdit(product: ProductRow): void {
    this.editId.set(product.id);
    const deptId = this.allCategories().find(c => c.categoryId === product.categoryId)?.departmentId ?? 0;
    this.formDeptId.set(deptId);
    this.form.patchValue({
      formDeptId: deptId,
      categoryId: product.categoryId,
      brandId: product.brandId,
      name: product.name,
      slug: product.slug,
      description: product.description ?? '',
      basePrice: product.basePrice,
      clubcardPrice: product.clubcardPrice,
      isAvailable: product.isAvailable
    });
    this.existingImageUrl.set(product.imageUrl ?? null);
    this._resetFileState();
    this.showForm.set(true);
  }

  protected cancelForm(): void {
    this._resetFileState();
    this.showForm.set(false);
    this.editId.set(null);
  }

  protected onFileSelect(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0] ?? null;
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    if (file) {
      this.selectedFile.set(file);
      this.previewUrl.set(URL.createObjectURL(file));
    } else {
      this.selectedFile.set(null);
      this.previewUrl.set(null);
    }
  }

  protected removeImage(): void {
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    this.selectedFile.set(null);
    this.previewUrl.set(null);
    this.existingImageUrl.set(null);
  }

  protected save(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const file = this.selectedFile();
    if (file) {
      this._uploadThenSave(file);
    } else {
      this._doSave(this.existingImageUrl());
    }
  }

  private _uploadThenSave(file: File): void {
    this.uploading.set(true);
    this.saving.set(true);
    const fd = new FormData();
    fd.append('file', file);
    this._http.post<{ path: string }>(`${environment.apiUrl}/admin/images/upload?folder=products`, fd).subscribe({
      next: res => { this.uploading.set(false); this._doSave(res.path); },
      error: () => {
        this.uploading.set(false);
        this.saving.set(false);
        this._showMessage('Image upload failed.', 'error');
      }
    });
  }

  private _doSave(imageUrl: string | null): void {
    this.saving.set(true);
    const v = this.form.getRawValue();
    const id = this.editId();
    const body = {
      categoryId: Number(v.categoryId),
      brandId: v.brandId ? Number(v.brandId) : null,
      name: v.name,
      slug: v.slug,
      description: v.description || null,
      basePrice: Number(v.basePrice),
      clubcardPrice: v.clubcardPrice ? Number(v.clubcardPrice) : null,
      imageUrl: imageUrl || null,
      isAvailable: v.isAvailable
    };

    const req = id
      ? this._http.put(`${this._base}/products/${id}`, body)
      : this._http.post(`${this._base}/products`, body);

    req.subscribe({
      next: () => {
        this._resetFileState();
        this.showForm.set(false);
        this.editId.set(null);
        this._load();
        this._showMessage(id ? 'Product updated.' : 'Product created.', 'success');
        this.saving.set(false);
      },
      error: () => { this._showMessage('Save failed. Please check the fields and try again.', 'error'); this.saving.set(false); }
    });
  }

  private _resetFileState(): void {
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    this.selectedFile.set(null);
    this.previewUrl.set(null);
  }

  protected requestDelete(id: number): void {
    this.deleteConfirmId.set(id);
  }

  protected cancelDelete(): void {
    this.deleteConfirmId.set(null);
  }

  protected confirmDelete(id: number): void {
    this._http.delete(`${this._base}/products/${id}`).subscribe({
      next: () => {
        this.deleteConfirmId.set(null);
        this._load();
        this._showMessage('Product deleted.', 'success');
      },
      error: () => this._showMessage('Delete failed.', 'error')
    });
  }

  protected sort(col: string): void {
    if (this.sortBy() === col) {
      this.sortDirection.update(d => d === 'asc' ? 'desc' : 'asc');
    } else {
      this.sortBy.set(col);
      this.sortDirection.set('asc');
    }
    this.currentPage.set(1);
    this._load();
  }

  protected sortIcon(col: string): string {
    if (this.sortBy() !== col) return 'bi-arrow-down-up';
    return this.sortDirection() === 'asc' ? 'bi-sort-up' : 'bi-sort-down';
  }

  protected goTo(page: number): void { this.currentPage.set(page); this._load(); }

  protected pages(): number[] {
    return Array.from({ length: this.totalPages() }, (_, i) => i + 1);
  }

  private _slugify(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .trim()
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }

  private _showMessage(text: string, type: 'success' | 'error'): void {
    this.message.set(text);
    this.messageType.set(type);
    setTimeout(() => this.message.set(''), 3500);
  }
}
