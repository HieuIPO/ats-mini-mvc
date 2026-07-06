using System;
using System.Security.Cryptography;
using System.Text;

namespace ATSMiniProject.Helpers
{
    public static class PasswordHashHelper
    {
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

            var leftBytes = Encoding.UTF8.GetBytes(left.ToUpperInvariant());
            var rightBytes = Encoding.UTF8.GetBytes(right.ToUpperInvariant());
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
