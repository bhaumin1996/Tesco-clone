import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface SellerProfile {
  businessName: string;
  logoUrl?: string;
  description: string;
  returnPolicyText: string;
  supportEmail: string;
  standardDeliveryDays: number;
  standardDeliveryCharge: number;
  freeDeliveryThreshold: number;
  expressDeliveryEnabled: boolean;
  expressDeliveryDays: number;
  expressDeliveryCharge: number;
}

@Component({
  selector: 'app-seller-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerProfileComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly saving = signal(false);
  readonly message = signal('');
  readonly profile = signal<SellerProfile>({
    businessName: '',
    description: '',
    returnPolicyText: '',
    supportEmail: '',
    standardDeliveryDays: 3,
    standardDeliveryCharge: 3.99,
    freeDeliveryThreshold: 50,
    expressDeliveryEnabled: false,
    expressDeliveryDays: 1,
    expressDeliveryCharge: 9.99
  });

  ngOnInit(): void {
    this._http.get<SellerProfile>(`${environment.apiUrl}/marketplace/profile`).subscribe({
      next: p => { this.profile.set(p); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  update(changes: Partial<SellerProfile>): void {
    this.profile.update(p => ({ ...p, ...changes }));
  }

  save(): void {
    this.saving.set(true);
    this._http.put(`${environment.apiUrl}/marketplace/profile`, this.profile()).subscribe({
      next: () => {
        this.saving.set(false);
        this.message.set('Profile saved successfully.');
        setTimeout(() => this.message.set(''), 3000);
      },
      error: () => this.saving.set(false)
    });
  }
}
