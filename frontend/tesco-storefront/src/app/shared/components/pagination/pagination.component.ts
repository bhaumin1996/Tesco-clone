import { ChangeDetectionStrategy, Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-pagination',
  standalone: true,
  imports: [CommonModule],
  template: `
    <nav class="pagination" aria-label="Pagination" *ngIf="totalPages > 1">
      <button class="pagination__btn" (click)="onPage(currentPage - 1)" [disabled]="currentPage === 1" aria-label="Previous page">
        &lsaquo;
      </button>
      @for (page of pages; track page) {
        @if (page === -1) {
          <span class="pagination__ellipsis">…</span>
        } @else {
          <button
            class="pagination__btn"
            [class.pagination__btn--active]="page === currentPage"
            (click)="onPage(page)"
            [attr.aria-current]="page === currentPage ? 'page' : null"
          >{{ page }}</button>
        }
      }
      <button class="pagination__btn" (click)="onPage(currentPage + 1)" [disabled]="currentPage === totalPages" aria-label="Next page">
        &rsaquo;
      </button>
    </nav>
  `,
  styles: [`
    .pagination { display: flex; align-items: center; gap: 4px; justify-content: center; }
    .pagination__btn {
      min-width: 36px; height: 36px; border: 1px solid #d8dde6; background: #fff;
      border-radius: 4px; cursor: pointer; font-size: 0.875rem; font-weight: 700;
      &:hover:not(:disabled) { border-color: #00539f; color: #00539f; }
      &--active { background: #00539f; color: #fff; border-color: #00539f; }
      &:disabled { opacity: 0.4; cursor: not-allowed; }
    }
    .pagination__ellipsis { padding: 0 4px; color: #5f6368; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class PaginationComponent {
  @Input() currentPage = 1;
  @Input() totalPages = 1;
  @Output() pageChange = new EventEmitter<number>();

  get pages(): number[] {
    const pages: number[] = [];
    const delta = 2;
    const left = Math.max(2, this.currentPage - delta);
    const right = Math.min(this.totalPages - 1, this.currentPage + delta);
    pages.push(1);
    if (left > 2) pages.push(-1);
    for (let i = left; i <= right; i++) pages.push(i);
    if (right < this.totalPages - 1) pages.push(-1);
    if (this.totalPages > 1) pages.push(this.totalPages);
    return pages;
  }

  onPage(page: number): void {
    if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
      this.pageChange.emit(page);
    }
  }
}
