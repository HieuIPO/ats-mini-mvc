using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Web;

namespace ATSMiniProject.Helpers
{
    public static class CandidateFileValidator
    {
        public const int MaxFileSizeBytes = 5 * 1024 * 1024;

        private static readonly HashSet<string> AllowedExtensions =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase) { ".pdf", ".doc", ".docx" };

        public static string Validate(HttpPostedFileBase file)
        {
            if (file == null || file.ContentLength <= 0)
            {
                return "Vui lòng chọn CV để tải lên.";
            }

            if (file.ContentLength > MaxFileSizeBytes)
            {
                return "CV không được vượt quá 5 MB.";
            }

            var extension = Path.GetExtension(Path.GetFileName(file.FileName));
            if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
            {
                return "CV chỉ chấp nhận định dạng PDF, DOC hoặc DOCX.";
            }

            if (!HasExpectedSignature(file.InputStream, extension))
            {
                return "Nội dung tệp không khớp với định dạng CV đã chọn.";
            }

            return null;
        }

        private static bool HasExpectedSignature(Stream stream, string extension)
        {
            if (stream == null || !stream.CanRead)
            {
                return false;
            }

            var originalPosition = stream.CanSeek ? stream.Position : 0;
            var header = new byte[8];
            var read = stream.Read(header, 0, header.Length);

            if (stream.CanSeek)
            {
                stream.Position = originalPosition;
            }

            if (extension.Equals(".pdf", StringComparison.OrdinalIgnoreCase))
            {
                return read >= 4 && header[0] == 0x25 && header[1] == 0x50 &&
                       header[2] == 0x44 && header[3] == 0x46;
            }

            if (extension.Equals(".docx", StringComparison.OrdinalIgnoreCase))
            {
                var isZip = read >= 4 && header[0] == 0x50 && header[1] == 0x4B &&
                            header[2] == 0x03 && header[3] == 0x04;
                return isZip && IsWordOpenXmlPackage(stream, originalPosition);
            }

            return read >= 8 &&
                   header[0] == 0xD0 && header[1] == 0xCF &&
                   header[2] == 0x11 && header[3] == 0xE0 &&
                   header[4] == 0xA1 && header[5] == 0xB1 &&
                   header[6] == 0x1A && header[7] == 0xE1;
        }

        private static bool IsWordOpenXmlPackage(Stream stream, long originalPosition)
        {
            if (!stream.CanSeek)
            {
                return false;
            }

            try
            {
                stream.Position = originalPosition;

                using (var archive = new ZipArchive(stream, ZipArchiveMode.Read, true))
                {
                    return archive.GetEntry("[Content_Types].xml") != null &&
                           archive.GetEntry("word/document.xml") != null;
                }
            }
            catch (InvalidDataException)
            {
                return false;
            }
            finally
            {
                stream.Position = originalPosition;
            }
        }
    }
}
