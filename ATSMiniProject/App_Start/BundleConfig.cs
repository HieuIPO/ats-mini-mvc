using System.Web.Optimization;

namespace ATSMiniProject
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/Content/css").Include(
                "~/Content/css/site.css"));
        }
    }
}
