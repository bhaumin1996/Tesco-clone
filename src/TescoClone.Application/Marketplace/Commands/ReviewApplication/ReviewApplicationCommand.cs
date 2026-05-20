using MediatR;

namespace TescoClone.Application.Marketplace.Commands.ReviewApplication;

public sealed record ReviewApplicationCommand(
    int ApplicationId,
    string Decision,
    string? ReviewNotes,
    int AdminId) : IRequest;
