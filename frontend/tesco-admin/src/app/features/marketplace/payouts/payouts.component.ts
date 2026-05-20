import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface PayoutRow {
  payoutId: number;
  sellerId: number;
  businessName: string;
  periodStart: string;
  periodEnd: string;
  grossSales: number;
  commissionDeducted: number;
  netPayout: number;
  status: string;
  processedOn?: string;
}

@Component({
  selector: 'app-payouts',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './payouts.component.html',
  styleUrl: './payouts.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class PayoutsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  readonly loading = signal(true);
  readonly payouts = signal<PayoutRow[]>([]);
  readonly message = signal('');
  readonly runningPayout = signal(false);
  readonly periodStart = signal(this._monthStart());
  readonly periodEnd = signal(this._today());
  readonly selectedSellerId = signal<number | null>(null);

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<PayoutRow[]>(`${this._base}/payouts`).subscribe({
      next: p => { this.payouts.set(p); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  runPayout(sellerId?: number): void {
    this.runningPayout.set(true);
    const body: Record<string, unknown> = {
      periodStart: this.periodStart(),
      periodEnd: this.periodEnd()
    };
    const request = sellerId
      ? this._http.post(`${this._base}/sellers/${sellerId}/payout`, body)
      : this._http.post(`${this._base}/payouts`, body);

    request.subscribe({
      next: () => {
        this.runningPayout.set(false);
        this._load();
        this.message.set('Payout run complete.');
        setTimeout(() => this.message.set(''), 4000);
      },
      error: () => { this.runningPayout.set(false); this.message.set('Payout run failed.'); }
    });
  }

  private _today(): string { return new Date().toISOString().slice(0, 10); }
  private _monthStart(): string { const d = new Date(); d.setDate(1); return d.toISOString().slice(0, 10); }
}
