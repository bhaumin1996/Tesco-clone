import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';

function passwordStrength(control: AbstractControl): ValidationErrors | null {
  const v: string = control.value ?? '';
  if (!v) return null;
  const hasLetter = /[a-zA-Z]/.test(v);
  const hasNumber = /\d/.test(v);
  if (!hasLetter || !hasNumber) return { passwordStrength: true };
  return null;
}

function emailsMatch(control: AbstractControl): ValidationErrors | null {
  const email = control.get('email')?.value;
  const confirm = control.get('confirmEmail')?.value;
  return email && confirm && email !== confirm ? { emailsMismatch: true } : null;
}

function mobileUk(control: AbstractControl): ValidationErrors | null {
  const v: string = control.value ?? '';
  if (!v) return null;
  const digits = v.replace(/\s+/g, '');
  if (!/^(\+44|0)7\d{9}$/.test(digits)) return { mobileUk: true };
  return null;
}

export const TITLES = ['Mr', 'Mrs', 'Miss', 'Ms', 'Dr', 'Prof', 'Rev'] as const;
export const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
] as const;

const CURRENT_YEAR = new Date().getFullYear();
export const DAYS = Array.from({ length: 31 }, (_, i) => i + 1);
export const YEARS = Array.from({ length: 100 }, (_, i) => CURRENT_YEAR - 16 - i);

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RegisterComponent {
  private readonly _fb = inject(FormBuilder);
  private readonly _auth = inject(AuthService);
  private readonly _router = inject(Router);
  private readonly _notifications = inject(NotificationService);

  protected readonly titles = TITLES;
  protected readonly months = MONTHS;
  protected readonly days = DAYS;
  protected readonly years = YEARS;

  protected form = this._fb.group(
    {
      title: [''],
      firstName: ['', [Validators.required, Validators.maxLength(50)]],
      lastName: ['', [Validators.required, Validators.maxLength(50)]],
      dobDay: [''],
      dobMonth: [''],
      dobYear: [''],
      email: ['', [Validators.required, Validators.email]],
      confirmEmail: ['', [Validators.required, Validators.email]],
      mobileNumber: ['', [mobileUk]],
      password: ['', [Validators.required, Validators.minLength(8), passwordStrength]],
      marketingEmail: [false],
      marketingPost: [false],
      marketingPhone: [false],
      marketingSms: [false],
      termsAccepted: [false, [Validators.requiredTrue]],
    },
    { validators: emailsMatch },
  );

  protected loading = signal(false);
  protected showPassword = signal(false);
  protected readonly currentYear = new Date().getFullYear();

  protected passwordStrengthLevel = computed(() => {
    const pw: string = this.form.get('password')?.value ?? '';
    if (pw.length < 8) return 0;
    let score = 0;
    if (/[a-zA-Z]/.test(pw)) score++;
    if (/\d/.test(pw)) score++;
    if (/[^a-zA-Z0-9]/.test(pw)) score++;
    if (pw.length >= 12) score++;
    return Math.min(score, 3);
  });

  protected strengthLabel = computed(() =>
    ['', 'Weak', 'Fair', 'Strong'][this.passwordStrengthLevel()],
  );

  protected togglePassword(): void {
    this.showPassword.update(v => !v);
  }

  protected submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    const v = this.form.getRawValue();
    this._auth
      .register({
        firstName: v.firstName!,
        lastName: v.lastName!,
        email: v.email!,
        password: v.password!,
        phoneNumber: v.mobileNumber || undefined,
      })
      .subscribe({
        next: () => {
          this.loading.set(false);
          this._router.navigate(['/account']);
        },
        error: (err) => {
          this.loading.set(false);
          this._notifications.error(
            err?.error?.error?.message ?? 'Registration failed. Please try again.',
          );
        },
      });
  }

  protected fieldError(name: string): string | null {
    const c = this.form.get(name);
    if (!c || !c.touched) return null;
    if (c.hasError('required')) return `${this._label(name)} is required`;
    if (c.hasError('email')) return 'Enter a valid email address';
    if (c.hasError('minlength'))
      return `Minimum ${c.errors!['minlength'].requiredLength} characters`;
    if (c.hasError('maxlength'))
      return `Maximum ${c.errors!['maxlength'].requiredLength} characters`;
    if (c.hasError('passwordStrength'))
      return 'Password must contain both letters and numbers';
    if (c.hasError('mobileUk'))
      return 'Enter a valid UK mobile number (e.g. 07700 900000)';
    return null;
  }

  protected get confirmEmailError(): string | null {
    const c = this.form.get('confirmEmail');
    if (!c || !c.touched) return null;
    if (c.hasError('required')) return 'Please confirm your email address';
    if (c.hasError('email')) return 'Enter a valid email address';
    if (this.form.hasError('emailsMismatch')) return 'Email addresses do not match';
    return null;
  }

  protected get termsError(): boolean {
    const c = this.form.get('termsAccepted');
    return !!c && c.touched && c.hasError('required');
  }

  private _label(name: string): string {
    const labels: Record<string, string> = {
      firstName: 'First name',
      lastName: 'Last name',
      email: 'Email address',
      confirmEmail: 'Confirm email address',
      mobileNumber: 'Mobile number',
      password: 'Password',
    };
    return labels[name] ?? name;
  }
}
