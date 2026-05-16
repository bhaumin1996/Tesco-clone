import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss'
})
export class ForgotPasswordComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);

  readonly form = this._fb.group({
    email: ['', [Validators.required, Validators.email]]
  });

  readonly loading = signal(false);
  readonly submitted = signal(false);
  readonly error = signal<string | null>(null);

  get emailError(): string | null {
    const ctrl = this.form.get('email');
    if (ctrl?.touched && ctrl.invalid) {
      if (ctrl.hasError('required')) return 'Email is required';
      if (ctrl.hasError('email')) return 'Invalid email address';
    }
    return null;
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    this.error.set(null);

    this._auth.forgotPassword({ email: this.form.value.email! }).subscribe({
      next: () => {
        this.loading.set(false);
        this.submitted.set(true);
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(err.error?.message || 'Something went wrong. Please try again.');
      }
    });
  }
}
