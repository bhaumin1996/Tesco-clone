using TescoClone.Application.Common.Abstractions;
using TescoClone.Infrastructure.Common;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IClock, SystemClock>();
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseHttpsRedirection();

app.MapHealthChecks("/health");
app.MapGet("/api/v1/status", () => Results.Ok(new
{
    service = "TescoClone.API",
    status = "Ready"
}));

app.Run();

public partial class Program { }
