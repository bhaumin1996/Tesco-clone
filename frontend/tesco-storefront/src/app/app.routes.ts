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
      {
        path: 'forgot-password',
        loadComponent: () => import('./features/auth/forgot-password/forgot-password.component').then(m => m.ForgotPasswordComponent)
      },
      {
        path: 'reset-password',
        loadComponent: () => import('./features/auth/reset-password/reset-password.component').then(m => m.ResetPasswordComponent)
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
            path: 'marketplace',
            children: [
              {
                path: '',
                loadComponent: () => import('./features/marketplace/marketplace-orders/marketplace-orders.component').then(m => m.MarketplaceOrdersComponent)
              },
              {
                path: ':id/return',
                loadComponent: () => import('./features/marketplace/marketplace-return/marketplace-return.component').then(m => m.MarketplaceReturnComponent)
              }
            ]
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
      },
      {
        path: 'addresses',
        loadComponent: () => import('./features/account/addresses/addresses.component').then(m => m.AddressesComponent)
      },
      {
        path: 'profile',
        loadComponent: () => import('./features/account/profile/profile.component').then(m => m.ProfileComponent)
      },
      {
        path: 'cards',
        loadComponent: () => import('./features/account/cards/cards.component').then(m => m.CardsComponent)
      },
      {
        path: 'favourites',
        loadComponent: () => import('./features/account/favourites/favourites.component').then(m => m.FavouritesComponent)
      }
    ]
  },
  {
    path: 'marketplace',
    children: [
      {
        path: '',
        loadComponent: () => import('./features/marketplace/marketplace-landing/marketplace-landing.component').then(m => m.MarketplaceLandingComponent)
      },
      {
        path: 'shop',
        loadComponent: () => import('./features/marketplace/marketplace-shop/marketplace-shop.component').then(m => m.MarketplaceShopComponent)
      },
      {
        path: 'shop/:category',
        loadComponent: () => import('./features/marketplace/marketplace-shop/marketplace-shop.component').then(m => m.MarketplaceShopComponent)
      },
      {
        path: 'sellers/:id',
        loadComponent: () => import('./features/marketplace/seller-profile/seller-profile.component').then(m => m.SellerProfileComponent)
      },
      {
        path: 'guarantee',
        loadComponent: () => import('./features/marketplace/marketplace-guarantee/marketplace-guarantee.component').then(m => m.MarketplaceGuaranteeComponent)
      }
    ]
  },
  {
    path: 'offers',
    loadComponent: () => import('./features/offers/offers.component').then(m => m.OffersComponent)
  },
  {
    path: 'banners',
    loadComponent: () => import('./features/banners/banners.component').then(m => m.BannersComponent)
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
    path: 'delivery-saver',
    children: [
      {
        path: '',
        loadComponent: () => import('./features/delivery-saver/delivery-saver.component').then(m => m.DeliverySaverComponent)
      },
      {
        path: 'terms',
        loadComponent: () => import('./features/delivery-saver/delivery-saver-terms/delivery-saver-terms.component').then(m => m.DeliverySaverTermsComponent)
      }
    ]
  },
  {
    path: '**',
    redirectTo: ''
  }
];
