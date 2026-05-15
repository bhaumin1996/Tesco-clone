import { Routes } from '@angular/router';
import { adminAuthGuard } from './core/guards/admin-auth.guard';
import { AdminLayoutComponent } from './shared/components/admin-layout/admin-layout.component';

export const routes: Routes = [
  {
    path: 'auth/login',
    loadComponent: () => import('./features/auth/admin-login/admin-login.component').then(m => m.AdminLoginComponent)
  },
  {
    path: 'auth/forgot-password',
    loadComponent: () => import('./features/auth/forgot-password/forgot-password.component').then(m => m.ForgotPasswordComponent)
  },
  {
    path: '',
    component: AdminLayoutComponent,
    canActivate: [adminAuthGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent)
      },
      {
        path: 'catalogue/products',
        loadComponent: () => import('./features/catalogue/products/products.component').then(m => m.AdminProductsComponent)
      },
      {
        path: 'catalogue/categories',
        loadComponent: () => import('./features/catalogue/categories/categories.component').then(m => m.AdminCategoriesComponent)
      },
      {
        path: 'catalogue/inventory',
        loadComponent: () => import('./features/catalogue/inventory/inventory.component').then(m => m.AdminInventoryComponent)
      },
      {
        path: 'orders',
        loadComponent: () => import('./features/orders/orders.component').then(m => m.AdminOrdersComponent)
      },
      {
        path: 'promotions',
        loadComponent: () => import('./features/promotions/promotions.component').then(m => m.AdminPromotionsComponent)
      },
      {
        path: 'marketplace',
        loadComponent: () => import('./features/marketplace/marketplace.component').then(m => m.AdminMarketplaceComponent)
      },
      {
        path: 'users',
        loadComponent: () => import('./features/users/users.component').then(m => m.AdminUsersComponent)
      },
      {
        path: 'content',
        loadComponent: () => import('./features/content/content.component').then(m => m.AdminContentComponent)
      },
      {
        path: 'analytics',
        loadComponent: () => import('./features/analytics/analytics.component').then(m => m.AdminAnalyticsComponent)
      },
      {
        path: 'audit',
        loadComponent: () => import('./features/audit/audit.component').then(m => m.AdminAuditComponent)
      },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'dashboard' }
];
