import { ChangeDetectionStrategy, Component, OnInit, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../../environments/environment';

interface Thread {
  threadId: number;
  sellerId: number;
  sellerName: string;
  subject?: string;
  lastMessageAt: string;
  unreadCount: number;
  status: string;
}

interface Message {
  id: number;
  senderName: string;
  body: string;
  sentAt: string;
  isAdmin: boolean;
}

@Component({
  selector: 'app-messages',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './messages.component.html',
  styleUrl: './messages.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MessagesComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private get _base() { return `${environment.apiUrl}/marketplace`; }

  readonly loading = signal(true);
  readonly threads = signal<Thread[]>([]);
  readonly activeThread = signal<Thread | null>(null);
  readonly messages = signal<Message[]>([]);
  readonly replyBody = signal('');
  readonly sending = signal(false);

  readonly unreadTotal = computed(() => this.threads().reduce((s, t) => s + t.unreadCount, 0));

  ngOnInit(): void { this._loadThreads(); }

  private _loadThreads(): void {
    this._http.get<Thread[]>(`${this._base}/messages/threads`).subscribe({
      next: t => { this.threads.set(t); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  openThread(thread: Thread): void {
    this.activeThread.set(thread);
    this.messages.set([]);
    this._http.get<Message[]>(`${this._base}/messages/${thread.threadId}`).subscribe({
      next: msgs => this.messages.set(msgs)
    });
  }

  sendReply(): void {
    const thread = this.activeThread();
    const body = this.replyBody().trim();
    if (!thread || !body) return;
    this.sending.set(true);
    this._http.post(`${this._base}/messages/${thread.threadId}/reply`, { body }).subscribe({
      next: () => {
        this.sending.set(false);
        this.replyBody.set('');
        this.openThread(thread);
      },
      error: () => this.sending.set(false)
    });
  }
}
