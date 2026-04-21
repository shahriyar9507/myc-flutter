import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../config/theme.dart';
import '../../themes/theme_engine.dart';
import '../../services/chat_service.dart';
import '../../services/realtime_service.dart';
import '../../services/call_service.dart';
import '../../services/secure_storage.dart';
import '../../models/chat_models.dart';
import '../calls/call_screen.dart';

const int _kMaxMessageChars = 4096;

class ChatThreadScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String themeId;
  final bool online;
  final int? peerId;

  const ChatThreadScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.themeId,
    required this.online,
    this.peerId,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late String _currentThemeId;
  final TextEditingController _msgController = TextEditingController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  Timer? _typingDebouncer;
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _readsSub;
  Map<String, dynamic> _peerTyping = {};
  Map<String, String> _reads = {}; // userId -> lastReadMessageId
  String? _userId;
  MessageModel? _replyTo;
  MessageModel? _editing;

  @override
  void initState() {
    super.initState();
    _currentThemeId = widget.themeId;
    _msgController.addListener(_onTextChanged);
    _init();
  }

  Future<void> _init() async {
    _userId = await SecureStorage.readUserId();
    await _loadMessages();
    _subscribe();
  }

  void _onTextChanged() {
    final notEmpty = _msgController.text.trim().isNotEmpty;
    if (_isTyping != notEmpty) setState(() => _isTyping = notEmpty);
    if (_userId != null) {
      RealtimeService.instance.setTyping(widget.chatId, _userId!, notEmpty);
      _typingDebouncer?.cancel();
      if (notEmpty) {
        _typingDebouncer = Timer(const Duration(seconds: 4),
            () => RealtimeService.instance.setTyping(widget.chatId, _userId!, false));
      }
    }
  }

  void _subscribe() {
    _msgSub = RealtimeService.instance.messageStream(widget.chatId).listen((_) {
      _loadMessages(hideLoader: true);
    });
    _typingSub = RealtimeService.instance.typingStream(widget.chatId).listen((ev) {
      if (!mounted) return;
      final val = ev.snapshot.value;
      setState(() => _peerTyping = val is Map ? Map<String, dynamic>.from(val) : {});
    });
    _readsSub = RealtimeService.instance.readsStream(widget.chatId).listen((ev) {
      if (!mounted) return;
      final val = ev.snapshot.value;
      if (val is Map) {
        final m = <String, String>{};
        val.forEach((k, v) {
          if (v is Map && v['message_id'] != null) m[k.toString()] = v['message_id'].toString();
        });
        setState(() => _reads = m);
      }
    });
  }

  Future<void> _loadMessages({bool hideLoader = false}) async {
    if (!mounted) return;
    final service = Provider.of<ChatService>(context, listen: false);
    final msgs = await service.fetchMessages(widget.chatId);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      if (!hideLoader) _isLoading = false;
    });
    // Mark newest incoming message as read.
    if (msgs.isNotEmpty && _userId != null) {
      final newest = msgs.first;
      if (!newest.isMine) {
        RealtimeService.instance.markRead(widget.chatId, _userId!, newest.id);
        service.markRead(widget.chatId, newest.id);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    if (text.length > _kMaxMessageChars) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Max $_kMaxMessageChars characters')));
      return;
    }
    _msgController.clear();
    final service = Provider.of<ChatService>(context, listen: false);
    if (_editing != null) {
      final id = _editing!.id;
      setState(() => _editing = null);
      await service.editMessage(id, text);
    } else {
      final replyId = _replyTo?.id;
      setState(() => _replyTo = null);
      await service.sendMessage(widget.chatId, text, replyTo: replyId);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;
      setState(() => _isLoading = true);
      final bytes = await image.readAsBytes();
      final service = Provider.of<ChatService>(context, listen: false);
      final mediaData = await service.uploadMedia(bytes, image.name, 'image');
      if (mediaData != null && mediaData['url'] != null) {
        await service.sendMessage(widget.chatId, '', type: 'image', mediaUrl: mediaData['url']);
        _loadMessages(hideLoader: true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startRecording() async {
    setState(() { _isRecording = true; _recordSeconds = 0; });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    setState(() => _isRecording = false);
    final service = Provider.of<ChatService>(context, listen: false);
    await service.sendMessage(widget.chatId,
        'Voice Message (0:${_recordSeconds.toString().padLeft(2, '0')})',
        type: 'voice', duration: _recordSeconds);
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _readsSub?.cancel();
    _recordTimer?.cancel();
    _typingDebouncer?.cancel();
    _msgController.removeListener(_onTextChanged);
    _msgController.dispose();
    if (_userId != null) {
      RealtimeService.instance.setTyping(widget.chatId, _userId!, false);
    }
    super.dispose();
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ThemePickerSheet(
        currentTheme: _currentThemeId,
        onSelect: (id) { setState(() => _currentThemeId = id); Navigator.pop(context); },
      ),
    );
  }

  bool _someoneTyping() {
    if (_userId == null) return false;
    return _peerTyping.entries.any((e) => e.key != _userId && e.value != null);
  }

  Future<void> _startCall(String type) async {
    if (widget.chatId.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CallScreen(chatId: widget.chatId, peerName: widget.name, type: type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Positioned.fill(child: AnimatedChatTheme(themeId: _currentThemeId)),
        SafeArea(
          bottom: false,
          child: Column(children: [
            _buildGlassHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return msg.isMine ? _buildSentBubble(msg) : _buildReceivedBubble(msg);
                      },
                    ),
            ),
            if (_someoneTyping()) _typingIndicator(),
            if (_replyTo != null || _editing != null) _replyEditBar(),
            _buildGlassComposer(),
          ]),
        ),
      ]),
    );
  }

  Widget _typingIndicator() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    alignment: Alignment.centerLeft,
    child: Text('${widget.name} is typing…',
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
  );

  Widget _replyEditBar() => Container(
    color: Colors.black45,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Icon(_editing != null ? Icons.edit : Icons.reply, color: MyCColors.accent, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(
        _editing != null ? 'Editing: ${_editing!.content}' : 'Reply to: ${_replyTo!.content}',
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      )),
      IconButton(icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => setState(() { _replyTo = null; _editing = null; _msgController.clear(); })),
    ]),
  );

  Widget _buildGlassHeader(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            const SizedBox(width: 4),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [MyCColors.accent.withValues(alpha: 0.6), MyCColors.pink.withValues(alpha: 0.6)]),
              ),
              child: Center(child: Text(widget.name.isNotEmpty ? widget.name[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                _headerPresence(),
              ],
            )),
            IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.white), onPressed: () => _startCall('video')),
            IconButton(icon: const Icon(Icons.call_outlined, color: Colors.white), onPressed: () => _startCall('voice')),
            IconButton(icon: const Icon(Icons.palette_outlined, color: Colors.white), onPressed: _showThemePicker),
            IconButton(icon: const Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
          ]),
        ),
      ),
    );
  }

  Widget _headerPresence() {
    if (widget.peerId == null) {
      return Text(widget.online ? 'Active now' : 'Offline',
          style: GoogleFonts.inter(color: widget.online ? MyCColors.online : Colors.white60, fontSize: 12));
    }
    return StreamBuilder<DatabaseEvent>(
      stream: RealtimeService.instance.presenceStream(widget.peerId.toString()),
      builder: (_, snap) {
        final val = snap.data?.snapshot.value;
        final online = val is Map && val['online'] == true;
        return Text(online ? 'Active now' : 'Offline',
            style: GoogleFonts.inter(color: online ? MyCColors.online : Colors.white60, fontSize: 12));
      },
    );
  }

  void _showMessageActions(MessageModel msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(color: MyCColors.darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          // Reactions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (final emoji in const ['👍', '❤️', '😂', '😮', '😢', '🙏'])
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final svc = context.read<ChatService>();
                    final current = _userId != null ? msg.reactions[_userId!] : null;
                    await svc.reactMessage(msg.id, current == emoji ? null : emoji);
                    _loadMessages(hideLoader: true);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),
          _action(Icons.copy, 'Copy', () {
            Navigator.pop(context);
            Clipboard.setData(ClipboardData(text: msg.content));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
          }),
          _action(Icons.reply, 'Reply', () { Navigator.pop(context); setState(() => _replyTo = msg); }),
          _action(Icons.forward, 'Forward', () async {
            Navigator.pop(context);
            final res = await _pickForwardTargets();
            if (res != null && res.isNotEmpty) {
              await context.read<ChatService>().forwardMessage(msg.id, res);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forwarded')));
            }
          }),
          _action(msg.starred ? Icons.star : Icons.star_border, msg.starred ? 'Unstar' : 'Star', () async {
            Navigator.pop(context);
            await context.read<ChatService>().starMessage(msg.id, !msg.starred);
            _loadMessages(hideLoader: true);
          }),
          _action(msg.pinned ? Icons.push_pin : Icons.push_pin_outlined, msg.pinned ? 'Unpin' : 'Pin', () async {
            Navigator.pop(context);
            await context.read<ChatService>().pinMessage(msg.id, !msg.pinned);
            _loadMessages(hideLoader: true);
          }),
          if (msg.editable) _action(Icons.edit, 'Edit', () {
            Navigator.pop(context);
            setState(() { _editing = msg; _msgController.text = msg.content; });
          }),
          if (msg.isMine) _action(Icons.delete, 'Delete for everyone', () async {
            Navigator.pop(context);
            await context.read<ChatService>().deleteMessage(msg.id, forEveryone: true);
            _loadMessages(hideLoader: true);
          }, color: Colors.redAccent),
          _action(Icons.visibility_off, 'Delete for me', () async {
            Navigator.pop(context);
            await context.read<ChatService>().deleteMessage(msg.id);
            _loadMessages(hideLoader: true);
          }, color: Colors.redAccent),
        ]),
      ),
    );
  }

  Widget _action(IconData ic, String label, VoidCallback onTap, {Color color = Colors.white}) =>
      ListTile(leading: Icon(ic, color: color), title: Text(label, style: TextStyle(color: color)), onTap: onTap);

  Future<List<String>?> _pickForwardTargets() async {
    final chats = context.read<ChatService>().chats;
    final selected = <String>{};
    return showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: MyCColors.darkCard,
      builder: (_) => StatefulBuilder(builder: (ctx, setM) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(12), child: Text('Forward to…', style: TextStyle(color: Colors.white, fontSize: 16))),
        Flexible(child: ListView.builder(
          shrinkWrap: true,
          itemCount: chats.length,
          itemBuilder: (_, i) {
            final c = chats[i];
            final sel = selected.contains(c.id);
            return CheckboxListTile(
              value: sel, activeColor: MyCColors.accent,
              onChanged: (v) => setM(() => v == true ? selected.add(c.id) : selected.remove(c.id)),
              title: Text(c.name, style: const TextStyle(color: Colors.white)),
            );
          },
        )),
        TextButton(onPressed: () => Navigator.pop(ctx, selected.toList()), child: const Text('Forward')),
      ])),
    );
  }

  Widget _statusTick(MessageModel msg) {
    if (!msg.isMine) return const SizedBox.shrink();
    final readByOther = _reads.entries.any((e) => e.key != _userId && e.value == msg.id);
    IconData ic;
    Color color;
    if (readByOther || msg.readBy.any((u) => u != _userId)) { ic = Icons.done_all; color = MyCColors.accent; }
    else if (msg.delivered) { ic = Icons.done_all; color = Colors.white54; }
    else { ic = Icons.done; color = Colors.white38; }
    return Icon(ic, size: 14, color: color);
  }

  Widget _reactionsRow(MessageModel msg) {
    if (msg.reactions.isEmpty) return const SizedBox.shrink();
    final counts = <String, int>{};
    for (final e in msg.reactions.values) { counts[e] = (counts[e] ?? 0) + 1; }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 4, children: [
        for (final e in counts.entries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
            child: Text('${e.key} ${e.value}', style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
      ]),
    );
  }

  Widget _replyPreview(MessageModel msg) {
    if (msg.replyPreview == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: MyCColors.accent, width: 3)),
      ),
      child: Text(msg.replyPreview!, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _mediaOrText(MessageModel msg) {
    if (msg.deletedForAll) {
      return const Text('This message was deleted',
          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic, fontSize: 14));
    }
    switch (msg.type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: msg.mediaUrl != null ? Image.network(msg.mediaUrl!, fit: BoxFit.cover) : const SizedBox.shrink(),
        );
      case 'video':
        return Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.play_circle_outline, color: Colors.white), SizedBox(width: 6),
          Text('Video', style: TextStyle(color: Colors.white))]);
      case 'audio':
      case 'voice':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.mic, color: Colors.white), const SizedBox(width: 6),
          Text(msg.content.isEmpty ? 'Voice message' : msg.content, style: const TextStyle(color: Colors.white))]);
      case 'file':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.attach_file, color: Colors.white), const SizedBox(width: 6),
          Flexible(child: Text(msg.content, style: const TextStyle(color: Colors.white)))]);
      case 'location':
        return Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.place, color: Colors.white), SizedBox(width: 6),
          Text('Location', style: TextStyle(color: Colors.white))]);
      case 'contact':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person, color: Colors.white), const SizedBox(width: 6),
          Flexible(child: Text(msg.content, style: const TextStyle(color: Colors.white)))]);
      case 'system':
        return Text(msg.content, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic));
      default:
        return Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3));
    }
  }

  Widget _buildSentBubble(MessageModel msg) {
    return GestureDetector(
      onLongPress: () => _showMessageActions(msg),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2, left: 50),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: MyCColors.accentGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20), bottomRight: Radius.circular(6),
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _replyPreview(msg),
              _mediaOrText(msg),
              const SizedBox(height: 2),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (msg.edited) const Text('edited ', style: TextStyle(color: Colors.white60, fontSize: 10)),
                Text(_formatTime(msg.createdAt), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(width: 4), _statusTick(msg),
              ]),
            ]),
          ),
          _reactionsRow(msg),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }

  Widget _buildReceivedBubble(MessageModel msg) {
    return GestureDetector(
      onLongPress: () => _showMessageActions(msg),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20),
              bottomRight: Radius.circular(20), bottomLeft: Radius.circular(6),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 2, right: 50),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20), bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _replyPreview(msg),
                  _mediaOrText(msg),
                  const SizedBox(height: 2),
                  Text(_formatTime(msg.createdAt), style: const TextStyle(color: Colors.white60, fontSize: 10)),
                ]),
              ),
            ),
          ),
          _reactionsRow(msg),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildGlassComposer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isRecording ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: _isRecording
                  ? Row(children: [
                      const Icon(Icons.mic, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text('Recording… 0:${_recordSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ])
                  : TextField(
                      controller: _msgController,
                      maxLength: _kMaxMessageChars,
                      maxLines: 5, minLines: 1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isTyping ? _sendMessage : null,
              onLongPress: !_isTyping ? _startRecording : null,
              onLongPressEnd: !_isTyping ? (_) => _stopRecording() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 48 : 36,
                height: _isRecording ? 48 : 36,
                decoration: BoxDecoration(
                  gradient: _isRecording ? const LinearGradient(colors: [Colors.red, Colors.redAccent]) : MyCColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: _isRecording ? [const BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2)] : null,
                ),
                child: Icon(_isTyping ? Icons.send : Icons.mic, color: Colors.white, size: _isRecording ? 24 : 18),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ThemePickerSheet extends StatelessWidget {
  final String currentTheme;
  final Function(String) onSelect;
  const _ThemePickerSheet({required this.currentTheme, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const themes = ['rain', 'snow', 'confetti', 'bubbles', 'aurora', 'fireflies', 'sakura', 'starfield', 'lava', 'matrix', 'ocean'];
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: MyCColors.darkCard, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text('Pick a mood', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
            itemCount: themes.length,
            itemBuilder: (_, i) {
              final id = themes[i];
              final isSelected = id == currentTheme;
              return GestureDetector(
                onTap: () => onSelect(id),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? MyCColors.accent : Colors.white10, width: isSelected ? 2 : 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(fit: StackFit.expand, children: [
                      AnimatedChatTheme(themeId: id),
                      if (isSelected) Container(color: Colors.black38,
                          child: const Center(child: Icon(Icons.check_circle, color: MyCColors.accent, size: 32))),
                      Positioned(bottom: 8, left: 0, right: 0,
                        child: Text(id[0].toUpperCase() + id.substring(1), textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
