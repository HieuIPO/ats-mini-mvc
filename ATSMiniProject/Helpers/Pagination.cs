using System;

namespace ATSMiniProject.Helpers
{
    public sealed class PaginationResult
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalItems { get; set; }
        public int TotalPages { get; set; }
        public int Offset { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
    }

    public static class Pagination
    {
        public static PaginationResult Calculate(int requestedPage, int totalItems, int pageSize)
        {
            if (totalItems < 0)
            {
                throw new ArgumentOutOfRangeException("totalItems");
            }

            if (pageSize <= 0)
            {
                throw new ArgumentOutOfRangeException("pageSize");
            }

            var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)pageSize));
            var page = Math.Max(1, Math.Min(requestedPage, totalPages));
            var offset = (page - 1) * pageSize;

            return new PaginationResult
            {
                Page = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                TotalPages = totalPages,
                Offset = offset,
                FirstItem = totalItems == 0 ? 0 : offset + 1,
                LastItem = Math.Min(offset + pageSize, totalItems)
            };
        }
    }
}
