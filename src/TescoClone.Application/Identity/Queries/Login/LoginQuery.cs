using MediatR;
using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Identity.Queries.Login;

public sealed record LoginQuery(string Email, string Password) : IRequest<AuthResultDto>;
