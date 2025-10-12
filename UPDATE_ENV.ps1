# Quick script to update .env with your MongoDB URI
# Usage: 
#   1. Replace YOUR_MONGODB_URI_HERE with your actual MongoDB connection string
#   2. Run: .\UPDATE_ENV.ps1

$mongoUri = "YOUR_MONGODB_URI_HERE"

# If you haven't replaced the URI above, this script will prompt you
if ($mongoUri -eq "YOUR_MONGODB_URI_HERE") {
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "MongoDB Atlas Setup Instructions:" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to: https://www.mongodb.com/cloud/atlas/register" -ForegroundColor Cyan
    Write-Host "2. Create FREE account and FREE cluster (M0)" -ForegroundColor Cyan
    Write-Host "3. Create database user (username: pangouser)" -ForegroundColor Cyan
    Write-Host "4. Whitelist IP: 0.0.0.0/0 (Allow from anywhere)" -ForegroundColor Cyan
    Write-Host "5. Get connection string from 'Connect' button" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your connection string should look like:" -ForegroundColor Green
    Write-Host "mongodb+srv://pangouser:PASSWORD@cluster0.xxxxx.mongodb.net/pango?retryWrites=true&w=majority" -ForegroundColor White
    Write-Host ""
    
    $mongoUri = Read-Host "Paste your MongoDB connection string here"
}

# Create .env content
$envContent = @"
NODE_ENV=development
PORT=3000
API_VERSION=v1
MONGODB_URI=$mongoUri
JWT_SECRET=pango-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=30d
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100
FRONTEND_URL=*
"@

# Write to .env file
$envContent | Out-File -FilePath .env -Encoding utf8 -Force

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ .env file updated successfully!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "The backend should automatically restart with nodemon." -ForegroundColor Cyan
Write-Host "Watch for this message:" -ForegroundColor Cyan
Write-Host "  info: MongoDB Connected: cluster0.xxxxx.mongodb.net" -ForegroundColor White
Write-Host ""
Write-Host "If it doesn't restart, run:" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""









