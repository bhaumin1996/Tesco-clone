export interface Order {
  id: number;
  orderNumber: string;
  status: OrderStatus;
  createdAt: string;
  deliveryDate?: string;
  deliverySlot?: string;
  deliveryAddress?: string;
  items: OrderItem[];
  subtotal: number;
  deliveryCharge: number;
  promotionSavings?: number;
  clubcardSavings: number;
  total: number;
  invoiceUrl?: string;
}

export type OrderStatus = 'Placed' | 'Confirmed' | 'Picking' | 'Packed' | 'OutForDelivery' | 'Delivered' | 'Cancelled';

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  imageUrl?: string;
  price: number;
  quantity: number;
  lineTotal: number;
  isMarketplace?: boolean;
  sellerId?: number;
  sellerName?: string;
  trackingNumber?: string;
  carrierName?: string;
  sellerOrderStatus?: string;
}

export interface PlaceOrderRequest {
  deliverySlotId?: number;
  deliveryAddress: string;
  deliveryCharge: number;
  acceptSubstitutions: boolean;
  ageConfirmed: boolean;
  paymentMethodId: string;
  saveCard?: boolean;
}
