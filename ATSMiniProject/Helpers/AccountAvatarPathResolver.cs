using System;
using System.IO;
using System.Linq;

namespace ATSMiniProject.Helpers
{
    public static class AccountAvatarPathResolver
    {
        private static readonly string[] AllowedExtensions =
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".gif"
        };

        public static string FindLatestFileName(string folder, int userId)
        {
            if (string.IsNullOrWhiteSpace(folder) || !Directory.Exists(folder))
            {
                return null;
            }

            var searchPatterns = new[]
            {
                "avatar-" + userId + "-*",
                "candidate-" + userId + ".*"
            };

            return searchPatterns
                .SelectMany(pattern => Directory.EnumerateFiles(folder, pattern, SearchOption.TopDirectoryOnly))
                .Where(IsAllowedAvatarFile)
                .OrderByDescending(File.GetLastWriteTimeUtc)
                .Select(Path.GetFileName)
                .FirstOrDefault();
        }

        private static bool IsAllowedAvatarFile(string path)
        {
            var extension = Path.GetExtension(path);
            return AllowedExtensions.Contains(
                extension,
                StringComparer.OrdinalIgnoreCase);
        }
    }
}
