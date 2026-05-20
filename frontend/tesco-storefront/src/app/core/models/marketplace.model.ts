export interface SellerProfile {
  id: number;
  businessName: string;
  contactEmail: string;
  statusName: string;
  description?: string;
  phone?: string;
  commissionRate?: number;
  approvedOn?: string;
}

export interface SellerPerformance {
  id: number;
  sellerId: number;
  scoreDate: string;
  onTimeDeliveryRate?: number;
  returnRate?: number;
  cancellationRate?: number;
  averageRating?: number;
  overallScore?: number;
  belowThreshold: boolean;
}

export interface SellerDeliveryOption {
  id: number;
  sellerId: number;
  deliveryType: string;
  price: number;
  freeThresholdAmount?: number;
  estimatedDaysMin: number;
  estimatedDaysMax: number;
  isActive: boolean;
}

export interface MarketplaceReturn {
  id: number;
  orderLineId: number;
  returnReason: string;
  sellerResponse?: string;
  resolution?: string;
  statusName: string;
  slaDeadline: string;
  resolvedOn?: string;
  refundAmount?: number;
  createdOn: string;
}

export interface MarketplaceCategory {
  id: number;
  name: string;
  slug: string;
  imageUrl?: string;
}

export interface FeaturedSeller {
  id: number;
  businessName: string;
  description?: string;
  listingCount: number;
  overallScore?: number;
}
