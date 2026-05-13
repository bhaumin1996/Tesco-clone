import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-account-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="page-container page-content">
      <h1 class="account-title">My Account</h1>
      @if (auth.user()) {
        <p class="account-welcome">Welcome back, <strong>{{ auth.user()!.firstName }}</strong></p>
      }

      <div class="account-grid">
        <a routerLink="/account/orders" class="account-card card card--hover">
          <div class="account-card__icon">📦</div>
          <h2 class="account-card__title">My Orders</h2>
          <p class="account-card__desc">Track, manage or re-order your past orders</p>
        </a>
        <a routerLink="/account/clubcard" class="account-card card card--hover account-card--clubcard">
          <div class="account-card__icon">💳</div>
          <h2 class="account-card__title">Clubcard</h2>
          <p class="account-card__desc">View points, vouchers and Clubcard Prices</p>
        </a>
        <a routerLink="/account/favourites" class="account-card card card--hover">
          <div class="account-card__icon">❤️</div>
          <h2 class="account-card__title">Favourites</h2>
          <p class="account-card__desc">Your saved products for quick re-ordering</p>
        </a>
        <a routerLink="/account/addresses" class="account-card card card--hover">
          <div class="account-card__icon">🏠</div>
          <h2 class="account-card__title">Addresses</h2>
          <p class="account-card__desc">Manage your delivery addresses</p>
        </a>
        <a routerLink="/account/profile" class="account-card card card--hover">
          <div class="account-card__icon">👤</div>
          <h2 class="account-card__title">Personal Details</h2>
          <p class="account-card__desc">Update your name, email and password</p>
        </a>
        <a routerLink="/help" class="account-card card card--hover">
          <div class="account-card__icon">❓</div>
          <h2 class="account-card__title">Help Centre</h2>
          <p class="account-card__desc">FAQs, contact us and more</p>
        </a>
      </div>
    </div>
  `,
  styles: [`
    .account-title { font-size: 1.5rem; margin-bottom: 0.5rem; }
    .account-welcome { color: #5f6368; margin-bottom: 2rem; }
    .account-grid { display: grid; grid-template-columns: 1fr; gap: 1rem; }
    @media (min-width: 600px) { .account-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (min-width: 1024px) { .account-grid { grid-template-columns: repeat(3, 1fr); } }
    .account-card { display: flex; flex-direction: column; gap: 0.5rem; padding: 1.5rem; text-decoration: none; color: inherit; }
    .account-card--clubcard { border-color: #ffdd00; background: #fff7bf; }
    .account-card__icon { font-size: 2rem; }
    .account-card__title { font-size: 1rem; font-weight: 700; }
    .account-card__desc { font-size: 0.875rem; color: #5f6368; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AccountDashboardComponent {
  protected readonly auth = inject(AuthService);
}
