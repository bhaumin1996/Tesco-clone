import { ChangeDetectionStrategy, Component, inject, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { OrderService } from '../../../core/services/order.service';
import { AddressService } from '../../../core/services/address.service';
import { Address } from '../../../core/models/address.model';
import { signal, OnInit } from '@angular/core';

@Component({
  selector: 'app-account-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="acc-page">

      <!-- Hero banner -->
      <div class="acc-hero">
        <div class="acc-hero__inner page-container">
          <div class="acc-hero__avatar">{{ initials() }}</div>
          <div class="acc-hero__info">
            <h1 class="acc-hero__name">Hello, {{ auth.user()?.firstName ?? 'there' }}!</h1>
            <p class="acc-hero__sub">Welcome to your Tesco account</p>
          </div>
          <div class="acc-hero__stats">
            <div class="acc-stat">
              <span class="acc-stat__value">{{ orderCount() }}</span>
              <span class="acc-stat__label">Orders</span>
            </div>
            <div class="acc-stat acc-stat--clubcard">
              <span class="acc-stat__value">0</span>
              <span class="acc-stat__label">Clubcard pts</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Cards grid -->
      <div class="page-container acc-body">
        <div class="acc-grid">

          <a routerLink="/account/orders" class="acc-card acc-card--blue">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <path d="M20 7H4a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1V8a1 1 0 0 0-1-1Z"/>
                <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                <line x1="12" y1="12" x2="12" y2="16"/><line x1="10" y1="14" x2="14" y2="14"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">My Orders</h2>
              <p class="acc-card__desc">Track, manage or re-order your past orders</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/account/clubcard" class="acc-card acc-card--clubcard">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <rect x="2" y="5" width="20" height="14" rx="2"/>
                <line x1="2" y1="10" x2="22" y2="10"/>
                <line x1="6" y1="15" x2="10" y2="15"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">Clubcard</h2>
              <p class="acc-card__desc">View points, vouchers and Clubcard Prices</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/account/favourites" class="acc-card acc-card--red">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78Z"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">Favourites</h2>
              <p class="acc-card__desc">Your saved products for quick re-ordering</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/account/addresses" class="acc-card acc-card--green">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                <polyline points="9 22 9 12 15 12 15 22"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">Addresses</h2>
              <p class="acc-card__desc" *ngIf="!defaultAddress()">Manage your delivery addresses</p>
              <div class="acc-card__preview" *ngIf="defaultAddress()">
                <span class="acc-card__preview-label">Default:</span>
                <span class="acc-card__preview-text">{{ defaultAddress()?.addressLine1 }}, {{ defaultAddress()?.postcode }}</span>
              </div>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/account/profile" class="acc-card acc-card--purple">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">Personal Details</h2>
              <p class="acc-card__desc">Update your name, email and password</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/account/cards" class="acc-card acc-card--cyan">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <rect x="1" y="4" width="22" height="16" rx="2" ry="2"/>
                <line x1="1" y1="10" x2="23" y2="10"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">My Cards</h2>
              <p class="acc-card__desc">Manage your saved payment methods</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

          <a routerLink="/help" class="acc-card acc-card--orange">
            <div class="acc-card__icon-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                <circle cx="12" cy="12" r="10"/>
                <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                <line x1="12" y1="17" x2="12.01" y2="17"/>
              </svg>
            </div>
            <div class="acc-card__body">
              <h2 class="acc-card__title">Help Centre</h2>
              <p class="acc-card__desc">FAQs, contact us and more</p>
            </div>
            <span class="acc-card__arrow">›</span>
          </a>

        </div>
      </div>
    </div>
  `,
  styles: [`
    /* ── Page shell ── */
    .acc-page { background: #f5f5f5; min-height: calc(100vh - 64px); padding-bottom: 3rem; }

    /* ── Hero ── */
    .acc-hero {
      background: linear-gradient(135deg, #00539f 0%, #003d7a 100%);
      color: #fff;
      padding: 2.5rem 0;
      margin-bottom: 2rem;
    }
    .acc-hero__inner {
      display: flex;
      align-items: center;
      gap: 1.5rem;
      flex-wrap: wrap;
    }
    .acc-hero__avatar {
      width: 72px; height: 72px;
      border-radius: 50%;
      background: rgba(255,255,255,.18);
      border: 3px solid rgba(255,255,255,.5);
      display: flex; align-items: center; justify-content: center;
      font-size: 1.75rem; font-weight: 800; letter-spacing: 1px;
      flex-shrink: 0;
    }
    .acc-hero__info { flex: 1; }
    .acc-hero__name { font-size: 1.6rem; font-weight: 700; margin: 0 0 0.25rem; }
    .acc-hero__sub { font-size: 0.9rem; opacity: .8; margin: 0; }
    .acc-hero__stats { display: flex; gap: 1.5rem; }
    .acc-stat {
      text-align: center;
      background: rgba(255,255,255,.12);
      border-radius: 12px;
      padding: 0.75rem 1.25rem;
      min-width: 90px;
    }
    .acc-stat--clubcard { background: rgba(255,221,0,.18); border: 1px solid rgba(255,221,0,.4); }
    .acc-stat__value { display: block; font-size: 1.5rem; font-weight: 800; }
    .acc-stat__label { font-size: 0.72rem; opacity: .85; text-transform: uppercase; letter-spacing: .04em; }

    /* ── Cards grid ── */
    .acc-body { padding-top: 0; }
    .acc-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 1rem;
    }
    @media (min-width: 600px)  { .acc-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (min-width: 1024px) { .acc-grid { grid-template-columns: repeat(3, 1fr); } }

    /* ── Card base ── */
    .acc-card {
      display: flex;
      align-items: center;
      gap: 1.1rem;
      background: #fff;
      border-radius: 16px;
      padding: 1.4rem 1.25rem;
      text-decoration: none;
      color: inherit;
      box-shadow: 0 2px 8px rgba(0,0,0,.06);
      border: 2px solid transparent;
      transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
      position: relative;
      overflow: hidden;
    }
    .acc-card::before {
      content: '';
      position: absolute;
      top: 0; left: 0;
      width: 5px; height: 100%;
      border-radius: 0;
    }
    .acc-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 10px 28px rgba(0,0,0,.12);
    }

    /* ── Icon wrap ── */
    .acc-card__icon-wrap {
      width: 52px; height: 52px;
      border-radius: 14px;
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0;
    }
    .acc-card__icon-wrap svg { width: 26px; height: 26px; }

    /* ── Card text ── */
    .acc-card__body { flex: 1; }
    .acc-card__title { font-size: 1rem; font-weight: 700; margin: 0 0 0.3rem; color: #1a1a1a; }
    .acc-card__desc { font-size: 0.8rem; color: #6b7280; margin: 0; line-height: 1.4; }
    .acc-card__arrow {
      font-size: 1.4rem; color: #9ca3af;
      transition: transform .18s ease, color .18s ease;
      line-height: 1;
    }
    .acc-card:hover .acc-card__arrow { transform: translateX(4px); color: inherit; }

    .acc-card__preview { margin-top: 0.4rem; background: #f9fafb; padding: 0.4rem 0.6rem; border-radius: 8px; border: 1px solid #f3f4f6; }
    .acc-card__preview-label { display: block; font-size: 0.65rem; color: #9ca3af; text-transform: uppercase; font-weight: 700; margin-bottom: 0.1rem; }
    .acc-card__preview-text { display: block; font-size: 0.75rem; color: #374151; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* ── Colour themes ── */
    .acc-card--blue::before  { background: #00539f; }
    .acc-card--blue .acc-card__icon-wrap  { background: #e8f0fa; color: #00539f; }
    .acc-card--blue:hover    { border-color: #00539f; }

    .acc-card--clubcard::before { background: #ffdd00; }
    .acc-card--clubcard { background: linear-gradient(135deg, #fffde7 0%, #fff9c4 100%); }
    .acc-card--clubcard .acc-card__icon-wrap { background: rgba(255,221,0,.35); color: #7a6000; }
    .acc-card--clubcard:hover { border-color: #ffdd00; }
    .acc-card--clubcard .acc-card__title { color: #4a3800; }

    .acc-card--red::before   { background: #ee1c25; }
    .acc-card--red .acc-card__icon-wrap   { background: #fde8e8; color: #ee1c25; }
    .acc-card--red:hover     { border-color: #ee1c25; }

    .acc-card--green::before { background: #1a7f4b; }
    .acc-card--green .acc-card__icon-wrap { background: #e6f4ee; color: #1a7f4b; }
    .acc-card--green:hover   { border-color: #1a7f4b; }

    .acc-card--purple::before { background: #6d28d9; }
    .acc-card--purple .acc-card__icon-wrap { background: #ede9fe; color: #6d28d9; }
    .acc-card--purple:hover   { border-color: #6d28d9; }

    .acc-card--orange::before { background: #ea580c; }
    .acc-card--orange .acc-card__icon-wrap { background: #fff0e6; color: #ea580c; }
    .acc-card--orange:hover   { border-color: #ea580c; }

    .acc-card--cyan::before { background: #0891b2; }
    .acc-card--cyan .acc-card__icon-wrap { background: #ecfeff; color: #0891b2; }
    .acc-card--cyan:hover   { border-color: #0891b2; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AccountDashboardComponent implements OnInit {
  protected readonly auth = inject(AuthService);
  private readonly _orders = inject(OrderService);
  private readonly _addressService = inject(AddressService);

  protected orderCount = signal(0);
  protected defaultAddress = signal<Address | null>(null);

  ngOnInit(): void {
    this._orders.getMyOrders(1, 1).subscribe({
      next: r => this.orderCount.set(r.totalCount),
      error: () => this.orderCount.set(0)
    });

    this._addressService.getAddresses().subscribe({
      next: addrs => {
        const def = addrs.find(a => a.isDefault) || addrs[0];
        this.defaultAddress.set(def || null);
      }
    });
  }

  protected readonly initials = computed(() => {
    const u = this.auth.user();
    if (!u) return '?';
    return `${u.firstName?.[0] ?? ''}${u.lastName?.[0] ?? ''}`.toUpperCase() || '?';
  });
}
