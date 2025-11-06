// lib/features/guidies/presentation/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/local/app_locle.dart';
import 'package:med_just/features/guidies/data/models/guide_model.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_bloc.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_event.dart';
import 'package:med_just/features/guidies/presentation/controller/guide_states.dart';
import 'package:med_just/features/guidies/presentation/widgets/message_bubble.dart';
import 'package:med_just/features/guidies/presentation/widgets/suggested_questions.dart';
import 'package:med_just/features/guidies/presentation/widgets/virtual_arabic_key_borad.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<GuideBloc>()..add(InitializeGuide()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: const _ChatScreenContent(),
      ),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent();

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;

  bool _isTyping = false;
  bool _showKeyboard = false;

  static const _suggestedQuestions = [
    'أين يقع مبنى الطب؟',
    'كيف أسجل المواد الدراسية؟',
    'ما هي مواعيد المكتبة؟',
    'كيف أنضم للأندية الطلابية؟',
    'كيف أتواصل مع المرشد الأكاديمي؟',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && !_showKeyboard) {
      setState(() => _showKeyboard = true);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<GuideBloc>().add(SendChatMessage(message));
    _clearInput();
    _scrollToBottom();
  }

  void _clearInput() {
    _messageController.clear();
    setState(() {
      _isTyping = false;
      _showKeyboard = false;
    });
    _focusNode.unfocus();
  }

  void _handleSuggestedQuestion(String question) {
    _messageController.text = question;
    _sendMessage();
  }

  void _toggleKeyboard() {
    setState(() => _showKeyboard = !_showKeyboard);
    if (_showKeyboard) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _handleKeyPress(String key) {
    if (key == 'backspace') {
      if (_messageController.text.isNotEmpty) {
        _messageController.text = _messageController.text.substring(
          0,
          _messageController.text.length - 1,
        );
      }
    } else if (key == 'send') {
      _sendMessage();
    } else if (key == 'space') {
      _messageController.text += ' ';
    } else {
      _messageController.text += key;
    }
    setState(() => _isTyping = _messageController.text.isNotEmpty);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildSuggestedQuestions(),
          _buildInputArea(context),
          if (_showKeyboard) _buildVirtualKeyboard(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.smartAssistant.getString(context),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 2),
          Text(
            AppLocale.newStudentGuide.getString(context),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<GuideBloc>().add(ClearChat()),
          tooltip: AppLocale.clearChat.getString(context),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<GuideBloc, GuideState>(
      listener: _handleBlocListener,
      builder: (context, state) {
        if (state is GuideLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatUpdated) {
          return state.messages.isEmpty
              ? _buildEmptyState(context)
              : _buildMessagesListView(state.messages);
        }

        return _buildEmptyState(context);
      },
    );
  }

  void _handleBlocListener(BuildContext context, GuideState state) {
    if (state is ChatUpdated) {
      _scrollToBottom();
    }

    if (state is GuideError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.message,
            style: const TextStyle(fontFamily: 'Cairo'),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMessagesListView(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder:
          (context, index) => MessageBubble(
            message: messages[index],
            onContentTap: _showContentDetail,
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocale.welcomeMessage.getString(context),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocale.helpMessage.getString(context),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    return BlocBuilder<GuideBloc, GuideState>(
      builder: (context, state) {
        if (state is ChatUpdated && state.messages.isEmpty && !_showKeyboard) {
          return SuggestedQuestions(
            questions: _suggestedQuestions,
            onQuestionTap: _handleSuggestedQuestion,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: _showKeyboard ? 12 : MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _buildSendButton(context),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField(context)),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Material(
      color:
          _isTyping
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _isTyping ? _sendMessage : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            Icons.send_rounded,
            color:
                _isTyping
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _messageController,
        focusNode: _focusNode,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        readOnly: true,
        showCursor: true,
        style: const TextStyle(fontSize: 15, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          hintText: AppLocale.searchPlaceholder.getString(context),
          hintStyle: const TextStyle(fontFamily: 'Cairo'),
          hintTextDirection: TextDirection.rtl,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          prefixIcon:
              _isTyping
                  ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _messageController.clear();
                      setState(() => _isTyping = false);
                    },
                  )
                  : null,
          suffixIcon: IconButton(
            icon: Icon(
              _showKeyboard ? Icons.keyboard_hide : Icons.keyboard,
              size: 20,
            ),
            onPressed: _toggleKeyboard,
          ),
        ),
        onTap: () => setState(() => _showKeyboard = true),
      ),
    );
  }

  Widget _buildVirtualKeyboard() {
    return VirtualArabicKeyboard(
      onKeyPress: _handleKeyPress,
      backgroundColor: Theme.of(context).colorScheme.surface,
      textColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  void _showContentDetail(GuideContent content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _ContentDetailSheet(content: content),
    );
  }
}

class _ContentDetailSheet extends StatelessWidget {
  final GuideContent content;

  const _ContentDetailSheet({required this.content});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder:
            (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildHandle(context),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildTitle(context),
                        const SizedBox(height: 16),
                        if (content.imageUrl != null) _buildImage(),
                        _buildContent(context),
                        if (content.keywords.isNotEmpty)
                          _buildKeywords(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      content.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildImage() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            content.imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      content.content,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(height: 1.6, fontFamily: 'Cairo'),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildKeywords(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          AppLocale.keywords.getString(context),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          textDirection: TextDirection.rtl,
          children:
              content.keywords
                  .map(
                    (keyword) => Chip(
                      label: Text(
                        keyword,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
