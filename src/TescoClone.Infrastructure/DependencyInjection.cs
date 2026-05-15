using Microsoft.Extensions.DependencyInjection;
using TescoClone.Application.Analytics.Interfaces;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Content.Interfaces;
using TescoClone.Application.Delivery.Interfaces;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Application.Loyalty.Interfaces;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Application.Promotions.Interfaces;
using TescoClone.Infrastructure.Analytics;
using TescoClone.Infrastructure.Catalogue;
using TescoClone.Infrastructure.Common;
using TescoClone.Infrastructure.Content;
using TescoClone.Infrastructure.Delivery;
using TescoClone.Infrastructure.Identity;
using TescoClone.Infrastructure.Loyalty;
using TescoClone.Infrastructure.Marketplace;
using TescoClone.Infrastructure.Order;
using TescoClone.Infrastructure.Promotions;

namespace TescoClone.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services)
    {
        services.AddSingleton<SqlConnectionFactory>();

        services.AddSingleton<IClock, SystemClock>();

        services.AddScoped<IPasswordService, PasswordService>();
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<ITwoFactorService, TwoFactorService>();

        // Identity
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IAdminUserRepository, AdminUserRepository>();

        // Catalogue
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        services.AddScoped<IDepartmentRepository, DepartmentRepository>();
        services.AddScoped<IBrandRepository, BrandRepository>();
        services.AddScoped<IAdminCatalogueRepository, AdminCatalogueRepository>();

        // Order
        services.AddScoped<ICartRepository, CartRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IAdminOrderRepository, AdminOrderRepository>();

        // Delivery
        services.AddScoped<IDeliveryRepository, DeliveryRepository>();

        // Loyalty
        services.AddScoped<ILoyaltyRepository, LoyaltyRepository>();
        services.AddScoped<IVoucherRepository, VoucherRepository>();

        // Promotions
        services.AddScoped<IPromotionRepository, PromotionRepository>();

        // Content
        services.AddScoped<IContentRepository, ContentRepository>();

        // Marketplace
        services.AddScoped<IMarketplaceRepository, MarketplaceRepository>();

        // Analytics
        services.AddScoped<IAnalyticsRepository, AnalyticsRepository>();

        // Audit and application log repositories
        services.AddScoped<IAuditLogRepository, AuditLogRepository>();
        services.AddScoped<IApplicationLogRepository, ApplicationLogRepository>();

        return services;
    }
}
