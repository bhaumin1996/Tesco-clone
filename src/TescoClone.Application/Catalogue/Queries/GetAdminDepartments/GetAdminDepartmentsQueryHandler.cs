using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetAdminDepartments;

public sealed class GetAdminDepartmentsQueryHandler : IRequestHandler<GetAdminDepartmentsQuery, IReadOnlyList<AdminDepartmentDto>>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public GetAdminDepartmentsQueryHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<IReadOnlyList<AdminDepartmentDto>> Handle(GetAdminDepartmentsQuery request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.GetDepartmentsAsync(cancellationToken);
}
