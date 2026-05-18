import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet, Router } from '@angular/router';
import { AdminAuthService } from '../../../core/services/admin-auth.service';
import { PermissionsService } from '../../../core/services/permissions.service';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

import { ImageUrlPipe } from '../../pipes/image-url.pipe';

interface NavItem {
  label: string;
  icon: string;
  route: string;
  module?: string;
  roles?: string[];
}

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet, ImageUrlPipe],
  templateUrl: './admin-layout.component.html',
  styleUrl: './admin-layout.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminLayoutComponent implements OnInit {
  protected readonly auth = inject(AdminAuthService);
  private readonly _perms = inject(PermissionsService);
  private readonly _http = inject(HttpClient);
  private readonly _router = inject(Router);
  protected sidebarOpen = signal(false);

  // Global search signals
  protected showSearch = signal(false);
  protected searchQuery = signal('');
  protected searchResults = signal<any>(null);
  protected searchLoading = signal(false);

  @HostListener('window:keydown', ['$event'])
  protected handleKeyDown(event: KeyboardEvent): void {
    if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
      event.preventDefault();
      this.toggleSearch();
    } else if (event.key === 'Escape' && this.showSearch()) {
      this.closeSearch();
    }
  }

  protected toggleSearch(): void {
    const isShowing = !this.showSearch();
    this.showSearch.set(isShowing);
    if (!isShowing) {
      this.closeSearch();
    }
  }

  protected closeSearch(): void {
    this.showSearch.set(false);
    this.searchQuery.set('');
    this.searchResults.set(null);
  }

  protected onSearchInput(val: string): void {
    this.searchQuery.set(val);
    const q = val.trim();
    if (!q) {
      this.searchResults.set(null);
      return;
    }
    this.searchLoading.set(true);
    this._http.get<any>(`${environment.apiUrl}/admin/search?q=${encodeURIComponent(q)}`).subscribe({
      next: res => {
        this.searchResults.set(res);
        this.searchLoading.set(false);
      },
      error: () => this.searchLoading.set(false)
    });
  }

  protected navigateAndClose(route: any[]): void {
    this._router.navigate(route);
    this.closeSearch();
  }

  ngOnInit(): void {
    this._perms.loadPermissions();
  }

  protected initials = computed(() => {
    const first = this.auth.user()?.firstName?.charAt(0) ?? '';
    const last  = this.auth.user()?.lastName?.charAt(0)  ?? '';
    return (first + last).toUpperCase();
  });

  protected toggleSidebar(): void {
    this.sidebarOpen.update(v => !v);
  }

  protected canView(module: string): boolean {
    return this._perms.hasPermission(module, 'view');
  }

  protected hasRole(roles: string[]): boolean {
    const r = this.auth.user()?.role;
    return r ? roles.includes(r) : false;
  }

  protected canViewGroup(group: { label: string; items: NavItem[] }): boolean {
    return group.items.some(item => 
      (!item.module || this.canView(item.module)) && 
      (!item.roles || this.hasRole(item.roles))
    );
  }

  protected navGroups: { label: string; items: NavItem[] }[] = [
    {
      label: 'Overview',
      items: [
        { label: 'Dashboard', icon: 'bi-speedometer2', route: '/dashboard' }
      ]
    },
    {
      label: 'Catalogue',
      items: [
        { label: 'Departments', icon: 'bi-grid',       route: '/catalogue/departments', module: 'Categories' },
        { label: 'Categories',  icon: 'bi-folder',     route: '/catalogue/categories',  module: 'Categories' },
        { label: 'Brands',      icon: 'bi-patch-check', route: '/catalogue/brands',      module: 'Categories' },
        { label: 'Products',    icon: 'bi-bag',        route: '/catalogue/products',    module: 'Products' },
        { label: 'Inventory',   icon: 'bi-box-seam',   route: '/catalogue/inventory',   module: 'Inventory' }
      ]
    },
    {
      label: 'Commerce',
      items: [
        { label: 'Orders',      icon: 'bi-cart3',        route: '/orders',     module: 'Orders' },
        { label: 'Promotions',  icon: 'bi-tag',          route: '/promotions', module: 'Promotions' }
      ]
    },
    {
      label: 'Customers',
      items: [
        { label: 'Users', icon: 'bi-people', route: '/users', module: 'Users' }
      ]
    },
    {
      label: 'Content',
      items: [
        { label: 'CMS', icon: 'bi-file-richtext', route: '/content', module: 'CMS' }
      ]
    },
    {
      label: 'Reports',
      items: [
        { label: 'Analytics', icon: 'bi-graph-up-arrow', route: '/analytics', module: 'Analytics' },
        { label: 'Audit Log', icon: 'bi-shield-check',   route: '/audit',     module: 'Audit' }
      ]
    },
    {
      label: 'SuperAdmin System',
      items: [
        { label: 'Access Control', icon: 'bi-shield-lock-fill', route: '/users', roles: ['SuperAdmin'] }
      ]
    }
  ];

  protected logout(): void {
    this._perms.clear();
    this.auth.logout();
  }
}
