import { ChangeDetectionStrategy, Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AddressService } from '../../../core/services/address.service';
import { NotificationService } from '../../../core/services/notification.service';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { Address } from '../../../core/models/address.model';

@Component({
  selector: 'app-addresses',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, BreadcrumbComponent, SpinnerComponent],
  template: `
    <div class="addr-page">
      <div class="page-container">
        <div class="page-content">
          <div class="addr-container">
            <app-breadcrumb [items]="[{ label: 'My Account', url: '/account' }, { label: 'Addresses' }]"></app-breadcrumb>

            <div class="addr-header">
              <div>
                <h1 class="addr-title">Addresses</h1>
                <p class="addr-sub">Manage your delivery and billing addresses</p>
              </div>
              <button *ngIf="!showForm()" (click)="openAddForm()" class="btn-primary">Add Address</button>
            </div>

            <!-- Address List -->
            <div *ngIf="!showForm()" class="addr-list">
              <div *ngIf="loading()" class="loading-wrap">
                <app-spinner></app-spinner>
              </div>

              <div *ngIf="!loading() && addresses().length === 0" class="empty-state">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                  <polyline points="9 22 9 12 15 12 15 22"/>
                </svg>
                <p>You haven't added any addresses yet.</p>
                <div class="empty-actions">
                  <button (click)="openAddForm()" class="btn-primary">Add your first address</button>
                  <button (click)="importFromOrders()" class="btn-ghost">Import from recent orders</button>
                </div>
              </div>

              <div *ngFor="let addr of addresses()" class="addr-card" [class.default]="addr.isDefault">
                <div class="addr-card__content">
                  <div class="addr-card__header">
                    <span *ngIf="addr.isDefault" class="badge">Default</span>
                    <span class="addr-card__id">#{{ addr.id }}</span>
                  </div>
                  <p class="addr-line">{{ addr.addressLine1 }}</p>
                  <p *ngIf="addr.addressLine2" class="addr-line">{{ addr.addressLine2 }}</p>
                  <p class="addr-line">{{ addr.townCity }}</p>
                  <p class="addr-postcode">{{ addr.postcode }}</p>
                </div>
                <div class="addr-card__actions">
                  <button (click)="editAddress(addr)" class="btn-icon" title="Edit">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  </button>
                  <button (click)="deleteAddress(addr.id)" class="btn-icon btn-icon--danger" title="Delete">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                  </button>
                </div>
              </div>
            </div>

            <!-- Add/Edit Form -->
            <div *ngIf="showForm()" class="addr-form-wrap">
              <h2 class="form-title">{{ editingId() ? 'Edit Address' : 'New Address' }}</h2>
              <form [formGroup]="addrForm" (ngSubmit)="submit()" class="addr-form">
                <div class="form-group">
                  <label for="addressLine1">Address Line 1</label>
                  <input type="text" id="addressLine1" formControlName="addressLine1" class="form-input" [class.error]="fieldError('addressLine1')">
                  <span class="error-msg" *ngIf="fieldError('addressLine1')">{{ fieldError('addressLine1') }}</span>
                </div>

                <div class="form-group">
                  <label for="addressLine2">Address Line 2 (Optional)</label>
                  <input type="text" id="addressLine2" formControlName="addressLine2" class="form-input">
                </div>

                <div class="form-grid">
                  <div class="form-group">
                    <label for="townCity">Town / City</label>
                    <input type="text" id="townCity" formControlName="townCity" class="form-input" [class.error]="fieldError('townCity')">
                    <span class="error-msg" *ngIf="fieldError('townCity')">{{ fieldError('townCity') }}</span>
                  </div>
                  <div class="form-group">
                    <label for="postcode">Postcode</label>
                    <input type="text" id="postcode" formControlName="postcode" class="form-input" [class.error]="fieldError('postcode')">
                    <span class="error-msg" *ngIf="fieldError('postcode')">{{ fieldError('postcode') }}</span>
                  </div>
                </div>

                <div class="form-checkbox">
                  <input type="checkbox" id="isDefault" formControlName="isDefault">
                  <label for="isDefault">Set as default address</label>
                </div>

                <div class="form-actions">
                  <button type="button" (click)="cancel()" class="btn-ghost">Cancel</button>
                  <button type="submit" class="btn-primary" [disabled]="loading() || addrForm.invalid">
                    <app-spinner *ngIf="loading()"></app-spinner>
                    <span *ngIf="!loading()">{{ editingId() ? 'Update' : 'Add' }} Address</span>
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .addr-page { background: #f5f7fa; min-height: calc(100vh - 80px); display: flex; flex-direction: column; }
    .page-container { flex: 1; display: flex; flex-direction: column; }
    .page-content { flex: 1; display: flex; align-items: flex-start; justify-content: center; padding: 2rem 1rem; }
    .addr-container { width: 100%; max-width: 600px; }
    app-breadcrumb { display: block; margin-bottom: 1.25rem; }
    
    .addr-header { 
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; 
      background: #fff; padding: 1.5rem 2rem; border-radius: 16px; 
      box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 8px 32px rgba(0,93,170,0.08); 
      border: 1px solid #e2e8f0;
    }
    .addr-title { font-size: 1.5rem; color: #0f172a; margin: 0 0 0.25rem; font-weight: 800; letter-spacing: -0.01em; }
    .addr-sub { color: #64748b; margin: 0; font-size: 0.8125rem; }

    .addr-list { display: flex; flex-direction: column; gap: 1rem; }

    .addr-card { 
      background: #fff; border-radius: 16px; padding: 1.25rem 1.75rem; 
      display: flex; justify-content: space-between; align-items: center;
      border: 1.5px solid #e2e8f0; transition: all 0.25s; 
      box-shadow: 0 1px 2px rgba(0,0,0,0.05); 
    }
    .addr-card.default { border-color: #005DAA; background: #f0f7ff; }
    .addr-card:hover { transform: translateY(-2px); box-shadow: 0 12px 24px rgba(0,93,170,0.12); border-color: #005DAA; }

    .addr-card__header { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem; }
    .badge { background: #005DAA; color: #fff; font-size: 0.625rem; font-weight: 700; padding: 0.2rem 0.6rem; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.05em; }
    .addr-card__id { font-size: 0.75rem; color: #94a3b8; font-weight: 600; }
    
    .addr-line { margin: 0 0 0.15rem; color: #1e293b; font-weight: 500; font-size: 0.9375rem; }
    .addr-postcode { margin: 0.375rem 0 0; color: #64748b; font-weight: 700; font-size: 0.875rem; }

    .addr-card__actions { display: flex; gap: 0.5rem; }
    .btn-icon { 
      background: #f8fafc; border: 1.5px solid #e2e8f0; width: 36px; height: 36px; border-radius: 10px; 
      display: flex; align-items: center; justify-content: center; cursor: pointer; color: #64748b; transition: all 0.2s; 
    }
    .btn-icon:hover { background: #fff; border-color: #005DAA; color: #005DAA; transform: scale(1.05); }
    .btn-icon--danger:hover { background: #fff5f5; border-color: #fca5a5; color: #dc2626; }
    .btn-icon svg { width: 18px; height: 18px; }

    .empty-state { background: #fff; padding: 3rem 2rem; border-radius: 16px; text-align: center; border: 1.5px dashed #e2e8f0; }
    .empty-state svg { width: 48px; height: 48px; margin-bottom: 1rem; color: #cbd5e1; }
    .empty-state p { color: #64748b; font-size: 0.875rem; margin-bottom: 1.5rem; }
    .empty-actions { display: flex; flex-direction: column; gap: 0.75rem; align-items: center; }

    .addr-form-wrap { 
      background: #fff; padding: 2rem 2.5rem; border-radius: 16px; 
      box-shadow: 0 8px 32px rgba(0,93,170,0.12); border: 1px solid #e2e8f0;
      animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1); 
    }
    @keyframes slideUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    .form-title { font-size: 1.375rem; color: #0f172a; margin-bottom: 1.5rem; font-weight: 800; letter-spacing: -0.01em; }

    .addr-form { display: flex; flex-direction: column; gap: 1rem; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
    .form-group { display: flex; flex-direction: column; gap: 0.375rem; }
    .form-group label { font-size: 0.8125rem; font-weight: 600; color: #374151; }
    .form-input { 
      padding: 0.65rem 1rem; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 0.9375rem; 
      background: #f8fafc; transition: all 0.2s; outline: none; box-sizing: border-box; width: 100%;
    }
    .form-input:focus { border-color: #005DAA; background: #fff; box-shadow: 0 0 0 3px rgba(0,93,170,0.1); }
    .form-input.error { border-color: #fca5a5; background: #fff5f5; }
    .error-msg { color: #dc2626; font-size: 0.75rem; font-weight: 500; margin-top: 0.125rem; }

    .form-checkbox { display: flex; align-items: center; gap: 0.75rem; margin: 0.25rem 0; cursor: pointer; }
    .form-checkbox input { width: 18px; height: 18px; cursor: pointer; accent-color: #005DAA; }
    .form-checkbox label { font-size: 0.875rem; cursor: pointer; color: #475569; font-weight: 500; }

    .form-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 0.5rem; }
    .btn-primary { 
      background: #005DAA; color: #fff; border: none; padding: 0.75rem 1.5rem; border-radius: 8px; 
      font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 0.5rem;
      box-shadow: 0 4px 12px rgba(0,93,170,0.25); transition: all 0.2s;
    }
    .btn-primary:hover:not(:disabled) { background: #003f7d; transform: translateY(-1px); box-shadow: 0 6px 18px rgba(0,93,170,0.3); }
    .btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }

    .btn-ghost { 
      background: #f1f5f9; color: #64748b; border: none; padding: 0.75rem 1.5rem; border-radius: 8px; 
      font-weight: 700; cursor: pointer; transition: all 0.2s;
    }
    .btn-ghost:hover { background: #e2e8f0; color: #1e293b; }

    .loading-wrap { grid-column: 1 / -1; display: flex; justify-content: center; padding: 2rem; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AddressesComponent implements OnInit {
  private readonly _fb = inject(FormBuilder);
  private readonly _addressService = inject(AddressService);
  private readonly _notifications = inject(NotificationService);

  protected addresses = signal<Address[]>([]);
  protected loading = signal(false);
  protected showForm = signal(false);
  protected editingId = signal<number | null>(null);

  protected addrForm = this._fb.group({
    addressLine1: ['', [Validators.required, Validators.maxLength(200)]],
    addressLine2: [''],
    townCity: ['', [Validators.required, Validators.maxLength(100)]],
    postcode: ['', [Validators.required, Validators.maxLength(20)]],
    isDefault: [false]
  });

  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading.set(true);
    this._addressService.getAddresses().subscribe({
      next: data => { this.addresses.set(data); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  openAddForm(): void {
    this.editingId.set(null);
    this.addrForm.reset({ isDefault: this.addresses().length === 0 });
    this.showForm.set(true);
  }

  editAddress(addr: Address): void {
    this.editingId.set(addr.id);
    this.addrForm.patchValue(addr);
    this.showForm.set(true);
  }

  cancel(): void {
    this.showForm.set(false);
    this.editingId.set(null);
  }

  submit(): void {
    if (this.addrForm.invalid) return;
    this.loading.set(true);
    const val = this.addrForm.getRawValue() as any;
    const obs = this.editingId() 
      ? this._addressService.updateAddress(this.editingId()!, val)
      : this._addressService.addAddress(val);

    obs.subscribe({
      next: () => {
        this._notifications.success(this.editingId() ? 'Address updated' : 'Address added');
        this.showForm.set(false);
        this.load();
      },
      error: () => {
        this.loading.set(false);
        this._notifications.error('Failed to save address');
      }
    });
  }

  deleteAddress(id: number): void {
    if (!confirm('Are you sure you want to delete this address?')) return;
    this._addressService.deleteAddress(id).subscribe({
      next: () => {
        this._notifications.success('Address deleted');
        this.load();
      },
      error: () => this._notifications.error('Failed to delete address')
    });
  }

  protected importFromOrders(): void {
    this.loading.set(true);
    this._addressService.importFromOrders().subscribe({
      next: () => {
        this._notifications.success('Addresses imported from previous orders');
        this.load();
      },
      error: () => {
        this.loading.set(false);
        this._notifications.error('Could not find any previous orders with addresses');
      }
    });
  }

  protected fieldError(name: string): string | null {
    const c = this.addrForm.get(name);
    return c && c.touched && c.hasError('required') ? 'Required' : null;
  }
}
