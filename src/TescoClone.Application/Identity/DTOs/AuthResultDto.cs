namespace TescoClone.Application.Identity.DTOs;

public sealed record AuthResultDto(UserDto User, TokenDto Token);
