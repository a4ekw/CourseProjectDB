using API.Filters;
using API.Models;
using Microsoft.AspNet.Identity;
using System;
using System.Web.Http;

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize(Roles = "Admin")]
    public class AdminController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpPut]
        public IHttpActionResult PutMonth(int id, Action action)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            DateTime now = DateTime.Now;
            string selectedMnth = "";
            int number;

            if (now.Month == action.Month)
            {
                selectedMnth = "Month";
            }

            if (now.Month + 1 == action.Month)
            {
                selectedMnth = "NextMonth";
            }

            if (selectedMnth != "")
            {
                return Ok(db.ChangeFS(id.ToString(), action.Day, selectedMnth, action.Value));
            }
            return BadRequest();
        }

        [HttpPost]
        public IHttpActionResult PostMonth(NewEmployee newEmployee)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            return Ok(db.AddNewUser(newEmployee.FullName, newEmployee.Phone, newEmployee.Email,
                new PasswordHasher().HashPassword(newEmployee.Password), newEmployee.Category, newEmployee.Exp, Guid.NewGuid().ToString()));
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}