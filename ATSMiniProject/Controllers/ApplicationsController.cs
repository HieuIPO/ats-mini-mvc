using System.Web.Mvc;
using ATSMiniProject.Filters;

namespace ATSMiniProject.Controllers
{
    public class ApplicationsController : Controller
    {
        [AuthorizeRole("Admin", "HR")]
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Create(int? jobId)
        {
            ViewBag.JobID = jobId;
            return View();
        }

        [HttpGet]
        public ActionResult Status()
        {
            return View();
        }
    }
}
