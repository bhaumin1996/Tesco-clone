import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';
import { ContentService, Page } from '../../core/services/content.service';
import { catchError, of, tap } from 'rxjs';

interface PolicySection {
  title: string;
  content: string;
  isOpen: boolean;
}

@Component({
  selector: 'app-ratings-reviews-policy',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './ratings-reviews-policy.component.html',
  styleUrl: './ratings-reviews-policy.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class RatingsReviewsPolicyComponent implements OnInit {
  private contentService = inject(ContentService);
  
  policy = signal<Page | null>(null);
  sections = signal<PolicySection[]>([]);
  loading = signal<boolean>(true);

  ngOnInit(): void {
    this.contentService.getPageBySlug('ratings-and-reviews-policy').pipe(
      tap(data => {
        this.policy.set(data);
        this.parseSections(data.content);
        this.loading.set(false);
      }),
      catchError(err => {
        console.error('Error fetching policy:', err);
        this.loading.set(false);
        return of(null);
      })
    ).subscribe();
  }

  private parseSections(htmlContent: string): void {
    // Regex to find <h2>TITLE</h2>CONTENT patterns
    const regex = /<h2>(.*?)<\/h2>(.*?)(?=<h2>|$)/gs;
    const matches = [...htmlContent.matchAll(regex)];
    
    const parsedSections = matches.map(match => ({
      title: match[1],
      content: match[2],
      isOpen: false
    }));

    this.sections.set(parsedSections);
  }

  toggleSection(index: number): void {
    const currentSections = this.sections();
    currentSections[index].isOpen = !currentSections[index].isOpen;
    this.sections.set([...currentSections]);
  }

  scrollToTop(): void {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}
