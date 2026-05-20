import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { SellerAuthService } from '../services/seller-auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(SellerAuthService);
  const token = auth.getToken();
  if (token) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  }
  return next(req);
};
