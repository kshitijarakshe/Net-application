# ---------- Build Stage ----------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

COPY . .

# Move into project folder (IMPORTANT)
WORKDIR /app/Net-application

RUN dotnet restore
RUN dotnet publish -c Release -o /app/out

# ---------- Runtime Stage ----------
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app

COPY --from=build /app/out .
EXPOSE 5000
ENTRYPOINT ["dotnet", "Net-application.dll"]
