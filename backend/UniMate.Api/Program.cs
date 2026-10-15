using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using UniMate.Api.Data;
using UniMate.Api.Endpoints;
using UniMate.Domain.Entities;

var builder = WebApplication.CreateBuilder(args);

// The connection string comes from user-secrets, never from appsettings (see README).
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// Hashes and checks passwords. One shared instance is fine because it holds no state.
builder.Services.AddSingleton<IPasswordHasher<User>, PasswordHasher<User>>();

// Send and receive enums as text ("Open") instead of numbers (0).
// The first line is for the endpoints, the second so Swagger shows the same thing.
builder.Services.ConfigureHttpJsonOptions(options =>
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.Configure<Microsoft.AspNetCore.Mvc.JsonOptions>(options =>
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Swagger stays on in production too, so the deployed API can be shown in the demo.
app.UseSwagger();
app.UseSwaggerUI();

// No UseHttpsRedirection: Render handles HTTPS in front of the app, so the app itself speaks plain HTTP.

// Bring the database up to the latest migration on every start, locally and on Render.
using (var scope = app.Services.CreateScope())
{
    await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.MigrateAsync();
}

await AdminSeeder.SeedAsync(app);

// "database": true proves the API can reach PostgreSQL.
app.MapGet("/api/health", async (AppDbContext db) =>
        Results.Ok(new { status = "ok", database = await db.Database.CanConnectAsync() }))
    .WithName("GetHealth")
    .WithOpenApi();

app.MapAuthEndpoints();
app.MapJobEndpoints();
app.MapApplicationEndpoints();
app.MapReportEndpoints();

app.Run();
