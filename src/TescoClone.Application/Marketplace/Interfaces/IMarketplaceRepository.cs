using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;

namespace TescoClone.Application.Marketplace.Interfaces;

public interface IMarketplaceRepository
{
    // Seller management (admin)
    Task<PaginatedResult<SellerDto>> GetSellersAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<SellerDto?> GetSellerByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<SellerDto?> GetSellerByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task ApproveSellerAsync(int sellerId, int adminId, CancellationToken cancellationToken = default);
    Task SuspendSellerAsync(int sellerId, string reason, int adminId, CancellationToken cancellationToken = default);

    // Dispute management (admin)
    Task<PaginatedResult<DisputeDto>> GetDisputesAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task ResolveDisputeAsync(int disputeId, string resolution, int adminId, CancellationToken cancellationToken = default);

    // Listing management (seller)
    Task<PaginatedResult<ListingDto>> GetSellerListingsAsync(int sellerId, string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<ListingDto?> GetListingByIdAsync(int listingId, int? sellerId, CancellationToken cancellationToken = default);
    Task<int> CreateListingAsync(int sellerId, CreateListingDto dto, int createdBy, CancellationToken cancellationToken = default);
    Task UpdateListingAsync(int listingId, int sellerId, UpdateListingDto dto, int modifiedBy, CancellationToken cancellationToken = default);
    Task PublishListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default);
    Task UnpublishListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default);
    Task SoftDeleteListingAsync(int listingId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default);

    // Commission engine
    Task<RecordCommissionResultDto> RecordCommissionAsync(int sellerId, int orderLineId, decimal saleAmount, int? categoryId, int createdBy, CancellationToken cancellationToken = default);
    Task<CommissionSummaryDto?> GetSellerCommissionSummaryAsync(int sellerId, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CommissionTierDto>> GetCommissionTiersAsync(CancellationToken cancellationToken = default);

    // Seller onboarding
    Task<int> ApplyAsSellerAsync(int userId, ApplyAsSellerDto dto, CancellationToken cancellationToken = default);
    Task SubmitApplicationAsync(int applicationId, int userId, CancellationToken cancellationToken = default);
    Task<SellerApplicationDto?> GetApplicationByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<PaginatedResult<SellerApplicationListDto>> GetSellerApplicationsAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<string?> CheckSellerUniqueAsync(string businessName, string email, string phone, string? website, CancellationToken cancellationToken = default);
    Task ReviewApplicationAsync(int applicationId, string decision, string? reviewNotes, int adminId, CancellationToken cancellationToken = default);

    // Seller order fulfillment
    Task CreateSellerOrdersForOrderAsync(int orderId, int createdBy, CancellationToken cancellationToken = default);
    Task<PaginatedResult<SellerOrderSummaryDto>> GetSellerOrdersAsync(int sellerId, string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<SellerOrderDto?> GetSellerOrderByIdAsync(int sellerOrderId, int sellerId, CancellationToken cancellationToken = default);
    Task ConfirmSellerOrderAsync(int sellerOrderId, int sellerId, int modifiedBy, CancellationToken cancellationToken = default);
    Task DispatchSellerOrderAsync(int sellerOrderId, int sellerId, string carrierName, string trackingNumber, int modifiedBy, CancellationToken cancellationToken = default);

    // ASN
    Task<int> CreateAsnAsync(int sellerId, CreateAsnDto dto, int createdBy, CancellationToken cancellationToken = default);
    Task<PaginatedResult<SellerAsnDto>> GetSellerAsnsAsync(int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);

    // Returns
    Task<int> RaiseReturnAsync(int orderLineId, int userId, string returnReason, int createdBy, CancellationToken cancellationToken = default);
    Task RespondToReturnAsync(int returnId, int sellerId, bool accept, string sellerResponse, int modifiedBy, CancellationToken cancellationToken = default);
    Task<PaginatedResult<MarketplaceReturnDto>> GetMarketplaceReturnsAsync(string? statusFilter, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task ResolveMarketplaceReturnAsync(int returnId, string resolution, decimal? refundAmount, int adminId, CancellationToken cancellationToken = default);

    // Payouts
    Task<RunPayoutResultDto> RunSellerPayoutAsync(int sellerId, DateOnly periodStart, DateOnly periodEnd, int adminId, CancellationToken cancellationToken = default);
    Task<PaginatedResult<SellerPayoutDto>> GetSellerPayoutsAsync(int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);

    // Messaging
    Task<int> CreateMessageThreadAsync(int sellerId, string subject, string body, int createdBy, CancellationToken cancellationToken = default);
    Task<int> SendMessageAsync(int threadId, int senderUserId, string body, int createdBy, CancellationToken cancellationToken = default);
    Task<PaginatedResult<MessageThreadSummaryDto>> GetMessageThreadsAsync(int sellerId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<MessageDto>> GetMessagesByThreadAsync(int threadId, int sellerId, CancellationToken cancellationToken = default);

    // Delivery options
    Task<IReadOnlyList<SellerDeliveryOptionDto>> GetSellerDeliveryOptionsAsync(int sellerId, CancellationToken cancellationToken = default);
    Task UpsertDeliveryOptionAsync(int sellerId, UpsertDeliveryOptionDto dto, int userId, CancellationToken cancellationToken = default);

    // Performance
    Task<SellerPerformanceDto?> GetLatestPerformanceAsync(int sellerId, CancellationToken cancellationToken = default);
}
