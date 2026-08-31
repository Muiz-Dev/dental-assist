import 'package:flutter/foundation.dart';
import 'chat_models.dart';
import 'conversation_repository.dart';

class ChatController extends ChangeNotifier {
  final ConversationRepository repository;

  ConversationModel? _currentConversation;
  bool _isLoading = false;
  String? _errorMessage;

  ChatController({required this.repository});

  ConversationModel? get currentConversation => _currentConversation;
  List<MessageModel> get messages => _currentConversation?.messages ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentConversation == null) {
        _currentConversation = await repository.createConversation(initialMessage: text);
      } else {
        _currentConversation = await repository.addMessage(
          conversationId: _currentConversation!.id,
          content: text,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startNewConversation() {
    _currentConversation = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
