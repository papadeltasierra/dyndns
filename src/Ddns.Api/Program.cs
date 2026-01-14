var builder = WebApplication.CreateBuilder(args);

// Configuration
builder.Configuration.AddEnvironmentVariables();

// Logging
builder.Services.AddApplicationInsightsTelemetry();

// AuthN/AuthZ
builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        options.Authority = builder.Configuration["AzureAd:Authority"];
        options.Audience = builder.Configuration["AzureAd:Audience"];
    });

builder.Services.AddAuthorization();

// Data access
builder.Services.AddDbContext<DdnsDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("Sql")));

// Domain services
builder.Services.AddScoped<IDdnsUpdateService, DdnsUpdateService>();
builder.Services.AddScoped<IDomainService, DomainService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();

// Azure integrations
builder.Services.AddSingleton<IKeyVaultService, KeyVaultService>();
builder.Services.AddSingleton<IDnsProvider, AzureDnsProvider>();

builder.Services.AddControllers();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
