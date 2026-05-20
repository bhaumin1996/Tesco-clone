import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

interface MessageItem { id: number; senderType: 'seller' | 'admin'; senderName: string; body: string; sentOn: string; isRead: boolean; }
interface Thread { id: number; subject: string; lastMessage: string; lastMessageOn: string; unreadCount: number; status: 'open' | 'closed'; }

@Component({
  selector: 'app-seller-messages',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './messages.component.html',
  styleUrl: './messages.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class SellerMessagesComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  readonly loading = signal(true);
  readonly threads = signal<Thread[]>([]);
  readonly activeThread = signal<Thread | null>(null);
  readonly messages = signal<MessageItem[]>([]);
  readonly replyText = signal('');
  readonly sending = signal(false);
  readonly composing = signal(false);
  readonly newSubject = signal('');
  readonly newBody = signal('');

  ngOnInit(): void {
    this._http.get<Thread[]>(`${environment.apiUrl}/marketplace/messages`).subscribe({
      next: t => { this.threads.set(t); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
  }

  openThread(thread: Thread): void {
    this.activeThread.set(thread);
    this.replyText.set('');
    this._http.get<MessageItem[]>(`${environment.apiUrl}/marketplace/messages/${thread.id}`).subscribe({
      next: msgs => {
        this.messages.set(msgs);
        this.threads.update(list => list.map(t => t.id === thread.id ? { ...t, unreadCount: 0 } : t));
      }
    });
  }

  sendReply(): void {
    const thread = this.activeThread();
    if (!thread || !this.replyText().trim()) return;
    this.sending.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/messages/${thread.id}/reply`, { body: this.replyText() }).subscribe({
      next: () => {
        this.sending.set(false);
        const reply: MessageItem = { id: Date.now(), senderType: 'seller', senderName: 'You', body: this.replyText(), sentOn: new Date().toISOString(), isRead: true };
        this.messages.update(m => [...m, reply]);
        this.replyText.set('');
      },
      error: () => this.sending.set(false)
    });
  }

  startCompose(): void { this.composing.set(true); this.newSubject.set(''); this.newBody.set(''); }
  cancelCompose(): void { this.composing.set(false); }

  sendNewMessage(): void {
    if (!this.newSubject().trim() || !this.newBody().trim()) return;
    this.sending.set(true);
    this._http.post(`${environment.apiUrl}/marketplace/messages`, { subject: this.newSubject(), body: this.newBody() }).subscribe({
      next: (t: any) => {
        this.sending.set(false);
        this.composing.set(false);
        this._reload();
      },
      error: () => this.sending.set(false)
    });
  }

  private _reload(): void {
    this._http.get<Thread[]>(`${environment.apiUrl}/marketplace/messages`).subscribe({ next: t => this.threads.set(t) });
  }
}
