import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DeliveryService } from '../../../core/services/delivery.service';
import { NotificationService } from '../../../core/services/notification.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { DeliverySlot } from '../../../core/models/delivery.model';

@Component({
  selector: 'app-delivery-slots',
  standalone: true,
  imports: [CommonModule, FormsModule, SpinnerComponent, BreadcrumbComponent],
  templateUrl: './delivery-slots.component.html',
  styleUrl: './delivery-slots.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DeliverySlotsComponent {
  private readonly _delivery = inject(DeliveryService);
  private readonly _notifications = inject(NotificationService);

  protected postcode = '';
  protected slots = signal<DeliverySlot[]>([]);
  protected loading = signal(false);
  protected searched = signal(false);
  protected selectedSlot = signal<DeliverySlot | null>(null);
  protected booking = signal(false);

  protected search(): void {
    if (!this.postcode.trim()) return;
    this.loading.set(true);
    this.searched.set(false);
    const today = new Date();
    const nextWeek = new Date(today);
    nextWeek.setDate(nextWeek.getDate() + 7);
    this._delivery.searchSlots({
      postcode: this.postcode,
      fromDate: today.toISOString().split('T')[0],
      toDate: nextWeek.toISOString().split('T')[0]
    }).subscribe({
      next: s => { this.slots.set(s); this.loading.set(false); this.searched.set(true); },
      error: () => { this.loading.set(false); this.searched.set(true); }
    });
  }

  protected bookSlot(): void {
    const slot = this.selectedSlot();
    if (!slot) return;
    this.booking.set(true);
    this._delivery.bookSlot(slot.id, 1).subscribe({
      next: () => {
        this.booking.set(false);
        this._notifications.success(`Delivery slot booked for ${slot.date} ${slot.startTime}–${slot.endTime}`);
        this.selectedSlot.set(null);
      },
      error: () => {
        this.booking.set(false);
        this._notifications.error('Could not book this slot. Please try another.');
      }
    });
  }

  get groupedByDate(): { date: string; slots: DeliverySlot[] }[] {
    const map = this.slots().reduce((acc, s) => {
      (acc[s.date] = acc[s.date] || []).push(s);
      return acc;
    }, {} as Record<string, DeliverySlot[]>);
    return Object.keys(map).map(date => ({ date, slots: map[date] }));
  }
}
