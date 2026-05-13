import { ChangeDetectionStrategy, Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-quantity-stepper',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="qty-stepper" role="group" [attr.aria-label]="label">
      <button class="qty-stepper__btn" (click)="decrement()" [disabled]="quantity <= min" aria-label="Decrease quantity">-</button>
      <span class="qty-stepper__value" aria-live="polite">{{ quantity }}</span>
      <button class="qty-stepper__btn" (click)="increment()" [disabled]="quantity >= max" aria-label="Increase quantity">+</button>
    </div>
  `,
  styles: [`
    .qty-stepper { display: inline-flex; align-items: center; border: 2px solid #00539f; border-radius: 4px; overflow: hidden; }
    .qty-stepper__btn {
      background: #fff; border: none; cursor: pointer; font-size: 1.25rem; font-weight: 700;
      width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; color: #00539f;
      &:hover:not(:disabled) { background: #e8f2fc; }
      &:disabled { opacity: 0.4; cursor: not-allowed; }
    }
    .qty-stepper__value { min-width: 36px; text-align: center; font-weight: 700; font-size: 1rem; }
  `],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class QuantityStepperComponent {
  @Input() quantity = 1;
  @Input() min = 1;
  @Input() max = 99;
  @Input() label = 'Quantity';
  @Output() quantityChange = new EventEmitter<number>();

  increment(): void { if (this.quantity < this.max) this.quantityChange.emit(this.quantity + 1); }
  decrement(): void { if (this.quantity > this.min) this.quantityChange.emit(this.quantity - 1); }
}
