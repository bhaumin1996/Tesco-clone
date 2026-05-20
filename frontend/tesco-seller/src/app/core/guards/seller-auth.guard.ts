import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { SellerAuthService } from '../services/seller-auth.service';

export const sellerAuthGuard: CanActivateFn = () => {
  const auth = inject(SellerAuthService);
  const router = inject(Router);
  
  if (!auth.isLoggedIn()) {
    return router.createUrlTree(['/auth/login']);
  }
  
  const user = auth.user();
  const hasSellerRole = user?.roles?.includes('Seller');
  
  if (!hasSellerRole) {
    return router.createUrlTree(['/auth/apply']);
  }
  
  return true;
};
