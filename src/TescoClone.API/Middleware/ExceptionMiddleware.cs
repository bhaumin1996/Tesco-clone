using System.Net;
using System.Text.Json;
using TescoClone.Application.Common.Exceptions;
using TescoClone.Domain.Common;

namespace TescoClone.API.Middleware;

public sealed class ExceptionMiddleware
{
    private static readonly JsonSerializerOptions JsonOptions =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var correlationId = context.Items["CorrelationId"]?.ToString() ?? Guid.NewGuid().ToString();

        var (statusCode, code, message, details) = exception switch
        {
            ValidationException ve => (
                (int)HttpStatusCode.UnprocessableEntity,
                "VALIDATION_ERROR",
                "One or more validation errors occurred.",
                ve.Errors.SelectMany(e => e.Value.Select(m => new { field = e.Key, message = m })).ToArray<object>()),

            NotFoundException nfe => (
                (int)HttpStatusCode.NotFound,
                "NOT_FOUND",
                nfe.Message,
                Array.Empty<object>()),

            ConflictException ce => (
                (int)HttpStatusCode.Conflict,
                "CONFLICT",
                ce.Message,
                Array.Empty<object>()),

            ForbiddenException fe => (
                (int)HttpStatusCode.Forbidden,
                "FORBIDDEN",
                fe.Message,
                Array.Empty<object>()),

            _ => (
                (int)HttpStatusCode.InternalServerError,
                "INTERNAL_ERROR",
                "An unexpected error occurred.",
                Array.Empty<object>())
        };

        if (statusCode >= 500)
            _logger.LogError(exception, "Unhandled exception. CorrelationId: {CorrelationId}", correlationId);
        else
            _logger.LogWarning(exception, "Handled exception {Code}. CorrelationId: {CorrelationId}", code, correlationId);

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        var response = new
        {
            success = false,
            error = new { code, message, details, correlationId }
        };

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, JsonOptions));
    }
}
