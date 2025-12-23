package com.pii.validation.config;

import com.pii.validation.service.RateLimiterService;
import io.github.bucket4j.Bucket;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class RateLimitFilter implements Filter {

    private final RateLimiterService rateLimiterService;

    public RateLimitFilter(RateLimiterService rateLimiterService) {
        this.rateLimiterService = rateLimiterService;
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
        HttpServletResponse httpResponse = (HttpServletResponse) servletResponse;

        String clientIp = getClientIP(httpRequest);
        Bucket bucket = rateLimiterService.resolveBucket(clientIp);

        if (bucket.tryConsume(1)) {
            long availableTokens = bucket.getAvailableTokens();
            
            httpResponse.addHeader("X-RateLimit-Limit", String.valueOf(rateLimiterService.getLimit()));
            httpResponse.addHeader("X-RateLimit-Remaining", String.valueOf(availableTokens));
            
            filterChain.doFilter(servletRequest, servletResponse);
        } else {
            long waitForRefill = bucket.estimateAbilityToConsume(1).getNanosToWaitForRefill() / 1_000_000_000;
            
            httpResponse.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            httpResponse.addHeader("X-RateLimit-Limit", String.valueOf(rateLimiterService.getLimit()));
            httpResponse.addHeader("X-RateLimit-Remaining", "0");
            httpResponse.addHeader("X-RateLimit-Reset", String.valueOf(System.currentTimeMillis() / 1000 + waitForRefill));
            httpResponse.setContentType("application/json");
            httpResponse.getWriter().write(
                "{\"error\": \"Too many requests\", \"message\": \"Rate limit exceeded. Please try again in " + waitForRefill + " seconds.\"}"
            );
        }
    }

    private String getClientIP(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null) {
            return request.getRemoteAddr();
        }
        return xfHeader.split(",")[0];
    }
}

