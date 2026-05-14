using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.CreateDepartment;

public sealed class CreateDepartmentCommandHandler : IRequestHandler<CreateDepartmentCommand, int>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public CreateDepartmentCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public Task<int> Handle(CreateDepartmentCommand request, CancellationToken cancellationToken) =>
        _adminCatalogueRepository.CreateDepartmentAsync(request.Name, request.AdminUserId, cancellationToken);
}
