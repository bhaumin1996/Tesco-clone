export interface SellerLoginRequest {
  email: string;
  password: string;
}

export interface SellerAuthResponse {
  user: {
    id: number;
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string | null;
    roles: string[];
  };
  token: {
    accessToken: string;
    expiresAt: string;
    refreshToken: string;
  };
}

export interface SellerUser {
  id: number;
  name: string;
  email: string;
  roles: string[];
  businessName?: string;
  sellerId?: number;
}

