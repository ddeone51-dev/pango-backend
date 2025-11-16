# 🎨 Homia Logo Replacement Guide

## 📋 Logo Files to Replace

To complete the rebranding from Pango to Homia, you need to replace the following logo files:

### 1. **Main Logo** (for app assets)
**File:** `mobile/assets/images/logo.png`
- **Size:** 512x512px (recommended)
- **Format:** PNG with transparent background
- **Usage:** App icon, splash screen, in-app branding

### 2. **Android App Icons** (multiple sizes needed)

Replace these files in `mobile/android/app/src/main/res/`:

#### **Main App Icons:**
- `mipmap-mdpi/ic_launcher.png` (48x48px)
- `mipmap-hdpi/ic_launcher.png` (72x72px)
- `mipmap-xhdpi/ic_launcher.png` (96x96px)
- `mipmap-xxhdpi/ic_launcher.png` (144x144px)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192px)

#### **Adaptive Icons (Android 8.0+):**
- `drawable-mdpi/ic_launcher_foreground.png` (108x108px)
- `drawable-hdpi/ic_launcher_foreground.png` (162x162px)
- `drawable-xhdpi/ic_launcher_foreground.png` (216x216px)
- `drawable-xxhdpi/ic_launcher_foreground.png` (324x324px)
- `drawable-xxxhdpi/ic_launcher_foreground.png` (432x432px)

### 3. **iOS App Icons** (if you have iOS support)
**Directory:** `mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Various sizes from 20x20 to 1024x1024px

---

## 🎨 Design Guidelines

### **Logo Design Requirements:**

1. **Style:** Modern, clean, professional
2. **Colors:** Consider your brand colors
3. **Text:** "Homia" should be readable at small sizes
4. **Icon:** Simple, recognizable symbol
5. **Background:** Transparent for PNG files

### **Recommended Logo Variations:**

1. **Full Logo:** Text + Icon (for splash screens)
2. **Icon Only:** Just the symbol (for app icons)
3. **Monochrome:** Single color version (for adaptive icons)

---

## 🔧 How to Replace Logos

### **Step 1: Create Your Homia Logo**

Design your Homia logo with these specifications:
- **Main logo:** 512x512px PNG
- **App icon:** Square format, works at 48x48px
- **Colors:** Choose your brand colors
- **Style:** Modern, clean, professional

### **Step 2: Generate Multiple Sizes**

Use online tools like:
- [App Icon Generator](https://appicon.co/)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)
- [Icon Kitchen](https://icon.kitchen/)

Or use design tools:
- **Figma:** Export at multiple sizes
- **Photoshop:** Use Image → Image Size
- **GIMP:** Free alternative

### **Step 3: Replace Files**

1. **Main Logo:**
   ```
   Replace: mobile/assets/images/logo.png
   ```

2. **Android Icons:**
   ```
   Replace all files in: mobile/android/app/src/main/res/mipmap-*/
   Replace all files in: mobile/android/app/src/main/res/drawable-*/
   ```

3. **Test the App:**
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 🎯 Quick Logo Creation Tips

### **If you don't have a designer:**

1. **Use Logo Makers:**
   - [Canva](https://canva.com) - Free logo maker
   - [LogoMaker](https://logomaker.com) - Professional tools
   - [Hatchful by Shopify](https://hatchful.shopify.com) - Free

2. **Simple Text Logo:**
   - Use a modern font
   - Add a simple icon (house, key, etc.)
   - Keep it clean and minimal

3. **Color Scheme:**
   - Primary: Choose your main brand color
   - Secondary: Complementary color
   - Consider: Blue (trust), Green (nature), Orange (energy)

---

## 📱 Testing Your New Logo

### **After replacing logos:**

1. **Clean and rebuild:**
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check these locations:**
   - App icon on home screen
   - Splash screen (if implemented)
   - In-app logo displays
   - Android app drawer

3. **Verify sizes:**
   - Icon looks good at small sizes (48x48)
   - No pixelation or blurriness
   - Text is readable

---

## 🎨 Brand Guidelines for Homia

### **Suggested Brand Identity:**

**Name:** Homia
**Tagline:** "Your Home Away From Home"
**Industry:** Accommodation booking platform
**Target:** Tanzania market

### **Color Suggestions:**
- **Primary:** Deep Blue (#1E3A8A) - Trust, reliability
- **Secondary:** Warm Orange (#F59E0B) - Energy, hospitality
- **Accent:** Forest Green (#059669) - Nature, growth
- **Neutral:** Gray (#6B7280) - Professional

### **Logo Style Ideas:**
1. **House + Key:** Classic accommodation symbol
2. **Mountain + House:** Tanzania landscape
3. **H + House:** Letter integration
4. **Geometric House:** Modern, clean
5. **Text + Icon:** "Homia" with house symbol

---

## ✅ Checklist

- [ ] Design Homia logo (512x512px)
- [ ] Create app icon variations
- [ ] Replace `mobile/assets/images/logo.png`
- [ ] Replace all Android mipmap icons
- [ ] Replace all Android drawable icons
- [ ] Test on device
- [ ] Verify all sizes look good
- [ ] Update any hardcoded logo references in code

---

## 🚀 Next Steps

1. **Create your Homia logo** using the guidelines above
2. **Replace all the files** listed in this guide
3. **Test the app** to ensure logos display correctly
4. **Update any remaining references** to "Pango" in the codebase

Your app will then be fully rebranded as **Homia**! 🏠✨

---

**Need help with logo design?** Consider hiring a designer on:
- Fiverr
- Upwork
- 99designs
- Local design agencies

**Budget option:** Use free logo makers and customize with your brand colors and style.





