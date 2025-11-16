# 🚀 Quick Start: Run Pango on Your Phone

## ✅ Current Status

- ✅ Flutter dependencies installed
- ✅ Mobile app configured with your IP: **10.42.217.17**
- ⏳ Waiting for phone connection

---

## 📱 Connect Your Phone

### For Android:

1. **Enable Developer Mode:**
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times until you see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to **Settings** → **System** → **Developer Options**
   - Enable **USB Debugging**

3. **Connect Phone:**
   - Connect your phone to computer with USB cable
   - On your phone, tap **Allow** when USB debugging prompt appears
   - Select **File Transfer** or **PTP** mode

4. **Verify Connection:**
   ```bash
   cd C:\pango\mobile
   flutter devices
   ```
   You should see your phone listed!

### For iPhone (iOS):

1. **Trust Computer:**
   - Connect iPhone to computer
   - On iPhone, tap **Trust** when prompted

2. **Install Required Tools:**
   - You need Xcode installed (Mac only)
   - iOS development requires a Mac computer

---

## 🏃 Run the App

### Once Your Phone is Connected:

```bash
# Navigate to mobile folder
cd C:\pango\mobile

# Check connected devices
flutter devices

# Run on your phone (automatic device selection if only one connected)
flutter run

# Or specify device explicitly
flutter run -d [device-id]
```

The app will:
1. Build (first time takes 2-5 minutes)
2. Install on your phone
3. Launch automatically

---

## 🎨 Testing Without Backend (UI Only)

The app is configured to work even if backend isn't running. You can test:
- ✅ Splash screen
- ✅ Onboarding flow
- ✅ Login/Register screens (UI only)
- ✅ Language switching (Swahili/English)

---

## 🔧 With Backend Running (Full Functionality)

### Step 1: Start MongoDB

**Option A: Using Docker (Easiest)**
```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

**Option B: Using MongoDB Atlas (Free Cloud)**
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create free account
3. Create cluster
4. Get connection string
5. Update `backend/.env` with connection string

**Option C: Local MongoDB**
- Download and install from [mongodb.com](https://www.mongodb.com/try/download/community)
- Start MongoDB service

### Step 2: Start Backend

```bash
cd C:\pango\backend
npm run dev
```

You should see:
```
Server running in development mode on port 3000
MongoDB Connected: localhost
```

### Step 3: Test API

Open browser: http://localhost:3000/health

You should see:
```json
{
  "success": true,
  "message": "Server is healthy"
}
```

---

## 🔥 Quick Commands

```bash
# Check Flutter setup
flutter doctor

# List devices
flutter devices

# Run app
cd C:\pango\mobile
flutter run

# Run on specific device
flutter run -d [device-name]

# Hot reload (press 'r' in terminal while app is running)
# Hot restart (press 'R')

# Clear and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 🐛 Troubleshooting

### Phone Not Detected?

**Android:**
```bash
# Check ADB devices
adb devices

# Restart ADB if needed
adb kill-server
adb start-server
```

**Fix: Install ADB Drivers**
- Download [Universal ADB Drivers](https://adb.clockworkmod.com/)
- Install and restart computer

### App Build Fails?

```bash
cd C:\pango\mobile
flutter clean
flutter pub get
flutter run
```

### Can't Connect to Backend?

Make sure:
- ✅ Backend is running on port 3000
- ✅ Your phone and computer are on same WiFi network
- ✅ Windows Firewall allows port 3000
- ✅ IP address in constants.dart is correct (**10.42.217.17**)

**Test backend from phone browser:**
Open: `http://10.42.217.17:3000/health`

### Allow Firewall (if needed):

```powershell
# Run PowerShell as Administrator
New-NetFirewallRule -DisplayName "Node.js 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

---

## 📱 What You Can Test

### Without Backend:
- ✅ UI/UX design
- ✅ Screen navigation
- ✅ Language switching
- ✅ Animations
- ✅ Layout responsiveness

### With Backend:
- ✅ User registration
- ✅ Login/logout
- ✅ Browse listings
- ✅ Search and filters
- ✅ View listing details
- ✅ Booking flow
- ✅ Profile management

---

## 🎯 Next Steps

1. ✅ Install the app on your phone
2. ✅ Test the UI and navigation
3. ✅ Start backend for full functionality
4. ✅ Register a test user
5. ✅ Test booking flow
6. ✅ Try language switching (Swahili ↔ English)

---

## 📞 Need Help?

- Check main **README.md** for detailed info
- See **SETUP_GUIDE.md** for complete setup
- Review **TECHNICAL_SPECIFICATION.md** for architecture

---

## 🚀 Current Configuration

- **Backend API**: `http://10.42.217.17:3000/api/v1`
- **Database**: MongoDB (local or Atlas)
- **Mobile**: Flutter on your phone
- **Platform**: Android (iOS requires Mac)

---

**Ready to test!** 🎉

Connect your phone and run:
```bash
cd C:\pango\mobile
flutter run
```

























