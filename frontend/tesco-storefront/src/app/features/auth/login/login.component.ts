import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class LoginComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);
  private readonly _router = inject(Router);
  private readonly _route = inject(ActivatedRoute);
  private readonly _notifications = inject(NotificationService);

  protected form = this._fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]]
  });

  protected loading = signal(false);
  protected showPassword = signal(false);
  protected readonly currentYear = new Date().getFullYear();

  protected toggleShowPassword(): void {
    this.showPassword.update(v => !v);
  }

  protected submit(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.loading.set(true);
    const { email, password } = this.form.getRawValue();
    this._auth.login({ email: email!, password: password! }).subscribe({
      next: (response) => {        
        console.log('Login successful:', response);
        this.loading.set(false);
        const returnUrl = this._route.snapshot.queryParamMap.get('returnUrl') ?? '/account';
        console.log('Navigating to:', returnUrl);
        this._router.navigateByUrl(returnUrl);
      },
      error: (err) => {
        console.error('Login error:', err);
        this.loading.set(false);
        this._notifications.error(err?.error?.error?.message ?? 'Invalid email or password');
      }
    });
  }

  get emailError(): string | null {
    const c = this.form.controls.email;
    if (!c.touched) return null;
    if (c.hasError('required')) return 'Email is required';
    if (c.hasError('email')) return 'Enter a valid email address';
    return null;
  }

  get passwordError(): string | null {
    const c = this.form.controls.password;
    if (!c.touched) return null;
    if (c.hasError('required')) return 'Password is required';
    if (c.hasError('minlength')) return 'Password must be at least 6 characters';
    return null;
  }
}
