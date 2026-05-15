import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-product-terms',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './product-terms.component.html',
  styleUrl: './product-terms.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductTermsComponent {}
