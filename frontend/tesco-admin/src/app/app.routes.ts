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
        path: 'catalogue/departments',
        loadComponent: () => import('./features/catalogue/departments/departments.component').then(m => m.AdminDepartmentsComponent)
      },
      {
        path: 'catalogue/brands',
        loadComponent: () => import('./features/catalogue/brands/brands.component').then(m => m.AdminBrandsComponent)
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
        path: 'orders/:id',
        loadComponent: () => import('./features/orders/order-detail/order-detail.component').then(m => m.AdminOrderDetailComponent)
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
        path: 'marketplace/applications',
        loadComponent: () => import('./features/marketplace/seller-applications/seller-applications.component').then(m => m.SellerApplicationsComponent)
      },
      {
        path: 'marketplace/performance',
        loadComponent: () => import('./features/marketplace/seller-performance/seller-performance.component').then(m => m.SellerPerformanceComponent)
      },
      {
        path: 'marketplace/commissions',
        loadComponent: () => import('./features/marketplace/commissions/commissions.component').then(m => m.CommissionsComponent)
      },
      {
        path: 'marketplace/analytics',
        loadComponent: () => import('./features/marketplace/marketplace-analytics/marketplace-analytics.component').then(m => m.MarketplaceAnalyticsComponent)
      },
      {
        path: 'marketplace/payouts',
        loadComponent: () => import('./features/marketplace/payouts/payouts.component').then(m => m.PayoutsComponent)
      },
      {
        path: 'marketplace/messages',
        loadComponent: () => import('./features/marketplace/messages/messages.component').then(m => m.MessagesComponent)
      },
      {
        path: 'marketplace/category-eligibility',
        loadComponent: () => import('./features/marketplace/category-eligibility/category-eligibility.component').then(m => m.CategoryEligibilityComponent)
      },
      {
        path: 'marketplace/returns',
        loadComponent: () => import('./features/marketplace/marketplace-returns/marketplace-returns.component').then(m => m.MarketplaceReturnsComponent)
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
