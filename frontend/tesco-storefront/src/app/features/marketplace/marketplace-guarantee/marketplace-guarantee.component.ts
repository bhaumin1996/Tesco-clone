import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-marketplace-guarantee',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './marketplace-guarantee.component.html',
  styleUrl: './marketplace-guarantee.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MarketplaceGuaranteeComponent {
  readonly breadcrumbs = [
    { label: 'Home', url: '/' },
    { label: 'Marketplace', url: '/marketplace' },
    { label: 'Our Guarantee' }
  ];
}
