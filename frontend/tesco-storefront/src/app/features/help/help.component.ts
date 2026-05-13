import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbComponent } from '../../shared/components/breadcrumb/breadcrumb.component';

interface FaqCategory {
  title: string;
  icon: string;
  faqs: { q: string; a: string }[];
}

@Component({
  selector: 'app-help',
  standalone: true,
  imports: [CommonModule, RouterLink, BreadcrumbComponent],
  templateUrl: './help.component.html',
  styleUrl: './help.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HelpComponent {
  protected openFaq = signal<string | null>(null);

  protected categories: FaqCategory[] = [
    {
      title: 'Orders & Delivery', icon: '📦',
      faqs: [
        { q: 'How do I track my order?', a: 'Go to My Account > My Orders and select your order to see its current status and estimated delivery time.' },
        { q: 'Can I change my delivery slot?', a: 'Yes, you can change your delivery slot up to the cut-off time shown on your order. Go to My Orders > select order > Change slot.' },
        { q: 'What if an item is out of stock?', a: 'If you have accepted substitutions, we may replace unavailable items with similar products. You\'ll see the substitution on your eCDN after delivery.' },
        { q: 'How do I cancel an order?', a: 'Orders can be cancelled before the cut-off time via My Account > My Orders > Cancel Order.' }
      ]
    },
    {
      title: 'Clubcard', icon: '💳',
      faqs: [
        { q: 'How do I earn Clubcard points?', a: 'You earn 1 point for every £1 spent on qualifying purchases online or in-store.' },
        { q: 'How do I redeem Clubcard vouchers?', a: 'Your vouchers are automatically applied at checkout when you sign in with your Clubcard-linked account.' },
        { q: 'When do my points expire?', a: 'Points are converted to vouchers every quarter (February, May, August, November). Vouchers are valid for 2 years.' }
      ]
    },
    {
      title: 'Account & Payments', icon: '👤',
      faqs: [
        { q: 'How do I reset my password?', a: 'Click "Forgot password?" on the sign in page and we\'ll email you a reset link.' },
        { q: 'What payment methods do you accept?', a: 'We accept Visa, Mastercard, American Express, PayPal, and Clubcard vouchers.' },
        { q: 'Is my payment information secure?', a: 'Yes. We use industry-standard encryption and never store your full card details.' }
      ]
    },
    {
      title: 'Returns & Refunds', icon: '↩️',
      faqs: [
        { q: 'How do I request a refund?', a: 'Contact us via My Account > Help > Raise a Refund Request. We aim to process refunds within 3-5 business days.' },
        { q: 'What if my order arrives damaged?', a: 'We\'re sorry to hear this. Contact us within 24 hours and we\'ll arrange a replacement or refund.' }
      ]
    }
  ];

  protected toggleFaq(key: string): void {
    this.openFaq.update(v => v === key ? null : key);
  }
}
