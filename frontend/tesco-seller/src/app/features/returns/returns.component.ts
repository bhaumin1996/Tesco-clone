import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface Return { id: number; orderNumber: string; productName: string; returnReason: string; statusName: string; slaDeadline: string; sellerResponse?: string; refundAmount?: number; createdOn: string; }

@Component({
  selector: 'app-seller-returns',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
<div class="ret-page">
  <h1>Returns</h1>
  <div class="ret-tabs">
    @for (tab of ['Open','Responded','Resolved']; track tab) {
    <button class="ret-tab" [class.ret-tab--active]="activeTab() === tab" (click)="activeTab.set(tab)">{{ tab }}</button>
    }
  </div>
  @if (loading()) { <p class="ret-loading">Loading…</p> }
  @else {
  @for (ret of filtered(); track ret.id) {
  <div class="ret-card" [class.ret-card--breach]="isBreach(ret.slaDeadline) && ret.statusName !== 'Resolved'">
    <div class="ret-card__header">
      <span class="ret-card__order">{{ ret.orderNumber }} — {{ ret.productName }}</span>
      <span class="ret-badge ret-badge--{{ ret.statusName | lowercase }}">{{ ret.statusName }}</span>
    </div>
    <p class="ret-card__reason">Reason: {{ ret.returnReason }}</p>
    <p class="ret-card__sla" [class.ret-card__sla--breach]="isBreach(ret.slaDeadline)">
      SLA: {{ ret.slaDeadline | date:'d MMM, h:mm a' }} {{ isBreach(ret.slaDeadline) && ret.statusName !== 'Resolved' ? '⚠ BREACHED' : '' }}
    </p>
    @if (ret.statusName === 'Pending' || ret.statusName === 'Requested') {
    <div class="ret-actions">
      <textarea class="ret-textarea" rows="2" placeholder="Your response…"
        [value]="response()" (input)="response.set($any($event.target).value)"></textarea>
      <div class="ret-actions__btns">
        <button class="ret-btn ret-btn--accept" [disabled]="submitting()" (click)="respond(ret.id, 'accept')">Accept & Refund</button>
        <button class="ret-btn ret-btn--dispute" [disabled]="submitting()" (click)="respond(ret.id, 'dispute')">Dispute</button>
      </div>
    </div>
    }
  </div>
  }
  @if (filtered().length === 0) { <p class="ret-empty">No returns in this category.</p> }
  }
  @if (message()) { <div class="ret-msg">{{ message() }}</div> }
</div>
  `,
  styles: [`.ret-page { h1 { font-size:1.4rem; font-weight:800; margin:0 0 1rem; } }
.ret-tabs { display:flex; gap:.25rem; margin-bottom:1rem; border-bottom:2px solid #e8ecf0; }
.ret-tab { border:none; background:none; padding:.6rem 1rem; font-size:.875rem; color:#555; cursor:pointer; border-bottom:2px solid transparent; margin-bottom:-2px; &--active { color:#00539f; border-bottom-color:#00539f; font-weight:700; } }
.ret-loading, .ret-empty { padding:2rem; text-align:center; color:#777; }
.ret-card { background:#fff; border:1px solid #e8ecf0; border-radius:8px; padding:1rem; margin-bottom:.75rem;
  &--breach { border-color:#fcc; background:#fff8f8; }
  &__header { display:flex; align-items:center; justify-content:space-between; margin-bottom:.4rem; }
  &__order { font-weight:600; font-size:.9rem; color:#1c1c1c; }
  &__reason { font-size:.85rem; color:#555; margin:.25rem 0; }
  &__sla { font-size:.78rem; color:#777; margin:0; &--breach { color:#b00; font-weight:600; } }
}
.ret-badge { display:inline-block; font-size:.72rem; font-weight:700; padding:.2rem .5rem; border-radius:4px;
  &--pending, &--requested { background:#fff5e6; color:#b05700; }
  &--resolved, &--accepted { background:#e8f4e8; color:#1a6b2a; }
  &--disputed { background:#fdf1f1; color:#b00; }
}
.ret-actions { margin-top:.75rem; &__btns { display:flex; gap:.5rem; margin-top:.4rem; } }
.ret-textarea { width:100%; border:1px solid #d1d5db; border-radius:6px; padding:.4rem .6rem; font-size:.85rem; resize:none; }
.ret-btn { border:none; border-radius:5px; padding:.4rem .9rem; font-size:.82rem; font-weight:600; cursor:pointer; &--accept { background:#1a6b2a; color:#fff; &:hover:not(:disabled) { background:#0f4d1f; } } &--dispute { background:#b00; color:#fff; &:hover:not(:disabled) { background:#800; } } &:disabled { opacity:.5; cursor:not-allowed; } }
.ret-msg { background:#e8f4e8; color:#1a6b2a; border-radius:6px; padding:.5rem 1rem; margin-top:1rem; font-size:.875rem; font-weight:600; }`],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerReturnsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly returns = signal<Return[]>([]);
  readonly activeTab = signal('Open');
  readonly response = signal('');
  readonly submitting = signal(false);
  readonly message = signal('');

  readonly filtered = computed(() => {
    const tab = this.activeTab();
    return this.returns().filter(r => {
      if (tab === 'Open') return ['Pending','Requested'].includes(r.statusName);
      if (tab === 'Responded') return ['Accepted','Disputed'].includes(r.statusName);
      return r.statusName === 'Resolved';
    });
  });

  ngOnInit(): void {
    this._http.get<Return[]>(`${environment.apiUrl}/marketplace/returns`).subscribe({
      next: r => { this.returns.set(r); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  respond(id: number, action: 'accept' | 'dispute'): void {
    this.submitting.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/returns/${id}/respond`, {
      accepted: action === 'accept', sellerResponse: this.response()
    }).subscribe({
      next: () => { this.submitting.set(false); this.response.set(''); this._reload(); this.message.set('Response submitted.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.submitting.set(false)
    });
  }

  isBreach(sla: string): boolean { return new Date(sla) < new Date(); }

  private _reload(): void {
    this._http.get<Return[]>(`${environment.apiUrl}/marketplace/returns`).subscribe({ next: r => this.returns.set(r) });
  }
}
