import { Component, OnInit, inject, signal, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ContentService, Page } from '../../../core/services/content.service';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  selector: 'app-delivery-saver-terms',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './delivery-saver-terms.component.html',
  styleUrl: './delivery-saver-terms.component.scss'
})
export class DeliverySaverTermsComponent implements OnInit, AfterViewChecked {
  private contentService = inject(ContentService);
  private sanitizer = inject(DomSanitizer);
  private el = inject(ElementRef);

  page = signal<Page | null>(null);
  safeContent = signal<SafeHtml>('');
  loading = signal(true);
  error = signal<string | null>(null);

  private accordionsInitialized = false;

  ngOnInit(): void {
    this.loadPage();
  }

  ngAfterViewChecked(): void {
    if (!this.accordionsInitialized && this.page()) {
      this.initializeAccordions();
    }
  }

  private loadPage(): void {
    this.contentService.getPageBySlug('delivery-saver-terms').subscribe({
      next: (data) => {
        this.page.set(data);
        this.safeContent.set(this.sanitizer.bypassSecurityTrustHtml(data.content));
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error loading terms page:', err);
        this.error.set('Failed to load terms and conditions. Please try again later.');
        this.loading.set(false);
      }
    });
  }

  private initializeAccordions(): void {
    const triggers = this.el.nativeElement.querySelectorAll('.accordion-trigger');
    if (triggers.length > 0) {
      this.accordionsInitialized = true;
      triggers.forEach((trigger: HTMLElement) => {
        trigger.addEventListener('click', () => {
          const item = trigger.parentElement;
          if (item) {
            const isOpen = item.classList.contains('active');
            
            // Optional: Close others
            // this.el.nativeElement.querySelectorAll('.accordion-item').forEach((i: HTMLElement) => i.classList.remove('active'));
            
            if (isOpen) {
              item.classList.remove('active');
            } else {
              item.classList.add('active');
            }
          }
        });
      });
    }
  }
}
