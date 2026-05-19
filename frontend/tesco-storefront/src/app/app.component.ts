import { ChangeDetectionStrategy, Component, computed, inject, OnInit } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';
import { filter, map } from 'rxjs';
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
    <app-header [minimal]="isAuthRoute()" />
    <main class="site-main">
      <router-outlet />
    </main>
    @if (!isAuthRoute()) {
      <app-footer />
    }
    <app-alert />
  `,
  styles: [`
    :host { display: flex; flex-direction: column; min-height: 100vh; }
    .site-main { flex: 1; display: flex; flex-direction: column; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppComponent implements OnInit {
  private readonly _cart = inject(CartService);
  private readonly _auth = inject(AuthService);
  private readonly _router = inject(Router);

  private readonly _url = toSignal(
    this._router.events.pipe(
      filter(e => e instanceof NavigationEnd),
      map(e => (e as NavigationEnd).urlAfterRedirects)
    ),
    { initialValue: this._router.url }
  );

  readonly isAuthRoute = computed(() => this._url().startsWith('/auth'));

  ngOnInit(): void {
    if (this._auth.isAuthenticated()) {
      this._cart.loadCart().subscribe();
    }
  }
}
