using System;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace ATSMiniProject.Helpers
{
    public static class SalaryRangePolicy
    {
        private static readonly CultureInfo VietnameseCulture = new CultureInfo("vi-VN");

        public static bool TryNormalize(string input, out string normalized, out string errorMessage)
        {
            normalized = null;
            errorMessage = null;

            if (string.IsNullOrWhiteSpace(input))
            {
                return true;
            }

            var value = input.Trim();
            if (value.Length > 100 || value.IndexOf('<') >= 0 || value.IndexOf('>') >= 0)
            {
                errorMessage = "Mức lương không được chứa mã HTML.";
                return false;
            }

            if (IsNegotiable(value))
            {
                return true;
            }

            value = value.Replace('–', '-').Replace('—', '-');
            value = Regex.Replace(value, @"^\s*(hỗ\s*trợ|ho\s*tro)\s+", string.Empty, RegexOptions.IgnoreCase);

            var usesMillions = Regex.IsMatch(value, @"\s*(triệu|trieu|tr)\s*$", RegexOptions.IgnoreCase);
            value = Regex.Replace(value, @"\s*(triệu|trieu|tr|vnđ|vnd|đ|dong)\s*$", string.Empty, RegexOptions.IgnoreCase);

            var parts = value.Split(new[] { '-' }, StringSplitOptions.None);
            if (parts.Length < 1 || parts.Length > 2)
            {
                errorMessage = BuildFormatError();
                return false;
            }

            var amounts = new long[parts.Length];
            for (var index = 0; index < parts.Length; index++)
            {
                if (!TryParsePositiveAmount(parts[index], usesMillions, out amounts[index]))
                {
                    errorMessage = BuildFormatError();
                    return false;
                }
            }

            if (amounts.Length == 2 && amounts[0] > amounts[1])
            {
                errorMessage = "Mức lương từ không được lớn hơn mức lương đến.";
                return false;
            }

            normalized = string.Join(
                " - ",
                amounts.Select(amount => amount.ToString("N0", VietnameseCulture))) + " VNĐ";
            return true;
        }

        private static bool TryParsePositiveAmount(string input, bool usesMillions, out long amount)
        {
            amount = 0;
            var digits = Regex.Replace((input ?? string.Empty).Trim(), @"[\s\.,]", string.Empty);
            long parsed;
            if (!Regex.IsMatch(digits, @"^\d+$") || !long.TryParse(digits, out parsed) || parsed <= 0)
            {
                return false;
            }

            if (usesMillions)
            {
                try
                {
                    parsed = checked(parsed * 1000000L);
                }
                catch (OverflowException)
                {
                    return false;
                }
            }

            amount = parsed;
            return true;
        }

        private static bool IsNegotiable(string value)
        {
            return string.Equals(value, "Thỏa thuận", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(value, "Thoả thuận", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(value, "Thoa thuan", StringComparison.OrdinalIgnoreCase);
        }

        private static string BuildFormatError()
        {
            return "Mức lương phải lớn hơn 0 và chỉ nhập một mức hoặc một khoảng, ví dụ 12000000 hoặc 12000000 - 18000000.";
        }
    }
}
