package com.dentassist.backend.ai.service;

import com.dentassist.backend.ai.dto.AiRequest;
import com.dentassist.backend.ai.dto.AiResponse;

public interface AiProvider {
    AiResponse generate(AiRequest request);
}
