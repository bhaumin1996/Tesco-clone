import { ChangeDetectionStrategy, Component, inject, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HeaderComponent } from './shared/components/header/header.component';
import { FooterComponent } from './shared/components/footer/footer.component';
import { AlertComponent } from './shared/components/alert/alert.component';
import { CartService } from './core/services/cart.service';
import { AuthService } from './core/services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, HeaderComponent, FooterComponent, AlertComponent],
  template: `
    <app-header />
    <main class="site-main">
      <router-outlet />
    </main>
    <app-footer />
    <app-alert />
  `,
  styles: [`
    :host { display: flex; flex-direction: column; min-height: 100vh; }
    .site-main { flex: 1; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppComponent implements OnInit {
  private readonly _cart = inject(CartService);
  private readonly _auth = inject(AuthService);

  ngOnInit(): void {
    if (this._auth.isAuthenticated()) {
      this._cart.loadCart().subscribe();
    }
  }
}
