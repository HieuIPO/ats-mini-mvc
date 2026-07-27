using System;

namespace ATSMiniProject.Helpers
{
    public static class InternalAccountRolePolicy
    {
        public const string AdminRoleName = "Admin";
        public const string HrRoleName = "HR";

        public static bool IsAllowedRoleName(string roleName)
        {
            return string.Equals(roleName, AdminRoleName, StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(roleName, HrRoleName, StringComparison.OrdinalIgnoreCase);
        }
    }
}
