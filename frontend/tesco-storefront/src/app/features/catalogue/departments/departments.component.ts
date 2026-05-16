import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { CatalogueService } from '../../../core/services/catalogue.service';
import { SpinnerComponent } from '../../../shared/components/spinner/spinner.component';
import { BreadcrumbComponent } from '../../../shared/components/breadcrumb/breadcrumb.component';
import { Department } from '../../../core/models/catalogue.model';
import { ImageUrlPipe } from '../../../shared/pipes/image-url.pipe';

@Component({
  selector: 'app-departments',
  standalone: true,
  imports: [CommonModule, RouterLink, SpinnerComponent, BreadcrumbComponent, ImageUrlPipe],
  template: `
    <div class="page-container page-content">
      <app-breadcrumb [items]="[{ label: 'Home', url: '/' }, { label: 'All Departments' }]" />
      <h1 class="depts-title">All Departments</h1>

      @if (loading()) {
        <app-spinner />
      } @else {
        <div class="depts-grid">
          @for (dept of departments(); track dept.id) {
            <a [routerLink]="['/departments', dept.slug]" class="dept-card card card--hover">
              <div class="dept-card__img">
                @if (dept.imageUrl) {
                  <img [src]="dept.imageUrl | imageUrl" [alt]="dept.name" loading="lazy" />
                } @else {
                  <span class="dept-card__icon">🛒</span>
                }
              </div>
              <div class="dept-card__body">
                <h2 class="dept-card__name">{{ dept.name }}</h2>
                <p class="dept-card__count">{{ dept.categoryCount }} categories</p>
              </div>
            </a>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .depts-title { margin: 1rem 0 1.5rem; font-size: 1.5rem; }
    .depts-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; }
    @media (min-width: 768px) { .depts-grid { grid-template-columns: repeat(4, 1fr); } }
    @media (min-width: 1024px) { .depts-grid { grid-template-columns: repeat(5, 1fr); } }
    .dept-card { text-decoration: none; color: inherit; display: flex; flex-direction: column; }
    .dept-card__img { aspect-ratio: 4/3; background: #f5f7fa; display: flex; align-items: center; justify-content: center; overflow: hidden; img { width: 100%; height: 100%; object-fit: cover; } }
    .dept-card__icon { font-size: 3rem; }
    .dept-card__body { padding: 0.75rem; }
    .dept-card__name { font-size: 0.875rem; font-weight: 700; margin-bottom: 0.25rem; }
    .dept-card__count { font-size: 0.75rem; color: #5f6368; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DepartmentsComponent implements OnInit {
  private readonly _catalogue = inject(CatalogueService);
  protected departments = signal<Department[]>([]);
  protected loading = signal(true);

  ngOnInit(): void {
    this._catalogue.getDepartments().subscribe({
      next: d => { this.departments.set(d); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
