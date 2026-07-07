using System;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Helpers;

namespace ATSMiniProject.Filters
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public class AuthorizeRoleAttribute : ActionFilterAttribute
    {
        private readonly string[] _allowedRoles;

        public AuthorizeRoleAttribute(params string[] allowedRoles)
        {
            _allowedRoles = allowedRoles ?? new string[0];
        }

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var session = filterContext.HttpContext.Session;
            var userId = session == null ? null : session[AuthSessionKeys.UserID];

            if (userId == null)
            {
                filterContext.Result = new RedirectToRouteResult(
                    new System.Web.Routing.RouteValueDictionary
                    {
                        { "controller", "Account" },
                        { "action", "Login" },
                        { "returnUrl", filterContext.HttpContext.Request.RawUrl }
                    });
                return;
            }

            if (_allowedRoles.Length > 0)
            {
                var roleName = session[AuthSessionKeys.RoleName] as string;
                var isAllowed = _allowedRoles.Any(role => string.Equals(role, roleName, StringComparison.OrdinalIgnoreCase));

                if (!isAllowed)
                {
                    filterContext.Result = new RedirectToRouteResult(
                        new System.Web.Routing.RouteValueDictionary
                        {
                            { "controller", "Account" },
                            { "action", "AccessDenied" },
                            { "returnUrl", filterContext.HttpContext.Request.RawUrl }
                        });
                    return;
                }
            }

            base.OnActionExecuting(filterContext);
        }
    }
}
