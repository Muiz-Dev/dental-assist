package com.dentassist.backend.conversation;

import com.dentassist.backend.conversation.dto.ConversationDto;
import com.dentassist.backend.conversation.dto.CreateConversationRequest;
import com.dentassist.backend.conversation.dto.AddMessageRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class ConversationIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void testFullConversationFlow() {
        // 1. Create conversation
        CreateConversationRequest createReq = new CreateConversationRequest("Sensitivity Query", "What causes tooth sensitivity?");
        ResponseEntity<ConversationDto> createResp = restTemplate.postForEntity("/api/v1/conversations", createReq, ConversationDto.class);

        assertThat(createResp.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        ConversationDto conv = createResp.getBody();
        assertThat(conv).isNotNull();
        assertThat(conv.id()).isNotNull();
        assertThat(conv.title()).isEqualTo("Sensitivity Query");
        assertThat(conv.messages()).hasSize(2); // User msg + Mock AI msg
        assertThat(conv.messages().get(0).role()).isEqualTo("USER");
        assertThat(conv.messages().get(0).content()).isEqualTo("What causes tooth sensitivity?");
        assertThat(conv.messages().get(1).role()).isEqualTo("ASSISTANT");
        assertThat(conv.messages().get(1).content()).contains("Tooth sensitivity is often caused by exposed dentin");

        String convId = conv.id();

        // 2. Fetch conversation
        ResponseEntity<ConversationDto> getResp = restTemplate.getForEntity("/api/v1/conversations/" + convId, ConversationDto.class);
        assertThat(getResp.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResp.getBody().id()).isEqualTo(convId);

        // 3. Add follow-up message
        AddMessageRequest addReq = new AddMessageRequest("What about dental pain?");
        ResponseEntity<ConversationDto> addResp = restTemplate.postForEntity("/api/v1/conversations/" + convId + "/messages", addReq, ConversationDto.class);

        assertThat(addResp.getStatusCode()).isEqualTo(HttpStatus.OK);
        ConversationDto updatedConv = addResp.getBody();
        assertThat(updatedConv.messages()).hasSize(4); // 2 previous + 1 user + 1 assistant
        assertThat(updatedConv.messages().get(3).content()).contains("Dental pain can stem from cavities");
    }

    @Test
    void testGetNonExistentConversation() {
        ResponseEntity<String> resp = restTemplate.getForEntity("/api/v1/conversations/non-existent-id", String.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(resp.getBody()).contains("NOT_FOUND");
    }
}
