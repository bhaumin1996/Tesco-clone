import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ContentService, Banner } from '../../core/services/content.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-banners',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent],
  templateUrl: './banners.component.html',
  styleUrl: './banners.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class BannersComponent implements OnInit {
  private readonly _content = inject(ContentService);

  protected loading = signal(true);
  protected banners = signal<Banner[]>([]);

  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'Promotions' }
  ];

  ngOnInit(): void {
    this._content.getActiveBanners().subscribe({
      next: b => { this.banners.set(b); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  protected isExpiringSoon(endsAt?: string): boolean {
    if (!endsAt) return false;
    const diff = new Date(endsAt).getTime() - Date.now();
    return diff > 0 && diff < 3 * 24 * 60 * 60 * 1000;
  }
}
