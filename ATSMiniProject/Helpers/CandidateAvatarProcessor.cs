using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Web;

namespace ATSMiniProject.Helpers
{
    public static class CandidateAvatarProcessor
    {
        public const int MaxFileSize = 3 * 1024 * 1024;
        private const int OutputSize = 512;

        public static string ValidateAndSave(HttpPostedFileBase file, string destinationPath)
        {
            if (file == null || file.ContentLength <= 0)
            {
                return "Vui lòng chọn ảnh đại diện.";
            }

            if (file.ContentLength > MaxFileSize)
            {
                return "Ảnh đại diện không được vượt quá 3 MB.";
            }

            var extension = Path.GetExtension(file.FileName ?? string.Empty).ToLowerInvariant();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
            {
                return "Chỉ chấp nhận ảnh JPG hoặc PNG.";
            }

            try
            {
                using (var source = Image.FromStream(file.InputStream, true, true))
                {
                    if (source.RawFormat.Guid != ImageFormat.Jpeg.Guid &&
                        source.RawFormat.Guid != ImageFormat.Png.Guid)
                    {
                        return "Nội dung tệp không phải ảnh JPG hoặc PNG hợp lệ.";
                    }

                    if (source.Width < 128 || source.Height < 128)
                    {
                        return "Ảnh đại diện phải có kích thước tối thiểu 128 x 128 pixel.";
                    }

                    if (source.Width > 8000 || source.Height > 8000 ||
                        (long)source.Width * source.Height > 40000000L)
                    {
                        return "Kích thước ảnh quá lớn để xử lý an toàn.";
                    }

                    var cropSize = Math.Min(source.Width, source.Height);
                    var sourceX = (source.Width - cropSize) / 2;
                    var sourceY = (source.Height - cropSize) / 2;

                    using (var output = new Bitmap(OutputSize, OutputSize, PixelFormat.Format24bppRgb))
                    using (var graphics = Graphics.FromImage(output))
                    {
                        graphics.Clear(Color.White);
                        graphics.CompositingQuality = CompositingQuality.HighQuality;
                        graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        graphics.SmoothingMode = SmoothingMode.HighQuality;
                        graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
                        graphics.DrawImage(
                            source,
                            new Rectangle(0, 0, OutputSize, OutputSize),
                            new Rectangle(sourceX, sourceY, cropSize, cropSize),
                            GraphicsUnit.Pixel);

                        var directory = Path.GetDirectoryName(destinationPath);
                        if (string.IsNullOrWhiteSpace(directory))
                        {
                            return "Đường dẫn lưu ảnh đại diện không hợp lệ.";
                        }

                        Directory.CreateDirectory(directory);
                        var temporaryPath = destinationPath + "." + Guid.NewGuid().ToString("N") + ".tmp";
                        try
                        {
                            SaveJpeg(output, temporaryPath);
                            if (File.Exists(destinationPath))
                            {
                                File.Replace(temporaryPath, destinationPath, null);
                            }
                            else
                            {
                                File.Move(temporaryPath, destinationPath);
                            }
                        }
                        finally
                        {
                            if (File.Exists(temporaryPath))
                            {
                                File.Delete(temporaryPath);
                            }
                        }
                    }
                }
            }
            catch (Exception exception) when (
                exception is ArgumentException ||
                exception is ExternalException ||
                exception is IOException ||
                exception is OutOfMemoryException ||
                exception is UnauthorizedAccessException)
            {
                return "Không thể đọc ảnh. Vui lòng chọn một tệp JPG hoặc PNG khác.";
            }

            return null;
        }

        private static void SaveJpeg(Image image, string path)
        {
            var encoder = ImageCodecInfo.GetImageEncoders()
                .First(codec => codec.MimeType == "image/jpeg");
            using (var parameters = new EncoderParameters(1))
            {
                parameters.Param[0] = new EncoderParameter(Encoder.Quality, 88L);
                image.Save(path, encoder, parameters);
            }
        }
    }
}
