using System.Collections.Generic;
using System.Linq;

namespace ATSMiniProject.Helpers
{
    public static class NotificationRecipientPolicy
    {
        public static IReadOnlyList<int> Resolve(
            int? creatorUserId,
            bool creatorIsEligible,
            IEnumerable<int> activeAdminUserIds)
        {
            if (creatorIsEligible && creatorUserId.HasValue)
            {
                return new[] { creatorUserId.Value };
            }

            return (activeAdminUserIds ?? Enumerable.Empty<int>())
                .Distinct()
                .OrderBy(id => id)
                .ToList();
        }
    }
}
