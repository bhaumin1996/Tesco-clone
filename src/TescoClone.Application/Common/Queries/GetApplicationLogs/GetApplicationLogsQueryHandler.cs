using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Common.Queries.GetApplicationLogs;

public sealed class GetApplicationLogsQueryHandler : IRequestHandler<GetApplicationLogsQuery, PaginatedResult<ApplicationLogDto>>
{
    private readonly IApplicationLogRepository _applicationLogRepository;

    public GetApplicationLogsQueryHandler(IApplicationLogRepository applicationLogRepository)
    {
        _applicationLogRepository = applicationLogRepository;
    }

    public Task<PaginatedResult<ApplicationLogDto>> Handle(GetApplicationLogsQuery request, CancellationToken cancellationToken) =>
        _applicationLogRepository.GetApplicationLogsAsync(
            request.Level, request.Source, request.CorrelationId,
            request.From, request.To, request.PageNumber, request.PageSize, cancellationToken);
}
