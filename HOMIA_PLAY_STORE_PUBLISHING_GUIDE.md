# 🚀 Homia - Play Store Publishing Guide

## 📱 **App Information**

**App Name:** Homia  
**Package ID:** com.techlandtz.homia  
**Category:** Travel & Local  
**Target Market:** Tanzania  
**Languages:** English, Swahili  

---

## 🎯 **Step 1: Prepare Release Build**

### **1.1 Update App Version**
```bash
cd mobile
# Update version in pubspec.yaml
version: 1.0.0+1  # Version 1.0.0, Build 1
```

### **1.2 Generate Release APK/AAB**
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Generate release APK
flutter build apk --release

# Generate release AAB (recommended for Play Store)
flutter build appbundle --release
```

### **1.3 Sign the App**
- The app is currently using debug signing
- For production, you'll need a release keystore
- Create release keystore: `keytool -genkey -v -keystore homia-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias homia`

---

## 🏪 **Step 2: Play Store Console Setup**

### **2.1 Create New App**
1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - **App name:** Homia
   - **Default language:** English
   - **App or game:** App
   - **Free or paid:** Free
   - **Declarations:** Check all applicable boxes

### **2.2 App Content Rating**
- Complete content rating questionnaire
- Select appropriate age ratings
- Submit for review

---

## 📝 **Step 3: Store Listing Content**

### **3.1 App Description**

**Short Description (80 chars max):**
```
Find your perfect stay in Tanzania - Book accommodations across the country
```

**Full Description:**
```
🏠 Welcome to Homia - Your Home Away From Home in Tanzania!

Discover and book amazing accommodations across Tanzania with Homia, the premier accommodation booking platform designed specifically for the Tanzanian market.

🌟 KEY FEATURES:
• 🔍 Advanced Search - Find properties by location, price, amenities
• 📱 Easy Booking - Simple and secure booking process
• 💳 Multiple Payment Options - M-Pesa, Tigo Pesa, Airtel Money, Cards
• ⭐ Reviews & Ratings - Read authentic reviews from other travelers
• 🗺️ Interactive Maps - Explore locations with detailed maps
• 🔔 Push Notifications - Stay updated on your bookings
• 🌍 Bilingual Support - English and Swahili language support
• 💰 Local Currency - All prices in Tanzanian Shillings (TZS)

🏖️ DESTINATIONS:
From bustling Dar es Salaam to the pristine beaches of Zanzibar, from the wildlife of Arusha to the cultural heritage of Stone Town - find your perfect stay anywhere in Tanzania.

🏨 ACCOMMODATION TYPES:
• Beach houses and villas
• City apartments and condos
• Safari lodges and camps
• Budget hostels and luxury hotels
• Traditional guesthouses

🔒 SECURE & TRUSTED:
• Secure payment processing
• Verified hosts and properties
• 24/7 customer support
• Easy cancellation policies

📱 EASY TO USE:
• Simple registration and login
• Quick property search and filtering
• Instant booking confirmation
• Real-time booking management

Whether you're planning a business trip to Dar es Salaam, a beach vacation in Zanzibar, or a safari adventure in the Serengeti, Homia has the perfect accommodation for you.

Download Homia today and start your Tanzanian adventure! 🇹🇿

#Homia #Tanzania #Travel #Accommodation #Booking #Zanzibar #DarEsSalaam
```

### **3.2 App Screenshots**
Prepare screenshots for:
- Phone screenshots (required)
- Tablet screenshots (optional)
- Feature graphic (1024 x 500)
- App icon (512 x 512)

### **3.3 App Icon**
- Size: 512 x 512 pixels
- Format: PNG
- Use your logo3.png as base
- Ensure it looks good at small sizes

---

## 🎨 **Step 4: Visual Assets**

### **4.1 Required Images**
1. **App Icon:** 512x512px PNG
2. **Feature Graphic:** 1024x500px PNG
3. **Phone Screenshots:** 1080x1920px or similar
4. **Tablet Screenshots:** 1200x1920px (optional)

### **4.2 Screenshot Content**
Capture screenshots of:
- Home screen with search
- Property listings
- Property details
- Booking process
- User profile
- Map view

---

## 🔧 **Step 5: Technical Requirements**

### **5.1 App Permissions**
Ensure these permissions are properly declared:
- Internet access
- Location access
- Camera (for profile photos)
- Storage (for image uploads)

### **5.2 Target SDK**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Compile SDK: 34

### **5.3 App Size**
- Optimize images and assets
- Use ProGuard for code obfuscation
- Target size: < 100MB

---

## 📋 **Step 6: Store Listing Details**

### **6.1 App Category**
- **Category:** Travel & Local
- **Tags:** Travel, Accommodation, Booking, Tanzania

### **6.2 Contact Information**
- **Website:** [Your website URL]
- **Email:** [Your support email]
- **Privacy Policy:** [Your privacy policy URL]

### **6.3 Content Rating**
- Complete the content rating questionnaire
- Select appropriate age groups
- Submit for rating review

---

## 🚀 **Step 7: Publishing Process**

### **7.1 Upload App Bundle**
1. Go to "Release" → "Production"
2. Upload your AAB file
3. Fill in release notes
4. Review and publish

### **7.2 Release Notes**
```
🎉 Homia v1.0.0 - Initial Release

✨ Features:
• Browse and search accommodations across Tanzania
• Secure booking with multiple payment options
• User reviews and ratings system
• Interactive maps and location services
• Push notifications for booking updates
• Bilingual support (English & Swahili)
• Local currency support (TZS)

🏠 Find your perfect stay in Tanzania with Homia!
```

### **7.3 Review Process**
- Google will review your app (1-3 days typically)
- Address any policy violations
- Respond to feedback promptly

---

## 📊 **Step 8: Post-Launch**

### **8.1 Monitor Performance**
- Track downloads and ratings
- Monitor crash reports
- Analyze user feedback

### **8.2 Regular Updates**
- Plan regular feature updates
- Fix bugs promptly
- Respond to user reviews

---

## 🎯 **Quick Checklist**

### **Before Publishing:**
- [ ] App builds successfully in release mode
- [ ] All features tested thoroughly
- [ ] App icons and screenshots prepared
- [ ] Store listing content written
- [ ] Privacy policy created
- [ ] Content rating completed
- [ ] Release notes prepared

### **Publishing:**
- [ ] Upload AAB to Play Console
- [ ] Complete store listing
- [ ] Submit for review
- [ ] Monitor review status

### **Post-Launch:**
- [ ] Monitor app performance
- [ ] Respond to user feedback
- [ ] Plan future updates

---

## 🆘 **Common Issues & Solutions**

### **Build Issues:**
```bash
# If build fails, try:
flutter clean
flutter pub get
flutter build appbundle --release
```

### **Signing Issues:**
- Ensure keystore is properly configured
- Check keystore password and alias
- Verify keystore file location

### **Upload Issues:**
- Ensure AAB file is properly signed
- Check app bundle size limits
- Verify all required fields are filled

---

## 📞 **Support Resources**

- **Google Play Console Help:** https://support.google.com/googleplay/android-developer
- **Flutter Documentation:** https://docs.flutter.dev/deployment/android
- **Play Store Policy:** https://play.google.com/about/developer-content-policy

---

**Ready to publish Homia to the Play Store! 🚀**

Your app is well-prepared with all the necessary features for a successful launch in Tanzania. Good luck with your publication! 🇹🇿





