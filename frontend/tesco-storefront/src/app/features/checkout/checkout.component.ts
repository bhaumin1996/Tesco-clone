import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { CartService } from '../../core/services/cart.service';
import { OrderService } from '../../core/services/order.service';
import { NotificationService } from '../../core/services/notification.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner.component';

@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [CommonModule, RouterLink, ReactiveFormsModule, SpinnerComponent],
  templateUrl: './checkout.component.html',
  styleUrl: './checkout.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CheckoutComponent {
  private readonly _fb = inject(FormBuilder);
  protected readonly cartService = inject(CartService);
  private readonly _orders = inject(OrderService);
  private readonly _notifications = inject(NotificationService);
  private readonly _router = inject(Router);

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
    cardNumber: ['', [Validators.required, Validators.pattern(/^\d{16}$/)]],
    expiryDate: ['', [Validators.required, Validators.pattern(/^\d{2}\/\d{2}$/)]],
    cvv: ['', [Validators.required, Validators.pattern(/^\d{3,4}$/)]],
    nameOnCard: ['', Validators.required],
    ageConfirmed: [false],
    acceptSubstitutions: [true]
  });

  protected nextStep(): void {
    if (this.step() === 1 && this.addressForm.invalid) {
      this.addressForm.markAllAsTouched();
      return;
    }
    
    if (this.step() === 2) {
      const isAgeRestricted = this.cartService.cart()?.hasAgeRestrictedItems;
      const ageConfirmed = this.paymentForm.get('ageConfirmed')?.value;
      
      if (isAgeRestricted && !ageConfirmed) {
        this.paymentForm.get('ageConfirmed')?.setErrors({ required: true });
        this.paymentForm.get('ageConfirmed')?.markAsTouched();
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
    
    const address = this.addressForm.value;
    const deliveryAddress = `${address.firstName} ${address.lastName}, ${address.addressLine1}${address.addressLine2 ? ', ' + address.addressLine2 : ''}, ${address.city}, ${address.postcode}`;
    
    this._orders.placeOrder({
      deliverySlotId: undefined, // Slot selection not implemented yet
      deliveryAddress: deliveryAddress,
      deliveryCharge: this.cartService.cart()?.deliveryCharge ?? 0,
      acceptSubstitutions: !!this.paymentForm.get('acceptSubstitutions')?.value,
      ageConfirmed: !!this.paymentForm.get('ageConfirmed')?.value
    }).subscribe({
      next: (order) => {
        this.submitting.set(false);
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
