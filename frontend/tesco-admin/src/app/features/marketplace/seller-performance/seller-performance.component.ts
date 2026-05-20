import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { extractApiError } from '../../../core/utils/api-error';

interface SellerScore {
  sellerId: number;
  businessName: string;
  scoreDate: string;
  onTimeDeliveryRate?: number;
  returnRate?: number;
  cancellationRate?: number;
  averageRating?: number;
  overallScore?: number;
  belowThreshold: boolean;
}

@Component({
  selector: 'app-seller-performance',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './seller-performance.component.html',
  styleUrl: './seller-performance.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerPerformanceComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  readonly loading = signal(true);
  readonly scores = signal<SellerScore[]>([]);
  readonly message = signal('');
  readonly showBelowOnly = signal(false);

  readonly filtered = computed(() => {
    const list = this.scores();
    return this.showBelowOnly() ? list.filter(s => s.belowThreshold) : list;
  });

  readonly belowThresholdCount = computed(() => this.scores().filter(s => s.belowThreshold).length);

  ngOnInit(): void {
    this.load();
  }

  private load(): void {
    this.loading.set(true);
    this.message.set('');

    this._http.get<any>(`${this._base}/sellers`, {
      params: { pageNumber: 1, pageSize: 200 }
    }).subscribe({
      next: response => {
        const rawItems = Array.isArray(response) ? response : (response?.items ?? []);
        const sellers: SellerScore[] = rawItems.map((seller: any) => ({
          sellerId: seller.sellerId ?? seller.id,
          businessName: seller.businessName ?? '',
          scoreDate: seller.scoreDate ?? seller.createdOn ?? '',
          onTimeDeliveryRate: seller.onTimeDeliveryRate,
          returnRate: seller.returnRate,
          cancellationRate: seller.cancellationRate,
          averageRating: seller.averageRating,
          overallScore: seller.overallScore,
          belowThreshold: seller.belowThreshold ?? false
        }));

        this.scores.set(sellers);
        this.loading.set(false);
      },
      error: err => {
        this.scores.set([]);
        this.message.set(extractApiError(err, 'Unable to load seller performance data.'));
        this.loading.set(false);
      }
    });
  }

  suspend(id: number): void {
    this._http.post(`${this._base}/sellers/${id}/suspend`, { reason: 'Suspended for below-threshold performance' }).subscribe({
      next: () => {
        this.message.set('Seller suspended.');
        this.load();
        setTimeout(() => this.message.set(''), 3000);
      },
      error: err => this.message.set(extractApiError(err, 'Action failed.'))
    });
  }

  stars(rating: number | undefined): string[] {
    if (!rating) return [];
    return Array.from({ length: 5 }, (_, i) =>
      i < Math.floor(rating) ? '★' : (i < rating ? '⯨' : '☆')
    );
  }
}
