export interface Address {
  id: number;
  userId: number;
  addressLine1: string;
  addressLine2?: string | null;
  townCity: string;
  postcode: string;
  isDefault: boolean;
}

export interface AddAddressRequest {
  addressLine1: string;
  addressLine2?: string | null;
  townCity: string;
  postcode: string;
  isDefault: boolean;
}

export interface UpdateAddressRequest extends AddAddressRequest {}
