import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CatalogueService } from '../../core/services/catalogue.service';
import { ProductCardComponent } from '../../shared/components/product-card/product-card.component';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { Department } from '../../core/models/catalogue.model';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCardComponent, SpinnerComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HomeComponent implements OnInit {
  private readonly _catalogue = inject(CatalogueService);

  protected departments = signal<Department[]>([]);
  protected loading = signal(true);

  protected heroBanners = [
    { title: "Fresh food, every day", subtitle: "Shop our great range of fresh produce", cta: "Shop Fresh Food", url: "/departments/fresh-food", bg: "#e8f2fc" },
    { title: "Clubcard Prices", subtitle: "Save more with your Clubcard on hundreds of products", cta: "View Clubcard deals", url: "/offers", bg: "#fff7bf" },
    { title: "Free delivery slots", subtitle: "Get free delivery with Delivery Saver", cta: "Find out more", url: "/delivery", bg: "#e6f4ed" }
  ];

  protected waysToSave = [
    { title: "Tesco Mobile", subtitle: "Great value SIM-only plans", url: "#", icon: "📱" },
    { title: "Clubcard Latest", subtitle: "Earn points on every shop", url: "/account/clubcard", icon: "💳" },
    { title: "Whoosh Fast Delivery", subtitle: "Delivered to your door in 60 mins", url: "/delivery", icon: "⚡" }
  ];

  protected discoverMore = [
    { title: "Recipes", subtitle: "Inspiration for every meal", url: "/recipes", icon: "🍳" },
    { title: "Delivery Saver", subtitle: "Unlimited free delivery from £7.99/month", url: "/delivery", icon: "🚚" },
    { title: "Gift Cards", subtitle: "The perfect present for everyone", url: "#", icon: "🎁" }
  ];

  ngOnInit(): void {
    this._catalogue.getDepartments().subscribe({
      next: d => { this.departments.set(d); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
