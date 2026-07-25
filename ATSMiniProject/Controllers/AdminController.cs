using System.Web.Mvc;
using ATSMiniProject.Filters;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin")]
    public class AdminController : Controller
    {
        public ActionResult Users()
        {
            return View();
        }
    }
}
