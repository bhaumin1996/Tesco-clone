import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { LoyaltyService } from '../../core/services/loyalty.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { ClubcardBalance, Voucher, PointsTransaction } from '../../core/models/loyalty.model';
import { PagedResult } from '../../core/models/catalogue.model';

@Component({
  selector: 'app-clubcard',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent],
  templateUrl: './clubcard.component.html',
  styleUrl: './clubcard.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ClubcardComponent implements OnInit {
  private readonly _loyalty = inject(LoyaltyService);

  protected balance = signal<ClubcardBalance | null>(null);
  protected vouchers = signal<Voucher[]>([]);
  protected transactions = signal<PagedResult<PointsTransaction> | null>(null);
  protected loading = signal(true);
  protected activeTab = signal<'overview' | 'vouchers' | 'history'>('overview');

  ngOnInit(): void {
    this._loyalty.getBalance().subscribe({
      next: b => { this.balance.set(b); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
    this._loyalty.getVouchers().subscribe({ next: v => this.vouchers.set(v) });
    this._loyalty.getTransactions().subscribe({ next: t => this.transactions.set(t) });
  }
}
