const mongoose = require('mongoose');
const Listing = require('../src/models/Listing');
const User = require('../src/models/User');
require('dotenv').config();

// Clean, ZenoPay-optimized listings
const cleanListings = [
  {
    title: {
      en: 'Modern Apartment in Dar es Salaam',
      sw: 'Ghorofa ya Kisasa Dar es Salaam'
    },
    description: {
      en: 'Beautiful modern apartment in the heart of Dar es Salaam. Perfect for business travelers and tourists. Close to shops, restaurants, and business district.',
      sw: 'Ghorofa ya kisasa na nzuri katikati ya Dar es Salaam. Kamili kwa wasafiri wa biashara na watalii. Karibu na maduka, mikahawa, na eneo la biashara.'
    },
    propertyType: 'apartment',
    location: {
      address: 'Slipway Road, Msasani Peninsula',
      region: 'Dar es Salaam',
      city: 'Dar es Salaam',
      district: 'Kinondoni',
      coordinates: {
        type: 'Point',
        coordinates: [39.2694, -6.7700]
      },
      nearbyLandmarks: ['Slipway Shopping Center', 'Coco Beach', 'Sea Cliff Hotel']
    },
    pricing: {
      basePrice: 150000,
      currency: 'TZS',
      weeklyDiscount: 10,
      monthlyDiscount: 20,
      cleaningFee: 25000,
      securityDeposit: 50000
    },
    capacity: {
      guests: 4,
      bedrooms: 2,
      beds: 2,
      bathrooms: 2
    },
    amenities: ['wifi', 'air_conditioning', 'kitchen', 'tv', 'parking', 'security', 'workspace'],
    images: [
      { url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', caption: 'Modern Living Room', order: 0 },
      { url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800', caption: 'Bedroom', order: 1 },
      { url: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800', caption: 'City View', order: 2 }
    ],
    houseRules: {
      checkIn: '15:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'No pets', 'Quiet hours: 10 PM - 7 AM'],
        sw: ['Usivute', 'Hakuna wanyama wa kipenzi', 'Wakati wa kimya: 10 PM - 7 AM']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 1,
      maxNights: 30
    },
    status: 'active',
    isFeatured: true
  },
  {
    title: {
      en: 'Luxury Villa in Zanzibar',
      sw: 'Villa ya Kifahari Zanzibar'
    },
    description: {
      en: 'Stunning beachfront villa with private pool and modern amenities. Perfect for families and groups looking for a luxurious getaway in Zanzibar.',
      sw: 'Villa ya ajabu ya pwani yenye bwawa la kibinafsi na vifaa vya kisasa. Kamili kwa familia na vikundi vinavyotafuta likizo ya kifahari Zanzibar.'
    },
    propertyType: 'villa',
    location: {
      address: 'Nungwi Beach, North Coast',
      region: 'Zanzibar',
      city: 'Nungwi',
      district: 'Kaskazini A',
      coordinates: {
        type: 'Point',
        coordinates: [39.2875, -5.7247]
      },
      nearbyLandmarks: ['Nungwi Beach', 'Mnarani Aquarium', 'Kendwa Beach']
    },
    pricing: {
      basePrice: 400000,
      currency: 'TZS',
      weeklyDiscount: 15,
      monthlyDiscount: 25,
      cleaningFee: 75000,
      securityDeposit: 150000
    },
    capacity: {
      guests: 8,
      bedrooms: 4,
      beds: 5,
      bathrooms: 3
    },
    amenities: ['wifi', 'pool', 'air_conditioning', 'kitchen', 'tv', 'parking', 'security', 'washer', 'workspace', 'breakfast'],
    images: [
      { url: 'https://images.unsplash.com/photo-1602343168117-bb8ffe3e2e9f?w=800', caption: 'Beachfront View', order: 0 },
      { url: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800', caption: 'Living Room', order: 1 },
      { url: 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800', caption: 'Pool Area', order: 2 }
    ],
    houseRules: {
      checkIn: '14:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking indoors', 'No parties or events', 'Pets allowed with prior approval'],
        sw: ['Usivute ndani', 'Hakuna sherehe au matukio', 'Wanyama wa kipenzi wanaruhusiwa baada ya kibali']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 2,
      maxNights: 30
    },
    status: 'active',
    isFeatured: true
  },
  {
    title: {
      en: 'Cozy Studio in Arusha',
      sw: 'Studio ya Starehe Arusha'
    },
    description: {
      en: 'Perfect studio apartment for solo travelers and couples. Close to Arusha National Park and Mount Meru. Ideal base for safari adventures.',
      sw: 'Studio kamili kwa wasafiri peke yao na wapendanao. Karibu na Mbuga ya Taifa ya Arusha na Mlima Meru. Mahali pazuri kwa safari za kutazama wanyama.'
    },
    propertyType: 'studio',
    location: {
      address: 'Ngongongare, Arusha',
      region: 'Arusha',
      city: 'Arusha',
      district: 'Arusha',
      coordinates: {
        type: 'Point',
        coordinates: [36.7500, -3.3500]
      },
      nearbyLandmarks: ['Arusha National Park', 'Mount Meru', 'Momella Lakes']
    },
    pricing: {
      basePrice: 80000,
      currency: 'TZS',
      weeklyDiscount: 12,
      monthlyDiscount: 25,
      cleaningFee: 15000
    },
    capacity: {
      guests: 2,
      bedrooms: 1,
      beds: 1,
      bathrooms: 1
    },
    amenities: ['wifi', 'kitchen', 'parking', 'workspace', 'mosquito_nets'],
    images: [
      { url: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800', caption: 'Studio Interior', order: 0 },
      { url: 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800', caption: 'Mountain View', order: 1 },
      { url: 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800', caption: 'Kitchen Area', order: 2 }
    ],
    houseRules: {
      checkIn: '14:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'Perfect for remote work', 'Quiet hours: 9 PM - 7 AM'],
        sw: ['Usivute', 'Kamili kwa kazi za mbali', 'Wakati wa kimya: 9 PM - 7 AM']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 1,
      maxNights: 14
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Family House in Dodoma',
      sw: 'Nyumba ya Familia Dodoma'
    },
    description: {
      en: 'Spacious family home in Tanzania\'s capital city. Close to government offices and city center. Perfect for long stays and families.',
      sw: 'Nyumba kubwa ya familia katika mji mkuu wa Tanzania. Karibu na ofisi za serikali na kituo cha jiji. Kamili kwa kukaa kwa muda mrefu na familia.'
    },
    propertyType: 'house',
    location: {
      address: 'Makole, Dodoma City',
      region: 'Dodoma',
      city: 'Dodoma',
      district: 'Dodoma Urban',
      coordinates: {
        type: 'Point',
        coordinates: [35.7516, -6.1630]
      },
      nearbyLandmarks: ['Parliament Building', 'Dodoma Cathedral', 'Central Market']
    },
    pricing: {
      basePrice: 120000,
      currency: 'TZS',
      weeklyDiscount: 10,
      monthlyDiscount: 20,
      cleaningFee: 30000
    },
    capacity: {
      guests: 6,
      bedrooms: 3,
      beds: 4,
      bathrooms: 2
    },
    amenities: ['wifi', 'kitchen', 'parking', 'security', 'workspace', 'family_friendly', 'air_conditioning'],
    images: [
      { url: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800', caption: 'House Front', order: 0 },
      { url: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800', caption: 'Living Area', order: 1 },
      { url: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', caption: 'Bedroom', order: 2 }
    ],
    houseRules: {
      checkIn: '14:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'Family friendly', 'Quiet neighborhood'],
        sw: ['Usivute', 'Rafiki kwa familia', 'Mtaa wa kimya']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 2,
      maxNights: 60
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Beach Bungalow in Tanga',
      sw: 'Bungalow ya Pwani Tanga'
    },
    description: {
      en: 'Charming beachside bungalow perfect for a romantic getaway. Steps from the Indian Ocean with stunning sunrises and peaceful atmosphere.',
      sw: 'Bungalow ya kupendeza kando ya pwani kamili kwa likizo ya kipenzi. Hatua chache kutoka Bahari ya Hindi na macheo ya kupendeza na mazingira ya amani.'
    },
    propertyType: 'bungalow',
    location: {
      address: 'Pangani Beach Road, Tanga',
      region: 'Tanga',
      city: 'Tanga',
      district: 'Tanga Urban',
      coordinates: {
        type: 'Point',
        coordinates: [39.0989, -5.0689]
      },
      nearbyLandmarks: ['Tanga Beach', 'Amboni Caves', 'Tongoni Ruins']
    },
    pricing: {
      basePrice: 100000,
      currency: 'TZS',
      weeklyDiscount: 8,
      monthlyDiscount: 15,
      cleaningFee: 20000
    },
    capacity: {
      guests: 4,
      bedrooms: 2,
      beds: 2,
      bathrooms: 1
    },
    amenities: ['wifi', 'kitchen', 'parking', 'breakfast', 'mosquito_nets', 'family_friendly'],
    images: [
      { url: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800', caption: 'Bungalow Exterior', order: 0 },
      { url: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800', caption: 'Beach View', order: 1 },
      { url: 'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800', caption: 'Interior', order: 2 }
    ],
    houseRules: {
      checkIn: '13:00',
      checkOut: '10:00',
      customRules: {
        en: ['No smoking', 'Beach cleanup encouraged', 'Respect local culture'],
        sw: ['Usivute', 'Kusafisha pwani kunashauriwa', 'Heshimu utamaduni wa hapa']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 2,
      maxNights: 14
    },
    status: 'active',
    isFeatured: true
  }
];

async function seedCleanListings() {
  try {
    console.log('🚀 Starting clean listings seeding for ZenoPay integration...');
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find or create a host user
    let host = await User.findOne({ role: 'host' });
    
    if (!host) {
      // If no host exists, find any user and update their role to host
      host = await User.findOne();
      if (host) {
        host.role = 'host';
        await host.save();
        console.log(`✅ Updated user ${host.email} to host role`);
      } else {
        console.log('❌ No users found! Please register a user first.');
        process.exit(1);
      }
    }

    console.log(`\n📝 Using host: ${host.email} (${host._id})`);

    // Delete ALL existing listings to start fresh
    const deletedCount = await Listing.deleteMany({});
    console.log(`🗑️  Deleted ${deletedCount.deletedCount} existing listings`);

    // Add hostId to all clean listings
    const listingsWithHost = cleanListings.map(listing => ({
      ...listing,
      hostId: host._id  // Ensure every listing has a valid hostId
    }));

    // Insert clean listings
    const created = await Listing.insertMany(listingsWithHost);
    console.log(`\n✅ Created ${created.length} clean listings optimized for ZenoPay:`);
    
    created.forEach((listing, index) => {
      console.log(`   ${index + 1}. ${listing.title.en} (${listing.propertyType})`);
      console.log(`      Location: ${listing.location.city}, ${listing.location.region}`);
      console.log(`      Price: ${listing.pricing.basePrice.toLocaleString()} TZS/night`);
      console.log(`      Host ID: ${listing.hostId}`);
      console.log(`      Status: ${listing.status}${listing.isFeatured ? ' ⭐ Featured' : ''}`);
    });

    console.log('\n🎉 Clean listings created successfully!');
    console.log('\n✨ ZenoPay Integration Ready:');
    console.log('  - All listings have valid hostId values');
    console.log('  - Optimized pricing for mobile money payments');
    console.log('  - Clean data structure for booking creation');
    console.log('  - Ready for ZenoPay payment processing\n');

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error seeding clean listings:', error);
    process.exit(1);
  }
}

// Run the clean seeder
seedCleanListings();
