import IORedis from "ioredis";
import dotenv from 'dotenv';

dotenv.config();

const testRedisConnection = async () => {
  const redisUrl = process.env.REDIS_URL;
  
  console.log('Testing Redis connection...');
  console.log('Redis URL:', redisUrl ? redisUrl.replace(/:[^:]*@/, ':***@') : 'not set');
  
  const redis = new IORedis(redisUrl, {
    maxRetriesPerRequest: null,
    tls: redisUrl.startsWith("rediss://") ? {} : undefined,
    retryDelayOnFailover: 100,
    enableReadyCheck: false,
    lazyConnect: true
  });

  redis.on('connect', () => {
    console.log('✅ Connected to Redis');
  });

  redis.on('error', (err) => {
    console.error('❌ Redis connection error:', err.message);
  });

  try {
    await redis.ping();
    console.log('✅ Redis PING successful');
    
    await redis.set('test', 'hello');
    const result = await redis.get('test');
    console.log('✅ Redis SET/GET test:', result);
    
    await redis.del('test');
    console.log('✅ Redis connection working properly');
    
  } catch (error) {
    console.error('❌ Redis test failed:', error.message);
  } finally {
    await redis.quit();
    console.log('Redis connection closed');
  }
};

testRedisConnection();