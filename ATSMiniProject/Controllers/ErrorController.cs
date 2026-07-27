using System.Web;
using System.Web.Mvc;

namespace ATSMiniProject.Controllers
{
    [AllowAnonymous]
    public class ErrorController : Controller
    {
        public ActionResult NotFound()
        {
            SetErrorResponse(404);
            return View();
        }

        public ActionResult Index()
        {
            SetErrorResponse(500);
            return View();
        }

        private void SetErrorResponse(int statusCode)
        {
            Response.StatusCode = statusCode;
            Response.TrySkipIisCustomErrors = true;
            Response.SuppressFormsAuthenticationRedirect = true;
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
        }
    }
}
