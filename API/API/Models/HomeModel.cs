using System.Collections.Generic;

namespace API.Models
{
    public class HomeModel
    {
        public string UserName { get; set; }

        public IEnumerable<ClaimModel> Claims { get; set; }
    }
}
