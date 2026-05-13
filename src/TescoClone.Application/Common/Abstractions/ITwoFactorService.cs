namespace TescoClone.Application.Common.Abstractions;

public interface ITwoFactorService
{
    string GenerateCode();
    bool ValidateCode(string code, string storedHash);
    string HashCode(string code);
    DateTime GetCodeExpiry();
}
