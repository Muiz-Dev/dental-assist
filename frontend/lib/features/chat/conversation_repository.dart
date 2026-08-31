import '../../core/api_client.dart';
import 'chat_models.dart';

class ConversationRepository {
  final ApiClient apiClient;

  ConversationRepository({required this.apiClient});

  Future<ConversationModel> createConversation({String? title, required String initialMessage}) async {
    final body = {
      if (title != null && title.isNotEmpty) 'title': title,
      'initialMessage': initialMessage,
    };
    final json = await apiClient.post('/conversations', body);
    return ConversationModel.fromJson(json);
  }

  Future<ConversationModel> getConversation(String id) async {
    final json = await apiClient.get('/conversations/$id');
    return ConversationModel.fromJson(json);
  }

  Future<ConversationModel> addMessage({required String conversationId, required String content}) async {
    final body = {'content': content};
    final json = await apiClient.post('/conversations/$conversationId/messages', body);
    return ConversationModel.fromJson(json);
  }
}
