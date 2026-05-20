import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { SellerAuthService } from '../../core/services/seller-auth.service';

@Component({
  selector: 'app-seller-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerLoginComponent {
  private readonly _auth = inject(SellerAuthService);
  private readonly _router = inject(Router);

  readonly email = signal('');
  readonly password = signal('');
  readonly loading = signal(false);
  readonly error = signal('');

  submit(): void {
    const e = this.email().trim();
    const p = this.password();
    if (!e || !p) { this.error.set('Please enter your email and password.'); return; }
    this.loading.set(true);
    this.error.set('');
    this._auth.login({ email: e, password: p }).subscribe({
      next: () => { this.loading.set(false); this._router.navigate(['/dashboard']); },
      error: () => { this.loading.set(false); this.error.set('Invalid email or password.'); }
    });
  }
}
