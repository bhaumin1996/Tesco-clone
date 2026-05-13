using TescoClone.Application.Identity.DTOs;

namespace TescoClone.Application.Common.Abstractions;

public interface ITokenService
{
    TokenDto GenerateAccessToken(int userId, string email, IEnumerable<string> roles);
    string GenerateRefreshToken();
    string HashRefreshToken(string token);
}
