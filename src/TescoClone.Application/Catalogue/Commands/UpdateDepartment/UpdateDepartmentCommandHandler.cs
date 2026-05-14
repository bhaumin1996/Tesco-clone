using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.UpdateDepartment;

public sealed class UpdateDepartmentCommandHandler : IRequestHandler<UpdateDepartmentCommand>
{
    private readonly IAdminCatalogueRepository _adminCatalogueRepository;

    public UpdateDepartmentCommandHandler(IAdminCatalogueRepository adminCatalogueRepository)
    {
        _adminCatalogueRepository = adminCatalogueRepository;
    }

    public async Task Handle(UpdateDepartmentCommand request, CancellationToken cancellationToken)
    {
        await _adminCatalogueRepository.UpdateDepartmentAsync(
            request.DepartmentId,
            request.Name,
            request.AdminUserId,
            cancellationToken);
    }
}
