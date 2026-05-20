import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface CommissionTier {
  id: number;
  categoryId: number;
  categoryName: string;
  rate: number;
  effectiveFrom: string;
}

@Component({
  selector: 'app-commissions',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './commissions.component.html',
  styleUrl: './commissions.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CommissionsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  readonly loading = signal(true);
  readonly tiers = signal<CommissionTier[]>([]);
  readonly message = signal('');
  readonly showForm = signal(false);
  readonly editTier = signal<Partial<CommissionTier>>({});

  ngOnInit(): void { this._load(); }

  private _load(): void {
    this.loading.set(true);
    this._http.get<CommissionTier[]>(`${this._base}/commission-tiers`).subscribe({
      next: t => { this.tiers.set(t); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  openNew(): void { this.editTier.set({ rate: 10 }); this.showForm.set(true); }

  openEdit(tier: CommissionTier): void { this.editTier.set({ ...tier }); this.showForm.set(true); }

  cancel(): void { this.showForm.set(false); this.editTier.set({}); }

  setCategoryId(value: string): void {
    this.editTier.update(t => ({ ...t, categoryId: +value }));
  }

  setRate(value: string): void {
    this.editTier.update(t => ({ ...t, rate: +value }));
  }

  setEffectiveFrom(value: string): void {
    this.editTier.update(t => ({ ...t, effectiveFrom: value }));
  }

  save(): void {
    const t = this.editTier();
    const req = t.id
      ? this._http.put(`${this._base}/commission-tiers/${t.id}`, t)
      : this._http.post(`${this._base}/commission-tiers`, t);
    req.subscribe({
      next: () => { this.cancel(); this._load(); this.message.set('Commission rate saved.'); setTimeout(() => this.message.set(''), 3000); },
      error: () => this.message.set('Save failed.')
    });
  }
}
