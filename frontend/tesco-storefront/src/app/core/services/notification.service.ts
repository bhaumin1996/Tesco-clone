import { Injectable, signal } from '@angular/core';

export type NotificationType = 'success' | 'error' | 'info' | 'warning';

export interface Notification {
  id: string;
  type: NotificationType;
  message: string;
}

@Injectable({ providedIn: 'root' })
export class NotificationService {
  private readonly _notifications = signal<Notification[]>([]);
  readonly notifications = this._notifications.asReadonly();

  show(message: string, type: NotificationType = 'info', durationMs = 4000): void {
    // Fallback for non-secure contexts where crypto.randomUUID might be undefined
    const id = (typeof crypto !== 'undefined' && crypto.randomUUID) 
      ? crypto.randomUUID() 
      : Math.random().toString(36).substring(2, 9) + Date.now().toString(36);

    this._notifications.update(n => [...n, { id, type, message }]);
    setTimeout(() => this.dismiss(id), durationMs);
  }

  success(message: string) { this.show(message, 'success'); }
  error(message: string) { this.show(message, 'error', 6000); }
  info(message: string) { this.show(message, 'info'); }
  warning(message: string) { this.show(message, 'warning'); }

  dismiss(id: string) {
    this._notifications.update(n => n.filter(x => x.id !== id));
  }
}
