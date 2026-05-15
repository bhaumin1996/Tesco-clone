import { ChangeDetectionStrategy, Component } from '@angular/core';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-product-recall',
  standalone: true,
  imports: [BreadcrumbComponent],
  templateUrl: './product-recall.component.html',
  styleUrl: './product-recall.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProductRecallComponent {}
