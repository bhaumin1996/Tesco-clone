import { ChangeDetectionStrategy, Component, inject, signal, OnInit, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { AddressService } from '../../../core/services/address.service';
import { Address } from '../../../core/models/address.model';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, BreadcrumbComponent, SpinnerComponent],
  template: `
    <div class="profile-page">
      <div class="page-container">
        <div class="page-content">
          <div class="profile-container">
            <app-breadcrumb [items]="[{ label: 'My Account', url: '/account' }, { label: 'Personal Details' }]"></app-breadcrumb>

            <!-- Step indicator -->
            <div class="prof-stepper">
              <div class="prof-stepper__item" [class.is-active]="step() >= 1" [class.is-done]="step() > 1">
                <div class="prof-stepper__dot">
                  @if (step() > 1) {
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                  } @else { 1 }
                </div>
                <span class="prof-stepper__label">Details</span>
              </div>
              <div class="prof-stepper__line" [class.is-done]="step() > 1"></div>
              <div class="prof-stepper__item" [class.is-active]="step() >= 2">
                <div class="prof-stepper__dot">2</div>
                <span class="prof-stepper__label">Security</span>
              </div>
            </div>

            <!-- Step 1: Personal Details -->
            @if (step() === 1) {
              <div class="prof-step">
                <h1 class="profile-title">Personal Details</h1>
                <p class="profile-sub">Update your name, email and contact details</p>

                <form [formGroup]="profileForm" (ngSubmit)="updateProfile()" class="profile-form">
                  <div class="form-grid">
                    <div class="form-group">
                      <label for="firstName">First name</label>
                      <input type="text" id="firstName" formControlName="firstName" class="form-input" [class.error]="fieldError('firstName')" placeholder="e.g. John">
                      <span class="error-msg" *ngIf="fieldError('firstName')">{{ fieldError('firstName') }}</span>
                    </div>

                    <div class="form-group">
                      <label for="lastName">Last name</label>
                      <input type="text" id="lastName" formControlName="lastName" class="form-input" [class.error]="fieldError('lastName')" placeholder="e.g. Doe">
                      <span class="error-msg" *ngIf="fieldError('lastName')">{{ fieldError('lastName') }}</span>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="email">Email address</label>
                    <input type="email" id="email" formControlName="email" class="form-input" [class.error]="fieldError('email')" placeholder="your@email.com">
                    <span class="error-msg" *ngIf="fieldError('email')">{{ fieldError('email') }}</span>
                  </div>

                  <div class="form-group">
                    <label for="phoneNumber">Mobile number (optional)</label>
                    <input type="tel" id="phoneNumber" formControlName="phoneNumber" class="form-input" placeholder="e.g. 07700 900000">
                  </div>

                  <div class="form-actions">
                    <button type="submit" class="btn-primary" [disabled]="loading() || profileForm.pristine">
                      <app-spinner *ngIf="loading()"></app-spinner>
                      <span *ngIf="!loading()">Save Changes</span>
                    </button>
                    <button type="button" class="btn-nav" (click)="nextStep()">
                      Next Step
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </button>
                  </div>
                </form>

                <hr class="divider">
                <h2 class="section-title">Default Delivery Address</h2>
                <p class="profile-sub" *ngIf="!defaultAddress()">No default address set. <a routerLink="/account/addresses">Add one now</a></p>
                
                <div class="address-preview" *ngIf="defaultAddress()">
                  <div class="address-preview__icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                  </div>
                  <div class="address-preview__text">
                    <p class="addr-line">{{ defaultAddress()?.addressLine1 }}</p>
                    <p class="addr-line" *ngIf="defaultAddress()?.addressLine2">{{ defaultAddress()?.addressLine2 }}</p>
                    <p class="addr-line">{{ defaultAddress()?.townCity }}, {{ defaultAddress()?.postcode }}</p>
                  </div>
                  <a routerLink="/account/addresses" class="btn-edit">Edit</a>
                </div>
              </div>
            }

            <!-- Step 2: Change Password -->
            @if (step() === 2) {
              <div class="prof-step">
                <h2 class="profile-title">Change Password</h2>
                <p class="profile-sub">Ensure your account is using a long, random password to stay secure.</p>

                <form [formGroup]="passwordForm" (ngSubmit)="updatePassword()" class="profile-form">
                  <div class="form-group">
                    <label for="currentPassword">Current password</label>
                    <input type="password" id="currentPassword" formControlName="currentPassword" class="form-input" [class.error]="passwordFieldError('currentPassword')" placeholder="••••••••">
                    <span class="error-msg" *ngIf="passwordFieldError('currentPassword')">{{ passwordFieldError('currentPassword') }}</span>
                  </div>

                  <div class="form-group">
                    <label for="newPassword">New password</label>
                    <input type="password" id="newPassword" formControlName="newPassword" class="form-input" [class.error]="passwordFieldError('newPassword')" placeholder="••••••••">
                    <span class="error-msg" *ngIf="passwordFieldError('newPassword')">{{ passwordFieldError('newPassword') }}</span>
                    
                    @if ((passwordForm.get('newPassword')?.value?.length ?? 0) > 0) {
                      <div class="reg-strength">
                        <div class="reg-strength__bar">
                          <div class="reg-strength__fill"
                            [class.reg-strength__fill--weak]="passwordStrengthLevel() === 1"
                            [class.reg-strength__fill--fair]="passwordStrengthLevel() === 2"
                            [class.reg-strength__fill--strong]="passwordStrengthLevel() === 3"
                            [style.width.%]="passwordStrengthLevel() * 33.3"
                          ></div>
                        </div>
                        <span class="reg-strength__label"
                          [class.reg-strength__label--weak]="passwordStrengthLevel() === 1"
                          [class.reg-strength__label--fair]="passwordStrengthLevel() === 2"
                          [class.reg-strength__label--strong]="passwordStrengthLevel() === 3"
                        >{{ strengthLabel() }}</span>
                      </div>
                    }
                  </div>

                  <div class="form-group">
                    <label for="confirmPassword">Confirm new password</label>
                    <input type="password" id="confirmPassword" formControlName="confirmPassword" class="form-input" [class.error]="passwordFieldError('confirmPassword')" placeholder="••••••••">
                    <span class="error-msg" *ngIf="passwordFieldError('confirmPassword')">{{ passwordFieldError('confirmPassword') }}</span>
                  </div>

                  <div class="form-actions">
                    <button type="button" class="btn-nav btn-nav--back" (click)="prevStep()">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
                      Back
                    </button>
                    <button type="submit" class="btn-primary" [disabled]="loadingPassword() || passwordForm.invalid">
                      <app-spinner *ngIf="loadingPassword()"></app-spinner>
                      <span *ngIf="!loadingPassword()">Update Password</span>
                    </button>
                  </div>
                </form>
              </div>
            }
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .profile-page { background: #f5f7fa; min-height: calc(100vh - 80px); display: flex; flex-direction: column; }
    .page-container { flex: 1; display: flex; flex-direction: column; }
    .page-content { flex: 1; display: flex; align-items: flex-start; justify-content: center; padding: 2rem 1rem; }
    
    .profile-container { 
      width: 100%; max-width: 520px; background: #fff; padding: 1.75rem 2.25rem; border-radius: 16px; 
      box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 8px 32px rgba(0,93,170,0.08); 
      border: 1px solid #e2e8f0;
      box-sizing: border-box;
    }

    app-breadcrumb { display: block; margin-bottom: 1rem; }
    
    // Stepper
    .prof-stepper {
      display: flex; align-items: center; margin-bottom: 1.5rem; width: 100%; box-sizing: border-box;
      &__item {
        display: flex; flex-direction: column; align-items: center; gap: 0.2rem;
        &.is-active .prof-stepper__dot { background: #005DAA; border-color: #005DAA; color: #fff; }
        &.is-done .prof-stepper__dot { background: #005DAA; border-color: #005DAA; color: #fff; }
      }
      &__dot {
        width: 30px; height: 30px; border-radius: 50%; border: 2px solid #cbd5e1;
        background: #fff; color: #94a3b8; font-size: 0.75rem; font-weight: 700;
        display: flex; align-items: center; justify-content: center; transition: all 0.25s;
        flex-shrink: 0;
      }
      &__label {
        font-size: 0.625rem; font-weight: 600; color: #94a3b8; text-transform: uppercase;
        letter-spacing: 0.04em; white-space: nowrap;
        .is-active &, .is-done & { color: #005DAA; }
      }
      &__line {
        flex: 1; height: 2px; background: #e2e8f0; margin: 0 0.5rem 0.9rem; border-radius: 99px;
        &.is-done { background: #005DAA; }
      }
    }

    .profile-title { font-size: 1.375rem; color: #0f172a; margin-bottom: 0.15rem; font-weight: 800; letter-spacing: -0.01em; }
    .profile-sub { color: #64748b; margin-bottom: 1.25rem; font-size: 0.8125rem; }
    .section-title { font-size: 1.05rem; margin: 1.25rem 0 0.5rem; font-weight: 700; color: #1e293b; }
    
    .profile-form { display: flex; flex-direction: column; gap: 0.875rem; width: 100%; box-sizing: border-box; }
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.875rem; width: 100%; }
    .form-group { display: flex; flex-direction: column; gap: 0.3rem; min-width: 0; }
    .form-group label { font-size: 0.75rem; font-weight: 600; color: #374151; }
    .form-input { 
      width: 100%; padding: 0.6rem 0.875rem; border: 1.5px solid #e2e8f0; border-radius: 8px; font-size: 0.875rem;
      background: #f8fafc; transition: all 0.2s; outline: none; box-sizing: border-box;
    }
    .form-input:focus { border-color: #005DAA; background: #fff; box-shadow: 0 0 0 3px rgba(0,93,170,0.1); }
    .form-input.error { border-color: #fca5a5; background: #fff5f5; }
    .error-msg { color: #dc2626; font-size: 0.7rem; font-weight: 500; margin-top: 0.125rem; }

    .divider { border: 0; border-top: 1px solid #e2e8f0; margin: 1.5rem 0; }

    .form-actions { display: flex; align-items: center; gap: 1rem; margin-top: 0.25rem; width: 100%; }
    
    .btn-primary { 
      flex: 1; background: #005DAA; color: #fff; border: none; padding: 0.75rem; border-radius: 8px; 
      font-weight: 700; cursor: pointer; transition: all 0.2s;
      display: flex; align-items: center; justify-content: center; min-height: 44px;
      box-shadow: 0 4px 12px rgba(0, 93, 170, 0.2);
    }
    .btn-primary:hover:not(:disabled) { background: #003f7d; transform: translateY(-1px); box-shadow: 0 6px 18px rgba(0, 93, 170, 0.25); }
    .btn-primary:disabled { opacity: 0.6; cursor: not-allowed; }

    .btn-nav {
      background: #fff; color: #005DAA; border: 1.5px solid #005DAA; padding: 0.65rem 1rem; border-radius: 8px;
      font-weight: 700; cursor: pointer; transition: all 0.2s; font-size: 0.875rem;
      display: flex; align-items: center; gap: 0.5rem; white-space: nowrap;
    }
    .btn-nav:hover { background: #f0f7ff; }
    .btn-nav--back { color: #64748b; border-color: #e2e8f0; }
    .btn-nav--back:hover { border-color: #005DAA; color: #005DAA; }

    .address-preview { 
      display: flex; align-items: center; gap: 1rem; padding: 1rem; 
      background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 12px;
    }
    .address-preview__icon { 
      width: 40px; height: 40px; background: #e0f2fe; color: #0369a1; 
      border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
    }
    .address-preview__icon svg { width: 20px; height: 20px; }
    .address-preview__text { flex: 1; }
    .addr-line { margin: 0; font-size: 0.875rem; font-weight: 500; color: #334155; }
    .btn-edit { color: #005DAA; font-weight: 700; text-decoration: none; font-size: 0.8125rem; }
    .btn-edit:hover { text-decoration: underline; }

    // Password strength (from register)
    .reg-strength {
      display: flex; align-items: center; gap: 0.625rem; margin-top: 0.5rem;
      &__bar { flex: 1; height: 4px; background: #e2e8f0; border-radius: 99px; overflow: hidden; }
      &__fill { 
        height: 100%; border-radius: 99px; transition: width 0.25s, background 0.25s; background: #e2e8f0;
        &--weak { background: #ef4444; } &--fair { background: #f59e0b; } &--strong { background: #16a34a; }
      }
      &__label { 
        font-size: 0.6875rem; font-weight: 700; min-width: 3rem; text-align: right; color: #94a3b8;
        &--weak { color: #ef4444; } &--fair { color: #f59e0b; } &--strong { color: #16a34a; }
      }
    }

    @media (max-width: 520px) {
      .form-grid { grid-template-columns: 1fr; gap: 0.75rem; }
      .profile-container { padding: 1.5rem; margin: 0.5rem; }
    }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ProfileComponent implements OnInit {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);
  private readonly _notifications = inject(NotificationService);
  private readonly _addressService = inject(AddressService);

  protected step = signal(1);
  protected loading = signal(false);
  protected loadingPassword = signal(false);
  protected defaultAddress = signal<Address | null>(null);

  protected profileForm = this._fb.group({
    firstName: ['', [Validators.required, Validators.maxLength(50)]],
    lastName: ['', [Validators.required, Validators.maxLength(50)]],
    email: ['', [Validators.required, Validators.email]],
    phoneNumber: ['']
  });

  protected passwordForm = this._fb.group({
    currentPassword: ['', [Validators.required]],
    newPassword: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', [Validators.required]]
  }, {
    validators: (group) => {
      const nw = group.get('newPassword')?.value;
      const cf = group.get('confirmPassword')?.value;
      return nw === cf ? null : { mismatch: true };
    }
  });

  protected passwordStrengthLevel = computed(() => {
    const pw: string = this.passwordForm.get('newPassword')?.value ?? '';
    if (pw.length < 8) return 0;
    let score = 0;
    if (/[a-zA-Z]/.test(pw)) score++;
    if (/\d/.test(pw)) score++;
    if (/[^a-zA-Z0-9]/.test(pw)) score++;
    if (pw.length >= 12) score++;
    return Math.min(score, 3);
  });

  protected strengthLabel = computed(() =>
    ['', 'Weak', 'Fair', 'Strong'][this.passwordStrengthLevel()]
  );

  ngOnInit(): void {
    const user = this._auth.user();
    if (user) {
      this.profileForm.patchValue({
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber ?? ''
      });
    }

    this.loadDefaultAddress();
  }

  private loadDefaultAddress(): void {
    this._addressService.getAddresses().subscribe({
      next: addrs => {
        const def = addrs.find(a => a.isDefault) || addrs[0];
        this.defaultAddress.set(def || null);
      }
    });
  }

  protected nextStep(): void {
    if (this.step() === 1) {
      this.profileForm.markAllAsTouched();
      if (this.profileForm.valid) {
        this.step.set(2);
      }
    }
  }

  protected prevStep(): void {
    this.step.set(1);
  }

  protected updateProfile(): void {
    if (this.profileForm.invalid) return;
    this.loading.set(true);
    this._auth.updateProfile(this.profileForm.getRawValue() as any).subscribe({
      next: () => {
        this.loading.set(false);
        this._notifications.success('Profile updated successfully');
        this.profileForm.markAsPristine();
      },
      error: (err) => {
        this.loading.set(false);
        this._notifications.error(err?.error?.message ?? 'Failed to update profile');
      }
    });
  }

  protected updatePassword(): void {
    if (this.passwordForm.invalid) return;
    this.loadingPassword.set(true);
    const { currentPassword, newPassword } = this.passwordForm.getRawValue();
    this._auth.updatePassword({ currentPassword: currentPassword!, newPassword: newPassword! }).subscribe({
      next: () => {
        this.loadingPassword.set(false);
        this._notifications.success('Password updated successfully. Please log in again with your new password.');
        this.passwordForm.reset();
        
        // Small delay to allow user to see the success message before redirect
        setTimeout(() => {
          this._auth.logout();
        }, 2000);
      },
      error: (err) => {
        this.loadingPassword.set(false);
        this._notifications.error(err?.error?.message ?? 'Failed to update password');
      }
    });
  }

  protected fieldError(name: string): string | null {
    const c = this.profileForm.get(name);
    if (!c || !c.touched) return null;
    if (c.hasError('required')) return 'Required';
    if (c.hasError('email')) return 'Invalid email';
    return null;
  }

  protected passwordFieldError(name: string): string | null {
    const c = this.passwordForm.get(name);
    if (!c || !c.touched) return null;
    if (c.hasError('required')) return 'Required';
    if (c.hasError('minlength')) return 'Too short';
    if (name === 'confirmPassword' && this.passwordForm.hasError('mismatch')) return 'Passwords do not match';
    return null;
  }
}
