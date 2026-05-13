import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';

function passwordsMatch(control: AbstractControl): { [key: string]: boolean } | null {
  const pw = control.get('password')?.value;
  const cpw = control.get('confirmPassword')?.value;
  return pw && cpw && pw !== cpw ? { passwordsMismatch: true } : null;
}

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class RegisterComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);
  private readonly _router = inject(Router);
  private readonly _notifications = inject(NotificationService);

  protected form = this._fb.group({
    firstName: ['', [Validators.required, Validators.maxLength(50)]],
    lastName: ['', [Validators.required, Validators.maxLength(50)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: ['', Validators.required]
  }, { validators: passwordsMatch });

  protected loading = signal(false);

  protected submit(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.loading.set(true);
    const v = this.form.getRawValue();
    this._auth.register({
      firstName: v.firstName!,
      lastName: v.lastName!,
      email: v.email!,
      password: v.password!,
      confirmPassword: v.confirmPassword!
    }).subscribe({
      next: () => this._router.navigate(['/']),
      error: (err) => {
        this.loading.set(false);
        this._notifications.error(err?.error?.error?.message ?? 'Registration failed. Please try again.');
      }
    });
  }

  fieldError(name: string): string | null {
    const c = this.form.get(name)!;
    if (!c.touched) return null;
    if (c.hasError('required')) return `${this._label(name)} is required`;
    if (c.hasError('email')) return 'Enter a valid email address';
    if (c.hasError('minlength')) return `Minimum ${c.errors!['minlength'].requiredLength} characters`;
    if (c.hasError('maxlength')) return `Maximum ${c.errors!['maxlength'].requiredLength} characters`;
    return null;
  }

  get confirmError(): string | null {
    const c = this.form.get('confirmPassword')!;
    if (!c.touched) return null;
    if (c.hasError('required')) return 'Please confirm your password';
    if (this.form.hasError('passwordsMismatch')) return 'Passwords do not match';
    return null;
  }

  private _label(name: string): string {
    return { firstName: 'First name', lastName: 'Last name', email: 'Email', password: 'Password', confirmPassword: 'Confirm password' }[name] ?? name;
  }
}
