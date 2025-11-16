# 🎯 Google Play Console Account Setup
## Step-by-Step Instructions

---

## 🔗 **Play Console Link**

**Main URL**: https://play.google.com/console

---

## 📝 **Step-by-Step Process**

### **Step 1: Create Developer Account (15 minutes)**

1. **Go to**: https://play.google.com/console

2. **Sign in** with your Google account
   - Use your primary Gmail account
   - This will be your developer account

3. **Accept Developer Agreement**
   - Read the terms
   - Check the box
   - Click "Accept"

4. **Pay Registration Fee**
   - One-time fee: **$25 USD**
   - Payment methods: Credit/Debit card
   - This fee is valid forever (not recurring)

5. **Complete Developer Profile**
   - **Developer name**: TechLand TZ (or your company name)
   - **Developer email**: Your contact email
   - **Developer website** (optional): Your website or leave blank
   - **Phone number**: Your contact number

6. **Wait for Verification**
   - Usually instant
   - Sometimes takes 24-48 hours
   - You'll get email confirmation

---

### **Step 2: Create Your App (10 minutes)**

1. **In Play Console Dashboard**
   - Click **"Create app"** button (top right)

2. **App Details**
   - **App name**: `Pango`
   - **Default language**: `English (United States)`
   - **App or game**: Select `App`
   - **Free or paid**: Select `Free`

3. **Declarations**
   - Check boxes confirming:
     - You follow Play policies
     - You comply with US export laws
   - Click **"Create app"**

---

### **Step 3: Complete Required Sections**

You'll see a dashboard with required tasks. Complete them in this order:

#### **A. Store Listing** (10 minutes)

1. Click **"Store listing"** in left menu

2. Fill in:
   - **App name**: Pango
   - **Short description** (80 chars):
     ```
     Find and book amazing accommodations across Tanzania. Easy, fast, secure.
     ```
   
   - **Full description** (copy from `PLAY_STORE_LISTING_CONTENT.md`):
     ```
     🏠 Pango - Your Gateway to Tanzanian Accommodations

     Find your perfect home away from home in Tanzania! Whether you're 
     planning a business trip to Dar es Salaam, a safari adventure in 
     Arusha, or a beach getaway in Zanzibar, Pango connects you with 
     verified hosts offering quality accommodations.

     ✨ KEY FEATURES...
     (Full text in PLAY_STORE_LISTING_CONTENT.md)
     ```

3. **Graphics** (Upload):
   - **App icon**: Upload your 512x512 logo (export from pango.png)
   - **Feature graphic**: Upload 1024x500 banner (can create later)
   - **Screenshots**: Upload your 4 screenshots (1.png, 2.png, 3.png, 4.png)

4. **Categorization**:
   - **App category**: Travel & Local
   - **Tags**: accommodation, booking, tanzania, travel

5. **Contact details**:
   - **Email**: Your support email
   - **Phone** (optional): Your number
   - **Website** (optional): Your website

6. Click **"Save"**

---

#### **B. Content Rating** (5 minutes)

1. Click **"Content rating"** in left menu
2. Click **"Start questionnaire"**
3. Select **"All other apps"** category
4. Answer questions:
   - Violence: No
   - Sexual content: No
   - Profanity: No
   - User-generated content: Yes (users can create listings)
   - Location sharing: Yes (for maps)
5. Get your rating (likely: Everyone or Teen)
6. Click **"Save"**

---

#### **C. Target Audience** (3 minutes)

1. Click **"Target audience"** in left menu
2. **Target age**: `13 years and older`
3. **Age appeal**: `All ages`
4. Click **"Save"**

---

#### **D. Data Safety** (10 minutes)

1. Click **"Data safety"** in left menu
2. Click **"Start"**
3. Declare data collected:
   
   **Location data**:
   - ✅ Approximate location
   - ✅ Precise location
   - Purpose: Show properties on map
   - Optional: No (required for maps)
   
   **Personal info**:
   - ✅ Name
   - ✅ Email address
   - ✅ Phone number
   - Purpose: User account & bookings
   - Optional: No (required)
   
   **Photos**:
   - ✅ Photos
   - Purpose: Profile & property listings
   - Optional: Yes
   
   **App activity**:
   - ✅ Search history
   - ✅ App interactions
   - Purpose: Improve experience
   
   **Security practices**:
   - ✅ Data encrypted in transit
   - ✅ Users can request deletion
   - ✅ Committed to Play Families Policy

