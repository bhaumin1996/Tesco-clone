import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { SellerAuthService } from '../../core/services/seller-auth.service';

interface ApplicationForm {
  businessName: string;
  businessType: string;
  contactName: string;
  email: string;
  phone: string;
  website: string;
  description: string;
  vatNumber: string;
  estimatedMonthlyTurnover: string;
}

const STEP_FIELDS: Record<number, (keyof ApplicationForm)[]> = {
  1: ['businessName', 'businessType', 'vatNumber', 'website'],
  2: ['contactName', 'email', 'phone'],
  3: ['description', 'estimatedMonthlyTurnover'],
};

@Component({
  selector: 'app-seller-apply',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './apply.component.html',
  styleUrl: './apply.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerApplyComponent {
  private readonly _http = inject(HttpClient);
  readonly auth = inject(SellerAuthService);

  readonly submitting = signal(false);
  readonly submitted = signal(false);
  readonly error = signal('');
  readonly fieldErrors = signal<Record<string, string>>({});
  readonly currentStep = signal(1);
  readonly totalSteps = 3;

  readonly form = signal<ApplicationForm>({
    businessName: '',
    businessType: '',
    contactName: '',
    email: '',
    phone: '',
    website: '',
    description: '',
    vatNumber: '',
    estimatedMonthlyTurnover: ''
  });

  readonly businessTypes = [
    'Sole Trader',
    'Limited Company',
    'Partnership',
    'PLC',
    'Other'
  ];

  readonly turnoverRanges = [
    'Under £10,000/month',
    '£10,000 – £50,000/month',
    '£50,000 – £200,000/month',
    '£200,000 – £500,000/month',
    'Over £500,000/month'
  ];

  update(changes: Partial<ApplicationForm>): void {
    this.form.update(f => ({ ...f, ...changes }));
    if (Object.keys(changes).length > 0) {
      const field = Object.keys(changes)[0];
      const errors = { ...this.fieldErrors() };
      delete errors[field];
      this.fieldErrors.set(errors);
    }
  }

  private validateStep(step: number): boolean {
    const f = this.form();
    const errors: Record<string, string> = { ...this.fieldErrors() };

    // Clear errors only for this step's fields
    for (const field of STEP_FIELDS[step]) {
      delete errors[field];
    }

    if (step === 1) {
      if (!f.businessName.trim()) errors['businessName'] = 'Business Name is required.';
      if (!f.businessType) errors['businessType'] = 'Business Type is required.';
      if (f.vatNumber?.trim()) {
        const clean = f.vatNumber.replace(/[\s\-]/g, '');
        if (clean.length < 9 || clean.length > 15) errors['vatNumber'] = 'VAT number must be 9–15 characters.';
      }
      if (f.website?.trim()) {
        const urlPattern = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i;
        if (!urlPattern.test(f.website.trim())) {
          errors['website'] = 'Please enter a valid website URL.';
        }
      }
    }

    if (step === 2) {
      if (!f.contactName.trim()) errors['contactName'] = 'Contact Name is required.';
      if (!f.email.trim()) {
        errors['email'] = 'Email Address is required.';
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.email)) {
        errors['email'] = 'Please enter a valid email address.';
      }
      if (!f.phone.trim()) {
        errors['phone'] = 'Phone Number is required.';
      } else {
        const clean = f.phone.replace(/[\s\-()+]/g, '');
        if (clean.length < 10 || clean.length > 15) errors['phone'] = 'Phone must be 10–15 digits.';
      }
    }

    if (step === 3) {
      if (!f.description.trim()) errors['description'] = 'Product description is required.';
    }

    this.fieldErrors.set(errors);
    return Object.keys(errors).every(k => !STEP_FIELDS[step].includes(k as keyof ApplicationForm));
  }

  next(): void {
    if (!this.validateStep(this.currentStep())) return;
    this.error.set('');
    this.currentStep.update(s => Math.min(s + 1, this.totalSteps));
  }

  prev(): void {
    this.error.set('');
    this.currentStep.update(s => Math.max(s - 1, 1));
  }

  submit(): void {
    if (!this.validateStep(3)) {
      this.error.set('Please fix the errors below before submitting.');
      return;
    }

    this.submitting.set(true);
    this.error.set('');

    const payload = {
      businessName: this.form().businessName,
      businessEmail: this.form().email,
      phone: this.form().phone,
      description: this.form().description,
      registrationNumber: '',
      vatNumber: this.form().vatNumber || null,
      bankDetailsRef: '',
      categoryIds: '',
      tsAndCsAccepted: true,
      contactName: this.form().contactName,
      website: this.form().website || null
    };

    this._http.post(`${environment.apiUrl}/marketplace/sellers/apply`, payload).subscribe({
      next: () => {
        this.submitting.set(false);
        this.submitted.set(true);
        this.fieldErrors.set({});
      },
      error: (err: any) => {
        this.submitting.set(false);
        if (err.status === 422 && err.error?.error?.details) {
          const apiErrors = err.error.error.details;
          const errors: Record<string, string> = {};
          apiErrors.forEach((e: any) => {
            const raw = e.field.replace(/^Dto\./, '');
            let key = raw.charAt(0).toLowerCase() + raw.slice(1);
            if (key === 'businessEmail') key = 'email';
            errors[key] = e.message;
          });
          this.fieldErrors.set(errors);
          this.error.set(err.error?.error?.message || 'One or more validation errors occurred.');
        } else if (err.status === 401) {
          this.error.set('You must be signed in to apply.');
        } else {
          this.error.set(err.error?.error?.message || 'Failed to submit. Please try again.');
        }
      }
    });
  }
}
