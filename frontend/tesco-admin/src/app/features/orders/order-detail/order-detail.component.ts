import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface OrderLine {
  id: number;
  productName: string;
  imageUrl: string | null;
  price: number;
  quantity: number;
  lineTotal: number;
}

interface OrderDetail {
  id: number;
  orderNumber: string;
  status: string;
  subtotal: number;
  deliveryCharge: number;
  clubcardSavings: number;
  total: number;
  deliveryAddress: string | null;
  customerName: string | null;
  createdAt: string;
  items: OrderLine[];
}

@Component({
  selector: 'app-admin-order-detail',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './order-detail.component.html',
  styleUrl: './order-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminOrderDetailComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _route = inject(ActivatedRoute);

  protected order = signal<OrderDetail | null>(null);
  protected loading = signal(true);
  protected error = signal('');

  ngOnInit(): void {
    const id = this._route.snapshot.paramMap.get('id');
    if (!id) { this.error.set('Invalid order ID.'); this.loading.set(false); return; }

    this._http.get<OrderDetail>(`${environment.apiUrl}/admin/orders/${id}`).subscribe({
      next: o => { this.order.set(o); this.loading.set(false); },
      error: () => { this.error.set('Order not found.'); this.loading.set(false); }
    });
  }
}
