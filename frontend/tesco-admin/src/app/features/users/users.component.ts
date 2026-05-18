import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { AdminAuthService } from '../../core/services/admin-auth.service';
import { PermissionsService, AdminPermission } from '../../core/services/permissions.service';
import { AdminPaginationComponent } from '../../shared/components/pagination/pagination.component';
import { extractApiError } from '../../core/utils/api-error';

interface UserRow {
  userId: number;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  isLocked: boolean;
  status: string;
  createdOn: string;
}

interface AdminUserDto {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  statusName: string;
  roles: string[];
  createdOn: string;
}

interface PagedResult<T> { items: T[]; totalPages: number; }

@Component({
  selector: 'app-admin-users',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, AdminPaginationComponent],
  templateUrl: './users.component.html',
  styleUrl: './users.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminUsersComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);
  protected readonly auth = inject(AdminAuthService);
  protected readonly perms = inject(PermissionsService);

  protected users = signal<UserRow[]>([]);
  protected totalPages = signal(1);
  protected currentPage = signal(1);
  protected loading = signal(true);
  protected message = signal('');

  // ── add admin user state ──────────────────────────────────────────────────
  protected showAddAdminForm = signal(false);
  protected savingAdmin = signal(false);

  // ── permissions management state ──────────────────────────────────────────
  protected showPermissionsForm = signal(false);
  protected selectedUserForPermissions = signal<UserRow | null>(null);
  protected permissionsSaving = signal(false);
  protected permissionsList = signal<AdminPermission[]>([]);

  protected readonly permissionModules = [
    { name: 'Products', label: 'Products Catalogue', icon: 'bi-bag-dash-fill', color: '#00539f' },
    { name: 'Categories', label: 'Product Categories', icon: 'bi-folder-fill', color: '#10b981' },
    { name: 'Inventory', label: 'Inventory & Stock', icon: 'bi-box-seam-fill', color: '#f59e0b' },
    { name: 'Orders', label: 'Orders Management', icon: 'bi-cart-fill', color: '#8b5cf6' },
    { name: 'Promotions', label: 'Promotions & Offers', icon: 'bi-tag-fill', color: '#ef4444' },
    { name: 'Users', label: 'User & Staff Management', icon: 'bi-people-fill', color: '#06b6d4' },
    { name: 'CMS', label: 'CMS Content & Banners', icon: 'bi-file-earmark-richtext-fill', color: '#d97706' },
    { name: 'Analytics', label: 'Sales & Top Product Analytics', icon: 'bi-bar-chart-line-fill', color: '#3b82f6' },
    { name: 'Audit', label: 'System Logs & Auditing', icon: 'bi-journal-text', color: '#6b7280' }
  ];

  protected filterForm = this._fb.group({ search: [''], role: [''] });
  protected readonly roles = ['Customer', 'Admin', 'SuperAdmin'];
  private readonly _roleIds: Record<string, number> = { 'Admin': 1, 'Customer': 2, 'SuperAdmin': 4 };

  protected addAdminForm = this._fb.group({
    firstName: ['', [Validators.required, Validators.maxLength(100)]],
    lastName: ['', [Validators.required, Validators.maxLength(100)]],
    email: ['', [Validators.required, Validators.email, Validators.maxLength(256)]],
    password: ['', [
      Validators.required,
      Validators.minLength(8),
      Validators.maxLength(128),
      Validators.pattern(/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/)
    ]],
    role: ['Admin', Validators.required]
  });

  protected sortBy = signal('createdOn');
  protected sortDirection = signal<'asc' | 'desc'>('desc');

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
    const params: Record<string, string> = {
      pageNumber: String(this.currentPage()),
      pageSize: '20',
      sortBy: this.sortBy(),
      sortDirection: this.sortDirection()
    };
    if (search) params['search'] = search;
    if (role) params['role'] = role;

    this._http.get<PagedResult<AdminUserDto>>(this._base, { params }).subscribe({
      next: r => {
        const mapped = r.items.map(dto => ({
          userId: dto.id,
          firstName: dto.firstName,
          lastName: dto.lastName,
          email: dto.email,
          role: dto.roles && dto.roles.includes('SuperAdmin') ? 'SuperAdmin' : (dto.roles && dto.roles.length > 0 ? dto.roles[0] : 'Customer'),
          isLocked: dto.statusName === 'Locked',
          status: dto.statusName,
          createdOn: dto.createdOn
        }));
        this.users.set(mapped);
        this.totalPages.set(r.totalPages);
        this.loading.set(false);
      },
      error: () => this.loading.set(false)
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

  protected toggleLock(user: UserRow): void {
    const action = user.isLocked ? 'unlock' : 'lock';
    this._http.post(`${this._base}/${user.userId}/${action}`, {}).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === user.userId ? { ...u, isLocked: !u.isLocked, status: user.isLocked ? 'Active' : 'Locked' } : u));
        this.message.set(`User ${user.isLocked ? 'unlocked' : 'locked'}.`);
        setTimeout(() => this.message.set(''), 3000);
      },
      error: (err) => this.message.set(extractApiError(err, 'Action failed.'))
    });
  }

  protected deactivateUser(user: UserRow): void {
    this._http.post(`${this._base}/${user.userId}/deactivate`, {}).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === user.userId ? { ...u, status: 'Disabled' } : u));
        this.message.set(`User "${user.firstName} ${user.lastName}" has been deactivated.`);
        setTimeout(() => this.message.set(''), 3500);
      },
      error: (err) => this.message.set(extractApiError(err, 'Deactivation failed.'))
    });
  }

  protected activateUser(user: UserRow): void {
    this._http.post(`${this._base}/${user.userId}/activate`, {}).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === user.userId ? { ...u, status: 'Active' } : u));
        this.message.set(`User "${user.firstName} ${user.lastName}" has been activated.`);
        setTimeout(() => this.message.set(''), 3500);
      },
      error: (err) => this.message.set(extractApiError(err, 'Activation failed.'))
    });
  }

  protected confirmDeleteUser(user: UserRow): void {
    if (confirm(`Are you sure you want to permanently delete the admin account for "${user.firstName} ${user.lastName}"?\n\nThis action cannot be undone.`)) {
      this._http.delete(`${this._base}/${user.userId}`).subscribe({
        next: () => {
          this.users.update(list => list.filter(u => u.userId !== user.userId));
          this.message.set(`User "${user.firstName} ${user.lastName}" has been successfully deleted.`);
          setTimeout(() => this.message.set(''), 4000);
        },
        error: (err) => {
          this.message.set(extractApiError(err, 'Delete operation failed.'));
          setTimeout(() => this.message.set(''), 4000);
        }
      });
    }
  }

  protected assignRole(userId: number, role: string): void {
    const roleId = this._roleIds[role];
    if (!roleId) return;

    this._http.post(`${this._base}/${userId}/roles`, { roleId }).subscribe({
      next: () => {
        this.users.update(list => list.map(u => u.userId === userId ? { ...u, role } : u));
        this.message.set('Role updated.');
        setTimeout(() => this.message.set(''), 3000);
      },
      error: (err) => this.message.set(extractApiError(err, 'Role update failed.'))
    });
  }

  protected openPermissions(user: UserRow): void {
    this.selectedUserForPermissions.set(user);
    this.showPermissionsForm.set(false); // reset form visibility during loading
    this.permissionsList.set([]); // clear
    this.loading.set(true);

    this._http.get<AdminPermission[]>(`${this._base}/${user.userId}/permissions`).subscribe({
      next: (perms) => {
        // Initialize permissions with active data or all empty for non-assigned modules
        const initialized: AdminPermission[] = this.permissionModules.map(m => {
          const existing = perms.find(p => p.moduleName.toLowerCase() === m.name.toLowerCase());
          return existing ? {
            moduleName: m.name,
            canView: existing.canView,
            canAdd: existing.canAdd,
            canEdit: existing.canEdit,
            canDelete: existing.canDelete
          } : {
            moduleName: m.name,
            canView: false,
            canAdd: false,
            canEdit: false,
            canDelete: false
          };
        });

        this.permissionsList.set(initialized);
        this.showPermissionsForm.set(true);
        this.loading.set(false);
      },
      error: (err) => {
        this.loading.set(false);
        this.message.set(extractApiError(err, 'Failed to load user permissions.'));
        setTimeout(() => this.message.set(''), 3000);
      }
    });
  }

  protected cancelPermissions(): void {
    this.showPermissionsForm.set(false);
    this.selectedUserForPermissions.set(null);
    this.permissionsList.set([]);
  }

  protected savePermissions(): void {
    const user = this.selectedUserForPermissions();
    if (!user) return;

    this.permissionsSaving.set(true);
    this._http.post(`${this._base}/${user.userId}/permissions`, this.permissionsList()).subscribe({
      next: () => {
        this.permissionsSaving.set(false);
        this.showPermissionsForm.set(false);
        this.selectedUserForPermissions.set(null);
        this.permissionsList.set([]);
        this.message.set('Permissions updated successfully.');
        // Also if we edited ourselves, let's refresh our permissions!
        if (user.userId === this.auth.user()?.id) {
          this.perms.loadPermissions();
        }
        setTimeout(() => this.message.set(''), 3500);
      },
      error: (err) => {
        this.permissionsSaving.set(false);
        this.message.set(extractApiError(err, 'Failed to save permissions.'));
        setTimeout(() => this.message.set(''), 3000);
      }
    });
  }

  protected hasModulePerm(moduleName: string, action: 'canView' | 'canAdd' | 'canEdit' | 'canDelete'): boolean {
    const list = this.permissionsList();
    const item = list.find(p => p.moduleName.toLowerCase() === moduleName.toLowerCase());
    return item ? item[action] : false;
  }

  protected toggleModulePerm(moduleName: string, action: 'canView' | 'canAdd' | 'canEdit' | 'canDelete'): void {
    this.permissionsList.update(list => {
      const idx = list.findIndex(p => p.moduleName.toLowerCase() === moduleName.toLowerCase());
      if (idx > -1) {
        const item = list[idx];
        const updated = { ...item, [action]: !item[action] };
        // If enabling add, edit, or delete, auto-enable view!
        if (action !== 'canView' && updated[action]) {
          updated.canView = true;
        }
        // If disabling view, auto-disable add, edit, delete!
        if (action === 'canView' && !updated.canView) {
          updated.canAdd = false;
          updated.canEdit = false;
          updated.canDelete = false;
        }
        const copy = [...list];
        copy[idx] = updated;
        return copy;
      } else {
        const newItem = {
          moduleName,
          canView: action === 'canView' ? true : false,
          canAdd: action === 'canAdd' ? true : false,
          canEdit: action === 'canEdit' ? true : false,
          canDelete: action === 'canDelete' ? true : false
        };
        // If enabling add, edit, or delete, auto-enable view!
        if (action !== 'canView' && newItem[action]) {
          newItem.canView = true;
        }
        return [...list, newItem];
      }
    });
  }

  protected openAddAdmin(): void {
    this.addAdminForm.reset({ role: 'Admin', firstName: '', lastName: '', email: '', password: '' });
    this.showAddAdminForm.set(true);
    this.showPermissionsForm.set(false);
  }

  protected cancelAddAdmin(): void {
    this.showAddAdminForm.set(false);
  }

  protected saveAdminUser(): void {
    if (this.addAdminForm.invalid) return;

    this.savingAdmin.set(true);
    const body = this.addAdminForm.getRawValue();

    this._http.post(this._base, body).subscribe({
      next: () => {
        this.savingAdmin.set(false);
        this.showAddAdminForm.set(false);
        this.message.set('Admin user created successfully.');
        this._load();
        setTimeout(() => this.message.set(''), 3500);
      },
      error: (err) => {
        this.savingAdmin.set(false);
        this.message.set(extractApiError(err, 'Failed to create admin user.'));
        setTimeout(() => this.message.set(''), 4000);
      }
    });
  }

  protected pages(): number[] { return Array.from({ length: this.totalPages() }, (_, i) => i + 1); }
}
