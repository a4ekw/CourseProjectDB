using System.Data.Entity;
using API.Models;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;

namespace API.Data
{
    public class UsersDbContext : IdentityDbContext<IdentityUser>
    {
        static UsersDbContext()
        {
            Database.SetInitializer(new Initializer());
        }

        private class Initializer : CreateDatabaseIfNotExists<UsersDbContext>
        {
            protected override void Seed(UsersDbContext context)
            {
                IdentityRole role = context.Roles.Add(new IdentityRole("User"));

                IdentityUser user = new IdentityUser("user@mail.ru");
                user.Roles.Add(new IdentityUserRole { Role = role });
                user.Claims.Add(new IdentityUserClaim
                {
                    ClaimType = "hasRegistered",
                    ClaimValue = "true"
                });

                user.PasswordHash = new PasswordHasher().HashPassword("secret");
                context.Users.Add(user);

                role = context.Roles.Add(new IdentityRole("Admin"));

                 user = new IdentityUser("lmv1996.96@mail.ru");
                user.Roles.Add(new IdentityUserRole { Role = role });
                user.Claims.Add(new IdentityUserClaim
                {
                    ClaimType = "hasRegistered",
                    ClaimValue = "true"
                });

                user.PasswordHash = new PasswordHasher().HashPassword("secret");
                context.Users.Add(user);


                context.SaveChanges();
                base.Seed(context);
            }
        }
    }
}