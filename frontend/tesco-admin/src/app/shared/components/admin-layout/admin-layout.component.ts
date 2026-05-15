import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AdminAuthService } from '../../../core/services/admin-auth.service';

interface NavItem {
  label: string;
  icon: string;
  route: string;
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
export class AdminLayoutComponent {
  protected readonly auth = inject(AdminAuthService);
  protected sidebarOpen = signal(false);

  protected initials = computed(() => {
    const first = this.auth.user()?.firstName?.charAt(0) ?? '';
    const last  = this.auth.user()?.lastName?.charAt(0)  ?? '';
    return (first + last).toUpperCase();
  });

  protected toggleSidebar(): void {
    this.sidebarOpen.update(v => !v);
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
        { label: 'Products',   icon: 'bi-bag',        route: '/catalogue/products' },
        { label: 'Categories', icon: 'bi-folder',     route: '/catalogue/categories' },
        { label: 'Inventory',  icon: 'bi-box-seam',   route: '/catalogue/inventory' }
      ]
    },
    {
      label: 'Commerce',
      items: [
        { label: 'Orders',      icon: 'bi-cart3',        route: '/orders' },
        { label: 'Promotions',  icon: 'bi-tag',          route: '/promotions' },
        { label: 'Marketplace', icon: 'bi-shop',         route: '/marketplace' }
      ]
    },
    {
      label: 'Customers',
      items: [
        { label: 'Users', icon: 'bi-people', route: '/users' }
      ]
    },
    {
      label: 'Content',
      items: [
        { label: 'CMS', icon: 'bi-file-richtext', route: '/content' }
      ]
    },
    {
      label: 'Reports',
      items: [
        { label: 'Analytics', icon: 'bi-graph-up-arrow', route: '/analytics' },
        { label: 'Audit Log', icon: 'bi-shield-check',   route: '/audit' }
      ]
    }
  ];

  protected logout(): void { this.auth.logout(); }
}
