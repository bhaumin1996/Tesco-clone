export interface CartItem {
  id: number;
  productId: number;
  productName: string;
  imageUrl?: string;
  price: number;
  clubcardPrice?: number;
  quantity: number;
  unitPrice?: string;
  promotionLabel?: string;
  lineTotal: number;
  isMarketplace?: boolean;
  sellerId?: number;
  sellerName?: string;
  marketplaceDeliveryCharge?: number;
  marketplaceFreeDeliveryThreshold?: number;
}

export interface Cart {
  items: CartItem[];
  subtotal: number;
  clubcardSavings: number;
  promotionSavings: number;
  deliveryCharge: number;
  total: number;
  itemCount: number;
  hasAgeRestrictedItems: boolean;
  minimumOrderMet: boolean;
}

export interface AddToCartRequest {
  productId: number;
  quantity: number;
}

export interface UpdateCartItemRequest {
  itemId: number;
  quantity: number;
}
