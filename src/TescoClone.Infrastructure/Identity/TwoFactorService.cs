using System.Security.Cryptography;
using TescoClone.Application.Common.Abstractions;

namespace TescoClone.Infrastructure.Identity;

public sealed class TwoFactorService : ITwoFactorService
{
    private static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(10);

    public string GenerateCode()
    {
        var bytes = new byte[4];
        RandomNumberGenerator.Fill(bytes);
        var number = BitConverter.ToUInt32(bytes, 0) % 1_000_000;
        return number.ToString("D6");
    }

    public string HashCode(string code)
    {
        var bytes = System.Text.Encoding.UTF8.GetBytes(code);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    public bool ValidateCode(string code, string storedHash) =>
        HashCode(code) == storedHash;

    public DateTime GetCodeExpiry() =>
        DateTime.UtcNow.Add(CodeLifetime);
}
