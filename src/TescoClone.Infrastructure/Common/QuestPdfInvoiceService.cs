using System.Globalization;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Infrastructure.Common;

public sealed class QuestPdfInvoiceService : IInvoiceService
{
    private const string TescoBlue = "#00539F";
    private const string TescoRed = "#EE1C2E";

    public QuestPdfInvoiceService()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public async Task<string> GenerateInvoicePdfAsync(OrderDto order, string outputPath)
    {
        var directory = Path.GetDirectoryName(outputPath);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }

        Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(1, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(10).FontFamily(Fonts.Arial));

                ComposeHeader(page, order);
                ComposeContent(page, order);
                ComposeFooter(page);
            });
        }).GeneratePdf(outputPath);

        return await Task.FromResult(outputPath);
    }

    private void ComposeHeader(PageDescriptor page, OrderDto order)
    {
        page.Header().Row(row =>
        {
            row.RelativeItem().Column(col =>
            {
                col.Item().Text("TESCO CLONE").FontSize(24).ExtraBold().FontColor(TescoBlue);
                col.Item().Text("Every little helps").FontSize(9).Italic().FontColor(Colors.Grey.Medium);
            });

            row.RelativeItem().Column(col =>
            {
                col.Item().AlignRight().Text("INVOICE").FontSize(28).ExtraBold().FontColor(Colors.Grey.Lighten1);
                col.Item().AlignRight().Text(text =>
                {
                    text.Span("Invoice #: ").SemiBold();
                    text.Span(order.OrderNumber ?? order.Id.ToString());
                });
                col.Item().AlignRight().Text(text =>
                {
                    text.Span("Date: ").SemiBold();
                    text.Span(order.CreatedAt.ToString("dd MMM yyyy"));
                });
            });
        });
    }

    private void ComposeContent(PageDescriptor page, OrderDto order)
    {
        page.Content().PaddingVertical(20).Column(col =>
        {
            // Address Section
            col.Item().Row(row =>
            {
                row.RelativeItem().Column(c =>
                {
                    c.Item().BorderBottom(1).BorderColor(TescoBlue).PaddingBottom(5).Text("DELIVERY ADDRESS").SemiBold().FontColor(TescoBlue);
                    c.Item().PaddingTop(5).Column(addrCol => {
                        if (!string.IsNullOrEmpty(order.DeliveryAddress))
                        {
                            foreach (var line in order.DeliveryAddress.Split(", "))
                            {
                                addrCol.Item().Text(line);
                            }
                        }
                        addrCol.Item().Text(order.CustomerName ?? "Valued Customer").SemiBold();
                    });
                });
                row.ConstantItem(50);
                row.RelativeItem().Column(c => {
                    // Placeholder for other info like payment method if needed
                });
            });

            // Table Section
            col.Item().PaddingTop(30).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.ConstantColumn(25);
                    columns.RelativeColumn(3);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });

                table.Header(header =>
                {
                    header.Cell().Element(HeaderStyle).Text("#");
                    header.Cell().Element(HeaderStyle).Text("Product Description");
                    header.Cell().Element(HeaderStyle).AlignRight().Text("Qty");
                    header.Cell().Element(HeaderStyle).AlignRight().Text("Unit Price");
                    header.Cell().Element(HeaderStyle).AlignRight().Text("Total");

                    static IContainer HeaderStyle(IContainer container)
                    {
                        return container.DefaultTextStyle(x => x.SemiBold().FontColor(Colors.White))
                                        .PaddingVertical(5)
                                        .PaddingHorizontal(5)
                                        .Background(TescoBlue);
                    }
                });

                int i = 1;
                foreach (var item in order.Items)
                {
                    table.Cell().Element(CellStyle).Text(i++.ToString());
                    table.Cell().Element(CellStyle).Text(item.ProductName);
                    table.Cell().Element(CellStyle).AlignRight().Text(item.Quantity.ToString());
                    table.Cell().Element(CellStyle).AlignRight().Text(item.Price.ToString("C", CultureInfo.GetCultureInfo("en-GB")));
                    table.Cell().Element(CellStyle).AlignRight().Text(item.LineTotal.ToString("C", CultureInfo.GetCultureInfo("en-GB")));

                    static IContainer CellStyle(IContainer container)
                    {
                        return container.BorderBottom(1)
                                        .BorderColor(Colors.Grey.Lighten3)
                                        .PaddingVertical(8)
                                        .PaddingHorizontal(5);
                    }
                }
            });

            // Summary Section
            col.Item().AlignRight().PaddingTop(20).MinWidth(200).Column(c =>
            {
                c.Item().Row(row => {
                    row.RelativeItem().Text("Subtotal");
                    row.RelativeItem().AlignRight().Text(order.Subtotal.ToString("C", CultureInfo.GetCultureInfo("en-GB")));
                });
                
                if (order.ClubcardSavings > 0)
                {
                    c.Item().Row(row => {
                        row.RelativeItem().Text("Clubcard Savings").FontColor(TescoBlue).SemiBold();
                        row.RelativeItem().AlignRight().Text($"-{order.ClubcardSavings.ToString("C", CultureInfo.GetCultureInfo("en-GB"))}").FontColor(TescoBlue).SemiBold();
                    });
                }

                c.Item().Row(row => {
                    row.RelativeItem().Text("Delivery Charge");
                    row.RelativeItem().AlignRight().Text(order.DeliveryCharge == 0 ? "FREE" : order.DeliveryCharge.ToString("C", CultureInfo.GetCultureInfo("en-GB")));
                });

                c.Item().PaddingTop(5).BorderTop(1).BorderColor(Colors.Black).PaddingTop(5).Background(Colors.Grey.Lighten4).Padding(5).Row(row => {
                    row.RelativeItem().Text("TOTAL").FontSize(14).ExtraBold().FontColor(TescoBlue);
                    row.RelativeItem().AlignRight().Text(order.Total.ToString("C", CultureInfo.GetCultureInfo("en-GB"))).FontSize(14).ExtraBold().FontColor(TescoBlue);
                });
            });

            // Promotion Section
            col.Item().PaddingTop(40).AlignCenter().Column(c => {
                c.Item().Text("Thank you for shopping with Tesco Clone!").SemiBold();
                c.Item().Text("We hope to see you again soon.").FontSize(9).FontColor(Colors.Grey.Medium);
            });
        });
    }

    private void ComposeFooter(PageDescriptor page)
    {
        page.Footer().PaddingTop(20).Column(col => {
            col.Item().BorderTop(1).BorderColor(Colors.Grey.Lighten2).PaddingTop(5).Row(row => {
                row.RelativeItem().Text(x => {
                    x.Span("Page ");
                    x.CurrentPageNumber();
                    x.Span(" of ");
                    x.TotalPages();
                });
                row.RelativeItem().AlignRight().Text("© 2026 Tesco Clone Ltd.");
            });
        });
    }
}
