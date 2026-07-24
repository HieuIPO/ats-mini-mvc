using System;
using System.Security.Cryptography;
using System.Text;

namespace ATSMiniProject.Helpers
{
    public static class PasswordHashHelper
    {
        private const int Pbkdf2Iterations = 100000;
        private const int Pbkdf2KeySize = 32;
        private const string Pbkdf2Prefix = "PBKDF2-SHA256";

        public static string ComputeSha256Hex(string salt, string password)
        {
            var input = (salt ?? string.Empty) + (password ?? string.Empty);

            using (var sha256 = SHA256.Create())
            {
                var bytes = Encoding.Unicode.GetBytes(input);
                var hash = sha256.ComputeHash(bytes);
                return BitConverter.ToString(hash).Replace("-", string.Empty);
            }
        }

        public static string GenerateSalt()
        {
            var bytes = new byte[32];

            using (var random = RandomNumberGenerator.Create())
            {
                random.GetBytes(bytes);
            }

            return Convert.ToBase64String(bytes);
        }

        public static string HashPassword(string salt, string password)
        {
            var saltBytes = Convert.FromBase64String(salt);

            using (var deriveBytes = new Rfc2898DeriveBytes(
                password ?? string.Empty,
                saltBytes,
                Pbkdf2Iterations,
                HashAlgorithmName.SHA256))
            {
                var hash = Convert.ToBase64String(deriveBytes.GetBytes(Pbkdf2KeySize));
                return Pbkdf2Prefix + "$" + Pbkdf2Iterations + "$" + hash;
            }
        }

        public static bool VerifyPassword(string salt, string password, string expectedHash)
        {
            if (!string.IsNullOrWhiteSpace(expectedHash) &&
                expectedHash.StartsWith(Pbkdf2Prefix + "$", StringComparison.Ordinal))
            {
                string actualHash;

                try
                {
                    actualHash = HashPassword(salt, password);
                }
                catch (FormatException)
                {
                    return false;
                }

                return FixedTimeEquals(actualHash, expectedHash);
            }

            // Backward compatibility for the SQL seed accounts.
            return VerifySha256Hex(salt, password, expectedHash);
        }

        public static bool NeedsRehash(string passwordHash)
        {
            return string.IsNullOrWhiteSpace(passwordHash) ||
                   !passwordHash.StartsWith(Pbkdf2Prefix + "$", StringComparison.Ordinal);
        }

        public static bool VerifySha256Hex(string salt, string password, string expectedHash)
        {
            var actualHash = ComputeSha256Hex(salt, password);
            return FixedTimeEquals(actualHash, expectedHash);
        }

        private static bool FixedTimeEquals(string left, string right)
        {
            if (left == null || right == null)
            {
                return false;
            }

            var leftBytes = Encoding.UTF8.GetBytes(left);
            var rightBytes = Encoding.UTF8.GetBytes(right);
            var maxLength = Math.Max(leftBytes.Length, rightBytes.Length);
            var diff = leftBytes.Length ^ rightBytes.Length;

            for (var i = 0; i < maxLength; i++)
            {
                var leftByte = i < leftBytes.Length ? leftBytes[i] : (byte)0;
                var rightByte = i < rightBytes.Length ? rightBytes[i] : (byte)0;
                diff |= leftByte ^ rightByte;
            }

            return diff == 0;
        }
    }
}
