import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-tesco-magazine',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './tesco-magazine.component.html',
  styleUrl: './tesco-magazine.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class TescoMagazineComponent {}
