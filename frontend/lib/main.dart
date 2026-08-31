import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'features/chat/chat_controller.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/conversation_repository.dart';

void main() {
  runApp(const DentAssistApp());
}

class DentAssistApp extends StatefulWidget {
  const DentAssistApp({super.key});

  @override
  State<DentAssistApp> createState() => _DentAssistAppState();
}

class _DentAssistAppState extends State<DentAssistApp> {
  late final ApiClient apiClient;
  late final ConversationRepository conversationRepository;
  late final ChatController chatController;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    conversationRepository = ConversationRepository(apiClient: apiClient);
    chatController = ChatController(repository: conversationRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentAssist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: ChatScreen(
        controller: chatController,
        apiClient: apiClient,
      ),
    );
  }
}
