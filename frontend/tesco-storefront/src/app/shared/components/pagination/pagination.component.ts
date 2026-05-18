import { ChangeDetectionStrategy, Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-pagination',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (totalPages > 1) {
      <div class="pagination-container">
        <nav class="pagination" aria-label="Pagination">
          <!-- Previous Button -->
          <button class="pagination__btn pagination__nav-btn" (click)="onPage(currentPage - 1)" [disabled]="currentPage === 1" aria-label="Previous page">
            ‹
          </button>

          @for (page of pages; track $index) {
            @if (page === -2) {
              <button class="pagination__btn pagination__btn--ellipsis" (click)="onPage(getCurrentBlockStart() - 1)" title="Previous pages">…</button>
            } @else if (page === -1) {
              <button class="pagination__btn pagination__btn--ellipsis" (click)="onPage(getCurrentBlockEnd() + 1)" title="Next pages">…</button>
            } @else {
              <button
                class="pagination__btn"
                [class.pagination__btn--active]="page === currentPage"
                (click)="onPage(page)"
                [attr.aria-current]="page === currentPage ? 'page' : null"
              >{{ page }}</button>
            }
          }

          <!-- Next Button -->
          <button class="pagination__btn pagination__nav-btn" (click)="onPage(currentPage + 1)" [disabled]="currentPage === totalPages" aria-label="Next page">
            ›
          </button>
        </nav>
      </div>
    }
  `,
  styles: [`
    .pagination-container {
      display: flex;
      justify-content: center;
      width: 100%;
      margin: 2.5rem 0 1rem;
    }

    .pagination { 
      display: inline-flex; 
      align-items: center; 
      gap: 8px; 
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      padding: 0.5rem 0.75rem;
      border-radius: 100px;
      box-shadow: 0 8px 30px rgba(0, 0, 0, 0.03);
      border: 1px solid rgba(0, 0, 0, 0.05);
    }
    
    .pagination__btn {
      width: 40px; 
      height: 40px; 
      min-width: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 1px solid rgba(0, 0, 0, 0.05); 
      background: #ffffff;
      border-radius: 50%; 
      cursor: pointer; 
      font-size: 0.875rem; 
      font-weight: 750;
      color: #1A1A1A;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      outline: none;

      &:hover:not(:disabled) { 
        border-color: #005DAA; 
        color: #005DAA; 
        background: #f1f7fd;
        transform: translateY(-2px);
      }
      
      &--active { 
        background: linear-gradient(135deg, #005DAA 0%, #003f7d 100%); 
        color: #ffffff !important; 
        border: none;
        box-shadow: 0 4px 12px rgba(0, 93, 170, 0.25);
        transform: scale(1.05) translateY(-2px);
      }

      &:disabled { 
        opacity: 0.35; 
        cursor: not-allowed; 
        background: #f9f9f9;
        border-color: rgba(0, 0, 0, 0.03);
      }
    }

    .pagination__nav-btn {
      font-size: 1.25rem;
      font-weight: 400;
    }

    .pagination__btn--ellipsis {
      border-style: dashed;
      color: #555555;
      background: #fafafa;

      &:hover {
        background: #e8f2fc;
        border-style: solid;
      }
    }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class PaginationComponent {
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

