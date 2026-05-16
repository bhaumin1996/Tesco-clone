import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

interface Category {
  categoryId: number;
  name: string;
  slug: string;
  departmentId: number;
  departmentName: string;
  productCount: number;
  isActive: boolean;
  imageUrl?: string;
  createdOn?: string;
}

interface Department { departmentId: number; name: string; }

@Component({
  selector: 'app-admin-categories',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ImageUrlPipe],
  templateUrl: './categories.component.html',
  styleUrl: './categories.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminCategoriesComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected categories = signal<Category[]>([]);
  protected departments = signal<Department[]>([]);
  protected loading = signal(true);
  protected showForm = signal(false);
  protected editId = signal<number | null>(null);
  protected message = signal('');
  protected messageType = signal<'success' | 'error'>('success');
  protected saving = signal(false);
  protected uploading = signal(false);

  protected searchQuery = signal('');
  protected selectedFile = signal<File | null>(null);
  protected previewUrl = signal<string | null>(null);
  protected existingImageUrl = signal<string | null>(null);

  protected sortBy = signal('createdOn');
  protected sortDirection = signal<'asc' | 'desc'>('desc');

  protected readonly pageSize = 10;
  protected currentPage = signal(1);
  protected filteredCategories = computed(() => {
    const q = this.searchQuery().toLowerCase();
    const col = this.sortBy();
    const dir = this.sortDirection();

    const filtered = q
      ? this.categories().filter(c =>
          c.name.toLowerCase().includes(q) ||
          c.slug.toLowerCase().includes(q) ||
          c.departmentName.toLowerCase().includes(q)
        )
      : this.categories().slice();

    return [...filtered].sort((a, b) => {
      const valA = String((a as any)[col] ?? '');
      const valB = String((b as any)[col] ?? '');
      const cmp = valA.localeCompare(valB, undefined, { numeric: true, sensitivity: 'base' });
      return dir === 'asc' ? cmp : -cmp;
    });
  });
  protected totalPages = computed(() => Math.max(1, Math.ceil(this.filteredCategories().length / this.pageSize)));
  protected pagedCategories = computed(() => {
    const start = (this.currentPage() - 1) * this.pageSize;
    return this.filteredCategories().slice(start, start + this.pageSize);
  });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  protected form = this._fb.group({
    name: ['', Validators.required],
    departmentId: [0, [Validators.required, Validators.min(1)]]
  });

  private get _base() { return `${environment.apiUrl}/admin`; }

  ngOnInit(): void {
    this._loadAll();
    this._http.get<Department[]>(`${this._base}/departments`).subscribe({ next: d => this.departments.set(d) });
  }

  private _loadAll(): void {
    this.loading.set(true);
    this._http.get<Category[]>(`${this._base}/categories`).subscribe({
      next: c => { this.categories.set(c); this.currentPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected onSearch(term: string): void { this.searchQuery.set(term); this.currentPage.set(1); }

  protected goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page);
  }

  protected rowIndex(indexOnPage: number): number {
    return (this.currentPage() - 1) * this.pageSize + indexOnPage + 1;
  }

  protected openCreate(): void {
    this.editId.set(null);
    this.form.reset({ departmentId: 0 });
    this._resetFileState();
    this.showForm.set(true);
  }

  protected openEdit(cat: Category): void {
    this.editId.set(cat.categoryId);
    this.form.patchValue({ name: cat.name, departmentId: cat.departmentId });
    this.existingImageUrl.set(cat.imageUrl ?? null);
    this._resetFileState();
    this.showForm.set(true);
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

    this._http.post<{ path: string }>(`${environment.apiUrl}/admin/images/upload?folder=categories`, fd).subscribe({
      next: res => {
        this.uploading.set(false);
        this._doSave(res.path);
      },
      error: () => {
        this.uploading.set(false);
        this.saving.set(false);
        this._showMessage('Image upload failed.', 'error');
      }
    });
  }

  private _doSave(imageUrl: string | null): void {
    this.saving.set(true);
    const { name, departmentId } = this.form.getRawValue();
    const body = { name, departmentId, imageUrl: imageUrl || null };

    const req = this.editId()
      ? this._http.put(`${this._base}/categories/${this.editId()}`, body)
      : this._http.post(`${this._base}/categories`, body);

    req.subscribe({
      next: () => {
        this.showForm.set(false);
        this._loadAll();
        this._showMessage('Category saved successfully.', 'success');
        this.saving.set(false);
      },
      error: () => { this._showMessage('Save failed.', 'error'); this.saving.set(false); }
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
  }

  protected sortIcon(col: string): string {
    if (this.sortBy() !== col) return 'bi-arrow-down-up';
    return this.sortDirection() === 'asc' ? 'bi-sort-up' : 'bi-sort-down';
  }

  protected deactivate(id: number): void {
    this._http.patch(`${this._base}/categories/${id}/deactivate`, {}).subscribe({
      next: () => { this._loadAll(); this._showMessage('Category deactivated.', 'success'); },
      error: () => this._showMessage('Action failed.', 'error')
    });
  }

  private _resetFileState(): void {
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    this.selectedFile.set(null);
    this.previewUrl.set(null);
  }

  private _showMessage(text: string, type: 'success' | 'error'): void {
    this.message.set(text);
    this.messageType.set(type);
    setTimeout(() => this.message.set(''), 3500);
  }
}
