using API.Filters;
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

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize]
    public class EmployeeDatasController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpGet]
        public IEnumerable<EmployeeData> GetEmployeeData()
        {
            return db.EmployeeData;
        }

        [HttpGet]
        public IHttpActionResult GetEmployeeData(int id)
        {
            EmployeeData employeeData = db.EmployeeData.Find(id);
            if (employeeData == null)
            {
                return NotFound();
            }

            return Ok(employeeData);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut]
        public IHttpActionResult PutEmployeeData(int id, EmployeeData employeeData)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != employeeData.Id)
            {
                return BadRequest();
            }

            db.Entry(employeeData).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!EmployeeDataExists(id))
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

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public IHttpActionResult PostEmployeeData(EmployeeData employeeData)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.EmployeeData.Add(employeeData);
            db.SaveChanges();

            return CreatedAtRoute("DefaultApi", new { id = employeeData.Id }, employeeData);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete]
        public IHttpActionResult DeleteEmployeeData(int id)
        {
            EmployeeData employeeData = db.EmployeeData.Find(id);
            if (employeeData == null)
            {
                return NotFound();
            }

            db.EmployeeData.Remove(employeeData);
            db.SaveChanges();

            return Ok(employeeData);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool EmployeeDataExists(int id)
        {
            return db.EmployeeData.Count(e => e.Id == id) > 0;
        }
    }
}