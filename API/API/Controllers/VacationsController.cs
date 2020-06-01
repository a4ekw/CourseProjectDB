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
    public class VacationsController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();

        [HttpGet]
        public IQueryable<Vacation> GetVacation()
        {
            return db.Vacation;
        }

        [HttpGet]
        public IHttpActionResult GetVacation(int id)
        {
            Vacation vacation = db.Vacation.Find(id);
            if (vacation == null)
            {
                return NotFound();
            }

            return Ok(vacation);
        }

        [HttpPut]
        public IHttpActionResult PutVacation(int id, Vacation vacation)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != vacation.Id)
            {
                return BadRequest();
            }

            db.Entry(vacation).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!VacationExists(id))
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
        public IHttpActionResult PostVacation(Vacation vacation)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.Vacation.Add(vacation);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (VacationExists(vacation.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = vacation.Id }, vacation);
        }

        [HttpDelete]
        public IHttpActionResult DeleteVacation(int id)
        {
            Vacation vacation = db.Vacation.Find(id);
            if (vacation == null)
            {
                return NotFound();
            }

            db.Vacation.Remove(vacation);
            db.SaveChanges();

            return Ok(vacation);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool VacationExists(int id)
        {
            return db.Vacation.Count(e => e.Id == id) > 0;
        }
    }
}