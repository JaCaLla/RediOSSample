require('dotenv').config(); // Fetch environment variables

const express = require('express');
const Redis = require('ioredis');

const app = express();

// Fetch environment variables
const PORT = process.env.PORT || 3000;
const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const REDIS_PORT = process.env.REDIS_PORT || 6379;

// Connect with Redis by using environnment variables
const redis = new Redis({ host: REDIS_HOST, port: REDIS_PORT });

app.use(express.json());

// 📌 Init some prices
async function initializeSamplePrices() {
    const initialPrices = {
        "iphone": "999",
        "macbook": "1999",
        "ipad": "799",
        "airpods": "199"
    };

    for (const [product, price] of Object.entries(initialPrices)) {
        await redis.set(`price:${product}`, price);
    }

    console.log("✅ Prices initialized in Redis.");
}

// Initialize sample prices
initializeSamplePrices();

// 📌 Endpoint for getting a product price
app.get('/price/:product', async (req, res) => {
    const price = await redis.get(`price:${req.params.product}`);
    
    if (price) {
        res.json({ product: req.params.product, price: price });
    } else {
        res.status(404).json({ error: "Product not found" });
    }
});

app.get('/prices', async (req, res) => {
    try {
        const keys = await redis.keys("price:*"); 
        
        // Fetch all prices
        const prices = await Promise.all(keys.map(async (key) => {
            const product = key.replace("price:", "");
            const price = await redis.get(key); 
            return { product: product, price: price };
        }));

        res.json(prices);
    } catch (error) {
        console.error("Error on getting prices:", error);
        res.status(500).json({ error: "Error on getting prices" });
    }
});

// 📌 Endpoint for adding or updating a product price
app.post('/price', async (req, res) => {
    const { product, price } = req.body;
    if (!product || !price) {
        return res.status(400).json({ error: "Misssing data" });
    }
    
    await redis.set(`price:${product}`, price);
    res.json({ mensaje: "Price stored", product, price });
});

// 📌 Server listening on specied port
app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
