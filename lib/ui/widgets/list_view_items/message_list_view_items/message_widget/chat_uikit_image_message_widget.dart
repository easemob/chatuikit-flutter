import 'dart:io';
import 'dart:math';

import 'package:em_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';

double maxImageWidth = 225;
double maxImageHeight = 300;

class ChatUIKitImageMessageWidget extends StatefulWidget {
  const ChatUIKitImageMessageWidget({
    required this.message,
    this.bubbleStyle = ChatUIKitMessageListViewBubbleStyle.arrow,
    this.progressIndicatorColor,
    this.isLeft,
    super.key,
  });
  final Message message;
  final ChatUIKitMessageListViewBubbleStyle bubbleStyle;
  final Color? progressIndicatorColor;
  final bool? isLeft;

  @override
  State<ChatUIKitImageMessageWidget> createState() =>
      _ChatUIKitImageMessageWidgetState();
}

class _ChatUIKitImageMessageWidgetState
    extends State<ChatUIKitImageMessageWidget> with MessageObserver {
  late final Message message;
  bool downloading = false;
  bool downloadError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    ChatUIKit.instance.addObserver(this);
    message = widget.message;
  }

  @override
  void dispose() {
    ChatUIKit.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onSuccess(String msgId, Message msg) {
    if (msgId == message.msgId) {
      safeSetState(() {
        downloading = false;
      });
    }
  }

  @override
  void onError(String msgId, Message msg, ChatError error) {
    if (msgId == message.msgId && msg.bodyType == MessageType.IMAGE) {
      (msg.body as ImageMessageBody).fileStatus !=
          (message.body as ImageMessageBody).fileStatus;
      safeSetState(() {
        downloading = false;
        downloadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatUIKitTheme.of(context);

    bool left = widget.isLeft ?? message.direction == MessageDirection.RECEIVE;

    String? localPath = message.localPath;
    String? thumbnailLocalPath = message.thumbnailLocalPath;
    double width = message.width;
    double height = message.height;
    if (width == 0) width = maxImageWidth;
    if (height == 0) height = maxImageHeight;
    double aspectRatio = width / height;

    if (aspectRatio < 0.1) {
      height = min(height, width * 10);
      if (height > maxImageHeight) {
        height = maxImageHeight;
        width = height / 10;
      }
    } else if (aspectRatio >= 0.1 && aspectRatio < 0.75) {
      if (height > maxImageHeight) {
        height = maxImageHeight;
        width = height * aspectRatio;
      }
    } else if (aspectRatio >= 0.75 && aspectRatio <= 1) {
      if (width > maxImageWidth) {
        width = maxImageWidth;
        height = width / aspectRatio;
      }
    } else if (aspectRatio > 1 && aspectRatio <= 10) {
      if (width > maxImageWidth) {
        width = maxImageWidth;
        height = width / aspectRatio;
      }
    } else {
      width = min(width, height * 10);
      if (width > maxImageWidth) {
        width = maxImageWidth;
        height = width / 10;
      }
    }

    Widget? content;

    if (downloadError) {
      content = loadError(width, height);
    } else {
      if (thumbnailLocalPath?.isNotEmpty == true) {
        final file = File(thumbnailLocalPath!);
        bool exists = file.existsSync();
        if (exists) {
          content = Image(
            image: ResizeImage(
              FileImage(file),
              width: width.toInt(),
              height: height.toInt(),
              policy: ResizeImagePolicy.fit,
            ),
            width: width,
            height: height,
            gaplessPlayback: true,
            excludeFromSemantics: true,
            alignment: left ? Alignment.centerLeft : Alignment.centerRight,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          );
        }
      }

      if (content == null) {
        if (localPath?.isNotEmpty == true) {
          final file = File(localPath!);
          bool exists = file.existsSync();
          if (exists) {
            content = Image(
              image: ResizeImage(
                FileImage(file),
                width: width.toInt(),
                height: height.toInt(),
                policy: ResizeImagePolicy.fit,
              ),
              width: width,
              height: height,
              gaplessPlayback: true,
              alignment: left ? Alignment.centerLeft : Alignment.centerRight,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
            );
          }
        }
      }

      if (content == null) {
        download();
        content = SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              color: widget.progressIndicatorColor,
            ),
          ),
        );
      }

      content = SizedBox(
        width: width,
        height: height,
        child: content,
      );
    }
    content = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            widget.bubbleStyle == ChatUIKitMessageListViewBubbleStyle.arrow
                ? 4
                : 16),
        border: Border.all(
          width: 1,
          color: theme.color.isDark
              ? downloadError
                  ? theme.color.neutralColor3
                  : theme.color.neutralColor2
              : downloadError
                  ? theme.color.neutralColor8
                  : theme.color.neutralColor9,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            widget.bubbleStyle == ChatUIKitMessageListViewBubbleStyle.arrow
                ? 4
                : 16),
        border: Border.all(
          width: 1,
          color: theme.color.isDark
              ? downloadError
                  ? theme.color.neutralColor3
                  : theme.color.neutralColor2
              : downloadError
                  ? theme.color.neutralColor8
                  : theme.color.neutralColor9,
        ),
      ),
      child: content,
    );

    return content;
  }

  void download() {
    if (downloading) return;
    downloading = true;
    if (message.thumbnailLocalPath?.isNotEmpty == true) {
      ChatUIKit.instance.downloadThumbnail(message: message);
    } else {
      ChatUIKit.instance.downloadAttachment(message: message);
    }
  }

  Widget loadError(double width, double height) {
    final theme = ChatUIKitTheme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.color.isDark
            ? theme.color.neutralColor2
            : theme.color.neutralColor9,
      ),
      child: Center(
        child: ChatUIKitImageLoader.imageDefault(
          width: 64,
          height: 64,
          color: theme.color.isDark
              ? theme.color.neutralColor5
              : theme.color.neutralColor7,
        ),
      ),
    );
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}
