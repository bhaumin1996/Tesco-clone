import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { OrderCountPipe } from '../../shared/pipes/order-count.pipe';

interface SellerOrderLine { id: number; productName: string; quantity: number; price: number; }
interface SellerOrder { id: number; orderNumber: string; statusName: string; sellerTotal: number; orderPlacedOn: string; lineCount: number; items?: SellerOrderLine[]; deliveryAddress?: string; carrierName?: string; trackingNumber?: string; }

@Component({
  selector: 'app-seller-orders',
  standalone: true,
  imports: [CommonModule, FormsModule, OrderCountPipe],
  templateUrl: './orders.component.html',
  styleUrl: './orders.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerOrdersComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly orders = signal<SellerOrder[]>([]);
  readonly activeTab = signal<string>('Pending');
  readonly selected = signal<SellerOrder | null>(null);
  readonly carrier = signal('');
  readonly tracking = signal('');
  readonly message = signal('');
  readonly submitting = signal(false);

  readonly tabs = ['Pending', 'Confirmed', 'Dispatched', 'Cancelled'];

  readonly filtered = computed(() => this.orders().filter(o => o.statusName === this.activeTab()));

  ngOnInit(): void {
    this._http.get<SellerOrder[]>(`${environment.apiUrl}/marketplace/orders`).subscribe({
      next: o => { this.orders.set(o); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  open(order: SellerOrder): void {
    this.selected.set(order);
    this.carrier.set('');
    this.tracking.set('');
    this._http.get<SellerOrder>(`${environment.apiUrl}/marketplace/orders/${order.id}`).subscribe({
      next: o => this.selected.set(o)
    });
  }

  close(): void { this.selected.set(null); }

  confirm(id: number): void {
    this.submitting.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/orders/${id}/confirm`, {}).subscribe({
      next: () => { this.submitting.set(false); this.close(); this._reload(); this._notify('Order confirmed.'); },
      error: () => this.submitting.set(false)
    });
  }

  dispatch(id: number): void {
    this.submitting.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/orders/${id}/dispatch`, {
      carrierName: this.carrier(), trackingNumber: this.tracking()
    }).subscribe({
      next: () => { this.submitting.set(false); this.close(); this._reload(); this._notify('Order dispatched.'); },
      error: () => this.submitting.set(false)
    });
  }

  private _reload(): void {
    this._http.get<SellerOrder[]>(`${environment.apiUrl}/marketplace/orders`).subscribe({
      next: o => this.orders.set(o)
    });
  }

  private _notify(msg: string): void { this.message.set(msg); setTimeout(() => this.message.set(''), 3000); }
}
