namespace TescoClone.Application.Common.Abstractions;

public interface IPasswordService
{
    string Hash(string plaintext);
    bool Verify(string plaintext, string hash);
}