4. Click **"Save"**

---

#### **E. Privacy Policy** (REQUIRED!)

1. Click **"App content"** → **"Privacy policy"**
2. Enter your privacy policy URL
   - **You MUST publish a privacy policy first!**
   - Can use: GitHub Pages, Google Sites, your website
   - Template in `PLAY_STORE_LISTING_CONTENT.md`

**Quick Privacy Policy Options:**

**Option 1: Use Generator (5 mins)**
- Go to: https://app-privacy-policy-generator.nisrulz.com/
- Fill in app details
- Generate policy
- Host on GitHub Pages (free)

**Option 2: Google Sites (10 mins)**
- Go to: https://sites.google.com/new
- Create new site
- Paste privacy policy
- Publish
- Copy URL

**Option 3: Use Template**
- Copy template from `PLAY_STORE_LISTING_CONTENT.md`
- Host anywhere public
- Must be HTTPS

---

#### **F. App Access** (2 minutes)

1. Click **"App access"**
2. Select **"All functionality is available without special access"**
3. Click **"Save"**

---

#### **G. Ads** (1 minute)

1. Click **"Ads"**
2. Select **"No, my app does not contain ads"**
3. Click **"Save"**

---

### **Step 4: Upload Your App** (5 minutes)

1. **Go to**: Production → Releases

2. Click **"Create new release"**

3. **Choose signing**:
   - Select **"Google Play App Signing"** (Recommended)
   - Google will manage your keys

4. **Upload AAB**:
   - Click "Upload"
   - Select your file: `mobile/build/app/outputs/bundle/release/app-release.aab`
   - Wait for upload

5. **Release name**: `1.0.0 - Initial Release`

6. **Release notes** (copy this):
   ```
   🎉 Welcome to Pango!

   First release with:
   • Browse and search accommodations across Tanzania
   • Interactive map view with location-based search
   • Secure booking and payment system
   • Multiple payment methods (M-Pesa, Tigo Pesa, Airtel Money, Cards)
   • User profiles and booking management
   • Available in English and Swahili

   Thank you for using Pango!
   ```

7. Click **"Save"**

---

### **Step 5: Review and Submit** (5 minutes)

1. **Review all sections** - Make sure all have green checkmarks

2. **Send for Review**:
   - Click **"Send for review"** button
   - Confirm submission

3. **Wait for Review**:
   - Takes 2-7 days (usually 2-3 days)
   - You'll get email updates
   - Can track status in Play Console

---

## ✅ **Complete Checklist**

Before submitting, make sure you have:

- [ ] Play Console account created ($25 paid)
- [ ] App created in console
- [ ] Store listing filled (name, descriptions, screenshots)
- [ ] Content rating completed
- [ ] Target audience set
- [ ] Data safety declared
- [ ] Privacy policy URL added
- [ ] App access configured
- [ ] Ads declaration done
- [ ] AAB file uploaded
- [ ] Release notes written

---

## 📞 **Important Links**

- **Play Console**: https://play.google.com/console
- **Help Center**: https://support.google.com/googleplay/android-developer
- **Policy Center**: https://play.google.com/about/developer-content-policy/
- **Privacy Policy Generator**: https://app-privacy-policy-generator.nisrulz.com/

---

## 🎉 **You're Almost There!**

1. ✅ Screenshots ready
2. ✅ App icons ready
3. ⏳ AAB building (should complete soon)
4. 📝 Next: Create Play Console account

**Start by going to**: https://play.google.com/console

**Follow the steps above and you'll have your app submitted today!** 🚀

---

## 🆘 **If You Get Stuck**

- Check **PLAY_STORE_DEPLOYMENT.md** for detailed help
- Check **PLAY_STORE_LISTING_CONTENT.md** for content to copy
- Google has great support documentation
- Play Console has help tooltips everywhere

**Good luck! You're so close to launching! 🎊**











