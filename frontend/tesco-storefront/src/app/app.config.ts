import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding, withRouterConfig, withInMemoryScrolling } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideNgxStripe } from 'ngx-stripe';
import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, 
      withComponentInputBinding(), 
      withRouterConfig({ paramsInheritanceStrategy: 'always' }),
      withInMemoryScrolling({ 
        anchorScrolling: 'enabled', 
        scrollPositionRestoration: 'enabled' 
      })
    ),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideNgxStripe('pk_test_51TXcGTHjHswXxF33Ae6smAuBKAmH3BtAdmR2dwce6i7dQoD4rSw96RDEcDPMjgZujXUrguG3jkLXGNJ5xRTJYLvx00C02oFQjd')
  ]
};
