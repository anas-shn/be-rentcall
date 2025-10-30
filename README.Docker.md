# Docker Setup untuk be-rentcall

Panduan lengkap untuk menjalankan aplikasi be-rentcall menggunakan Docker dan Bun.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose V2+
- (Opsional) Make untuk menjalankan shortcut commands

## Quick Start

### 1. Clone dan Setup Environment

```bash
# Copy environment variables
cp .env.example .env

# Edit .env sesuai kebutuhan
nano .env
```

### 2. Build dan Jalankan dengan Docker Compose

```bash
# Build dan start semua services
docker-compose up -d

# Atau build ulang jika ada perubahan
docker-compose up -d --build
```

### 3. Akses Aplikasi

- **Aplikasi Next.js**: http://localhost:3000
- **PostgreSQL Database**: localhost:5432

## Perintah Docker Compose

### Menjalankan Services

```bash
# Start services
docker-compose up -d

# Start dengan rebuild
docker-compose up -d --build

# Lihat logs
docker-compose logs -f

# Lihat logs aplikasi saja
docker-compose logs -f app

# Lihat logs database saja
docker-compose logs -f postgres
```

### Menghentikan Services

```bash
# Stop services (data tetap ada)
docker-compose stop

# Stop dan hapus containers
docker-compose down

# Stop dan hapus containers + volumes (HATI-HATI: data database akan terhapus)
docker-compose down -v
```

### Database Management

```bash
# Jalankan Prisma migrations
docker-compose exec app bunx prisma migrate deploy

# Generate Prisma Client
docker-compose exec app bunx prisma generate

# Push schema ke database (development)
docker-compose exec app bunx prisma db push

# Buka Prisma Studio
docker-compose exec app bunx prisma studio
```

### Debugging

```bash
# Masuk ke container aplikasi
docker-compose exec app sh

# Masuk ke PostgreSQL
docker-compose exec postgres psql -U admin_rentcall -d db_rentcall

# Lihat status containers
docker-compose ps

# Restart aplikasi
docker-compose restart app

# Rebuild dan restart
docker-compose up -d --build app
```

## Struktur Docker

### Dockerfile

Multi-stage build untuk optimasi ukuran image:

1. **deps**: Install dependencies dengan Bun
2. **builder**: Build aplikasi Next.js
3. **runner**: Production image yang ringan

### docker-compose.yml

Services:

- **postgres**: PostgreSQL 16 dengan Alpine Linux
- **app**: Next.js application dengan Bun runtime

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://admin_rentcall:katasandi@postgres:5432/db_rentcall` |
| `AUTH_SECRET` | NextAuth secret key | Generated |
| `AUTH_DISCORD_ID` | Discord OAuth Client ID | - |
| `AUTH_DISCORD_SECRET` | Discord OAuth Secret | - |
| `NEXTAUTH_URL` | Application URL | `http://localhost:3000` |

## Production Deployment

### 1. Update Environment Variables

```bash
# Gunakan database credentials yang aman
DATABASE_URL="postgresql://user:secure_password@postgres:5432/db_rentcall"

# Generate AUTH_SECRET baru
AUTH_SECRET=$(openssl rand -base64 32)

# Set production URL
NEXTAUTH_URL="https://yourdomain.com"
```

### 2. Security Hardening

- Ubah default database credentials
- Gunakan secrets management (Docker Swarm secrets, Kubernetes secrets)
- Enable SSL/TLS untuk database connection
- Setup reverse proxy (Nginx/Traefik) dengan HTTPS

### 3. Performance Tuning

```yaml
# Tambahkan resource limits di docker-compose.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 512M
```

## Troubleshooting

### Database Connection Error

```bash
# Check database status
docker-compose ps postgres

# Restart database
docker-compose restart postgres

# Check database logs
docker-compose logs postgres
```

### Build Failed

```bash
# Clean build cache
docker-compose build --no-cache

# Remove old containers and volumes
docker-compose down -v
docker system prune -a
```

### Prisma Migration Issues

```bash
# Reset database (DEVELOPMENT ONLY)
docker-compose exec app bunx prisma migrate reset

# Deploy pending migrations
docker-compose exec app bunx prisma migrate deploy
```

### Port Already in Use

```bash
# Ubah port di docker-compose.yml
ports:
  - "3001:3000"  # Ganti 3000 ke port lain
```

## Development dengan Docker

### Hot Reload untuk Development

Untuk development dengan hot reload, gunakan volume mounting:

```yaml
# docker-compose.dev.yml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
      - /app/.next
    environment:
      - NODE_ENV=development
    command: bun run dev
```

## Backup dan Restore

### Backup Database

```bash
# Backup ke file SQL
docker-compose exec postgres pg_dump -U admin_rentcall db_rentcall > backup.sql

# Atau menggunakan docker-compose
docker-compose exec -T postgres pg_dump -U admin_rentcall db_rentcall > backup.sql
```

### Restore Database

```bash
# Restore dari file SQL
docker-compose exec -T postgres psql -U admin_rentcall db_rentcall < backup.sql
```

## Monitoring

### Health Check

```bash
# Check container health
docker-compose ps

# Test database connection
docker-compose exec postgres pg_isready -U admin_rentcall
```

### Logs Monitoring

```bash
# Follow logs dari semua services
docker-compose logs -f

# Logs dengan timestamp
docker-compose logs -f --timestamps

# Logs 100 baris terakhir
docker-compose logs --tail=100
```

## Cleanup

```bash
# Stop dan hapus semua containers
docker-compose down

# Hapus containers, volumes, dan networks
docker-compose down -v

# Clean up unused Docker resources
docker system prune -a --volumes
```

## Support

Jika mengalami masalah, silakan:

1. Check logs: `docker-compose logs -f`
2. Verify environment variables di `.env`
3. Ensure Docker dan Docker Compose sudah terinstall dengan benar
4. Check port availability (3000, 5432)

## License

Sesuai dengan lisensi project utama.
