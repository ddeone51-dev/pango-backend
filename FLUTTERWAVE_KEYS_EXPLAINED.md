# 🔑 Flutterwave Keys Explained

## ⚠️ IMPORTANT: They Are Different Keys!

Flutterwave gives you **3 different keys** - each has a different purpose.

---

## 🔐 THE 3 KEYS

### 1. **Public Key** (Safe for Mobile App)
```
Format: FLWPUBK_TEST-xxxxxxxxxxxxxxxxx
Example: FLWPUBK_TEST-1a2b3c4d5e6f7g8h9i0j
```

**What it's for:**
- ✅ Used in your mobile app
- ✅ Initializes payment screen
- ✅ Safe to use client-side
- ✅ Users can see it (that's okay!)

**Where to use:**
- Mobile app: `payment_service.dart`

**Security:** Low risk (designed to be public)

---

### 2. **Secret Key** (KEEP PRIVATE!)
```
Format: FLWSECK_TEST-xxxxxxxxxxxxxxxxx
Example: FLWSECK_TEST-9z8y7x6w5v4u3t2s1r0q
```

**What it's for:**
- ✅ Used in your backend ONLY
- ✅ Verifies payments
- ✅ Processes refunds
- ✅ Server-to-server API calls

**Where to use:**
- Backend only: `.env` file
- NEVER in mobile app!

**Security:** HIGH risk (like a password!)

---

### 3. **Encryption Key** (KEEP PRIVATE!)
```
Format: FLWSECK-xxxxxxxxxxxxxxx
or: Random string
Example: FLWENC-abc123def456
```

**What it's for:**
- ✅ Encrypts sensitive data
- ✅ Used with secret key
- ✅ Additional security layer

**Where to use:**
- Backend only: `.env` file

**Security:** HIGH risk

---

## 📍 WHERE TO FIND THEM

### In Flutterwave Dashboard:

1. Login: https://dashboard.flutterwave.com/
2. Go to: **Settings** → **API Keys** (or **API** tab)
3. You'll see a table like this:

```
┌──────────────┬─────────────────────────┐
│ Key Type     │ Value                   │
├──────────────┼─────────────────────────┤
│ Public Key   │ FLWPUBK_TEST-xxxxxx... │ ← Use in mobile app
├──────────────┼─────────────────────────┤
│ Secret Key   │ FLWSECK_TEST-xxxxxx... │ ← Use in backend
├──────────────┼─────────────────────────┤
│ Encryption   │ FLWENC-xxxxxxxxx...    │ ← Use in backend
└──────────────┴─────────────────────────┘
```

**Copy all three!**

---

## ✅ HOW TO USE THEM

### Mobile App (payment_service.dart):
```dart
// ONLY Public Key here!
static const String _publicKey = 'FLWPUBK_TEST-1a2b3c4d...';
                                   ↑
                                Public Key ONLY!
```

### Backend (.env):
```env
# All three keys go here:
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-1a2b3c4d...
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-9z8y7x6w...  ← Different!
FLUTTERWAVE_ENCRYPTION_KEY=FLWENC-abc123...
```

---

## ❌ COMMON MISTAKES

### Mistake 1: Using Secret Key in Mobile App
```dart
❌ WRONG:
static const String _publicKey = 'FLWSECK_TEST-...';
                                   ↑
                              This is SECRET key!

✅ CORRECT:
static const String _publicKey = 'FLWPUBK_TEST-...';
                                   ↑
                              This is PUBLIC key!
```

### Mistake 2: Only Using One Key
```
❌ WRONG: Using same key everywhere

✅ CORRECT:
- Public Key → Mobile app
- Secret Key → Backend
- Encryption Key → Backend
```

### Mistake 3: Sharing Secret Keys
```
❌ NEVER share: Secret Key, Encryption Key
✅ Can share: Public Key (but no need to)
```

---

## 🎯 QUICK CHECKLIST

When you add your keys:

### Mobile App:
- [ ] Open `mobile/lib/core/services/payment_service.dart`
- [ ] Find line with `_publicKey = '...'`
- [ ] Replace with: **Public Key** (FLWPUBK_TEST-...)
- [ ] NOT the secret key!

### Backend:
- [ ] Open `backend/.env`
- [ ] Add **Public Key** (FLWPUBK_TEST-...)
- [ ] Add **Secret Key** (FLWSECK_TEST-...)
- [ ] Add **Encryption Key** (FLWENC-... or string)
- [ ] All three different values!

---

## 📸 VISUAL GUIDE

### In Flutterwave Dashboard:

**Look for a table/section showing:**

```
API Keys (Test Mode)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Public Key (Client-side)
FLWPUBK_TEST-abc123def456... [Copy]
Use this in your frontend/mobile app

Secret Key (Server-side)  
FLWSECK_TEST-xyz789uvw012... [Copy]
Use this on your backend only

Encryption Key
FLWENC-qwerty123... [Copy]
Use for encrypting sensitive data
```

**Copy all three separately!**

---

## 🎯 SUMMARY

### The Keys Are:

| Key | Format | Where | Security |
|-----|--------|-------|----------|
| **Public** | FLWPUBK_TEST-... | Mobile App | Low (safe) |
| **Secret** | FLWSECK_TEST-... | Backend Only | HIGH (protect!) |
| **Encryption** | FLWENC-... | Backend Only | HIGH (protect!) |

**They are NOT the same!** Each has a specific purpose!

---

## ✅ WHAT TO DO

1. Go to Flutterwave dashboard
2. Find **API Keys** section
3. You'll see **3 different keys**:
   - Public Key (FLWPUBK_TEST-...)
   - Secret Key (FLWSECK_TEST-...)
   - Encryption Key (FLWENC-...)
4. Copy each one separately
5. Add to correct locations (as shown above)

---

## 🚀 READY?

After you add all THREE keys:
- ✅ Run `flutter pub get`
- ✅ Restart backend
- ✅ Hot restart mobile app
- ✅ Test payment!

**Then Flutterwave will work!** 💳✨

---

**Need help finding them? Check the screenshot/guide in your Flutterwave dashboard under Settings → API Keys!** 🔑











