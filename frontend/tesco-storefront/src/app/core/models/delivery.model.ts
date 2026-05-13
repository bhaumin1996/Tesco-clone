export interface DeliverySlot {
  id: number;
  date: string;
  startTime: string;
  endTime: string;
  charge: number;
  isAvailable: boolean;
  isFree?: boolean;
}

export interface SlotSearchRequest {
  postcode: string;
  fromDate: string;
  toDate: string;
}

export interface BookSlotRequest {
  slotId: number;
  addressId: number;
}

export interface Store {
  id: number;
  name: string;
  type: string;
  address: string;
  postcode: string;
  phone: string;
  openingHours: string;
  latitude: number;
  longitude: number;
  facilities: string[];
  isWhooshEnabled: boolean;
}
