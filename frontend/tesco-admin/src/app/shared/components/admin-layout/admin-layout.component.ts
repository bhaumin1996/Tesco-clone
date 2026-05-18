import { ChangeDetectionStrategy, Component, computed, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AdminAuthService } from '../../../core/services/admin-auth.service';
import { PermissionsService } from '../../../core/services/permissions.service';

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
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './admin-layout.component.html',
  styleUrl: './admin-layout.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminLayoutComponent implements OnInit {
  protected readonly auth = inject(AdminAuthService);
  private readonly _perms = inject(PermissionsService);
  protected sidebarOpen = signal(false);

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
        { label: 'Products',   icon: 'bi-bag',        route: '/catalogue/products',   module: 'Products' },
        { label: 'Categories', icon: 'bi-folder',     route: '/catalogue/categories', module: 'Categories' },
        { label: 'Inventory',  icon: 'bi-box-seam',   route: '/catalogue/inventory',  module: 'Inventory' }
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
