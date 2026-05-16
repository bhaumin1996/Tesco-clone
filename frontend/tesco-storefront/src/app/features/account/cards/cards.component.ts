import { ChangeDetectionStrategy, Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PaymentService, UserCard } from '../../../core/services/payment.service';
import { NotificationService } from '../../../core/services/notification.service';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-cards',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent, SpinnerComponent],
  template: `
    <div class="acc-page">
      <div class="page-container">
        <app-breadcrumb [items]="[{ label: 'My Account', url: '/account' }, { label: 'My Cards' }]"></app-breadcrumb>

        <div class="acc-header">
          <h1 class="acc-title">My Cards</h1>
          <p class="acc-subtitle">Manage your saved payment methods for faster checkout.</p>
        </div>

        @if (loading()) {
          <div class="loading-wrap">
            <app-spinner></app-spinner>
          </div>
        } @else if (cards().length === 0) {
          <div class="empty-state">
            <div class="empty-state__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                <rect x="1" y="4" width="22" height="16" rx="2" ry="2"/>
                <line x1="1" y1="10" x2="23" y2="10"/>
              </svg>
            </div>
            <h2 class="empty-state__title">No saved cards yet</h2>
            <p class="empty-state__desc">You can save your card details during the checkout process for your next order.</p>
            <a routerLink="/catalogue" class="btn-primary">Go shopping</a>
          </div>
        } @else {
          <div class="cards-grid">
            @for (card of cards(); track card.id) {
              <div class="card-item" [class.is-default]="card.isDefault">
                <div class="card-item__type">
                  <span class="brand-badge">{{ card.brand | uppercase }}</span>
                  @if (card.isDefault) {
                    <span class="default-badge">Default</span>
                  }
                </div>
                
                <div class="card-item__number">
                  <span class="dots">•••• •••• ••••</span>
                  <span class="last4">{{ card.last4 }}</span>
                </div>

                <div class="card-item__footer">
                  <div class="card-item__expiry">
                    <span class="label">Expires</span>
                    <span class="value">{{ card.expiryMonth | number:'2.0' }}/{{ card.expiryYear }}</span>
                  </div>
                  <button class="btn-delete" (click)="onDelete(card.id)" [disabled]="deletingId() === card.id">
                    @if (deletingId() === card.id) {
                      <app-spinner size="sm"></app-spinner>
                    } @else {
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                      </svg>
                      Remove
                    }
                  </button>
                </div>
              </div>
            }
          </div>
        }
      </div>
    </div>
  `,
  styles: [`
    .acc-page { padding: 2rem 0 4rem; background: #f8fafc; min-height: 80vh; }
    .acc-header { margin-bottom: 2.5rem; }
    .acc-title { font-size: 2rem; font-weight: 800; color: #0f172a; margin: 0 0 0.5rem; }
    .acc-subtitle { color: #64748b; font-size: 1rem; }

    .loading-wrap { display: flex; justify-content: center; padding: 4rem; }

    .empty-state {
      background: #fff; border-radius: 20px; padding: 4rem 2rem; text-align: center;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0;
      max-width: 600px; margin: 0 auto;
    }
    .empty-state__icon {
      width: 80px; height: 80px; background: #f0f7ff; border-radius: 50%;
      display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;
      color: #00539f;
    }
    .empty-state__icon svg { width: 40px; height: 40px; }
    .empty-state__title { font-size: 1.5rem; font-weight: 700; color: #1e293b; margin: 0 0 0.75rem; }
    .empty-state__desc { color: #64748b; margin: 0 0 2rem; }

    .cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; }

    .card-item {
      background: #fff; border-radius: 16px; padding: 1.5rem;
      border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      display: flex; flex-direction: column; gap: 1.5rem; transition: all 0.2s ease;
    }
    .card-item:hover { border-color: #00539f; transform: translateY(-2px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
    .card-item.is-default { border-left: 4px solid #00539f; }

    .card-item__type { display: flex; justify-content: space-between; align-items: center; }
    .brand-badge { background: #1e293b; color: #fff; padding: 0.25rem 0.75rem; border-radius: 6px; font-size: 0.75rem; font-weight: 800; letter-spacing: 1px; }
    .default-badge { background: #e6f4ee; color: #1a7f4b; padding: 0.25rem 0.6rem; border-radius: 6px; font-size: 0.65rem; font-weight: 800; text-transform: uppercase; }

    .card-item__number { display: flex; align-items: center; gap: 0.5rem; font-size: 1.25rem; font-family: monospace; color: #1e293b; }
    .dots { color: #cbd5e1; letter-spacing: 2px; }
    .last4 { font-weight: 700; }

    .card-item__footer { display: flex; justify-content: space-between; align-items: flex-end; border-top: 1px solid #f1f5f9; pt: 1rem; }
    .card-item__expiry { display: flex; flex-direction: column; gap: 0.25rem; }
    .card-item__expiry .label { font-size: 0.65rem; color: #94a3b8; text-transform: uppercase; font-weight: 700; }
    .card-item__expiry .value { font-size: 0.875rem; color: #475569; font-weight: 700; }

    .btn-delete {
      display: flex; align-items: center; gap: 0.5rem; background: none; border: none;
      color: #ef4444; font-size: 0.875rem; font-weight: 600; cursor: pointer; padding: 0.5rem;
      border-radius: 8px; transition: background 0.2s;
    }
    .btn-delete:hover:not(:disabled) { background: #fef2f2; }
    .btn-delete:disabled { opacity: 0.5; cursor: not-allowed; }

    .btn-primary {
      display: inline-block; background: #00539f; color: #fff; padding: 0.75rem 2rem;
      border-radius: 12px; font-weight: 700; text-decoration: none; transition: background 0.2s;
    }
    .btn-primary:hover { background: #003d7a; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CardsComponent implements OnInit {
  private readonly _payment = inject(PaymentService);
  private readonly _notifications = inject(NotificationService);

  protected cards = signal<UserCard[]>([]);
  protected loading = signal(true);
  protected deletingId = signal<number | null>(null);

  ngOnInit(): void {
    this._loadCards();
  }

  private _loadCards(): void {
    this.loading.set(true);
    this._payment.getCards().subscribe({
      next: cards => {
        this.cards.set(cards);
        this.loading.set(false);
      },
      error: () => {
        this._notifications.error('Failed to load cards.');
        this.loading.set(false);
      }
    });
  }

  protected onDelete(id: number): void {
    if (!confirm('Are you sure you want to remove this card?')) return;

    this.deletingId.set(id);
    this._payment.deleteCard(id).subscribe({
      next: () => {
        this.cards.update(list => list.filter(c => c.id !== id));
        this._notifications.success('Card removed successfully.');
        this.deletingId.set(null);
      },
      error: () => {
        this._notifications.error('Failed to remove card.');
        this.deletingId.set(null);
      }
    });
  }
}
