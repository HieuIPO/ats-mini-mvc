using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using HtmlAgilityPack;

namespace ATSMiniProject.Helpers
{
    public static class RichTextSanitizer
    {
        private static readonly HashSet<string> AllowedTags = new HashSet<string>(
            new[] { "p", "div", "br", "strong", "b", "em", "i", "ul", "ol", "li", "h3", "h4" },
            StringComparer.OrdinalIgnoreCase);

        private static readonly HashSet<string> RemovedWithContent = new HashSet<string>(
            new[] { "script", "style", "iframe", "object", "embed", "svg", "math", "template" },
            StringComparer.OrdinalIgnoreCase);

        public static string Sanitize(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
            {
                return string.Empty;
            }

            var document = new HtmlDocument
            {
                OptionFixNestedTags = true
            };
            document.LoadHtml(html);
            CleanChildren(document.DocumentNode);

            var hasElement = document.DocumentNode
                .Descendants()
                .Any(node => node.NodeType == HtmlNodeType.Element);
            if (!hasElement)
            {
                var plainText = HtmlEntity.DeEntitize(document.DocumentNode.InnerText).Trim();
                return string.IsNullOrWhiteSpace(plainText)
                    ? string.Empty
                    : "<p>" + HttpUtility.HtmlEncode(plainText)
                        .Replace("\r\n", "<br />")
                        .Replace("\n", "<br />") + "</p>";
            }

            return document.DocumentNode.InnerHtml.Trim();
        }

        public static bool HasMeaningfulText(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
            {
                return false;
            }

            var document = new HtmlDocument();
            document.LoadHtml(Sanitize(html));
            return !string.IsNullOrWhiteSpace(HtmlEntity.DeEntitize(document.DocumentNode.InnerText));
        }

        public static string ToPlainText(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
            {
                return string.Empty;
            }

            var document = new HtmlDocument();
            document.LoadHtml(Sanitize(html));
            return HtmlEntity.DeEntitize(document.DocumentNode.InnerText).Trim();
        }

        private static void CleanChildren(HtmlNode parent)
        {
            foreach (var node in parent.ChildNodes.ToList())
            {
                if (node.NodeType == HtmlNodeType.Comment)
                {
                    parent.RemoveChild(node);
                    continue;
                }

                if (node.NodeType != HtmlNodeType.Element)
                {
                    continue;
                }

                if (RemovedWithContent.Contains(node.Name))
                {
                    parent.RemoveChild(node);
                    continue;
                }

                CleanChildren(node);
                if (!AllowedTags.Contains(node.Name))
                {
                    foreach (var child in node.ChildNodes.ToList())
                    {
                        parent.InsertBefore(child, node);
                    }

                    parent.RemoveChild(node);
                    continue;
                }

                node.Attributes.RemoveAll();
            }
        }
    }
}
