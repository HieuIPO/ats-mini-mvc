using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System;
using System.Web;
using ATSMiniProject.Controllers;

namespace ATSMiniProject
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            MvcHandler.DisableMvcResponseHeader = true;
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            var exception = Server.GetLastError();
            var httpException = exception as HttpException;
            var statusCode = httpException == null ? 500 : httpException.GetHttpCode();
            var actionName = statusCode == 404 ? "NotFound" : "Index";

            Server.ClearError();
            Response.Clear();
            Response.StatusCode = statusCode == 404 ? 404 : 500;
            Response.TrySkipIisCustomErrors = true;
            Response.SuppressFormsAuthenticationRedirect = true;

            var routeData = new RouteData();
            routeData.Values["controller"] = "Error";
            routeData.Values["action"] = actionName;

            IController errorController = new ErrorController();
            errorController.Execute(
                new RequestContext(new HttpContextWrapper(Context), routeData)
            );
        }

        protected void Application_PreSendRequestHeaders(object sender, EventArgs e)
        {
            Response.Headers.Remove("X-SourceFiles");
            Response.Headers.Remove("X-AspNet-Version");
            Response.Headers.Remove("X-AspNetMvc-Version");
            Response.Headers.Remove("X-Powered-By");
        }
    }
}
