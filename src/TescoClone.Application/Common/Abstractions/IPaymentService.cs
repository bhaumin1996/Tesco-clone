namespace TescoClone.Application.Common.Abstractions;

public interface IPaymentService
{
    Task<(bool Success, string TransactionId, string ErrorMessage)> ProcessPaymentAsync(decimal amount, string currency, string paymentMethodId, string description, string? customerId = null, string? setupFutureUsage = null);
    Task<string> CreateCustomerAsync(string email, string name);
    Task<(string Brand, string Last4, int ExpMonth, int ExpYear)> GetPaymentMethodDetailsAsync(string paymentMethodId);
    Task AttachPaymentMethodToCustomerAsync(string paymentMethodId, string customerId);
}
