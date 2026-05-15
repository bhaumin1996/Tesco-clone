import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AdminAuthService } from '../../../core/services/admin-auth.service';
import { environment } from '../../../../environments/environment';

@Component({
  selector: 'app-admin-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './admin-login.component.html',
  styleUrl: './admin-login.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminLoginComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AdminAuthService);
  private readonly _router = inject(Router);

  protected step = signal<'login' | '2fa'>('login');
  protected loading = signal(false);
  protected error = signal('');
  protected devCode = signal('');
  protected readonly isDev = !environment.production;
  protected readonly currentYear = new Date().getFullYear();

  protected loginForm = this._fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required]
  });

  protected twoFaForm = this._fb.group({
    code: ['', [Validators.required, Validators.pattern(/^\d{6}$/)]]
  });

  protected submitLogin(): void {
    if (this.loginForm.invalid) { this.loginForm.markAllAsTouched(); return; }
    this.loading.set(true);
    this.error.set('');
    const { email, password } = this.loginForm.getRawValue();
    this._auth.login(email!, password!).subscribe({
      next: r => {
        this.loading.set(false);
        if (r.twoFactorToken) {
          // twoFactorToken format: "{userId}:{code}" — expose code in dev for testability
          const code = r.twoFactorToken.split(':')[1] ?? '';
          this.devCode.set(code);
          this.step.set('2fa');
        } else {
          this._router.navigate(['/dashboard']);
        }
      },
      error: () => { this.loading.set(false); this.error.set('Invalid email or password.'); }
    });
  }

  protected submitTwoFa(): void {
    if (this.twoFaForm.invalid) { this.twoFaForm.markAllAsTouched(); return; }
    this.loading.set(true);
    this.error.set('');
    const { code } = this.twoFaForm.getRawValue();
    this._auth.verifyTwoFactor(code!).subscribe({
      next: () => { this.loading.set(false); this._router.navigate(['/dashboard']); },
      error: () => { this.loading.set(false); this.error.set('Invalid or expired code. Please try again.'); }
    });
  }
}
