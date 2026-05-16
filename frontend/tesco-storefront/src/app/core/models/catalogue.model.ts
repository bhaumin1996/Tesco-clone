export interface Department {
  id: number;
  name: string;
  slug: string;
  imageUrl?: string;
  categoryCount: number;
}

export interface Brand {
  id: number;
  name: string;
  slug: string;
  logoUrl?: string;
}

export interface Banner {
  id: number;
  title: string;
  subTitle?: string;
  imageUrl?: string;
  linkUrl?: string;
  displayOrder: number;
}

export interface Category {
  id: number;
  departmentId: number;
  name: string;
  slug: string;
  imageUrl?: string;
}

export interface ProductSummary {
  id: number;
  name: string;
  brand?: string;
  price: number;
  clubcardPrice?: number;
  unitPrice?: string;
  imageUrl?: string;
  categoryName: string;
  promotionLabel?: string;
  averageRating: number;
  reviewCount: number;
  isInStock: boolean;
}

export interface ProductDetail extends ProductSummary {
  sku?: string;
  description?: string;
  ingredients?: string;
  nutritionalInfo?: NutritionalInfo;
  allergens?: string;
  storageInstructions?: string;
  weight?: string;
  countryOfOrigin?: string;
  dietaryTags?: string[];
  images?: string[];
  variants?: ProductVariant[];
}

export interface ProductVariant {
  id: number;
  sku: string;
  variantName?: string;
  priceModifier: number;
  stockQuantity: number;
  isInStock: boolean;
}

export interface NutritionalInfo {
  per100g: NutritionalValues;
  perServing?: NutritionalValues;
  servingSize?: string;
}

export interface NutritionalValues {
  calories: number;
  fat: number;
  saturatedFat: number;
  carbohydrates: number;
  sugars: number;
  fibre: number;
  protein: number;
  salt: number;
}

export interface SearchRequest {
  query: string;
  departmentId?: number;
  categoryId?: number;
  minPrice?: number;
  maxPrice?: number;
  brand?: string;
  dietaryTag?: string;
  clubcardOnly?: boolean;
  pageNumber: number;
  pageSize: number;
  sortBy?: string;
  sortDirection?: 'asc' | 'desc';
}

export interface PagedResult<T> {
  items: T[];
  pageNumber: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}
