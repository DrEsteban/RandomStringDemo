using Microsoft.EntityFrameworkCore;
using StringFetcher.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<StringsDbContext>(options => options.UseSqlServer(builder.Configuration["AZURE_SQL_CONNECTIONSTRING"]));

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseDeveloperExceptionPage(); // Demo app - don't care about leaking the stack :)
app.MapGet("/", (StringsDbContext db) => db.StringsTable.OrderBy(x => Guid.NewGuid()).FirstOrDefault()?.Quote);

app.Run();
