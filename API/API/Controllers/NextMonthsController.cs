using API.Filters;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Web.Http;
using System.Web.Http.Description;

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize]
    public class NextMonthsController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpGet]
        public IEnumerable<NextMonth> GetNextMonth()
        {
            return db.NextMonth;
        }

        [HttpGet]
        public IHttpActionResult GetNextMonth(int id)
        {
            NextMonth nextMonth = db.NextMonth.Find(id);
            if (nextMonth == null)
            {
                return NotFound();
            }

            return Ok(nextMonth);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut]
        public IHttpActionResult PutNextMonth(int id, NextMonth nextMonth)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != nextMonth.Id)
            {
                return BadRequest();
            }

            db.Entry(nextMonth).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!NextMonthExists(id))
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
        public IHttpActionResult PostNextMonth(NextMonth nextMonth)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.NextMonth.Add(nextMonth);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (NextMonthExists(nextMonth.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = nextMonth.Id }, nextMonth);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete]
        public IHttpActionResult DeleteNextMonth(int id)
        {
            NextMonth nextMonth = db.NextMonth.Find(id);
            if (nextMonth == null)
            {
                return NotFound();
            }

            db.NextMonth.Remove(nextMonth);
            db.SaveChanges();

            return Ok(nextMonth);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool NextMonthExists(int id)
        {
            return db.NextMonth.Count(e => e.Id == id) > 0;
        }
    }
}