import 'package:em_chat_uikit/chat_uikit.dart';

import 'package:flutter/material.dart';

class SearchGroupMembersView extends StatefulWidget {
  SearchGroupMembersView.arguments(
    SearchGroupMembersViewArguments arguments, {
    super.key,
  })  : searchData = arguments.searchData,
        searchHideText = arguments.searchHideText,
        itemBuilder = arguments.itemBuilder,
        enableAppBar = arguments.enableAppBar,
        appBar = arguments.appBar,
        onTap = arguments.onTap,
        attributes = arguments.attributes;

  const SearchGroupMembersView({
    required this.searchData,
    required this.searchHideText,
    this.itemBuilder,
    this.onTap,
    this.appBar,
    this.enableAppBar = false,
    this.attributes,
    super.key,
  });

  final List<NeedSearch> searchData;
  final String searchHideText;
  final void Function(BuildContext context, ChatUIKitProfile profile)? onTap;
  final Widget Function(BuildContext context, ChatUIKitProfile profile,
      String? searchKeyword)? itemBuilder;
  final ChatUIKitAppBar? appBar;
  final bool enableAppBar;
  final String? attributes;

  @override
  State<SearchGroupMembersView> createState() =>
      _SSearchGroupMembersViewState();
}

class _SSearchGroupMembersViewState extends State<SearchGroupMembersView> {
  @override
  Widget build(BuildContext context) {
    final theme = ChatUIKitTheme.of(context);
    Widget content = ChatUIKitSearchWidget(
      searchHideText: widget.searchHideText,
      list: widget.searchData,
      autoFocus: true,
      builder: (context, searchKeyword, list) {
        return ChatUIKitListView(
          list: list,
          type: list.isEmpty
              ? ChatUIKitListViewType.empty
              : ChatUIKitListViewType.normal,
          enableSearchBar: false,
          itemBuilder: (context, model) {
            if (model is NeedSearch) {
              if (widget.itemBuilder != null) {
                return widget.itemBuilder!
                    .call(context, model.profile, searchKeyword);
              }

              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  widget.onTap?.call(context, model.profile);
                },
                child: ChatUIKitSearchListViewItem(
                  profile: model.profile,
                  highlightWord: searchKeyword,
                ),
              );
            }
            return const SizedBox();
          },
        );
      },
    );

    content = NotificationListener(
      child: content,
      onNotification: (notification) {
        if (notification is SearchNotification) {
          if (!notification.isSearch) {
            Navigator.of(context).pop();
          }
        }
        return false;
      },
    );

    content = Scaffold(
      backgroundColor: theme.color.isDark
          ? theme.color.neutralColor1
          : theme.color.neutralColor98,
      appBar: !widget.enableAppBar
          ? null
          : widget.appBar ?? const ChatUIKitAppBar(showBackButton: false),
      body: SafeArea(child: content),
    );

    return content;
  }
}
