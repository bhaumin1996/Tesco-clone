import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-accessibility',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './accessibility.component.html',
  styleUrl: './accessibility.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AccessibilityComponent {}
