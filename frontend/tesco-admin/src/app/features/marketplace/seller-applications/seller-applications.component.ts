import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';
import { extractApiError } from '../../../core/utils/api-error';

interface SellerApplication {
  id: number;
  businessName: string;
  businessEmail: string;
  phone?: string;
  statusName: string;
  tsAndCsAccepted: boolean;
  reviewNotes?: string;
  reviewedOn?: string;
  createdOn: string;
  modifiedOn?: string;
  registrationNumber?: string;
  vatNumber?: string;
  description?: string;
  bankDetailsRef?: string;
  categoryIds?: string;
  website?: string;
}

@Component({
  selector: 'app-seller-applications',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './seller-applications.component.html',
  styleUrl: './seller-applications.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerApplicationsComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/admin/marketplace`; }

  readonly loading = signal(true);
  readonly applications = signal<SellerApplication[]>([]);
  readonly statusFilter = signal<string>('all');
  readonly searchTerm = signal('');
  readonly message = signal('');
  readonly selectedApp = signal<SellerApplication | null>(null);
  readonly actionNotes = signal('');
  readonly actionInProgress = signal<'approve' | 'reject' | null>(null);
  readonly submitting = computed(() => this.actionInProgress() !== null);

  readonly filtered = computed(() => {
    let list = this.applications();
    const sf = this.statusFilter();
    const q = this.searchTerm().toLowerCase();
    if (sf !== 'all') list = list.filter(a => a.statusName.toLowerCase() === sf.toLowerCase());
    if (q) list = list.filter(a =>
      a.businessName.toLowerCase().includes(q) || a.businessEmail.toLowerCase().includes(q)
    );
    return list;
  });

  readonly statusCounts = computed(() => {
    const all = this.applications();
    return {
      all: all.length,
      submitted: all.filter(a => a.statusName === 'Submitted').length,
      underReview: all.filter(a => a.statusName === 'UnderReview').length,
      approved: all.filter(a => a.statusName === 'Approved').length,
      rejected: all.filter(a => a.statusName === 'Rejected').length
    };
  });

  ngOnInit(): void {
    this._load();
  }

  private _load(): void {
    this.loading.set(true);
    this._http.get<any>(`${this._base}/applications`).subscribe({
      next: res => {
        const items: SellerApplication[] = Array.isArray(res) ? res : (res?.items ?? []);
        this.applications.set(items);
        this.loading.set(false);
      },
      error: () => this.loading.set(false)
    });
  }

  selectApp(app: SellerApplication): void {
    this.selectedApp.set(app);
    this.actionNotes.set('');
  }

  closeDetail(): void {
    this.selectedApp.set(null);
    this.actionNotes.set('');
  }

  approve(id: number): void {
    this._review(id, 'Approve');
  }

  reject(id: number): void {
    this._review(id, 'Reject');
  }

  private _review(id: number, decision: 'Approve' | 'Reject'): void {
    this.actionInProgress.set(decision === 'Approve' ? 'approve' : 'reject');
    const notes = this.actionNotes().trim();

    this._http.post(`${this._base}/applications/${id}/review`, {
      decision,
      reviewNotes: notes || null
    }).subscribe({
      next: () => {
        this.actionInProgress.set(null);
        this.closeDetail();
        this._load();
        this._notify(`Seller application ${decision === 'Approve' ? 'approved' : 'rejected'}.`);
      },
      error: err => {
        this.actionInProgress.set(null);
        this._notify(extractApiError(err, 'Action failed. Please try again.'));
      }
    });
  }

  private _notify(msg: string): void {
    this.message.set(msg);
    setTimeout(() => this.message.set(''), 4000);
  }
}
