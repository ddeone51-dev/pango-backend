const mongoose = require('mongoose');
const Listing = require('../src/models/Listing');
const User = require('../src/models/User');
require('dotenv').config();

const sampleListings = [
  {
    title: {
      en: 'Luxury Beachfront Villa in Zanzibar',
      sw: 'Villa ya Kifahari Pwani ya Zanzibar'
    },
    description: {
      en: 'Experience paradise in this stunning beachfront villa with private pool, modern amenities, and breathtaking ocean views. Perfect for families and groups looking for a luxurious getaway.',
      sw: 'Furahia peponi katika villa hii ya ajabu ya pwani yenye bwawa la kibinafsi, vifaa vya kisasa, na mandhari ya bahari ya kushangaza. Kamili kwa familia na vikundi vinavyotafuta likizo ya kifahari.'
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
      basePrice: 350000,
      currency: 'TZS',
      weeklyDiscount: 10,
      monthlyDiscount: 20,
      cleaningFee: 50000,
      securityDeposit: 100000
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
      en: 'Modern Apartment in Dar es Salaam City Center',
      sw: 'Ghorofa ya Kisasa Katikati ya Jiji la Dar es Salaam'
    },
    description: {
      en: 'Stylish and modern apartment in the heart of Dar es Salaam. Close to shops, restaurants, and business district. Ideal for business travelers and tourists.',
      sw: 'Ghorofa ya kisasa na ya kuvutia katikati ya Dar es Salaam. Karibu na maduka, mikahawa, na eneo la biashara. Bora kwa wasafiri wa biashara na watalii.'
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
      basePrice: 120000,
      currency: 'TZS',
      weeklyDiscount: 5,
      monthlyDiscount: 15,
      cleaningFee: 20000
    },
    capacity: {
      guests: 3,
      bedrooms: 2,
      beds: 2,
      bathrooms: 1
    },
    amenities: ['wifi', 'air_conditioning', 'kitchen', 'tv', 'parking', 'security', 'workspace'],
    images: [
      { url: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', caption: 'Modern Living Room', order: 0 },
      { url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800', caption: 'Bedroom', order: 1 },
      { url: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800', caption: 'City View', order: 2 }
    ],
    houseRules: {
      checkIn: '15:00',
      checkOut: '10:00',
      customRules: {
        en: ['No smoking', 'No pets', 'Quiet hours: 10 PM - 7 AM'],
        sw: ['Usivute', 'Hakuna wanyama wa kipenzi', 'Wakati wa kimya: 10 PM - 7 AM']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 1,
      maxNights: 90
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Cozy Cottage near Mount Kilimanjaro',
      sw: 'Nyumba Ndogo ya Starehe Karibu na Mlima Kilimanjaro'
    },
    description: {
      en: 'Charming cottage with stunning views of Mount Kilimanjaro. Perfect base for hiking and exploring the region. Peaceful and relaxing atmosphere.',
      sw: 'Nyumba ndogo yenye mandhari ya kupendeza ya Mlima Kilimanjaro. Mahali pazuri kwa kupanda mlima na kuchunguza eneo. Mazingira ya amani na utulivu.'
    },
    propertyType: 'cottage',
    location: {
      address: 'Moshi Rural, Kilimanjaro Region',
      region: 'Kilimanjaro',
      city: 'Moshi',
      district: 'Moshi Rural',
      coordinates: {
        type: 'Point',
        coordinates: [37.3516, -3.3869]
      },
      nearbyLandmarks: ['Mount Kilimanjaro', 'Moshi Town', 'Coffee Plantations']
    },
    pricing: {
      basePrice: 80000,
      currency: 'TZS',
      weeklyDiscount: 8,
      monthlyDiscount: 18,
      cleaningFee: 15000
    },
    capacity: {
      guests: 4,
      bedrooms: 2,
      beds: 3,
      bathrooms: 1
    },
    amenities: ['wifi', 'kitchen', 'parking', 'workspace', 'family_friendly', 'mosquito_nets'],
    images: [
      { url: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=800', caption: 'Cottage Exterior', order: 0 },
      { url: 'https://images.unsplash.com/photo-1587381420270-3e1a5b9e6904?w=800', caption: 'Mountain View', order: 1 },
      { url: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800', caption: 'Interior', order: 2 }
    ],
    houseRules: {
      checkIn: '14:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'Pets welcome', 'Respect nature and wildlife'],
        sw: ['Usivute', 'Wanyama wa kipenzi wanakaribish wa', 'Heshimu asili na wanyamapori']
      }
    },
    availability: {
      instantBooking: false,
      minNights: 2,
      maxNights: 14
    },
    status: 'active',
    isFeatured: true
  },
  {
    title: {
      en: 'Lakeside Guesthouse in Mwanza',
      sw: 'Nyumba ya Wageni Kando ya Ziwa Mwanza'
    },
    description: {
      en: 'Beautiful guesthouse on the shores of Lake Victoria. Enjoy fishing, boat rides, and spectacular sunsets. Comfortable and welcoming environment.',
      sw: 'Nyumba nzuri ya wageni ukingoni mwa Ziwa Victoria. Furahia uvuvi, safari za mashua, na macheo ya kupendeza. Mazingira ya starehe na kukaribisha.'
    },
    propertyType: 'guesthouse',
    location: {
      address: 'Capri Point, Lake Victoria',
      region: 'Mwanza',
      city: 'Mwanza',
      district: 'Ilemela',
      coordinates: {
        type: 'Point',
        coordinates: [32.9175, -2.5164]
      },
      nearbyLandmarks: ['Lake Victoria', 'Bismarck Rock', 'Mwanza City Center']
    },
    pricing: {
      basePrice: 95000,
      currency: 'TZS',
      weeklyDiscount: 7,
      monthlyDiscount: 15,
      cleaningFee: 18000
    },
    capacity: {
      guests: 5,
      bedrooms: 3,
      beds: 4,
      bathrooms: 2
    },
    amenities: ['wifi', 'kitchen', 'parking', 'security', 'family_friendly', 'breakfast', 'mosquito_nets'],
    images: [
      { url: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800', caption: 'Lakeside View', order: 0 },
      { url: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800', caption: 'Guest Room', order: 1 },
      { url: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800', caption: 'Dining Area', order: 2 }
    ],
    houseRules: {
      checkIn: '13:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'Family friendly', 'Keep noise to minimum'],
        sw: ['Usivute', 'Rafiki kwa familia', 'Punguza kelele']
      }
    },
    availability: {
      instantBooking: true,
      minNights: 1,
      maxNights: 21
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Safari Lodge in Arusha National Park',
      sw: 'Lodge ya Safari Mbuga ya Taifa ya Arusha'
    },
    description: {
      en: 'Unique safari experience in a comfortable lodge near Arusha National Park. Wake up to wildlife sounds and enjoy game drives. Unforgettable adventure.',
      sw: 'Uzoefu wa kipekee wa safari katika lodge ya starehe karibu na Mbuga ya Taifa ya Arusha. Amka na sauti za wanyamapori na furahia safari za kuona wanyama. Tukio lisilosahaului.'
    },
    propertyType: 'resort',
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
      basePrice: 250000,
      currency: 'TZS',
      weeklyDiscount: 12,
      monthlyDiscount: 25,
      cleaningFee: 30000
    },
    capacity: {
      guests: 6,
      bedrooms: 3,
      beds: 4,
      bathrooms: 2
    },
    amenities: ['wifi', 'parking', 'security', 'breakfast', 'family_friendly', 'mosquito_nets', 'workspace'],
    images: [
      { url: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=800', caption: 'Safari Lodge', order: 0 },
      { url: 'https://images.unsplash.com/photo-1580041065738-e72023775cdc?w=800', caption: 'Wildlife View', order: 1 },
      { url: 'https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=800', caption: 'Lodge Interior', order: 2 }
    ],
    houseRules: {
      checkIn: '12:00',
      checkOut: '10:00',
      customRules: {
        en: ['No smoking', 'Respect wildlife', 'Follow safari guide instructions'],
        sw: ['Usivute', 'Heshimu wanyamapori', 'Fuata maelekezo ya kiongozi wa safari']
      }
    },
    availability: {
      instantBooking: false,
      minNights: 3,
      maxNights: 14
    },
    status: 'active',
    isFeatured: true
  },
  {
    title: {
      en: 'Spacious Family House in Dodoma',
      sw: 'Nyumba Kubwa ya Familia Dodoma'
    },
    description: {
      en: 'Large family home in Tanzania\'s capital city. Close to government offices and city center. Perfect for long stays and families visiting the capital.',
      sw: 'Nyumba kubwa ya familia katika mji mkuu wa Tanzania. Karibu na ofisi za serikali na kituo cha jiji. Bora kwa kukaa kwa muda mrefu na familia zinazote mula mji mkuu.'
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
      basePrice: 110000,
      currency: 'TZS',
      weeklyDiscount: 10,
      monthlyDiscount: 20,
      cleaningFee: 25000
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
      en: 'Beachside Bungalow in Tanga',
      sw: 'Bungalow ya Pwani Tanga'
    },
    description: {
      en: 'Charming beachside bungalow perfect for a romantic getaway or small family vacation. Steps from the Indian Ocean with stunning sunrises.',
      sw: 'Bungalow ya kupendeza kando ya pwani kamili kwa likizo ya kipenzi au familia ndogo. Hatua chache kutoka Bahari ya Hindi na macheo ya kupendeza.'
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
      basePrice: 135000,
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
  },
  {
    title: {
      en: 'Mountain View Studio in Mbeya',
      sw: 'Studio ya Mlima Mbeya'
    },
    description: {
      en: 'Cozy studio apartment with spectacular mountain views. Ideal for solo travelers and couples. Cool highland climate year-round.',
      sw: 'Studio ya starehe yenye mandhari ya milima. Bora kwa wasafiri peke yao na wapendanao. Hali ya hewa ya juu baridi mwaka mzima.'
    },
    propertyType: 'studio',
    location: {
      address: 'Mbalizi Road, Mbeya',
      region: 'Mbeya',
      city: 'Mbeya',
      district: 'Mbeya Urban',
      coordinates: {
        type: 'Point',
        coordinates: [33.4617, -8.9094]
      },
      nearbyLandmarks: ['Mbeya Peak', 'Lake Ngozi', 'Kitulo National Park']
    },
    pricing: {
      basePrice: 65000,
      currency: 'TZS',
      weeklyDiscount: 12,
      monthlyDiscount: 25,
      cleaningFee: 10000
    },
    capacity: {
      guests: 2,
      bedrooms: 1,
      beds: 1,
      bathrooms: 1
    },
    amenities: ['wifi', 'kitchen', 'parking', 'workspace', 'heating', 'mosquito_nets'],
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
      maxNights: 90
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Riverside Retreat in Morogoro',
      sw: 'Makao ya Pumziko Kando ya Mto Morogoro'
    },
    description: {
      en: 'Peaceful riverside property surrounded by nature. Perfect for bird watching and nature lovers. Close to Uluguru Mountains.',
      sw: 'Mali ya amani kando ya mto ikiwa na mazingira ya asili. Kamili kwa kutazama ndege na wapenda asili. Karibu na Milima ya Uluguru.'
    },
    propertyType: 'cottage',
    location: {
      address: 'Bigwa, Morogoro Rural',
      region: 'Morogoro',
      city: 'Morogoro',
      district: 'Morogoro Rural',
      coordinates: {
        type: 'Point',
        coordinates: [37.6633, -6.8212]
      },
      nearbyLandmarks: ['Uluguru Mountains', 'Mikumi National Park', 'Morogoro Town']
    },
    pricing: {
      basePrice: 90000,
      currency: 'TZS',
      weeklyDiscount: 10,
      monthlyDiscount: 20,
      cleaningFee: 15000
    },
    capacity: {
      guests: 5,
      bedrooms: 2,
      beds: 3,
      bathrooms: 2
    },
    amenities: ['wifi', 'kitchen', 'parking', 'family_friendly', 'mosquito_nets', 'pet_friendly'],
    images: [
      { url: 'https://images.unsplash.com/photo-1570213489059-0aac6626cade?w=800', caption: 'Riverside View', order: 0 },
      { url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800', caption: 'Nature Surroundings', order: 1 },
      { url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800', caption: 'Living Space', order: 2 }
    ],
    houseRules: {
      checkIn: '13:00',
      checkOut: '11:00',
      customRules: {
        en: ['No smoking', 'Pets welcome', 'Respect nature and wildlife'],
        sw: ['Usivute', 'Wanyama wanakaribish wa', 'Heshimu asili na wanyamapori']
      }
    },
    availability: {
      instantBooking: false,
      minNights: 2,
      maxNights: 21
    },
    status: 'active',
    isFeatured: false
  },
  {
    title: {
      en: 'Coastal Resort in Pwani Region',
      sw: 'Resort ya Pwani Mkoa wa Pwani'
    },
    description: {
      en: 'Luxurious coastal resort with private beach access. All-inclusive amenities including restaurant and spa services. Perfect for honeymoons.',
      sw: 'Resort ya kifahari ya pwani na ufikiaji wa pwani binafsi. Huduma zote pamoja na mkahawa na spa. Kamili kwa arusi mpya.'
    },
    propertyType: 'resort',
    location: {
      address: 'Bagamoyo Beach, Pwani',
      region: 'Pwani',
      city: 'Bagamoyo',
      district: 'Bagamoyo',
      coordinates: {
        type: 'Point',
        coordinates: [38.9033, -6.4423]
      },
      nearbyLandmarks: ['Bagamoyo Historical Town', 'Kaole Ruins', 'Marine Reserve']
    },
    pricing: {
      basePrice: 280000,
      currency: 'TZS',
      weeklyDiscount: 15,
      monthlyDiscount: 30,
      cleaningFee: 40000,
      securityDeposit: 150000
    },
    capacity: {
      guests: 4,
      bedrooms: 2,
      beds: 2,
      bathrooms: 2
    },
    amenities: ['wifi', 'pool', 'air_conditioning', 'kitchen', 'tv', 'parking', 'security', 'breakfast', 'gym', 'workspace'],
    images: [
      { url: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800', caption: 'Resort View', order: 0 },
      { url: 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800', caption: 'Private Beach', order: 1 },
      { url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800', caption: 'Pool Area', order: 2 }
    ],
    houseRules: {
      checkIn: '14:00',
      checkOut: '12:00',
      customRules: {
        en: ['No smoking', 'Adults only preferred', 'Spa services available'],
        sw: ['Usivute', 'Watu wazima wanapendelewa', 'Huduma za spa zinapatikana']
      }
    },
    availability: {
      instantBooking: false,
      minNights: 3,
      maxNights: 21
    },
    status: 'active',
    isFeatured: true
  }
];

async function seedListings() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find a user to use as host (preferably one with host role)
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

    // Delete existing listings to avoid duplicates
    const deletedCount = await Listing.deleteMany({});
    console.log(`🗑️  Deleted ${deletedCount.deletedCount} existing listings`);

    // Add hostId to all sample listings
    const listingsWithHost = sampleListings.map(listing => ({
      ...listing,
      hostId: host._id
    }));

    // Insert sample listings
    const created = await Listing.insertMany(listingsWithHost);
    console.log(`\n✅ Created ${created.length} sample listings across Tanzania:`);
    
    created.forEach((listing, index) => {
      console.log(`   ${index + 1}. ${listing.title.en} (${listing.propertyType})`);
      console.log(`      Location: ${listing.location.city}, ${listing.location.region}`);
      console.log(`      Price: ${listing.pricing.basePrice.toLocaleString()} TZS/night`);
      console.log(`      Status: ${listing.status}${listing.isFeatured ? ' ⭐ Featured' : ''}`);
    });

    console.log('\n🎉 Sample listings created successfully!');
    console.log('\nYou can now:');
    console.log('  - Browse listings in your mobile app');
    console.log('  - View listing details');
    console.log('  - Create bookings');
    console.log('  - Test search and filters\n');

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error seeding listings:', error);
    process.exit(1);
  }
}

// Run the seeder
seedListings();

