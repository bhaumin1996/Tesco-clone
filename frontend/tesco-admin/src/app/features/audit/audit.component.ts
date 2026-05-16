import { ChangeDetectionStrategy, Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

interface AuditEntry {
  auditId: number;
  tableName: string;
  action: string;
  changedBy: string;
  changedOn: string;
  recordId: number;
  summary: string;
}

interface LogEntry {
  logId: number;
  level: string;
  source: string;
  message: string;
  correlationId: string;
  createdOn: string;
}

interface PagedResult<T> { items: T[]; totalPages: number; totalCount: number; }

@Component({
  selector: 'app-admin-audit',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './audit.component.html',
  styleUrl: './audit.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminAuditComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);

  protected readonly pageSize = 20;

  protected auditEntries = signal<AuditEntry[]>([]);
  protected logEntries = signal<LogEntry[]>([]);
  protected totalAuditPages = signal(1);
  protected totalLogPages = signal(1);
  protected totalAuditCount = signal(0);
  protected totalLogCount = signal(0);
  protected auditPage = signal(1);
  protected logPage = signal(1);
  protected loading = signal(true);
  protected activeTab = signal<'audit' | 'logs'>('audit');

  protected auditFilter = this._fb.group({ table: [''], action: [''] });
  protected logFilter = this._fb.group({ level: [''], source: [''] });

  protected readonly logLevels = ['Info', 'Warning', 'Error', 'Critical'];

  private get _base() { return `${environment.apiUrl}/admin`; }

  ngOnInit(): void {
    this._loadAudit();
    this._loadLogs();
    this.auditFilter.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.auditPage.set(1); this._loadAudit();
    });
    this.logFilter.valueChanges.pipe(debounceTime(400), distinctUntilChanged()).subscribe(() => {
      this.logPage.set(1); this._loadLogs();
    });
  }

  private _loadAudit(): void {
    const { table, action } = this.auditFilter.getRawValue();
    const params: Record<string, string> = { pageNumber: String(this.auditPage()), pageSize: '20' };
    if (table) params['table'] = table;
    if (action) params['action'] = action;
    this._http.get<PagedResult<AuditEntry>>(`${this._base}/audit`, { params }).subscribe({
      next: r => { this.auditEntries.set(r.items); this.totalAuditPages.set(r.totalPages); this.totalAuditCount.set(r.totalCount); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  private _loadLogs(): void {
    const { level, source } = this.logFilter.getRawValue();
    const params: Record<string, string> = { pageNumber: String(this.logPage()), pageSize: '20' };
    if (level) params['level'] = level;
    if (source) params['source'] = source;
    this._http.get<PagedResult<LogEntry>>(`${this._base}/logs`, { params }).subscribe({
      next: r => { this.logEntries.set(r.items); this.totalLogPages.set(r.totalPages); this.totalLogCount.set(r.totalCount); },
      error: () => {}
    });
  }

  protected goAudit(p: number): void { this.auditPage.set(p); this._loadAudit(); }
  protected goLog(p: number): void { this.logPage.set(p); this._loadLogs(); }
  protected auditPages(): number[] { return Array.from({ length: this.totalAuditPages() }, (_, i) => i + 1); }
  protected logPages(): number[] { return Array.from({ length: this.totalLogPages() }, (_, i) => i + 1); }
}
