import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface Category {
  categoryId: number;
  name: string;
  slug: string;
  departmentName: string;
  productCount: number;
  isActive: boolean;
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
      next: c => { this.categories.set(c); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected openCreate(): void { this.editId.set(null); this.form.reset({ departmentId: 0 }); this.showForm.set(true); }

  protected openEdit(cat: Category): void {
    this.editId.set(cat.categoryId);
    this.form.patchValue({ name: cat.name, departmentId: Number(cat.departmentName) });
    this.showForm.set(true);
  }

  protected save(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    const body = this.form.getRawValue();
    const req = this.editId()
      ? this._http.put(`${this._base}/categories/${this.editId()}`, body)
      : this._http.post(`${this._base}/categories`, body);
    req.subscribe({
      next: () => { this.showForm.set(false); this._loadAll(); this.message.set('Saved.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Save failed.')
    });
  }

  protected deactivate(id: number): void {
    this._http.patch(`${this._base}/categories/${id}/deactivate`, {}).subscribe({
      next: () => { this._loadAll(); this.message.set('Category deactivated.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Action failed.')
    });
  }
}
