import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AdminAuthService } from './admin-auth.service';
import { environment } from '../../../environments/environment';

export interface AdminPermission {
  moduleName: string;
  canView: boolean;
  canAdd: boolean;
  canEdit: boolean;
  canDelete: boolean;
}

@Injectable({ providedIn: 'root' })
export class PermissionsService {
  private readonly _http = inject(HttpClient);
  private readonly _auth = inject(AdminAuthService);

  readonly permissions = signal<AdminPermission[]>([]);

  private get _url() {
    return `${environment.apiUrl}/admin/users/my-permissions`;
  }

  loadPermissions(): void {
    if (!this._auth.isAuthenticated()) {
      this.permissions.set([]);
      return;
    }

    this._http.get<AdminPermission[]>(this._url).subscribe({
      next: (perms) => this.permissions.set(perms),
      error: () => this.permissions.set([])
    });
  }

  hasPermission(moduleName: string, action: 'view' | 'add' | 'edit' | 'delete'): boolean {
    const user = this._auth.user();
    if (!user) return false;

    // SuperAdmin always has all rights!
    if (user.role === 'SuperAdmin') return true;

    // Standard admin permissions check
    const perm = this.permissions().find(
      (p) => p.moduleName.toLowerCase() === moduleName.toLowerCase()
    );
    if (!perm) return false;

    switch (action) {
      case 'view': return perm.canView;
      case 'add': return perm.canAdd;
      case 'edit': return perm.canEdit;
      case 'delete': return perm.canDelete;
      default: return false;
    }
  }

  clear(): void {
    this.permissions.set([]);
  }
}
