using MediatR;

namespace TescoClone.Application.Catalogue.Commands.DeleteProduct;

public sealed record DeleteProductCommand(int ProductId, int AdminUserId) : IRequest;
