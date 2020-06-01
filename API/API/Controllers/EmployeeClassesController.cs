using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using API.Filters;

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize(Roles = "Admin")]
    public class EmployeeClassesController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();


        [HttpGet]
        public IQueryable<EmployeeClass> GetEmployeeClass()
        {
            return db.EmployeeClass;
        }

        [HttpGet]
        public IHttpActionResult GetEmployeeClass(int id)
        {
            EmployeeClass employeeClass = db.EmployeeClass.Find(id);
            if (employeeClass == null)
            {
                return NotFound();
            }

            return Ok(employeeClass);
        }

        [HttpPut]
        public IHttpActionResult PutEmployeeClass(int id, EmployeeClass employeeClass)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != employeeClass.Id)
            {
                return BadRequest();
            }

            db.Entry(employeeClass).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!EmployeeClassExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return StatusCode(HttpStatusCode.NoContent);
        }

        [HttpPost]
        public IHttpActionResult PostEmployeeClass(EmployeeClass employeeClass)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.EmployeeClass.Add(employeeClass);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (EmployeeClassExists(employeeClass.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = employeeClass.Id }, employeeClass);
        }

        [HttpDelete]
        public IHttpActionResult DeleteEmployeeClass(int id)
        {
            EmployeeClass employeeClass = db.EmployeeClass.Find(id);
            if (employeeClass == null)
            {
                return NotFound();
            }

            db.EmployeeClass.Remove(employeeClass);
            db.SaveChanges();

            return Ok(employeeClass);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool EmployeeClassExists(int id)
        {
            return db.EmployeeClass.Count(e => e.Id == id) > 0;
        }
    }
}