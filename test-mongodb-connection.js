// MongoDB Connection Test Script
// Run this locally to test your MongoDB Atlas connection

const mongoose = require('mongoose');

// Test connection function
async function testMongoConnection() {
    console.log('🔍 Testing MongoDB Atlas Connection...\n');
    
    // Your MongoDB Atlas connection string (replace with your actual string)
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://ddeone51:your-password@cluster0.xxxxx.mongodb.net/pango?retryWrites=true&w=majority';
    
    console.log('📡 Connection String:', mongoUri.replace(/\/\/[^:]+:[^@]+@/, '//***:***@')); // Hide credentials
    
    try {
        console.log('⏳ Connecting to MongoDB Atlas...');
        
        // Connection options
        const options = {
            serverSelectionTimeoutMS: 10000, // 10 seconds
            connectTimeoutMS: 10000,
            socketTimeoutMS: 10000,
            maxPoolSize: 10,
            bufferMaxEntries: 0,
            useNewUrlParser: true,
            useUnifiedTopology: true,
        };
        
        await mongoose.connect(mongoUri, options);
        console.log('✅ SUCCESS: Connected to MongoDB Atlas!');
        
        // Test a simple query
        console.log('🧪 Testing database query...');
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log('📊 Collections found:', collections.length);
        
        // Test listings collection
        const Listings = mongoose.model('Listing', new mongoose.Schema({}, { strict: false }));
        const count = await Listings.countDocuments();
        console.log('📋 Total listings:', count);
        
        console.log('\n🎉 MongoDB Atlas is working perfectly!');
        console.log('✅ Your connection string and network access are correct.');
        
    } catch (error) {
        console.log('\n❌ CONNECTION FAILED!');
        console.log('Error:', error.message);
        
        // Diagnose common issues
        console.log('\n🔍 DIAGNOSIS:');
        
        if (error.message.includes('ENOTFOUND') || error.message.includes('ECONNREFUSED')) {
            console.log('❌ Network/DNS Issue:');
            console.log('   • Check if MongoDB Atlas cluster is running');
            console.log('   • Verify cluster URL is correct');
            console.log('   • Check internet connection');
        }
        
        if (error.message.includes('authentication failed') || error.message.includes('auth')) {
            console.log('❌ Authentication Issue:');
            console.log('   • Check username and password');
            console.log('   • Make sure user has read/write permissions');
        }
        
        if (error.message.includes('IP') || error.message.includes('whitelist')) {
            console.log('❌ IP Whitelist Issue:');
            console.log('   • Go to MongoDB Atlas → Security → Network Access');
            console.log('   • Add IP Address → Allow Access from Anywhere (0.0.0.0/0)');
        }
        
        if (error.message.includes('timeout')) {
            console.log('❌ Timeout Issue:');
            console.log('   • MongoDB Atlas cluster might be sleeping');
            console.log('   • Network connectivity issues');
            console.log('   • Firewall blocking connection');
        }
        
        console.log('\n🔧 FIXES TO TRY:');
        console.log('1. MongoDB Atlas → Security → Network Access → Add 0.0.0.0/0');
        console.log('2. MongoDB Atlas → Database → Connect → Get new connection string');
        console.log('3. Check if cluster is paused (wake it up)');
        console.log('4. Verify username/password are correct');
        
    } finally {
        await mongoose.disconnect();
        console.log('\n📤 Disconnected from MongoDB Atlas');
    }
}

// Run the test
testMongoConnection().catch(console.error);




