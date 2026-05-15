import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AdminAuthService } from '../../../core/services/admin-auth.service';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ForgotPasswordComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AdminAuthService);
  private readonly _router = inject(Router);

  protected step = signal<'request' | 'reset' | 'done'>('request');
  protected loading = signal(false);
  protected error = signal('');
  protected success = signal('');
  protected readonly currentYear = new Date().getFullYear();

  protected requestForm = this._fb.group({
    email: ['', [Validators.required, Validators.email]]
  });

  protected resetForm = this._fb.group({
    code: ['', [Validators.required, Validators.minLength(6)]],
    newPassword: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required]
  }, { validators: this._passwordMatchValidator });

  private _passwordMatchValidator(group: import('@angular/forms').AbstractControl) {
    const pw = group.get('newPassword')?.value;
    const confirm = group.get('confirmPassword')?.value;
    return pw && confirm && pw !== confirm ? { mismatch: true } : null;
  }

  protected submitRequest(): void {
    if (this.requestForm.invalid) { this.requestForm.markAllAsTouched(); return; }
    this.loading.set(true);
    this.error.set('');
    const { email } = this.requestForm.getRawValue();
    this._auth.requestPasswordReset(email!).subscribe({
      next: () => { this.loading.set(false); this.step.set('reset'); },
      error: () => { this.loading.set(false); this.error.set('No admin account found with that email address.'); }
    });
  }

  protected submitReset(): void {
    if (this.resetForm.invalid) { this.resetForm.markAllAsTouched(); return; }
    if (this.resetForm.hasError('mismatch')) { return; }
    this.loading.set(true);
    this.error.set('');
    const email = this.requestForm.getRawValue().email!;
    const { code, newPassword } = this.resetForm.getRawValue();
    this._auth.resetPassword(email, code!, newPassword!).subscribe({
      next: () => { this.loading.set(false); this.step.set('done'); },
      error: () => { this.loading.set(false); this.error.set('Invalid or expired reset code. Please try again.'); }
    });
  }

  protected goToLogin(): void {
    this._router.navigate(['/auth/login']);
  }

  get confirmMismatch(): boolean {
    return this.resetForm.hasError('mismatch') &&
      !!this.resetForm.get('confirmPassword')?.touched;
  }
}
