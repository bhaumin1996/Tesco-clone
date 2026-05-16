using Microsoft.Extensions.Configuration;
using Stripe;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.Infrastructure.Common;

public sealed class StripePaymentService : IPaymentService
{
    private readonly string _secretKey;

    public StripePaymentService(IConfiguration configuration)
    {
        _secretKey = configuration["Stripe:SecretKey"] ?? throw new ArgumentNullException("Stripe SecretKey is not configured.");
        StripeConfiguration.ApiKey = _secretKey;
    }

    public async Task<(bool Success, string TransactionId, string ErrorMessage)> ProcessPaymentAsync(
        decimal amount, 
        string currency, 
        string paymentMethodId, 
        string description, 
        string? customerId = null, 
        string? setupFutureUsage = null)
    {
        try
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100), // Stripe expects amounts in cents
                Currency = currency.ToLower(),
                PaymentMethod = paymentMethodId,
                Customer = customerId,
                Description = description,
                Confirm = true,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true,
                    AllowRedirects = "never"
                },
                OffSession = false,
                SetupFutureUsage = setupFutureUsage
            };

            var service = new PaymentIntentService();
            var intent = await service.CreateAsync(options);

            if (intent.Status == "succeeded")
            {
                return (true, intent.Id, string.Empty);
            }

            return (false, string.Empty, $"Payment failed with status: {intent.Status}");
        }
        catch (StripeException e)
        {
            return (false, string.Empty, e.Message);
        }
    }

    public async Task<string> CreateCustomerAsync(string email, string name)
    {
        var options = new CustomerCreateOptions
        {
            Email = email,
            Name = name,
        };
        var service = new CustomerService();
        var customer = await service.CreateAsync(options);
        return customer.Id;
    }

    public async Task<(string Brand, string Last4, int ExpMonth, int ExpYear)> GetPaymentMethodDetailsAsync(string paymentMethodId)
    {
        var service = new PaymentMethodService();
        var pm = await service.GetAsync(paymentMethodId);
        return (pm.Card.Brand, pm.Card.Last4, (int)pm.Card.ExpMonth, (int)pm.Card.ExpYear);
    }

    public async Task AttachPaymentMethodToCustomerAsync(string paymentMethodId, string customerId)
    {
        var options = new PaymentMethodAttachOptions
        {
            Customer = customerId,
        };
        var service = new PaymentMethodService();
        await service.AttachAsync(paymentMethodId, options);
    }
}
