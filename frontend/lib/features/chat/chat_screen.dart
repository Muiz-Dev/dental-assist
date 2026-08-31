import 'package:flutter/material.dart';
import 'chat_controller.dart';
import 'chat_models.dart';
import '../health/health_status_widget.dart';
import '../../core/api_client.dart';

class ChatScreen extends StatefulWidget {
  final ChatController controller;
  final ApiClient apiClient;

  const ChatScreen({
    super.key,
    required this.controller,
    required this.apiClient,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    widget.controller.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.messages;
    final isLoading = widget.controller.isLoading;
    final error = widget.controller.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DentAssist AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Conversation',
            onPressed: () {
              widget.controller.startNewConversation();
            },
          )
        ],
      ),
      body: Column(
        children: [
          HealthStatusWidget(apiClient: widget.apiClient),
          if (error != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.shade100,
              width: double.infinity,
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      child: Text(
                        'Welcome to DentAssist!\nAsk any question regarding your oral health to get started.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your dental concern...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: isLoading ? null : _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final isUser = msg.role.toUpperCase() == 'USER';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'You' : 'DentAssist Assistant',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.blue.shade900 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
