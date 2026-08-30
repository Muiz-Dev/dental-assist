package com.dentassist.backend.common.controller;

import com.dentassist.backend.common.dto.HealthResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
public class HealthController {

    private final DataSource dataSource;
    private final RedisConnectionFactory redisConnectionFactory;

    @Value("${APP_ENV:development}")
    private String environment;

    public HealthController(DataSource dataSource, RedisConnectionFactory redisConnectionFactory) {
        this.dataSource = dataSource;
        this.redisConnectionFactory = redisConnectionFactory;
    }

    @GetMapping
    public ResponseEntity<HealthResponse> getHealth() {
        return ResponseEntity.ok(new HealthResponse("ok", environment, Map.of()));
    }

    @GetMapping("/readiness")
    public ResponseEntity<HealthResponse> getReadiness() {
        Map<String, Object> checks = new HashMap<>();
        boolean dbHealthy = checkDatabase(checks);
        boolean redisHealthy = checkRedis(checks);

        boolean overallHealthy = dbHealthy && redisHealthy;
        HttpStatus status = overallHealthy ? HttpStatus.OK : HttpStatus.SERVICE_UNAVAILABLE;

        return ResponseEntity.status(status).body(
                new HealthResponse(overallHealthy ? "UP" : "DOWN", environment, checks)
        );
    }

    private boolean checkDatabase(Map<String, Object> checks) {
        try (Connection conn = dataSource.getConnection()) {
            boolean valid = conn.isValid(2);
            checks.put("database", valid ? "UP" : "DOWN");
            return valid;
        } catch (Exception e) {
            checks.put("database", "DOWN: " + e.getMessage());
            return false;
        }
    }

    private boolean checkRedis(Map<String, Object> checks) {
        try {
            String ping = redisConnectionFactory.getConnection().ping();
            boolean valid = "PONG".equalsIgnoreCase(ping);
            checks.put("redis", valid ? "UP" : "DOWN");
            return valid;
        } catch (Exception e) {
            checks.put("redis", "DOWN: " + e.getMessage());
            return false;
        }
    }
}
