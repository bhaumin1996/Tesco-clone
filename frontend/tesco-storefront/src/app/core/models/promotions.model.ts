export interface Promotion {
  id: number;
  name: string;
  typeName: string;
  discountValue?: number;
  discountPercent?: number;
  minQuantity?: number;
  startsAt?: string;
  endsAt?: string;
  isActive: boolean;
  requiresClubcard: boolean;
}

export interface PromotionsPagedResult {
  items: Promotion[];
  pageNumber: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}
