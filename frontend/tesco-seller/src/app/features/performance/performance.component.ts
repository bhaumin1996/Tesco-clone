import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface PerformanceMetric { label: string; value: number; unit: string; benchmark: number; description: string; }
interface PerformanceSummary {
  overallScore: number;
  deliverySpeedScore: number;
  onTimeRate: number;
  returnRate: number;
  cancellationRate: number;
  averageRating: number;
  totalReviews: number;
  marketplaceAvgScore: number;
  trend: 'up' | 'down' | 'stable';
}

@Component({
  selector: 'app-seller-performance',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './performance.component.html',
  styleUrl: './performance.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerPerformanceComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly perf = signal<PerformanceSummary | null>(null);

  readonly metrics = computed<PerformanceMetric[]>(() => {
    const p = this.perf();
    if (!p) return [];
    return [
      { label: 'On-Time Delivery', value: p.onTimeRate, unit: '%', benchmark: 95, description: 'Orders delivered within the promised window.' },
      { label: 'Return Rate', value: p.returnRate, unit: '%', benchmark: 5, description: 'Lower is better. Target: under 5%.' },
      { label: 'Cancellation Rate', value: p.cancellationRate, unit: '%', benchmark: 2, description: 'Lower is better. Target: under 2%.' },
      { label: 'Average Rating', value: p.averageRating, unit: '/5', benchmark: 4, description: 'Customer satisfaction score out of 5.' },
    ];
  });

  readonly scoreColor = computed(() => {
    const score = this.perf()?.overallScore ?? 0;
    if (score >= 80) return 'good';
    if (score >= 60) return 'warn';
    return 'poor';
  });

  ngOnInit(): void {
    this._http.get<PerformanceSummary>(`${environment.apiUrl}/marketplace/performance`).subscribe({
      next: p => { this.perf.set(p); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  stars(rating: number): string[] {
    return Array.from({ length: 5 }, (_, i) => i < Math.round(rating) ? '★' : '☆');
  }

  isAboveBenchmark(metric: PerformanceMetric): boolean {
    if (metric.label === 'Return Rate' || metric.label === 'Cancellation Rate') return metric.value <= metric.benchmark;
    return metric.value >= metric.benchmark;
  }
}
