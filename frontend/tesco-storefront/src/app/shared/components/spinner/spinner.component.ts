import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-spinner',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="spinner" [class]="'spinner--' + size" role="status" aria-label="Loading">
      <div class="spinner__ring"></div>
    </div>
  `,
  styles: [`
    .spinner { display: inline-flex; align-items: center; justify-content: center; }
    .spinner__ring {
      border: 3px solid #d8dde6;
      border-top-color: #00539f;
      border-radius: 50%;
      animation: spin 0.7s linear infinite;
      width: 32px;
      height: 32px;
    }
    .spinner--sm .spinner__ring { width: 20px; height: 20px; border-width: 2px; }
    .spinner--lg .spinner__ring { width: 48px; height: 48px; border-width: 4px; }
    @keyframes spin { to { transform: rotate(360deg); } }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SpinnerComponent {
  @Input() size: 'sm' | 'md' | 'lg' = 'md';
}
