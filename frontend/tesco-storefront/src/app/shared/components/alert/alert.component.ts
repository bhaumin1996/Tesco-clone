import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="alerts" aria-live="polite" aria-atomic="true">
      @for (n of notifications.notifications(); track n.id) {
        <div class="alert" [class]="'alert--' + n.type" role="alert">
          <span>{{ n.message }}</span>
          <button class="alert__close" (click)="notifications.dismiss(n.id)" aria-label="Dismiss">×</button>
        </div>
      }
    </div>
  `,
  styles: [`
    .alerts { position: fixed; top: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column; gap: 0.5rem; max-width: 380px; }
    .alert {
      display: flex; align-items: center; justify-content: space-between; gap: 0.75rem;
      border-radius: 8px; font-size: 0.875rem; font-weight: 600; padding: 0.75rem 1rem;
      box-shadow: 0 4px 16px rgba(0,0,0,0.15);
      animation: slideIn 0.2s ease;
    }
    .alert--success { background: #007a3d; color: #fff; }
    .alert--error   { background: #b00020; color: #fff; }
    .alert--info    { background: #00539f; color: #fff; }
    .alert--warning { background: #b36b00; color: #fff; }
    .alert__close { background: none; border: none; color: inherit; cursor: pointer; font-size: 1.25rem; line-height: 1; opacity: 0.8; padding: 0; &:hover { opacity: 1; } }
    @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AlertComponent {
  protected readonly notifications = inject(NotificationService);
}
