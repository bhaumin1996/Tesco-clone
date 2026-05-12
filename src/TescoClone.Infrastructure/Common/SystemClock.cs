using TescoClone.Application.Common.Abstractions;

namespace TescoClone.Infrastructure.Common;

public sealed class SystemClock : IClock
{
    public DateTime UtcNow => DateTime.UtcNow;
}
