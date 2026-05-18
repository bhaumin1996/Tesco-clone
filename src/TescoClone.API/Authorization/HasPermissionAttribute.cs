using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;

namespace TescoClone.API.Authorization;

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = true)]
public class HasPermissionAttribute : Attribute, IAsyncActionFilter
{
    private readonly string _moduleName;
    private readonly string _action; // View, Add, Edit, Delete

    public HasPermissionAttribute(string moduleName, string action)
    {
        _moduleName = moduleName;
        _action = action;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var httpContext = context.HttpContext;
        var currentUser = httpContext.RequestServices.GetRequiredService<ICurrentUser>();
        
        // If not logged in, return unauthorized
        if (!currentUser.IsAuthenticated || currentUser.UserId == 0)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        // 1. SuperAdmin bypass: always has all rights!
        if (currentUser.Roles.Contains("SuperAdmin", StringComparer.OrdinalIgnoreCase))
        {
            await next();
            return;
        }

        // Get user repository to check permissions
        var userRepo = httpContext.RequestServices.GetRequiredService<IAdminUserRepository>();
        var permissions = await userRepo.GetUserPermissionsAsync(currentUser.UserId);
        var permission = permissions.FirstOrDefault(p => string.Equals(p.ModuleName, _moduleName, StringComparison.OrdinalIgnoreCase));

        if (permission == null)
        {
            context.Result = new ForbidResult();
            return;
        }

        var isAuthorized = _action.ToLowerInvariant() switch
        {
            "view" => permission.CanView,
            "add" => permission.CanAdd,
            "edit" => permission.CanEdit,
            "delete" => permission.CanDelete,
            _ => false
        };

        if (!isAuthorized)
        {
            context.Result = new ForbidResult();
            return;
        }

        await next();
    }
}
