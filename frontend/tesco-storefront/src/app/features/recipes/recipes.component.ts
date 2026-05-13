import { ChangeDetectionStrategy, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

@Component({
  selector: 'app-recipes',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  template: `
    <div class="page-container page-content">
      <app-breadcrumb [items]="[{ label: 'Home', url: '/' }, { label: 'Recipes' }]" />
      <h1 style="font-size:1.5rem;margin-bottom:0.5rem">Real Food Hub</h1>
      <p style="color:#5f6368;margin-bottom:2rem">Discover delicious recipes made with Tesco ingredients</p>

      <!-- Filter pills -->
      <div class="recipe-filters">
        @for (tag of filters; track tag) {
          <button class="recipe-filter-pill" [class.active]="activeFilter === tag" (click)="activeFilter = tag">{{ tag }}</button>
        }
      </div>

      <div class="recipe-grid">
        @for (recipe of recipes; track recipe.title) {
          <div class="recipe-card card card--hover">
            <div class="recipe-card__img" [style.background]="recipe.color">
              <span style="font-size:3rem">{{ recipe.emoji }}</span>
            </div>
            <div class="recipe-card__body">
              <div class="recipe-card__meta">
                <span class="badge badge--grey">{{ recipe.cuisine }}</span>
                <span style="font-size:0.75rem;color:#5f6368">{{ recipe.time }}</span>
              </div>
              <h3 class="recipe-card__title">{{ recipe.title }}</h3>
              <p class="recipe-card__desc">{{ recipe.desc }}</p>
              <button class="button button--primary button--sm" style="align-self:flex-start;margin-top:auto">
                Add ingredients to basket
              </button>
            </div>
          </div>
        }
      </div>
    </div>
  `,
  styles: [`
    .recipe-filters { display: flex; gap: 0.5rem; flex-wrap: wrap; margin-bottom: 1.5rem; }
    .recipe-filter-pill { background: #f5f7fa; border: 1px solid #d8dde6; border-radius: 9999px; cursor: pointer; font-size: 0.875rem; padding: 0.25rem 0.875rem;
      &.active { background: #00539f; color: #fff; border-color: #00539f; } }
    .recipe-grid { display: grid; grid-template-columns: 1fr; gap: 1.25rem; }
    @media (min-width: 600px) { .recipe-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (min-width: 1024px) { .recipe-grid { grid-template-columns: repeat(3, 1fr); } }
    .recipe-card { display: flex; flex-direction: column; }
    .recipe-card__img { aspect-ratio: 16/9; display: flex; align-items: center; justify-content: center; }
    .recipe-card__body { padding: 1rem; display: flex; flex-direction: column; gap: 0.5rem; flex: 1; }
    .recipe-card__meta { display: flex; align-items: center; gap: 0.5rem; }
    .recipe-card__title { font-size: 1rem; font-weight: 700; }
    .recipe-card__desc { font-size: 0.875rem; color: #5f6368; flex: 1; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class RecipesComponent {
  protected activeFilter = 'All';
  protected filters = ['All', 'Quick', 'Vegetarian', 'Family', 'Healthy', 'Budget'];
  protected recipes = [
    { title: 'Classic Spaghetti Bolognese', desc: 'A hearty Italian classic the whole family will love.', cuisine: 'Italian', time: '45 min', emoji: '🍝', color: '#fde8ec' },
    { title: 'Chicken Tikka Masala', desc: 'Creamy, fragrant curry with tender marinated chicken.', cuisine: 'Indian', time: '40 min', emoji: '🍛', color: '#fff7bf' },
    { title: 'Avocado Toast', desc: 'Quick, nutritious and delicious. Ready in 10 minutes.', cuisine: 'Brunch', time: '10 min', emoji: '🥑', color: '#e6f4ed' },
    { title: 'Fish & Chips', desc: 'Crispy battered fish with chunky chips — a British classic.', cuisine: 'British', time: '35 min', emoji: '🐟', color: '#e8f2fc' },
    { title: 'Vegan Buddha Bowl', desc: 'Colourful, nourishing bowl packed with plant-based goodness.', cuisine: 'Healthy', time: '20 min', emoji: '🥗', color: '#e6f4ed' },
    { title: 'Banana Bread', desc: 'Moist, delicious banana bread — perfect for using ripe bananas.', cuisine: 'Baking', time: '60 min', emoji: '🍌', color: '#fff3e0' }
  ];
}
