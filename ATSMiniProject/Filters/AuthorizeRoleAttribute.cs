using System;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;

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
            var userIdValue = session == null ? null : session[AuthSessionKeys.UserID];

            if (userIdValue == null)
            {
                RedirectToLogin(filterContext);
                return;
            }

            int userId;
            if (!int.TryParse(userIdValue.ToString(), out userId))
            {
                session.Clear();
                RedirectToLogin(filterContext);
                return;
            }

            string roleName;
            using (var db = new ATSMiniDBContext())
            {
                var currentUser = db.Users
                    .Where(u => u.UserID == userId && u.IsActive && u.Role.IsActive)
                    .Select(u => new { u.FullName, RoleName = u.Role.RoleName })
                    .SingleOrDefault();

                if (currentUser == null)
                {
                    session.Clear();
                    RedirectToLogin(filterContext);
                    return;
                }

                roleName = currentUser.RoleName;
                session[AuthSessionKeys.FullName] = currentUser.FullName;
                session[AuthSessionKeys.RoleName] = roleName;
            }

            if (_allowedRoles.Length > 0 &&
                !_allowedRoles.Any(role => string.Equals(role, roleName, StringComparison.OrdinalIgnoreCase)))
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

            base.OnActionExecuting(filterContext);
        }

        private static void RedirectToLogin(ActionExecutingContext filterContext)
        {
            filterContext.Result = new RedirectToRouteResult(
                new System.Web.Routing.RouteValueDictionary
                {
                    { "controller", "Account" },
                    { "action", "Login" },
                    { "returnUrl", filterContext.HttpContext.Request.RawUrl }
                });
        }
    }
}
