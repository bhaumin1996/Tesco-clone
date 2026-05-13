export interface RegisterRequest {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  phoneNumber?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthToken {
  accessToken: string;
  expiresAt: string;
  refreshToken: string;
}

export interface UserProfile {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber?: string | null;
  roles: string[];
}

export interface AuthResponse {
  user: UserProfile;
  token: AuthToken;
}
