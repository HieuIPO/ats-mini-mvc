using System.Web.Mvc;
using ATSMiniProject.Filters;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class DashboardController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }
    }
}
