import { ChangeDetectionStrategy, Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AddressService } from '../../../core/services/address.service';
import { NotificationService } from '../../../core/services/notification.service';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { Address } from '../../../core/models/address.model';
import { extractApiError } from '../../../core/utils/api-error';

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

            <div class="addr-header-card">
              <div class="addr-header-content">
                <div class="addr-header-text">
                  <h1 class="addr-title">Delivery Addresses</h1>
                  <p class="addr-sub">Manage where you want your groceries delivered.</p>
                </div>
                <button *ngIf="!showForm()" (click)="openAddForm()" class="btn-add-main">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                  Add New Address
                </button>
              </div>
            </div>

            <!-- Address List -->
            <div *ngIf="!showForm()" class="addr-list">
              <div *ngIf="loading()" class="loading-wrap">
                <app-spinner></app-spinner>
              </div>

              <div *ngIf="!loading() && addresses().length === 0" class="premium-empty-state">
                <div class="empty-glow"></div>
                <div class="empty-icon-box">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                    <polyline points="9 22 9 12 15 12 15 22"/>
                  </svg>
                </div>
                <h3 class="empty-title">No addresses found</h3>
                <p class="empty-text">Your delivery addresses will appear here once added. You can also import them from your order history.</p>
                <div class="empty-actions-grid">
                  <button (click)="openAddForm()" class="btn-premium">Add First Address</button>
                  <button (click)="importFromOrders()" class="btn-outline-premium">Import from Orders</button>
                </div>
              </div>

              <div class="addr-grid">
                <div *ngFor="let addr of addresses()" class="premium-addr-card" [class.is-default]="addr.isDefault">
                  <div class="card-glass"></div>
                  <div class="addr-card-body">
                    <div class="addr-card-top">
                      <span *ngIf="addr.isDefault" class="default-pill">Default</span>
                      <span class="addr-id-tag">ADDR-{{ addr.id }}</span>
                    </div>
                    <div class="addr-details">
                      <p class="addr-main-line">{{ addr.addressLine1 }}</p>
                      <p *ngIf="addr.addressLine2" class="addr-second-line">{{ addr.addressLine2 }}</p>
                      <div class="addr-city-post">
                        <span class="city-text">{{ addr.townCity }}</span>
                        <span class="postcode-tag">{{ addr.postcode }}</span>
                      </div>
                    </div>
                  </div>
                  <div class="addr-card-footer">
                    <button (click)="editAddress(addr)" class="action-btn" title="Edit">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                      Edit
                    </button>
                    <div class="footer-divider"></div>
                    <button (click)="deleteAddress(addr.id)" class="action-btn delete" title="Delete">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Add/Edit Form -->
            <div *ngIf="showForm()" class="premium-form-card">
              <div class="form-header">
                <h2 class="form-title-text">{{ editingId() ? 'Update Address' : 'New Address' }}</h2>
                <button (click)="cancel()" class="btn-close-form" aria-label="Close form">✕</button>
              </div>
              
              <form [formGroup]="addrForm" (ngSubmit)="submit()" class="premium-form">
                <div class="premium-form-group">
                  <label class="premium-label" for="addressLine1">Address Line 1</label>
                  <div class="input-wrapper">
                    <input type="text" id="addressLine1" formControlName="addressLine1" placeholder="e.g. 123 High Street" class="premium-input" [class.has-error]="fieldError('addressLine1')">
                    <span class="error-indicator" *ngIf="fieldError('addressLine1')">!</span>
                  </div>
                  <span class="premium-error" *ngIf="fieldError('addressLine1')">{{ fieldError('addressLine1') }} is required</span>
                </div>

                <div class="premium-form-group">
                  <label class="premium-label" for="addressLine2">Address Line 2 (Optional)</label>
                  <input type="text" id="addressLine2" formControlName="addressLine2" placeholder="e.g. Flat 4b" class="premium-input">
                </div>

                <div class="premium-form-row">
                  <div class="premium-form-group">
                    <label class="premium-label" for="townCity">Town / City</label>
                    <input type="text" id="townCity" formControlName="townCity" placeholder="City" class="premium-input" [class.has-error]="fieldError('townCity')">
                  </div>
                  <div class="premium-form-group">
                    <label class="premium-label" for="postcode">Postcode</label>
                    <input type="text" id="postcode" formControlName="postcode" placeholder="E1 6AN" class="premium-input" [class.has-error]="fieldError('postcode')">
                  </div>
                </div>

                <div class="premium-checkbox-card" (click)="addrForm.get('isDefault')?.setValue(!addrForm.get('isDefault')?.value)">
                  <div class="checkbox-ui" [class.checked]="addrForm.get('isDefault')?.value">
                    <svg *ngIf="addrForm.get('isDefault')?.value" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                  </div>
                  <div class="checkbox-text">
                    <strong>Set as default</strong>
                    <span>Use this address for all future orders by default.</span>
                  </div>
                </div>

                <div class="premium-form-actions">
                  <button type="button" (click)="cancel()" class="btn-cancel-premium">Cancel</button>
                  <button type="submit" class="btn-save-premium" [disabled]="loading() || addrForm.invalid">
                    <app-spinner *ngIf="loading()" size="sm"></app-spinner>
                    <span>{{ editingId() ? 'Save Changes' : 'Add Address' }}</span>
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
    .addr-page { background: #f8fafc; min-height: calc(100vh - 80px); padding-bottom: 4rem; }
    .page-content { display: flex; justify-content: center; padding: 2rem 1rem; }
    .addr-container { width: 100%; max-width: 720px; }
    app-breadcrumb { margin-bottom: 2rem; opacity: 0.8; transition: opacity 0.3s; &:hover { opacity: 1; } }

    /* --- Header Card --- */
    .addr-header-card {
      background: #ffffff; border-radius: 24px; padding: 2rem 2.5rem;
      border: 1px solid rgba(226, 232, 240, 0.8);
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 10px 15px -3px rgba(0, 0, 0, 0.03);
      margin-bottom: 2.5rem; position: relative; overflow: hidden;
      &::before {
        content: ''; position: absolute; top: 0; left: 0; width: 6px; height: 100%; background: #005DAA;
      }
    }
    .addr-header-content { display: flex; justify-content: space-between; align-items: center; gap: 1.5rem; }
    .addr-title { font-size: 1.75rem; color: #0f172a; font-weight: 850; letter-spacing: -0.03em; margin: 0 0 0.5rem; }
    .addr-sub { color: #64748b; margin: 0; font-size: 0.9375rem; font-weight: 500; }
    
    .btn-add-main {
      background: #005DAA; color: #fff; border: none; padding: 0.875rem 1.5rem; border-radius: 14px;
      font-weight: 700; font-size: 0.875rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem;
      box-shadow: 0 10px 20px -5px rgba(0, 93, 170, 0.3); transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
      &:hover { transform: translateY(-3px) scale(1.02); box-shadow: 0 15px 30px -8px rgba(0, 93, 170, 0.4); background: #004d8c; }
      &:active { transform: translateY(-1px) scale(0.98); }
    }

    /* --- Empty State --- */
    .premium-empty-state {
      background: #fff; border-radius: 30px; padding: 5rem 3rem; text-align: center;
      border: 2px dashed #e2e8f0; position: relative; overflow: hidden;
    }
    .empty-glow {
      position: absolute; top: 50%; left: 50%; width: 300px; height: 300px;
      background: radial-gradient(circle, rgba(0, 93, 170, 0.05) 0%, transparent 70%);
      transform: translate(-50%, -50%); pointer-events: none;
    }
    .empty-icon-box {
      width: 80px; height: 80px; background: #f1f5f9; border-radius: 24px;
      display: flex; align-items: center; justify-content: center; margin: 0 auto 2rem;
      color: #94a3b8; transition: all 0.5s ease;
      svg { width: 40px; height: 40px; }
      .premium-empty-state:hover & { transform: scale(1.1) rotate(5deg); background: #e0f2fe; color: #005DAA; }
    }
    .empty-title { font-size: 1.5rem; color: #1e293b; font-weight: 800; margin-bottom: 1rem; }
    .empty-text { color: #64748b; font-size: 1rem; max-width: 400px; margin: 0 auto 2.5rem; line-height: 1.6; }
    .empty-actions-grid { display: flex; gap: 1rem; justify-content: center; }
    
    .btn-premium {
      background: #005DAA; color: #fff; border: none; padding: 1rem 2rem; border-radius: 16px;
      font-weight: 700; cursor: pointer; transition: all 0.3s;
      &:hover { background: #004d8c; transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0, 93, 170, 0.25); }
    }
    .btn-outline-premium {
      background: transparent; color: #005DAA; border: 2px solid #005DAA; padding: 1rem 2rem; border-radius: 16px;
      font-weight: 700; cursor: pointer; transition: all 0.3s;
      &:hover { background: rgba(0, 93, 170, 0.05); transform: translateY(-2px); }
    }

    /* --- Address Grid & Cards --- */
    .addr-grid { display: grid; grid-template-columns: 1fr; gap: 1.5rem; }
    .premium-addr-card {
      background: #fff; border-radius: 24px; border: 1px solid #e2e8f0;
      overflow: hidden; position: relative; transition: all 0.3s ease;
      display: flex; flex-direction: column;
      &:hover {
        transform: translateY(-5px); border-color: #005DAA;
        box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.08);
      }
      &.is-default {
        border-color: #005DAA; background: linear-gradient(to bottom right, #fff, #f8fbff);
        box-shadow: 0 10px 30px -5px rgba(0, 93, 170, 0.1);
      }
    }
    .card-glass { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(135deg, rgba(255,255,255,0.4) 0%, transparent 100%); pointer-events: none; }
    .addr-card-body { padding: 2rem 2.25rem; flex: 1; }
    .addr-card-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
    .default-pill {
      background: #005DAA; color: #fff; font-size: 0.6875rem; font-weight: 800; padding: 0.35rem 0.875rem;
      border-radius: 30px; text-transform: uppercase; letter-spacing: 0.06em;
    }
    .addr-id-tag { font-size: 0.75rem; color: #94a3b8; font-weight: 700; font-family: monospace; }
    .addr-main-line { font-size: 1.125rem; font-weight: 700; color: #0f172a; margin: 0 0 0.5rem; }
    .addr-second-line { font-size: 1rem; font-weight: 500; color: #64748b; margin: 0 0 1rem; }
    .addr-city-post { display: flex; align-items: center; gap: 1rem; }
    .city-text { font-size: 1rem; font-weight: 600; color: #475569; }
    .postcode-tag { background: #f1f5f9; color: #475569; font-size: 0.8125rem; font-weight: 800; padding: 0.25rem 0.75rem; border-radius: 8px; }

    .addr-card-footer {
      padding: 1.25rem 2.25rem; background: #fafafa; border-top: 1px solid #f1f5f9;
      display: flex; align-items: center; gap: 1.5rem;
    }
    .action-btn {
      background: none; border: none; color: #64748b; font-size: 0.875rem; font-weight: 700;
      cursor: pointer; display: flex; align-items: center; gap: 0.5rem; transition: all 0.2s;
      svg { width: 18px; height: 18px; }
      &:hover { color: #005DAA; }
      &.delete:hover { color: #dc2626; }
    }
    .footer-divider { width: 1px; height: 16px; background: #e2e8f0; }

    /* --- Form Styling --- */
    .premium-form-card {
      background: #fff; border-radius: 30px; padding: 3rem; border: 1px solid #e2e8f0;
      box-shadow: 0 25px 60px -15px rgba(0, 93, 170, 0.15);
      animation: formIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
    }
    @keyframes formIn { from { opacity: 0; transform: translateY(20px) scale(0.98); } to { opacity: 1; transform: translateY(0) scale(1); } }
    .form-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 2.5rem; }
    .form-title-text { font-size: 1.75rem; font-weight: 850; color: #0f172a; margin: 0; letter-spacing: -0.02em; }
    .btn-close-form {
      background: #f1f5f9; border: none; width: 36px; height: 36px; border-radius: 50%;
      cursor: pointer; font-size: 1.25rem; color: #94a3b8; display: flex; align-items: center; justify-content: center;
      transition: all 0.2s; &:hover { background: #e2e8f0; color: #475569; transform: rotate(90deg); }
    }

    .premium-form { display: flex; flex-direction: column; gap: 1.5rem; }
    .premium-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
    .premium-form-group { display: flex; flex-direction: column; gap: 0.625rem; }
    .premium-label { font-size: 0.8125rem; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: 0.05em; }
    .input-wrapper { position: relative; display: flex; align-items: center; }
    .premium-input {
      width: 100%; padding: 0.875rem 1.25rem; background: #f8fafc; border: 2px solid #e2e8f0;
      border-radius: 14px; font-size: 1rem; color: #1e293b; font-weight: 500; transition: all 0.3s;
      &:focus { background: #fff; border-color: #005DAA; box-shadow: 0 0 0 4px rgba(0, 93, 170, 0.08); outline: none; }
      &.has-error { border-color: #fda4af; background: #fff1f2; }
    }
    .error-indicator { position: absolute; right: 1rem; width: 20px; height: 20px; background: #ef4444; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 900; font-size: 0.75rem; }
    .premium-error { font-size: 0.75rem; color: #ef4444; font-weight: 600; margin-top: 0.25rem; }

    .premium-checkbox-card {
      background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 20px; padding: 1.25rem;
      display: flex; gap: 1.25rem; align-items: center; cursor: pointer; transition: all 0.2s;
      &:hover { border-color: #005DAA; background: #fff; }
    }
    .checkbox-ui {
      width: 24px; height: 24px; border: 2px solid #cbd5e1; border-radius: 8px;
      display: flex; align-items: center; justify-content: center; transition: all 0.2s;
      &.checked { background: #005DAA; border-color: #005DAA; color: #fff; }
    }
    .checkbox-text {
      display: flex; flex-direction: column;
      strong { font-size: 0.9375rem; color: #1e293b; }
      span { font-size: 0.8125rem; color: #64748b; }
    }

    .premium-form-actions { display: flex; justify-content: flex-end; gap: 1.25rem; margin-top: 1rem; }
    .btn-cancel-premium {
      background: none; border: none; padding: 1rem 2rem; color: #64748b; font-weight: 700; cursor: pointer; transition: color 0.2s;
      &:hover { color: #1e293b; }
    }
    .btn-save-premium {
      background: #005DAA; color: #fff; border: none; padding: 1rem 2.5rem; border-radius: 16px;
      font-weight: 700; font-size: 1rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem;
      box-shadow: 0 10px 25px -5px rgba(0, 93, 170, 0.3); transition: all 0.3s;
      &:hover:not(:disabled) { background: #004d8c; transform: translateY(-2px); box-shadow: 0 15px 30px -8px rgba(0, 93, 170, 0.4); }
      &:disabled { opacity: 0.5; cursor: not-allowed; transform: none; box-shadow: none; }
    }

    .loading-wrap { display: flex; justify-content: center; padding: 4rem; }
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
      error: (err) => {
        this.loading.set(false);
        this._notifications.error(extractApiError(err, 'Failed to save address'));
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
      error: (err) => this._notifications.error(extractApiError(err, 'Failed to delete address'))
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
