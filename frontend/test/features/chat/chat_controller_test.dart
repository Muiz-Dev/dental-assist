import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/features/chat/chat_controller.dart';
import 'package:frontend_app/features/chat/chat_models.dart';
import 'package:frontend_app/features/chat/conversation_repository.dart';
import 'package:frontend_app/core/api_client.dart';

class MockConversationRepository extends ConversationRepository {
  MockConversationRepository() : super(apiClient: ApiClient());

  @override
  Future<ConversationModel> createConversation({String? title, required String initialMessage}) async {
    return ConversationModel(
      id: 'conv-123',
      title: 'Sensitivity Query',
      createdAt: '2026-08-30T20:00:00Z',
      updatedAt: '2026-08-30T20:00:00Z',
      messages: [
        MessageModel(
          id: 'msg-1',
          conversationId: 'conv-123',
          role: 'USER',
          content: initialMessage,
          createdAt: '2026-08-30T20:00:00Z',
        ),
        MessageModel(
          id: 'msg-2',
          conversationId: 'conv-123',
          role: 'ASSISTANT',
          content: '[Mock AI] Response to: $initialMessage',
          createdAt: '2026-08-30T20:00:01Z',
        ),
      ],
    );
  }

  @override
  Future<ConversationModel> addMessage({required String conversationId, required String content}) async {
    return ConversationModel(
      id: conversationId,
      title: 'Sensitivity Query',
      createdAt: '2026-08-30T20:00:00Z',
      updatedAt: '2026-08-30T20:01:00Z',
      messages: [
        MessageModel(
          id: 'msg-1',
          conversationId: conversationId,
          role: 'USER',
          content: 'Initial message',
          createdAt: '2026-08-30T20:00:00Z',
        ),
        MessageModel(
          id: 'msg-2',
          conversationId: conversationId,
          role: 'ASSISTANT',
          content: 'Initial response',
          createdAt: '2026-08-30T20:00:01Z',
        ),
        MessageModel(
          id: 'msg-3',
          conversationId: conversationId,
          role: 'USER',
          content: content,
          createdAt: '2026-08-30T20:01:00Z',
        ),
        MessageModel(
          id: 'msg-4',
          conversationId: conversationId,
          role: 'ASSISTANT',
          content: '[Mock AI] Response to: $content',
          createdAt: '2026-08-30T20:01:01Z',
        ),
      ],
    );
  }
}

void main() {
  late ChatController chatController;
  late MockConversationRepository mockRepo;

  setUp(() {
    mockRepo = MockConversationRepository();
    chatController = ChatController(repository: mockRepo);
  });

  test('Initial chat controller state is empty', () {
    expect(chatController.currentConversation, isNull);
    expect(chatController.messages, isEmpty);
    expect(chatController.isLoading, isFalse);
    expect(chatController.errorMessage, isNull);
  });

  test('sendMessage creates new conversation when none exists', () async {
    await chatController.sendMessage('What causes tooth sensitivity?');

    expect(chatController.currentConversation, isNotNull);
    expect(chatController.currentConversation!.id, equals('conv-123'));
    expect(chatController.messages.length, equals(2));
    expect(chatController.messages[0].content, equals('What causes tooth sensitivity?'));
    expect(chatController.messages[1].role, equals('ASSISTANT'));
  });

  test('sendMessage appends messages when conversation already exists', () async {
    await chatController.sendMessage('Initial message');
    expect(chatController.messages.length, equals(2));

    await chatController.sendMessage('Follow-up question');
    expect(chatController.messages.length, equals(4));
    expect(chatController.messages[2].content, equals('Follow-up question'));
  });

  test('startNewConversation resets conversation state', () async {
    await chatController.sendMessage('Initial message');
    expect(chatController.currentConversation, isNotNull);

    chatController.startNewConversation();
    expect(chatController.currentConversation, isNull);
    expect(chatController.messages, isEmpty);
  });
}
