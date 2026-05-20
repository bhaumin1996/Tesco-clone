import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { SellerAuthService } from '../../../core/services/seller-auth.service';

interface NavItem { label: string; icon: string; route: string; }

const NAV_ITEMS: NavItem[] = [
  { label: 'Dashboard',   icon: '📊', route: '/dashboard' },
  { label: 'Listings',    icon: '📦', route: '/listings' },
  { label: 'Orders',      icon: '🛒', route: '/orders' },
  { label: 'Returns',     icon: '↩️',  route: '/returns' },
  { label: 'Inventory',   icon: '🗄️',  route: '/inventory' },
  { label: 'Performance', icon: '📈', route: '/performance' },
  { label: 'Finance',     icon: '💰', route: '/finance' },
  { label: 'Profile',     icon: '🏪', route: '/profile' },
  { label: 'Messages',    icon: '💬', route: '/messages' },
  { label: 'ASN',         icon: '🚚', route: '/asn' }
];

@Component({
  selector: 'app-seller-layout',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './seller-layout.component.html',
  styleUrl: './seller-layout.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerLayoutComponent {
  readonly auth = inject(SellerAuthService);
  readonly navItems = NAV_ITEMS;
  readonly sidebarOpen = signal(false);

  toggleSidebar(): void { this.sidebarOpen.update(v => !v); }

  logout(): void { this.auth.logout(); }
}
