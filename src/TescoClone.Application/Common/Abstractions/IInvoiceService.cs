using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Common.Abstractions;

public interface IInvoiceService
{
    Task<string> GenerateInvoicePdfAsync(OrderDto order, string outputPath);
}
