import { Routes } from '@angular/router';
import { sellerAuthGuard } from './core/guards/seller-auth.guard';
import { SellerLayoutComponent } from './shared/components/seller-layout/seller-layout.component';

export const routes: Routes = [
  {
    path: 'auth',
    children: [
      {
        path: 'login',
        loadComponent: () => import('./features/auth/login.component').then(m => m.SellerLoginComponent)
      },
      {
        path: 'apply',
        loadComponent: () => import('./features/auth/apply.component').then(m => m.SellerApplyComponent)
      },
      { path: '', redirectTo: 'login', pathMatch: 'full' }
    ]
  },
  {
    path: '',
    component: SellerLayoutComponent,
    canActivate: [sellerAuthGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.SellerDashboardComponent)
      },
      {
        path: 'listings',
        loadComponent: () => import('./features/listings/listings.component').then(m => m.SellerListingsComponent)
      },
      {
        path: 'listings/new',
        loadComponent: () => import('./features/listings/listing-form.component').then(m => m.ListingFormComponent)
      },
      {
        path: 'listings/:id/edit',
        loadComponent: () => import('./features/listings/listing-form.component').then(m => m.ListingFormComponent)
      },
      {
        path: 'orders',
        loadComponent: () => import('./features/orders/orders.component').then(m => m.SellerOrdersComponent)
      },
      {
        path: 'returns',
        loadComponent: () => import('./features/returns/returns.component').then(m => m.SellerReturnsComponent)
      },
      {
        path: 'inventory',
        loadComponent: () => import('./features/inventory/inventory.component').then(m => m.SellerInventoryComponent)
      },
      {
        path: 'performance',
        loadComponent: () => import('./features/performance/performance.component').then(m => m.SellerPerformanceComponent)
      },
      {
        path: 'finance',
        loadComponent: () => import('./features/finance/finance.component').then(m => m.SellerFinanceComponent)
      },
      {
        path: 'profile',
        loadComponent: () => import('./features/profile/profile.component').then(m => m.SellerProfileComponent)
      },
      {
        path: 'messages',
        loadComponent: () => import('./features/messages/messages.component').then(m => m.SellerMessagesComponent)
      },
      {
        path: 'asn',
        loadComponent: () => import('./features/asn/asn.component').then(m => m.SellerAsnComponent)
      },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: '/dashboard' }
];
