import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';
import { PermissionsService } from '../../../core/services/permissions.service';
import { AdminPaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { extractApiError } from '../../../core/utils/api-error';

interface Department {
  departmentId: number;
  name: string;
  slug: string;
  imageUrl?: string;
}

@Component({
  selector: 'app-admin-departments',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ImageUrlPipe, AdminPaginationComponent],
  templateUrl: './departments.component.html',
  styleUrl: './departments.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminDepartmentsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);
  protected readonly perms = inject(PermissionsService);

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

  protected sortBy = signal('name');
  protected sortDirection = signal<'asc' | 'desc'>('asc');

  protected readonly pageSize = 10;
  protected currentPage = signal(1);

  protected filteredDepartments = computed(() => {
    const q = this.searchQuery().toLowerCase();
    const col = this.sortBy();
    const dir = this.sortDirection();

    const filtered = q
      ? this.departments().filter(d =>
          d.name.toLowerCase().includes(q) ||
          d.slug.toLowerCase().includes(q)
        )
      : this.departments().slice();

    return [...filtered].sort((a, b) => {
      const valA = String((a as any)[col] ?? '');
      const valB = String((b as any)[col] ?? '');
      const cmp = valA.localeCompare(valB, undefined, { numeric: true, sensitivity: 'base' });
      return dir === 'asc' ? cmp : -cmp;
    });
  });

  protected totalPages = computed(() => Math.max(1, Math.ceil(this.filteredDepartments().length / this.pageSize)));
  protected pagedDepartments = computed(() => {
    const start = (this.currentPage() - 1) * this.pageSize;
    return this.filteredDepartments().slice(start, start + this.pageSize);
  });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  protected form = this._fb.group({
    name: ['', Validators.required],
    slug: ['', [Validators.required, Validators.pattern(/^[a-z0-9-]+$/)]],
  });

  private get _base() { return `${environment.apiUrl}/admin`; }

  ngOnInit(): void {
    this._loadAll();

    // Auto-generate slug from name
    this.form.get('name')?.valueChanges.subscribe(name => {
      if (name && !this.editId()) {
        const slug = name
          .toLowerCase()
          .trim()
          .replace(/[^\w\s-]/g, '')
          .replace(/[\s_-]+/g, '-')
          .replace(/^-+|-+$/g, '');
        this.form.patchValue({ slug }, { emitEvent: false });
      }
    });
  }

  private _loadAll(): void {
    this.loading.set(true);
    this._http.get<Department[]>(`${this._base}/departments`).subscribe({
      next: d => { this.departments.set(d); this.currentPage.set(1); this.loading.set(false); },
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
    this.form.reset();
    this._resetFileState();
    this.showForm.set(true);
  }

  protected openEdit(dept: Department): void {
    this.editId.set(dept.departmentId);
    this.form.patchValue({ name: dept.name, slug: dept.slug });
    this.existingImageUrl.set(dept.imageUrl ?? null);
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

    this._http.post<{ path: string }>(`${environment.apiUrl}/admin/images/upload?folder=departments`, fd).subscribe({
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
    const { name, slug } = this.form.getRawValue();
    const body = { name, slug, imageUrl: imageUrl || null };

    const req = this.editId()
      ? this._http.put(`${this._base}/departments/${this.editId()}`, body)
      : this._http.post(`${this._base}/departments`, body);

    req.subscribe({
      next: () => {
        this.showForm.set(false);
        this._loadAll();
        this._showMessage('Department saved successfully.', 'success');
        this.saving.set(false);
      },
      error: (err) => { this._showMessage(extractApiError(err, 'Save failed.'), 'error'); this.saving.set(false); }
    });
  }

  protected deleteDepartment(id: number): void {
    if (confirm('Are you sure you want to delete this department? This will also soft delete all associated categories.')) {
      this._http.delete(`${this._base}/departments/${id}`).subscribe({
        next: () => { this._loadAll(); this._showMessage('Department deleted successfully.', 'success'); },
        error: (err) => this._showMessage(extractApiError(err, 'Delete failed.'), 'error')
      });
    }
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
