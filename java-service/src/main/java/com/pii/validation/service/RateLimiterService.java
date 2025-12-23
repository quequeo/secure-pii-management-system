package com.pii.validation.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class RateLimiterService {

    private final int requestsPerMinute;
    private final Cache<String, Bucket> cache;

    public RateLimiterService(@Value("${rate.limit.requests-per-minute:100}") int requestsPerMinute) {
        this.requestsPerMinute = requestsPerMinute;
        this.cache = Caffeine.newBuilder()
                // Evict buckets for IPs that have been idle for 15 minutes
                .expireAfterAccess(Duration.ofMinutes(15))
                // Hard cap on number of distinct IPs to prevent unbounded growth
                .maximumSize(10_000)
                .build();
    }

    public Bucket resolveBucket(String key) {
        return cache.get(key, k -> createNewBucket());
    }

    private Bucket createNewBucket() {
        Bandwidth limit = Bandwidth.classic(requestsPerMinute, Refill.intervally(requestsPerMinute, Duration.ofMinutes(1)));
        return Bucket.builder()
                .addLimit(limit)
                .build();
    }

    public int getLimit() {
        return requestsPerMinute;
    }
}
