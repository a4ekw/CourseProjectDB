using API.Filters;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using System.Web.Http.Description;

namespace API.Controllers
{
    [IdentityAPI]
    [Authorize]
    public class GetIdController : ApiController
    {
        private ProjectEntities db = new ProjectEntities();
        class Id
        {
            public int valueId { get; set; }
            public Id(int id)
            {
                this.valueId = id;
            }
        }
        

        [HttpGet]
        public IHttpActionResult GetEmployeeData()
        {
            string email = User.Identity.Name;
            IEnumerable<int> id = db.EmployeeData.Where(e => e.Email == email).Select(i => i.Id);
            if (id == null)
            {
                return NotFound();
            }
            else
            {
                Id objId = new Id(id.First());
                return Ok(objId);
            }
        }
    }
}