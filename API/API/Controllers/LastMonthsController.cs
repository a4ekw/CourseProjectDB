using API.Filters;
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
    public class LastMonthsController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpGet]
        public IQueryable<LastMonth> GetLastMonth()
        {
            return db.LastMonth;
        }

        [HttpGet]
        public IHttpActionResult GetLastMonth(int id)
        {
            LastMonth lastMonth = db.LastMonth.Find(id);
            if (lastMonth == null)
            {
                return NotFound();
            }

            return Ok(lastMonth);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut]
        public IHttpActionResult PutLastMonth(int id, LastMonth lastMonth)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != lastMonth.Id)
            {
                return BadRequest();
            }

            db.Entry(lastMonth).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!LastMonthExists(id))
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
        public IHttpActionResult PostLastMonth(LastMonth lastMonth)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.LastMonth.Add(lastMonth);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (LastMonthExists(lastMonth.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = lastMonth.Id }, lastMonth);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete]
        public IHttpActionResult DeleteLastMonth(int id)
        {
            LastMonth lastMonth = db.LastMonth.Find(id);
            if (lastMonth == null)
            {
                return NotFound();
            }

            db.LastMonth.Remove(lastMonth);
            db.SaveChanges();

            return Ok(lastMonth);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool LastMonthExists(int id)
        {
            return db.LastMonth.Count(e => e.Id == id) > 0;
        }
    }
}