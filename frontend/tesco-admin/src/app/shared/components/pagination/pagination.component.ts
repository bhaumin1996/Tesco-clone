import { ChangeDetectionStrategy, Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-admin-pagination',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (totalPages > 1) {
      <div class="admin-pagination-container">
        <span class="admin-pagination-info">
          Showing page <strong>{{ currentPage }}</strong> of <strong>{{ totalPages }}</strong>
        </span>
        <nav class="admin-pagination-nav" aria-label="Pagination">
          <!-- Previous Button -->
          <button class="pagination-btn pagination-nav-btn" (click)="onPage(currentPage - 1)" [disabled]="currentPage === 1" aria-label="Previous page">
            ‹ Previous
          </button>

          @for (page of pages; track $index) {
            @if (page === -2) {
              <button class="pagination-btn pagination-btn--ellipsis" (click)="onPage(getCurrentBlockStart() - 1)" title="Previous pages">…</button>
            } @else if (page === -1) {
              <button class="pagination-btn pagination-btn--ellipsis" (click)="onPage(getCurrentBlockEnd() + 1)" title="Next pages">…</button>
            } @else {
              <button
                class="pagination-btn"
                [class.pagination-btn--active]="page === currentPage"
                (click)="onPage(page)"
                [attr.aria-current]="page === currentPage ? 'page' : null"
              >{{ page }}</button>
            }
          }

          <!-- Next Button -->
          <button class="pagination-btn pagination-nav-btn" (click)="onPage(currentPage + 1)" [disabled]="currentPage === totalPages" aria-label="Next page">
            Next ›
          </button>
        </nav>
      </div>
    }
  `,
  styles: [`
    .admin-pagination-container {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 1rem 1.25rem;
      border-top: 1px solid rgba(0, 0, 0, 0.06);
      background: #ffffff;
      width: 100%;
      box-sizing: border-box;
      flex-wrap: wrap;
      gap: 1rem;
    }

    .admin-pagination-info {
      font-size: 0.875rem;
      color: #64748b;
      font-weight: 500;
      strong {
        color: #1e293b;
        font-weight: 600;
      }
    }

    .admin-pagination-nav {
      display: inline-flex; 
      align-items: center; 
      gap: 6px;
    }
    
    .pagination-btn {
      height: 38px; 
      min-width: 38px;
      padding: 0 12px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border: 1.5px solid #e2e8f0; 
      background: #ffffff;
      border-radius: 8px; 
      cursor: pointer; 
      font-size: 0.875rem; 
      font-weight: 600;
      color: #334155;
      transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
      outline: none;
      font-family: inherit;

      &:hover:not(:disabled) { 
        border-color: #6366f1; 
        color: #6366f1; 
        background: #f5f3ff;
      }
      
      &--active { 
        background: #6366f1 !important; 
        border-color: #6366f1 !important;
        color: #ffffff !important; 
        box-shadow: 0 4px 10px rgba(99, 102, 241, 0.2);
        cursor: default;
      }

      &:disabled { 
        opacity: 0.4; 
        cursor: not-allowed; 
        background: #f8fafc;
        border-color: #e2e8f0;
        color: #94a3b8;
      }
    }

    .pagination-nav-btn {
      padding: 0 14px;
      font-weight: 500;
    }

    .pagination-btn--ellipsis {
      border-style: dashed;
      color: #64748b;
      background: #f8fafc;

      &:hover {
        background: #f5f3ff;
        border-style: solid;
      }
    }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminPaginationComponent {
  @Input() currentPage = 1;
  @Input() totalPages = 1;
  @Output() pageChange = new EventEmitter<number>();

  get pages(): number[] {
    const pages: number[] = [];
    if (this.totalPages <= 3) {
      for (let i = 1; i <= this.totalPages; i++) {
        pages.push(i);
      }
    } else {
      const blockStart = this.getCurrentBlockStart();
      const blockEnd = this.getCurrentBlockEnd();

      if (blockStart > 1) {
        pages.push(-2); // Previous block ellipsis
      }

      for (let i = blockStart; i <= blockEnd; i++) {
        pages.push(i);
      }

      if (blockEnd < this.totalPages) {
        pages.push(-1); // Next block ellipsis
      }
    }
    return pages;
  }

  getCurrentBlockStart(): number {
    return Math.floor((this.currentPage - 1) / 3) * 3 + 1;
  }

  getCurrentBlockEnd(): number {
    return Math.min(this.getCurrentBlockStart() + 2, this.totalPages);
  }

  onPage(page: number): void {
    if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
      this.pageChange.emit(page);
    }
  }
}
