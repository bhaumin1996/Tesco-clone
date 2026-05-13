import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface UserRow {
  userId: number;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  isLocked: boolean;
  createdOn: string;
}

interface PagedResult<T> { items: T[]; totalPages: number; }

@Component({
  selector: 'app-admin-users',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './users.component.html',
  styleUrl: './users.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminUsersComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected users = signal<UserRow[]>([]);
  protected totalPages = signal(1);
  protected currentPage = signal(1);
  protected loading = signal(true);
  protected message = signal('');

  protected filterForm = this._fb.group({ search: [''], role: [''] });
  protected readonly roles = ['Customer', 'Admin', 'SuperAdmin'];

  private get _base() { return `${environment.apiUrl}/admin/users`; }

  ngOnInit(): void {
    this._load();
    this.filterForm.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.currentPage.set(1); this._load();
    });
  }

  private _load(): void {
    this.loading.set(true);
    const { search, role } = this.filterForm.getRawValue();
    const params: Record<string, string> = { pageNumber: String(this.currentPage()), pageSize: '20' };
    if (search) params['search'] = search;
    if (role) params['role'] = role;
    this._http.get<PagedResult<UserRow>>(this._base, { params }).subscribe({
      next: r => { this.users.set(r.items); this.totalPages.set(r.totalPages); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected goTo(page: number): void { this.currentPage.set(page); this._load(); }

  protected toggleLock(user: UserRow): void {
    const action = user.isLocked ? 'unlock' : 'lock';
    this._http.patch(`${this._base}/${user.userId}/${action}`, {}).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === user.userId ? { ...u, isLocked: !u.isLocked } : u));
        this.message.set(`User ${user.isLocked ? 'unlocked' : 'locked'}.`);
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.message.set('Action failed.')
    });
  }

  protected assignRole(userId: number, role: string): void {
    this._http.patch(`${this._base}/${userId}/role`, { role }).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === userId ? { ...u, role } : u));
        this.message.set('Role updated.');
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.message.set('Role update failed.')
    });
  }

  protected pages(): number[] { return Array.from({ length: this.totalPages() }, (_, i) => i + 1); }
}
