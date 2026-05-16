import { ChangeDetectionStrategy, Component, inject, signal, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { StripeCardComponent, StripeService, NgxStripeModule } from 'ngx-stripe';
import { StripeCardElementOptions, StripeElementsOptions } from '@stripe/stripe-js';
import { CartService } from '../../core/services/cart.service';
import { OrderService } from '../../core/services/order.service';
import { AddressService } from '../../core/services/address.service';
import { AuthService } from '../../core/services/auth.service';
import { PaymentService, UserCard } from '../../core/services/payment.service';
import { NotificationService } from '../../core/services/notification.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [CommonModule, RouterLink, ReactiveFormsModule, SpinnerComponent, NgxStripeModule],
  templateUrl: './checkout.component.html',
  styleUrl: './checkout.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CheckoutComponent implements OnInit {
  private readonly _fb = inject(FormBuilder);
  protected readonly cartService = inject(CartService);
  private readonly _orders = inject(OrderService);
  private readonly _addresses = inject(AddressService);
  private readonly _payment = inject(PaymentService);
  private readonly _auth = inject(AuthService);
  private readonly _notifications = inject(NotificationService);
  private readonly _router = inject(Router);
  private readonly _stripeService = inject(StripeService);

  @ViewChild(StripeCardComponent) card!: StripeCardComponent;
  
  protected savedCards = signal<UserCard[]>([]);
  protected showNewCardForm = signal(true);
  protected isCardComplete = signal(false);
  protected cardError = signal<string | null>(null);
  
  ngOnInit(): void {
    this._loadDefaultAddress();
    this._loadSavedCards();
  }

  protected onCardChange(event: any): void {
    this.isCardComplete.set(event.complete);
    this.cardError.set(event.error ? event.error.message : null);
  }

  private _loadSavedCards(): void {
    this._payment.getCards().subscribe({
      next: (cards) => {
        this.savedCards.set(cards);
        if (cards.length > 0) {
          this.showNewCardForm.set(false);
          const defaultCard = cards.find(c => c.isDefault) || cards[0];
          this.paymentForm.patchValue({ selectedCardId: defaultCard.id.toString() });
        }
      }
    });
  }

  private _loadDefaultAddress(): void {
    const user = this._auth.user();
    if (user) {
      this.addressForm.patchValue({
        firstName: user.firstName,
        lastName: user.lastName
      });
      this.paymentForm.patchValue({
        nameOnCard: `${user.firstName} ${user.lastName}`
      });
    }

    this._addresses.getAddresses().subscribe({
      next: (addresses) => {
        const defaultAddr = addresses.find(a => a.isDefault);
        if (defaultAddr) {
          this.addressForm.patchValue({
            addressLine1: defaultAddr.addressLine1,
            addressLine2: defaultAddr.addressLine2,
            city: defaultAddr.townCity,
            postcode: defaultAddr.postcode
          });
        }
      }
    });
  }

  protected readonly cardOptions: StripeCardElementOptions = {
    hidePostalCode: true,
    style: {
      base: {
        color: '#333',
        fontFamily: '"Tesco Modern", Arial, sans-serif',
        fontSize: '16px',
        '::placeholder': {
          color: '#666'
        }
      }
    }
  };

  protected readonly elementsOptions: StripeElementsOptions = {
    locale: 'en'
  };

  protected step = signal<1 | 2 | 3>(1);
  protected submitting = signal(false);

  protected addressForm = this._fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    addressLine1: ['', Validators.required],
    addressLine2: [''],
    city: ['', Validators.required],
    postcode: ['', [Validators.required, Validators.pattern(/^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$/i)]]
  });

  protected paymentForm = this._fb.group({
    nameOnCard: ['', Validators.required],
    ageConfirmed: [false],
    acceptSubstitutions: [true],
    selectedCardId: ['new'],
    saveCard: [false]
  });

  protected toggleNewCard(show: boolean): void {
    this.showNewCardForm.set(show);
    if (show) {
      this.paymentForm.get('selectedCardId')?.setValue('new');
    }
  }

  protected nextStep(): void {
    if (this.step() === 1) {
      if (this.addressForm.invalid) {
        this.addressForm.markAllAsTouched();
        return;
      }
    }
    
    if (this.step() === 2) {
      const selectedCardId = this.paymentForm.get('selectedCardId')?.value;
      
      if (selectedCardId === 'new') {
        if (this.paymentForm.get('nameOnCard')?.invalid) {
          this.paymentForm.get('nameOnCard')?.markAsTouched();
          return;
        }
        if (!this.isCardComplete()) {
          if (!this.cardError()) this.cardError.set('Please enter your card details');
          return;
        }
      }

      const isAgeRestricted = this.cartService.cart()?.hasAgeRestrictedItems;
      const ageConfirmed = this.paymentForm.get('ageConfirmed')?.value;
      
      if (isAgeRestricted && !ageConfirmed) {
        this.paymentForm.get('ageConfirmed')?.setErrors({ required: true });
        this.paymentForm.get('ageConfirmed')?.markAsTouched();
        return;
      }

      if (this.paymentForm.invalid) {
        this.paymentForm.markAllAsTouched();
        return;
      }
    }

    if (this.step() < 3) this.step.update(s => (s + 1) as 1 | 2 | 3);
  }

  protected prevStep(): void { if (this.step() > 1) this.step.update(s => (s - 1) as 1 | 2 | 3); }

  protected placeOrder(): void {
    const isAgeRestricted = this.cartService.cart()?.hasAgeRestrictedItems;
    const ageConfirmed = this.paymentForm.get('ageConfirmed')?.value;
    
    if (isAgeRestricted && !ageConfirmed) {
      this.paymentForm.get('ageConfirmed')?.setErrors({ required: true });
    }

    if (this.paymentForm.invalid) {
      this.paymentForm.markAllAsTouched();
      return;
    }

    this.submitting.set(true);
    
    const selectedCardId = this.paymentForm.get('selectedCardId')?.value;
    const saveCard = !!this.paymentForm.get('saveCard')?.value;

    if (selectedCardId && selectedCardId !== 'new') {
      // Use existing card
      const card = this.savedCards().find(c => c.id.toString() === selectedCardId);
      if (card) {
        this._placeOrderInternal(card.paymentMethodId, false);
      } else {
        this.submitting.set(false);
        this._notifications.error('Selected card not found.');
      }
    } else {
      // Check if card is complete
      if (!this.isCardComplete()) {
        this.submitting.set(false);
        if (!this.cardError()) this.cardError.set('Please enter your card details');
        return;
      }

      // Create new payment method via Stripe
      const nameOnCard = this.paymentForm.get('nameOnCard')?.value || '';
      this._stripeService.createPaymentMethod({
        type: 'card',
        card: this.card.element,
        billing_details: { name: nameOnCard }
      }).subscribe({
        next: (result) => {
          if (result.error) {
            this.submitting.set(false);
            this._notifications.error(result.error.message ?? 'Payment error. Please check your card details.');
            return;
          }
          this._placeOrderInternal(result.paymentMethod.id, saveCard);
        },
        error: () => {
          this.submitting.set(false);
          this._notifications.error('Stripe integration error. Please try again.');
        }
      });
    }
  }

  private _placeOrderInternal(paymentMethodId: string, saveCard: boolean): void {
    const address = this.addressForm.value;
    const deliveryAddress = `${address.firstName} ${address.lastName}, ${address.addressLine1}${address.addressLine2 ? ', ' + address.addressLine2 : ''}, ${address.city}, ${address.postcode}`;
    
    this._orders.placeOrder({
      deliverySlotId: undefined,
      deliveryAddress: deliveryAddress,
      deliveryCharge: this.cartService.cart()?.deliveryCharge ?? 0,
      acceptSubstitutions: !!this.paymentForm.get('acceptSubstitutions')?.value,
      ageConfirmed: !!this.paymentForm.get('ageConfirmed')?.value,
      paymentMethodId: paymentMethodId,
      saveCard: saveCard
    }).subscribe({
      next: (order) => {
        this.submitting.set(false);
        this.cartService.loadCart().subscribe(); // Refresh cart state (it will be empty)
        this._notifications.success('Order placed successfully!');
        this._router.navigate(['/account/orders', order.id]);
      },
      error: (err) => {
        this.submitting.set(false);
        this._notifications.error(err?.error?.error?.message ?? 'Could not place order. Please try again.');
      }
    });
  }
}
