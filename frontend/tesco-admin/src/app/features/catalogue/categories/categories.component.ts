import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface Category {
  categoryId: number;
  name: string;
  slug: string;
  departmentId: number;
  departmentName: string;
  productCount: number;
  isActive: boolean;
  imageUrl?: string;
}

interface Department { departmentId: number; name: string; }

@Component({
  selector: 'app-admin-categories',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
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

  protected readonly pageSize = 10;
  protected currentPage = signal(1);
  protected totalPages = computed(() => Math.max(1, Math.ceil(this.categories().length / this.pageSize)));
  protected pagedCategories = computed(() => {
    const start = (this.currentPage() - 1) * this.pageSize;
    return this.categories().slice(start, start + this.pageSize);
  });
  protected pageNumbers = computed(() => Array.from({ length: this.totalPages() }, (_, i) => i + 1));

  protected form = this._fb.group({
    name: ['', Validators.required],
    departmentId: [0, [Validators.required, Validators.min(1)]],
    imageUrl: ['']
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

  protected goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages()) this.currentPage.set(page);
  }

  protected rowIndex(indexOnPage: number): number {
    return (this.currentPage() - 1) * this.pageSize + indexOnPage + 1;
  }

  protected openCreate(): void {
    this.editId.set(null);
    this.form.reset({ departmentId: 0, imageUrl: '' });
    this.showForm.set(true);
  }

  protected openEdit(cat: Category): void {
    this.editId.set(cat.categoryId);
    this.form.patchValue({ name: cat.name, departmentId: cat.departmentId, imageUrl: cat.imageUrl ?? '' });
    this.showForm.set(true);
  }

  protected save(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.saving.set(true);

    const { name, departmentId, imageUrl } = this.form.getRawValue();
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

  protected deactivate(id: number): void {
    this._http.patch(`${this._base}/categories/${id}/deactivate`, {}).subscribe({
      next: () => { this._loadAll(); this._showMessage('Category deactivated.', 'success'); },
      error: () => this._showMessage('Action failed.', 'error')
    });
  }

  private _showMessage(text: string, type: 'success' | 'error'): void {
    this.message.set(text);
    this.messageType.set(type);
    setTimeout(() => this.message.set(''), 3500);
  }
}
