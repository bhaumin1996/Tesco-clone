import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
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

  protected toggleSidebar(): void {
    this.sidebarOpen.update(v => !v);
  }

  protected navGroups: { label: string; items: NavItem[] }[] = [
    {
      label: 'Overview',
      items: [
        { label: 'Dashboard', icon: '📊', route: '/dashboard' }
      ]
    },
    {
      label: 'Catalogue',
      items: [
        { label: 'Products', icon: '🛍️', route: '/catalogue/products' },
        { label: 'Categories', icon: '📂', route: '/catalogue/categories' },
        { label: 'Inventory', icon: '📦', route: '/catalogue/inventory' }
      ]
    },
    {
      label: 'Commerce',
      items: [
        { label: 'Orders', icon: '🛒', route: '/orders' },
        { label: 'Promotions', icon: '🏷️', route: '/promotions' },
        { label: 'Marketplace', icon: '🏪', route: '/marketplace' }
      ]
    },
    {
      label: 'Customers',
      items: [
        { label: 'Users', icon: '👥', route: '/users' }
      ]
    },
    {
      label: 'Content',
      items: [
        { label: 'CMS', icon: '📝', route: '/content' }
      ]
    },
    {
      label: 'Reports',
      items: [
        { label: 'Analytics', icon: '📈', route: '/analytics' },
        { label: 'Audit Log', icon: '🔍', route: '/audit' }
      ]
    }
  ];

  protected logout(): void { this.auth.logout(); }
}
