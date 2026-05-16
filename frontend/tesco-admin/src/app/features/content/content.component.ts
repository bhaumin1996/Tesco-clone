import { ChangeDetectionStrategy, Component, computed, DestroyRef, inject, OnInit, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { ImageUrlPipe } from '../../shared/pipes/image-url.pipe';

interface CmsPage {
  id: number;
  title: string;
  slug: string;
  content: string | null;
  isPublished: boolean;
  createdOn: string;
  modifiedOn: string | null;
}

interface Banner {
  id: number;
  title: string;
  subTitle: string | null;
  imageUrl: string | null;
  linkUrl: string | null;
  isActive: boolean;
  displayOrder: number;
  startsAt: string | null;
  endsAt: string | null;
}

@Component({
  selector: 'app-admin-content',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, ImageUrlPipe],
  templateUrl: './content.component.html',
  styleUrl: './content.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AdminContentComponent implements OnInit {
  private readonly _http = inject(HttpClient);
  private readonly _fb = inject(FormBuilder);
  private readonly _destroyRef = inject(DestroyRef);
  private _slugAutoSync = false;

  protected pages = signal<CmsPage[]>([]);
  protected banners = signal<Banner[]>([]);
  protected loading = signal(true);
  protected activeTab = signal<'pages' | 'banners'>('pages');
  protected showForm = signal(false);
  protected formType = signal<'page' | 'banner'>('page');
  protected editId = signal<number | null>(null);
  protected message = signal('');

  protected cmsSearch = signal('');
  protected bannerSearch = signal('');

  // ── Image Upload State ────────────────────────────────────────────────────
  protected selectedFile = signal<File | null>(null);
  protected previewUrl = signal<string | null>(null);
  protected existingImageUrl = signal<string | null>(null);
  protected uploading = signal(false);
  protected saving = signal(false);

  protected readonly pageSize = 10;
  protected cmsPage = signal(1);
  protected filteredPages = computed(() => {
    const q = this.cmsSearch().toLowerCase();
    return q ? this.pages().filter(p =>
      p.title.toLowerCase().includes(q) ||
      p.slug.toLowerCase().includes(q)
    ) : this.pages();
  });
  protected cmsTotalPages = computed(() => Math.max(1, Math.ceil(this.filteredPages().length / this.pageSize)));
  protected pagedCmsPages = computed(() => { const s = (this.cmsPage() - 1) * this.pageSize; return this.filteredPages().slice(s, s + this.pageSize); });
  protected cmsPageNumbers = computed(() => Array.from({ length: this.cmsTotalPages() }, (_, i) => i + 1));

  protected bannerPage = signal(1);
  protected filteredBanners = computed(() => {
    const q = this.bannerSearch().toLowerCase();
    return q ? this.banners().filter(b => b.title.toLowerCase().includes(q)) : this.banners();
  });
  protected bannerTotalPages = computed(() => Math.max(1, Math.ceil(this.filteredBanners().length / this.pageSize)));
  protected pagedBanners = computed(() => { const s = (this.bannerPage() - 1) * this.pageSize; return this.filteredBanners().slice(s, s + this.pageSize); });
  protected bannerPageNumbers = computed(() => Array.from({ length: this.bannerTotalPages() }, (_, i) => i + 1));

  protected pageForm = this._fb.group({
    title: ['', Validators.required],
    slug: ['', Validators.required],
    content: ['', Validators.required],
    isPublished: [false]
  });

  protected bannerForm = this._fb.group({
    title: ['', Validators.required],
    imageUrl: [''],
    linkUrl: [''],
    displayOrder: [1, Validators.required],
    startsAt: [null as string | null],
    endsAt: [null as string | null]
  });

  private get _base() { return `${environment.apiUrl}/admin/content`; }

  ngOnInit(): void {
    this._load();
    this._setupSlugSync();
  }

  private _setupSlugSync(): void {
    this.pageForm.get('title')!.valueChanges
      .pipe(takeUntilDestroyed(this._destroyRef))
      .subscribe(title => {
        if (this._slugAutoSync && title !== null) {
          this.pageForm.get('slug')!.setValue(this._toSlug(title), { emitEvent: false });
        }
      });

    this.pageForm.get('slug')!.valueChanges
      .pipe(takeUntilDestroyed(this._destroyRef))
      .subscribe(() => { this._slugAutoSync = false; });
  }

  private _toSlug(value: string): string {
    return value
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-');
  }

  private _load(): void {
    this.loading.set(true);
    this._http.get<{ items: CmsPage[] }>(`${this._base}/pages`).subscribe({
      next: p => { this.pages.set(p.items ?? []); this.cmsPage.set(1); this.loading.set(false); },
      error: () => this.loading.set(false)
    });
    this._http.get<Banner[]>(`${this._base}/banners`).subscribe({
      next: b => { this.banners.set(b); this.bannerPage.set(1); },
      error: () => {}
    });
  }

  protected onCmsSearch(term: string): void { this.cmsSearch.set(term); this.cmsPage.set(1); }
  protected onBannerSearch(term: string): void { this.bannerSearch.set(term); this.bannerPage.set(1); }

  protected goToCmsPage(page: number): void { if (page >= 1 && page <= this.cmsTotalPages()) this.cmsPage.set(page); }
  protected goToBannerPage(page: number): void { if (page >= 1 && page <= this.bannerTotalPages()) this.bannerPage.set(page); }

  protected openPageForm(page?: CmsPage): void {
    this.formType.set('page');
    this.editId.set(page?.id ?? null);
    this._slugAutoSync = !page;
    this.pageForm.reset(page
      ? { title: page.title, slug: page.slug, content: page.content ?? '', isPublished: page.isPublished }
      : { isPublished: false });
    this.showForm.set(true);
  }

  protected onFileSelect(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0] ?? null;
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    if (file) {
      this.selectedFile.set(file);
      this.previewUrl.set(URL.createObjectURL(file));
    } else {
      this.selectedFile.set(null);
      this.previewUrl.set(null);
    }
  }

  protected removeImage(): void {
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    this.selectedFile.set(null);
    this.previewUrl.set(null);
    this.existingImageUrl.set(null);
    this.bannerForm.get('imageUrl')?.setValue('');
  }

  private _resetFileState(): void {
    const prev = this.previewUrl();
    if (prev?.startsWith('blob:')) URL.revokeObjectURL(prev);
    this.selectedFile.set(null);
    this.previewUrl.set(null);
    this.existingImageUrl.set(null);
  }

  protected cancelForm(): void {
    this._resetFileState();
    this.showForm.set(false);
    this.editId.set(null);
  }

  protected openBannerForm(banner?: Banner): void {
    this.formType.set('banner');
    this.editId.set(banner?.id ?? null);
    this.existingImageUrl.set(banner?.imageUrl ?? null);
    this._resetFileState();
    
    this.bannerForm.reset(banner
      ? { 
          title: banner.title, 
          imageUrl: banner.imageUrl ?? '', 
          linkUrl: banner.linkUrl ?? '', 
          displayOrder: banner.displayOrder,
          startsAt: banner.startsAt ? banner.startsAt.substring(0, 10) : null,
          endsAt: banner.endsAt ? banner.endsAt.substring(0, 10) : null
        }
      : { displayOrder: 1, imageUrl: '', startsAt: null, endsAt: null });
    this.showForm.set(true);
  }

  protected savePage(): void {
    if (this.pageForm.invalid) { this.pageForm.markAllAsTouched(); return; }
    const body = this.pageForm.getRawValue();
    const req = this.editId() ? this._http.put(`${this._base}/pages/${this.editId()}`, body) : this._http.post(`${this._base}/pages`, body);
    req.subscribe({ next: () => { this.showForm.set(false); this._load(); this.message.set('Page saved.'); setTimeout(() => this.message.set(''), 3000); }, error: () => this.message.set('Save failed.') });
  }

  protected saveBanner(): void {
    if (this.bannerForm.invalid) { this.bannerForm.markAllAsTouched(); return; }
    
    const file = this.selectedFile();
    if (file) {
      this._uploadThenSaveBanner(file);
    } else {
      this._doSaveBanner(this.existingImageUrl());
    }
  }

  private _uploadThenSaveBanner(file: File): void {
    this.uploading.set(true);
    this.saving.set(true);
    const fd = new FormData();
    fd.append('file', file);
    this._http.post<{ path: string }>(`${environment.apiUrl}/admin/images/upload?folder=banners`, fd).subscribe({
      next: res => { this.uploading.set(false); this._doSaveBanner(res.path); },
      error: () => {
        this.uploading.set(false);
        this.saving.set(false);
        this.message.set('Image upload failed.');
        setTimeout(() => this.message.set(''), 3000);
      }
    });
  }

  private _doSaveBanner(imageUrl: string | null): void {
    this.saving.set(true);
    const body = { ...this.bannerForm.getRawValue(), imageUrl };
    const req = this.editId() ? this._http.put(`${this._base}/banners/${this.editId()}`, body) : this._http.post(`${this._base}/banners`, body);
    req.subscribe({
      next: () => {
        this._resetFileState();
        this.showForm.set(false);
        this._load();
        this.message.set('Banner saved.');
        setTimeout(() => this.message.set(''), 3000);
        this.saving.set(false);
      },
      error: () => {
        this.message.set('Save failed.');
        setTimeout(() => this.message.set(''), 3000);
        this.saving.set(false);
      }
    });
  }

  protected publishPage(id: number): void {
    this._http.patch(`${this._base}/pages/${id}/publish`, {}).subscribe({ next: () => this._load(), error: () => this.message.set('Action failed.') });
  }

  protected toggleBanner(id: number): void {
    this._http.patch(`${this._base}/banners/${id}/toggle`, {}).subscribe({ next: () => this._load(), error: () => this.message.set('Action failed.') });
  }
}
