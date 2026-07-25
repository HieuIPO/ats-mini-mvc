using System.Web.Mvc;

namespace ATSMiniProject.Controllers
{
    public class CandidateController : Controller
    {
        [ActionName("Profile")]
        public ActionResult ProfilePage()
        {
            return View();
        }
    }
}
