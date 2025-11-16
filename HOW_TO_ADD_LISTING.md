# How to Add Your Own Listing to Pango

## 📋 Prerequisites

Your user account must have the **"host"** role to add listings.

---

## 🔧 Quick Setup

### Option 1: Update Your Existing User to Host

Run this script to make yourself a host:

```javascript
// Run in backend directory: node scripts/makeHost.js
const mongoose = require('mongoose');
const User = require('../src/models/User');
require('dotenv').config();

async function makeHost() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
    
    // Update the user - change email to your actual email
    const email = 'techlandtz@gmail.com'; // CHANGE THIS to your email
    
    const user = await User.findOne({ email });
    
    if (!user) {
      console.log(`User with email ${email} not found`);
      process.exit(1);
    }
    
    user.role = 'host';
    await user.save();
    
    console.log(`✅ User ${email} is now a HOST!`);
    console.log(`User ID: ${user._id}`);
    
    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

makeHost();
```

---

## 📱 How to Add a Listing in the App

### Step 1: Navigate to Host Dashboard

1. Open the Pango app
2. Go to **Profile** tab (bottom navigation)
3. Look for **"Host Dashboard"** button
4. Tap on it

### Step 2: Add New Listing

1. In the Host Dashboard, tap **"Add Listing"**
2. Fill in the form with your property details

### Step 3: Fill Out Property Information

#### 🏠 Property Information
- **Property Type**: Choose from apartment, house, villa, cottage, etc.
- **Title (English)**: e.g., "Beautiful 2BR Apartment in Dar es Salaam"
- **Title (Swahili)**: e.g., "Ghorofa Nzuri ya Vyumba 2 Dar es Salaam"
- **Description (English)**: Detailed description of your property
- **Description (Swahili)**: Maelezo kamili ya mali yako

#### 📍 Location
- **Region**: Select from dropdown (Dar es Salaam, Zanzibar, etc.)
- **City**: e.g., "Dar es Salaam"
- **Address**: e.g., "Masaki Peninsula"
- **District**: e.g., "Kinondoni"

#### 💰 Pricing
- **Price per Night**: e.g., "150000" (TZS)
- **Cleaning Fee** (optional): e.g., "20000" (TZS)

#### 🛏️ Capacity
- **Guests**: e.g., "4"
- **Bedrooms**: e.g., "2"
- **Beds**: e.g., "2"
- **Bathrooms**: e.g., "1"

#### ✨ Amenities
Select what your property has:
- WiFi
- Parking
- Kitchen
- Air Conditioning
- TV
- Pool
- Gym
- Security
- Breakfast

#### 📸 Photos
Paste image URLs (you can use Unsplash for free images):
- **Image 1**: e.g., `https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800`
- **Image 2**: (optional)
- **Image 3**: (optional)

**Tip**: Search on [Unsplash](https://unsplash.com/) for images, right-click on an image, and copy the URL.

### Step 4: Submit

1. Review all information
2. Tap **"Create Listing"** button
3. Wait for confirmation
4. You should see "✅ Listing created successfully!"

---

## 🎯 Example Listing Data

```
Property Type: apartment
Title (EN): Modern 2BR Apartment in Masaki
Title (SW): Ghorofa ya Kisasa ya Vyumba 2 Masaki

Description (EN): Beautiful modern apartment in the heart of Masaki. Walking distance to Slipway, restaurants, and the beach. Perfect for business travelers and tourists.

Description (SW): Ghorofa nzuri ya kisasa katikati ya Masaki. Umbali wa kutembea hadi Slipway, mikahawa, na pwani. Bora kwa wasafiri wa biashara na watalii.

Region: Dar es Salaam
City: Dar es Salaam
Address: Peninsula Drive, Masaki
District: Kinondoni

Price per Night: 120000 TZS
Cleaning Fee: 20000 TZS

Guests: 3
Bedrooms: 2
Beds: 2
Bathrooms: 1

Amenities: wifi, parking, kitchen, air_conditioning, security

Image 1: https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800
Image 2: https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800
Image 3: https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800
```

---

## ✅ After Creating a Listing

Your listing will:
- ✅ Be saved to the database
- ✅ Appear in the home screen listings
- ✅ Be searchable by other users
- ✅ Show up in your "My Listings" (Host Dashboard)

---

## 🔍 Troubleshooting

### "I don't see Host Dashboard"
- Make sure your user role is "host"
- Logout and login again
- Check with backend script above

### "Create Listing" button doesn't work
- Check all required fields (marked with *)
- Make sure price is a number (no commas)
- Make sure guests/bedrooms/beds/bathrooms are numbers
- Make sure at least one image URL is provided

### "Failed to create listing"
- Check backend is running (`npm run dev` in backend folder)
- Check your network connection
- Look at the error message for details

---

## 📞 Need Help?

- Check backend logs: `backend/logs/combined.log`
- Check backend errors: `backend/logs/error.log`
- Ensure backend is running on port 3000

---

**Happy Hosting! 🏠**
























