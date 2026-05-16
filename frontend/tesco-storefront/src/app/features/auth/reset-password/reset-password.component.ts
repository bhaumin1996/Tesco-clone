import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { RouterLink, ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-reset-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './reset-password.component.html',
  styleUrl: './reset-password.component.scss'
})
export class ResetPasswordComponent implements OnInit {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);
  private readonly _route = inject(ActivatedRoute);
  private readonly _router = inject(Router);

  readonly form = this._fb.group({
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', [Validators.required]]
  }, {
    validators: (group) => {
      const pass = group.get('password')?.value;
      const confirm = group.get('confirmPassword')?.value;
      return pass === confirm ? null : { mismatch: true };
    }
  });

  readonly loading = signal(false);
  readonly submitted = signal(false);
  readonly error = signal<string | null>(null);
  readonly showPassword = signal(false);
  
  token: string | null = null;

  ngOnInit(): void {
    this.token = this._route.snapshot.queryParamMap.get('token');
    if (!this.token) {
      this.error.set('Invalid or missing reset token.');
    }
  }

  get passwordError(): string | null {
    const ctrl = this.form.get('password');
    if (ctrl?.touched && ctrl.invalid) {
      if (ctrl.hasError('required')) return 'Password is required';
      if (ctrl.hasError('minlength')) return 'Password must be at least 8 characters';
    }
    return null;
  }

  get confirmPasswordError(): string | null {
    const ctrl = this.form.get('confirmPassword');
    if (ctrl?.touched) {
      if (ctrl.hasError('required')) return 'Please confirm your password';
      if (this.form.hasError('mismatch')) return 'Passwords do not match';
    }
    return null;
  }

  toggleShowPassword(): void {
    this.showPassword.update(v => !v);
  }

  submit(): void {
    if (this.form.invalid || !this.token) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    this.error.set(null);

    this._auth.resetPassword({
      token: this.token,
      newPassword: this.form.value.password!
    }).subscribe({
      next: () => {
        this.loading.set(false);
        this.submitted.set(true);
        setTimeout(() => {
          this._router.navigate(['/auth/login']);
        }, 3000);
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(err.error?.message || 'Failed to reset password. The link may have expired.');
      }
    });
  }
}
