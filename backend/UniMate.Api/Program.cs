using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;

var builder = WebApplication.CreateBuilder(args);

// The connection string comes from user-secrets, never from appsettings (see README).
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// No UseHttpsRedirection: the iPad talks to this API over plain HTTP on the local network.

// "database": true proves the API can reach PostgreSQL.
app.MapGet("/api/health", async (AppDbContext db) =>
        Results.Ok(new { status = "ok", database = await db.Database.CanConnectAsync() }))
    .WithName("GetHealth")
    .WithOpenApi();

app.Run();
