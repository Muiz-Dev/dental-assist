package com.dentassist.backend.ai.service;

import com.dentassist.backend.ai.dto.AiRequest;
import com.dentassist.backend.ai.dto.AiResponse;
import org.springframework.stereotype.Service;

@Service
public class MockAiProvider implements AiProvider {

    @Override
    public AiResponse generate(AiRequest request) {
        String promptLower = request.prompt().toLowerCase();

        String content;
        if (promptLower.contains("sensitivity") || promptLower.contains("sensitive")) {
            content = "[Mock AI] Tooth sensitivity is often caused by exposed dentin, worn tooth enamel, or a exposed tooth root. Common causes include brushing too hard, acidic foods, or teeth grinding. Please consult a licensed dentist for a full clinical evaluation.";
        } else if (promptLower.contains("pain") || promptLower.contains("hurt")) {
            content = "[Mock AI] Dental pain can stem from cavities, gum infection, or tooth fractures. If you experience severe pain, swelling, or fever, please seek emergency dental care promptly. This is an educational response and not a medical diagnosis.";
        } else {
            content = "[Mock AI] Thank you for your inquiry regarding oral health. Good daily hygiene practices include brushing twice daily with fluoride toothpaste and flossing daily. For specific symptoms, always seek advice from a qualified dental professional.";
        }

        return new AiResponse(content, "MockAiProvider", true);
    }
}
