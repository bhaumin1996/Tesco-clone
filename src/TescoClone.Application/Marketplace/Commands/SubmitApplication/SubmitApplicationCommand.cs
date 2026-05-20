using MediatR;

namespace TescoClone.Application.Marketplace.Commands.SubmitApplication;

public sealed record SubmitApplicationCommand(int ApplicationId, int UserId) : IRequest;
