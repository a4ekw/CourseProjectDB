using API.Filters;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Web.Http;
using System.Web.Http.Description;
using Newtonsoft.Json;
using System;
using System.Data;

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize]
    public class MonthsController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpGet]
        public IQueryable<Month> GetMonth()
        {
            return db.Month;
        }

        [ResponseType(typeof(Month))]
        [HttpGet]
        public IHttpActionResult GetMonth(int id)
        {
            Month month = db.Month.Find(id);
            if (month == null)
            {
                return NotFound();
            }

            return Ok(month);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut]
        public IHttpActionResult PutMonth(int id, Month month)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != month.Id)
            {
                return BadRequest();
            }

            db.Entry(month).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!MonthExists(id))
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
        public IHttpActionResult PostMonth(Month month)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.Month.Add(month);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (MonthExists(month.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = month.Id }, month);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete]
        public IHttpActionResult DeleteMonth(int id)
        {
            Month month = db.Month.Find(id);
            if (month == null)
            {
                return NotFound();
            }

            db.Month.Remove(month);
            db.SaveChanges();

            return Ok(month);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool MonthExists(int id)
        {
            return db.Month.Count(e => e.Id == id) > 0;
        }
    }
}