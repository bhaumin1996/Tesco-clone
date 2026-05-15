import { Component, OnInit, inject, signal, ElementRef, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ContentService, Page } from '../../core/services/content.service';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { Router } from '@angular/router';

@Component({
  selector: 'app-delivery-saver',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './delivery-saver.component.html',
  styleUrl: './delivery-saver.component.scss'
})
export class DeliverySaverComponent implements OnInit, AfterViewChecked {
  private contentService = inject(ContentService);
  private sanitizer = inject(DomSanitizer);
  private el = inject(ElementRef);
  private router = inject(Router);

  page = signal<Page | null>(null);
  safeContent = signal<SafeHtml>('');
  loading = signal(true);
  error = signal<string | null>(null);

  private elementsInitialized = false;

  ngOnInit(): void {
    this.loadPage();
  }

  ngAfterViewChecked(): void {
    if (!this.elementsInitialized && this.page()) {
      this.initializeElements();
    }
  }

  private loadPage(): void {
    this.contentService.getPageBySlug('delivery-saver').subscribe({
      next: (data) => {
        this.page.set(data);
        this.safeContent.set(this.sanitizer.bypassSecurityTrustHtml(data.content));
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error loading delivery saver page:', err);
        this.error.set('Failed to load page content. Please try again later.');
        this.loading.set(false);
      }
    });
  }

  private initializeElements(): void {
    const tabBtns = this.el.nativeElement.querySelectorAll('.tab-btn');
    const ctaBtns = this.el.nativeElement.querySelectorAll('.cta-btn');
    const tcLinks = this.el.nativeElement.querySelectorAll('.tc-link');
    
    if (tabBtns.length > 0 || ctaBtns.length > 0 || tcLinks.length > 0) {
      this.elementsInitialized = true;
      
      // Initialize Tabs
      tabBtns.forEach((btn: HTMLElement) => {
        btn.addEventListener('click', () => {
          tabBtns.forEach((b: HTMLElement) => b.classList.remove('active'));
          btn.classList.add('active');
          const tabText = btn.innerText || btn.textContent || '';
          this.switchPlans(tabText);
        });
      });

      // Initialize Sign up buttons
      ctaBtns.forEach((btn: HTMLElement) => {
        btn.addEventListener('click', (e: Event) => {
          e.preventDefault();
          this.router.navigate(['/auth/register']);
        });
      });

      // Initialize Terms Links (supporting multiple links if needed)
      tcLinks.forEach((link: HTMLElement) => {
        link.addEventListener('click', (e: Event) => {
          e.preventDefault();
          this.router.navigate(['/delivery-saver/terms']);
        });
      });
    }
  }

  private switchPlans(tabText: string): void {
    const planCards = this.el.nativeElement.querySelectorAll('.plan-card');
    const is12Month = tabText.toLowerCase().includes('12-month');
    
    planCards.forEach((card: HTMLElement) => {
      card.style.opacity = '0.5';
      card.style.transform = 'translateY(10px)';
      
      setTimeout(() => {
        const freq = card.querySelector('.freq') as HTMLElement;
        const total = card.querySelector('.total') as HTMLElement;
        const priceAmount = card.querySelector('.amount') as HTMLElement;
        const originalPrice = card.querySelector('.original-price') as HTMLElement;
        const savingsText = card.querySelector('.savings-text') as HTMLElement;
        
        const basePriceStr = card.getAttribute('data-base-price') || '0';
        const basePrice = parseFloat(basePriceStr);
        
        if (freq && total && priceAmount && basePrice > 0) {
          if (is12Month) {
            freq.innerText = 'a month for 12 months';
            const discountPercent = 0.125;
            const discountedMonthly = (basePrice * (1 - discountPercent));
            const roundedDiscounted = Math.floor(discountedMonthly) + 0.99;
            
            priceAmount.innerText = `£${roundedDiscounted.toFixed(2)}`;
            total.innerText = `£${(roundedDiscounted * 12).toFixed(2)} in total`;
            
            if (originalPrice) {
              originalPrice.innerText = `£${basePrice.toFixed(2)}`;
              originalPrice.style.display = 'inline-block';
            }
            
            if (savingsText) {
              const savingsPercent = Math.round(discountPercent * 100);
              savingsText.innerText = `Save ${savingsPercent}% over 12 months compared with a 6-month plan`;
              savingsText.style.display = 'block';
            }
          } else {
            freq.innerText = 'a month for 6 months';
            priceAmount.innerText = `£${basePrice.toFixed(2)}`;
            total.innerText = `£${(basePrice * 6).toFixed(2)} in total`;
            
            if (originalPrice) {
              originalPrice.style.display = 'none';
            }
            
            if (savingsText) {
              savingsText.style.display = 'none';
            }
          }
        }
        
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
      }, 250);
    });
  }
}
