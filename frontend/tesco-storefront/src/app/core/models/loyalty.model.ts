export interface ClubcardBalance {
  points: number;
  voucherValue: number;
  pointsExpiry?: string;
}

export interface PointsTransaction {
  id: number;
  date: string;
  description: string;
  points: number;
  type: 'Earn' | 'Redeem';
}

export interface Voucher {
  id: number;
  code: string;
  value: number;
  expiryDate: string;
  isUsed: boolean;
  description?: string;
}

export interface RedeemPointsRequest {
  points: number;
}

export interface RedeemVoucherRequest {
  voucherCode: string;
}
