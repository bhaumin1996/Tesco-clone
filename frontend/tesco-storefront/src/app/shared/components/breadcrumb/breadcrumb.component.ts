import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';

export interface BreadcrumbItem {
  label: string;
  url?: string;
}

@Component({
  selector: 'app-breadcrumb',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <nav class="breadcrumb" aria-label="Breadcrumb">
      <ol class="breadcrumb__list">
        @for (item of items; track item.label; let last = $last) {
          <li class="breadcrumb__item">
            @if (item.url && !last) {
              <a [routerLink]="item.url" class="breadcrumb__link">{{ item.label }}</a>
            } @else {
              <span class="breadcrumb__current" [attr.aria-current]="last ? 'page' : null">{{ item.label }}</span>
            }
            @if (!last) { <span class="breadcrumb__sep" aria-hidden="true">/</span> }
          </li>
        }
      </ol>
    </nav>
  `,
  styles: [`
    .breadcrumb { padding: 0.5rem 0; }
    .breadcrumb__list { display: flex; align-items: center; gap: 0.25rem; flex-wrap: wrap; list-style: none; }
    .breadcrumb__item { display: flex; align-items: center; gap: 0.25rem; }
    .breadcrumb__link { font-size: 0.8125rem; color: #00539f; text-decoration: none; &:hover { text-decoration: underline; } }
    .breadcrumb__current { font-size: 0.8125rem; color: #5f6368; }
    .breadcrumb__sep { font-size: 0.8125rem; color: #d8dde6; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class BreadcrumbComponent {
  @Input({ required: true }) items: BreadcrumbItem[] = [];
}
