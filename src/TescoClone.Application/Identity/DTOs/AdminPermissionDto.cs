namespace TescoClone.Application.Identity.DTOs;

public sealed record AdminPermissionDto(
    string ModuleName,
    bool CanView,
    bool CanAdd,
    bool CanEdit,
    bool CanDelete);
