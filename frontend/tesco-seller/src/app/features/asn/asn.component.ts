import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface AsnLine { sku: string; quantity: number; }
interface AsnRecord { id: number; reference: string; expectedArrivalDate: string; status: 'Submitted' | 'Received' | 'Processed'; lineCount: number; submittedOn: string; }

@Component({
  selector: 'app-seller-asn',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './asn.component.html',
  styleUrl: './asn.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerAsnComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly asnList = signal<AsnRecord[]>([]);
  readonly showForm = signal(false);
  readonly submitting = signal(false);
  readonly message = signal('');
  readonly expectedDate = signal('');
  readonly lines = signal<AsnLine[]>([{ sku: '', quantity: 1 }]);

  ngOnInit(): void {
    this._load();
  }

  openForm(): void { this.showForm.set(true); this.expectedDate.set(''); this.lines.set([{ sku: '', quantity: 1 }]); }
  closeForm(): void { this.showForm.set(false); }

  addLine(): void { this.lines.update(l => [...l, { sku: '', quantity: 1 }]); }

  removeLine(index: number): void {
    this.lines.update(l => l.filter((_, i) => i !== index));
  }

  updateLine(index: number, changes: Partial<AsnLine>): void {
    this.lines.update(l => l.map((line, i) => i === index ? { ...line, ...changes } : line));
  }

  isFormValid(): boolean {
    return !!this.expectedDate() && this.lines().length > 0 && this.lines().every(l => l.sku.trim() && l.quantity > 0);
  }

  submit(): void {
    if (!this.isFormValid()) return;
    this.submitting.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/asn`, {
      expectedArrivalDate: this.expectedDate(),
      lines: this.lines()
    }).subscribe({
      next: () => {
        this.submitting.set(false);
        this.closeForm();
        this._load();
        this.message.set('ASN submitted successfully.');
        setTimeout(() => this.message.set(''), 4000);
      },
      error: () => this.submitting.set(false)
    });
  }

  statusStep(status: AsnRecord['status']): number {
    return { 'Submitted': 1, 'Received': 2, 'Processed': 3 }[status] ?? 1;
  }

  private _load(): void {
    this._http.get<AsnRecord[]>(`${environment.apiUrl}/marketplace/asn`).subscribe({
      next: list => { this.asnList.set(list); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }
}
