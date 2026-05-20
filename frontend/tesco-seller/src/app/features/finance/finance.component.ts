import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface CommissionStatement { id: number; period: string; grossSales: number; commissionAmount: number; netPayout: number; status: string; payoutDate?: string; invoiceUrl?: string; }
interface PayoutSummary { pendingAmount: number; lastPayoutAmount: number; lastPayoutDate: string; bankAccountLast4: string; }

@Component({
  selector: 'app-seller-finance',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './finance.component.html',
  styleUrl: './finance.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerFinanceComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly statements = signal<CommissionStatement[]>([]);
  readonly summary = signal<PayoutSummary | null>(null);
  readonly message = signal('');

  ngOnInit(): void {
    this._http.get<{ statements: CommissionStatement[]; summary: PayoutSummary }>(`${environment.apiUrl}/marketplace/finance`).subscribe({
      next: d => { this.statements.set(d.statements); this.summary.set(d.summary); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  downloadInvoice(statement: CommissionStatement): void {
    if (statement.invoiceUrl) {
      window.open(`${environment.apiBaseUrl}${statement.invoiceUrl}`, '_blank');
    } else {
      this._http.get(`${environment.apiUrl}/marketplace/finance/${statement.id}/invoice`, { responseType: 'blob' }).subscribe({
        next: blob => {
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = `invoice-${statement.period}.pdf`;
          a.click();
          URL.revokeObjectURL(url);
        }
      });
    }
  }
}
