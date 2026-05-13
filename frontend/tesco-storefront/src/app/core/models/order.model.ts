export interface Order {
  id: number;
  orderNumber: string;
  status: OrderStatus;
  createdAt: string;
  deliveryDate?: string;
  deliverySlot?: string;
  address: DeliveryAddress;
  items: OrderItem[];
  subtotal: number;
  deliveryCharge: number;
  promotionSavings: number;
  clubcardSavings: number;
  total: number;
}

export type OrderStatus = 'Pending' | 'Confirmed' | 'Picking' | 'Packed' | 'OutForDelivery' | 'Delivered' | 'Cancelled';

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  imageUrl?: string;
  price: number;
  quantity: number;
  lineTotal: number;
}

export interface DeliveryAddress {
  firstName: string;
  lastName: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  postcode: string;
}

export interface PlaceOrderRequest {
  slotId?: number;
  addressId: number;
  paymentMethodId?: string;
  voucherCode?: string;
  specialInstructions?: string;
  acceptSubstitutions: boolean;
  ageConfirmed: boolean;
}
