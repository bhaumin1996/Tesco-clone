using System.Text;
using MediatR;
using TescoClone.Application.Analytics.Interfaces;

namespace TescoClone.Application.Analytics.Queries.GetAnalyticsExport;

public sealed class GetAnalyticsExportQueryHandler : IRequestHandler<GetAnalyticsExportQuery, byte[]>
{
    private readonly IAnalyticsRepository _repository;

    public GetAnalyticsExportQueryHandler(IAnalyticsRepository repository)
    {
        _repository = repository;
    }

    public async Task<byte[]> Handle(GetAnalyticsExportQuery request, CancellationToken cancellationToken)
    {
        var sales = await _repository.GetSalesAnalyticsAsync(request.From, request.To, cancellationToken);
        var topProducts = await _repository.GetTopProductsAsync(request.From, request.To, 100, cancellationToken);

        var csv = new StringBuilder();

        // Section 1: Sales Summary
        csv.AppendLine("Sales Summary");
        csv.AppendLine($"From,{sales.FromDate:yyyy-MM-dd}");
        csv.AppendLine($"To,{sales.ToDate:yyyy-MM-dd}");
        csv.AppendLine($"Total Revenue,{sales.TotalRevenue:F2}");
        csv.AppendLine($"Total Orders,{sales.TotalOrders}");
        csv.AppendLine($"Average Order Value,{sales.AverageOrderValue:F2}");
        csv.AppendLine($"New Customers,{sales.NewCustomers}");
        csv.AppendLine($"Returning Customers,{sales.ReturningCustomers}");
        csv.AppendLine();

        // Section 2: Daily Sales Breakdown
        csv.AppendLine("Daily Sales Breakdown");
        csv.AppendLine("Date,Orders,Revenue");
        foreach (var day in sales.DailySales)
        {
            csv.AppendLine($"{day.Date:yyyy-MM-dd},{day.Orders},{day.Revenue:F2}");
        }
        csv.AppendLine();

        // Section 3: Top Products
        csv.AppendLine("Top Products (Top 100)");
        csv.AppendLine("Product Name,Units Sold,Total Revenue");
        foreach (var product in topProducts)
        {
            // Escape commas in product names
            var productName = product.ProductName.Contains(",") 
                ? $"\"{product.ProductName}\"" 
                : product.ProductName;
            csv.AppendLine($"{productName},{product.TotalUnitsSold},{product.TotalRevenue:F2}");
        }

        return Encoding.UTF8.GetBytes(csv.ToString());
    }
}
