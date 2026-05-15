import { ChangeDetectionStrategy, Component, ElementRef, inject, OnInit, signal, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CatalogueService } from '../../core/services/catalogue.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';
import { Department, Brand } from '../../core/models/catalogue.model';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HomeComponent implements OnInit {
  @ViewChild('deptScroll') private readonly _deptScroll!: ElementRef<HTMLDivElement>;
  @ViewChild('brandScroll') private readonly _brandScroll!: ElementRef<HTMLDivElement>;

  private readonly _catalogue = inject(CatalogueService);

  protected departments = signal<Department[]>([]);
  protected brands = signal<Brand[]>([]);
  protected loading = signal(true);

  protected scrollDepts(dir: 'left' | 'right'): void {
    this._scroll(this._deptScroll, dir);
  }

  protected scrollBrands(dir: 'left' | 'right'): void {
    this._scroll(this._brandScroll, dir);
  }

  private _scroll(ref: ElementRef<HTMLDivElement>, dir: 'left' | 'right'): void {
    const el = ref?.nativeElement;
    if (!el) return;
    el.scrollBy({ left: dir === 'left' ? -320 : 320, behavior: 'smooth' });
  }

  protected newThisWeek = [
    {
      title: 'Summer BBQ essentials',
      text: 'Everything you need for the perfect garden barbecue this weekend.',
      url: '/departments/fresh-food',
      bg: 'linear-gradient(135deg, #ff9a56 0%, #ffb347 100%)',
      icon: '🔥'
    },
    {
      title: 'Fresh summer fruits',
      text: 'Strawberries, raspberries, peaches and more — perfectly in season.',
      url: '/departments/fresh-food',
      bg: 'linear-gradient(135deg, #f8a5c2 0%, #ff6b9d 100%)',
      icon: '🍓'
    },
    {
      title: 'Meal deal under £4',
      text: 'Sandwich, snack and drink — perfect for lunch on the go.',
      url: '/departments/food-cupboard',
      bg: 'linear-gradient(135deg, #a8e6cf 0%, #56ab2f 100%)',
      icon: '🥪'
    }
  ];

  protected topPicks = [
    {
      title: 'Clubcard Prices',
      text: 'Save more with hundreds of exclusive deals.',
      url: '/offers',
      icon: '💳',
      color: '#004F9F'
    },
    {
      title: 'Special Offers',
      text: 'Great value across all departments this week.',
      url: '/offers',
      icon: '🏷️',
      color: '#EE1C2E'
    },
    {
      title: 'Whoosh delivery',
      text: 'Order now — delivered to your door in 60 minutes.',
      url: '/delivery',
      icon: '⚡',
      color: '#005DAA'
    },
    {
      title: 'New & Trending',
      text: 'Discover the latest products and seasonal favourites.',
      url: '/departments',
      icon: '✨',
      color: '#007A33'
    }
  ];

  protected waysToSave = [
    {
      title: 'Tesco Mobile',
      text: 'SIM-only plans from just £5 a month. No contract.',
      url: '#',
      icon: '📱',
      color: '#005DAA'
    },
    {
      title: 'Delivery Saver',
      text: 'Unlimited free delivery from £7.99/month — save every time.',
      url: '/delivery',
      icon: '🚚',
      color: '#007A33'
    },
    {
      title: 'Click & Collect',
      text: 'Order online and collect from your nearest store for free.',
      url: '/stores',
      icon: '🏪',
      color: '#EE1C2E'
    }
  ];

  protected discoverMore = [
    {
      title: 'Recipes',
      text: 'Inspiration for every meal — from quick weeknight dinners to weekend feasts.',
      cta: 'Explore recipes',
      url: '/recipes',
      icon: '🍳',
      theme: 'orange'
    },
    {
      title: 'Delivery Saver',
      text: 'Unlimited deliveries from £7.99/month. Save every time you shop.',
      cta: 'Learn more',
      url: '/delivery',
      icon: '🚚',
      theme: 'blue'
    },
    {
      title: 'Gift Cards',
      text: 'The perfect present for any occasion. Available in-store and online.',
      cta: 'Shop gift cards',
      url: '#',
      icon: '🎁',
      theme: 'red'
    }
  ];

  protected brandImgErrors = signal<Set<string>>(new Set());

  protected onBrandImgError(slug: string): void {
    this.brandImgErrors.update(prev => new Set([...prev, slug]));
  }

  protected communityItems = [
    {
      title: 'Food Bank Donations',
      text: 'We partner with food banks to help fight food poverty in local communities.',
      cta: 'Learn how to donate',
      url: '/help',
      icon: '❤️'
    },
    {
      title: 'Community Projects',
      text: 'Our Stronger Starts programme supports thousands of local community initiatives.',
      cta: 'Find out more',
      url: '#',
      icon: '🤝'
    },
    {
      title: 'Sustainability',
      text: 'Our commitment to reaching net zero and reducing food waste.',
      cta: 'Our pledge',
      url: '#',
      icon: '🌱'
    }
  ];

  protected services = [
    {
      title: 'Tesco Bank',
      text: 'Credit cards, loans, savings and insurance.',
      url: '#',
      icon: '🏦'
    },
    {
      title: 'Tesco Insurance',
      text: 'Home, car, pet and travel insurance policies.',
      url: '#',
      icon: '🛡️'
    },
    {
      title: 'Travel Money',
      text: 'Best exchange rates with no commission fees.',
      url: '#',
      icon: '✈️'
    },
    {
      title: 'Gift Cards',
      text: 'For every occasion — Tesco, restaurant and experience cards.',
      url: '#',
      icon: '🎁'
    }
  ];

  ngOnInit(): void {
    this._catalogue.getDepartments().subscribe({
      next: d => { this.departments.set(d); },
      error: () => {}
    });

    this._catalogue.getBrands().subscribe({
      next: b => { this.brands.set(b); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
