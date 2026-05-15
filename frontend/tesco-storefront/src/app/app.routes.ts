import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'auth',
    children: [
      {
        path: 'login',
        loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent)
      },
      {
        path: 'register',
        loadComponent: () => import('./features/auth/register/register.component').then(m => m.RegisterComponent)
      },
      { path: '', redirectTo: 'login', pathMatch: 'full' }
    ]
  },
  {
    path: 'departments',
    children: [
      {
        path: '',
        loadComponent: () => import('./features/catalogue/departments/departments.component').then(m => m.DepartmentsComponent)
      },
      {
        path: ':deptSlug',
        loadComponent: () => import('./features/catalogue/category/category.component').then(m => m.CategoryComponent)
      },
      {
        path: ':deptSlug/:categorySlug',
        loadComponent: () => import('./features/catalogue/category/category.component').then(m => m.CategoryComponent)
      }
    ]
  },
  {
    path: 'products/:id',
    loadComponent: () => import('./features/catalogue/product-detail/product-detail.component').then(m => m.ProductDetailComponent)
  },
  {
    path: 'search',
    loadComponent: () => import('./features/search/search.component').then(m => m.SearchComponent)
  },
  {
    path: 'cart',
    loadComponent: () => import('./features/cart/cart.component').then(m => m.CartComponent)
  },
  {
    path: 'checkout',
    canActivate: [authGuard],
    loadComponent: () => import('./features/checkout/checkout.component').then(m => m.CheckoutComponent)
  },
  {
    path: 'account',
    canActivate: [authGuard],
    children: [
      {
        path: '',
        loadComponent: () => import('./features/account/account-dashboard/account-dashboard.component').then(m => m.AccountDashboardComponent)
      },
      {
        path: 'orders',
        children: [
          {
            path: '',
            loadComponent: () => import('./features/orders/order-list/order-list.component').then(m => m.OrderListComponent)
          },
          {
            path: ':id',
            loadComponent: () => import('./features/orders/order-detail/order-detail.component').then(m => m.OrderDetailComponent)
          }
        ]
      },
      {
        path: 'clubcard',
        loadComponent: () => import('./features/clubcard/clubcard.component').then(m => m.ClubcardComponent)
      }
    ]
  },
  {
    path: 'offers',
    redirectTo: '/departments',
    pathMatch: 'full'
  },
  {
    path: 'delivery',
    loadComponent: () => import('./features/delivery/delivery-slots/delivery-slots.component').then(m => m.DeliverySlotsComponent)
  },
  {
    path: 'stores',
    loadComponent: () => import('./features/store-locator/store-locator.component').then(m => m.StoreLocatorComponent)
  },
  {
    path: 'recipes',
    loadComponent: () => import('./features/recipes/recipes.component').then(m => m.RecipesComponent)
  },
  {
    path: 'help',
    loadComponent: () => import('./features/help/help.component').then(m => m.HelpComponent)
  },
  {
    path: 'product-recall',
    loadComponent: () => import('./features/product-recall/product-recall.component').then(m => m.ProductRecallComponent)
  },
  {
    path: 'magazine',
    loadComponent: () => import('./features/tesco-magazine/tesco-magazine.component').then(m => m.TescoMagazineComponent)
  },
  {
    path: 'accessibility',
    loadComponent: () => import('./features/accessibility/accessibility.component').then(m => m.AccessibilityComponent)
  },
  {
    path: 'terms-and-conditions',
    loadComponent: () => import('./features/terms-and-conditions/terms-and-conditions.component').then(m => m.TermsAndConditionsComponent)
  },
  {
    path: 'product-terms',
    loadComponent: () => import('./features/product-terms/product-terms.component').then(m => m.ProductTermsComponent)
  },
  {
    path: 'ratings-reviews-policy',
    loadComponent: () => import('./features/ratings-reviews-policy/ratings-reviews-policy.component').then(m => m.RatingsReviewsPolicyComponent)
  },
  {
    path: '**',
    redirectTo: ''
  }
];
