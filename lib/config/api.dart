/// MyC API Configuration — single source of truth for endpoint URLs.
class ApiConfig {
  static const String baseUrl = 'https://crispybroasted.com/myc-api1';

  // Auth
  static const String register = '$baseUrl/api/auth/register.php';
  static const String login = '$baseUrl/api/auth/login.php';
  static const String logout = '$baseUrl/api/auth/logout.php';
  static const String logoutAll = '$baseUrl/api/auth/logout-all.php';
  static const String checkUsername = '$baseUrl/api/auth/check-username.php';
  static const String firebaseToken = '$baseUrl/api/auth/firebase-token.php';

  // Profile
  static const String profileGet = '$baseUrl/api/profile/get.php';
  static const String profileUpdate = '$baseUrl/api/profile/update.php';
  static const String profileSearch = '$baseUrl/api/profile/search.php';
  static const String uploadAvatar = '$baseUrl/api/profile/upload-avatar.php';

  // Chats
  static const String chatCreate = '$baseUrl/api/chats/create.php';
  static const String chatList = '$baseUrl/api/chats/list.php';
  static const String chatGet = '$baseUrl/api/chats/get.php';
  static const String chatPin = '$baseUrl/api/chats/pin.php';
  static const String chatMute = '$baseUrl/api/chats/mute.php';

  // Groups
  static const String groupUpdate = '$baseUrl/api/groups/update.php';
  static const String groupAddMember = '$baseUrl/api/groups/add-member.php';
  static const String groupRemoveMember = '$baseUrl/api/groups/remove-member.php';
  static const String groupSetAdmin = '$baseUrl/api/groups/set-admin.php';
  static const String groupSetNickname = '$baseUrl/api/groups/set-nickname.php';

  // Sessions
  static const String sessionsList = '$baseUrl/api/auth/sessions.php';
  static const String sessionRevoke = '$baseUrl/api/auth/session-revoke.php';

  // Messages
  static const String messageSend = '$baseUrl/api/messages/send.php';
  static const String messageList = '$baseUrl/api/messages/list.php';
  static const String messageEdit = '$baseUrl/api/messages/edit.php';
  static const String messageDelete = '$baseUrl/api/messages/delete.php';
  static const String messageReact = '$baseUrl/api/messages/react.php';
  static const String messageRead = '$baseUrl/api/messages/read.php';
  static const String messageStar = '$baseUrl/api/messages/star.php';
  static const String messagePin = '$baseUrl/api/messages/pin.php';
  static const String messageForward = '$baseUrl/api/messages/forward.php';
  static const String messagesStarred = '$baseUrl/api/messages/starred.php';

  // Media
  static const String mediaUpload = '$baseUrl/api/media/upload.php';

  // Calls
  static const String callStart = '$baseUrl/api/calls/start.php';
  static const String callAnswer = '$baseUrl/api/calls/answer.php';
  static const String callEnd = '$baseUrl/api/calls/end.php';
  static const String callHistory = '$baseUrl/api/calls/history.php';

  // Contacts
  static const String contactAdd = '$baseUrl/api/contacts/add.php';
  static const String contactRemove = '$baseUrl/api/contacts/remove.php';
  static const String contactList = '$baseUrl/api/contacts/list.php';
  static const String contactFavorite = '$baseUrl/api/contacts/favorite.php';

  // Blocks
  static const String blockUser = '$baseUrl/api/blocks/block.php';
  static const String unblockUser = '$baseUrl/api/blocks/unblock.php';
  static const String blockList = '$baseUrl/api/blocks/list.php';

  // Stories
  static const String storyCreate = '$baseUrl/api/stories/create.php';
  static const String storyList = '$baseUrl/api/stories/list.php';
  static const String storyView = '$baseUrl/api/stories/view.php';
  static const String storyDelete = '$baseUrl/api/stories/delete.php';

  // Settings
  static const String settingsGet = '$baseUrl/api/settings/get.php';
  static const String settingsUpdate = '$baseUrl/api/settings/update.php';
  static const String settingsChatOverride = '$baseUrl/api/settings/chat-override.php';

  // Palettes
  static const String paletteSave = '$baseUrl/api/palettes/save.php';
  static const String paletteList = '$baseUrl/api/palettes/list.php';
  static const String paletteApply = '$baseUrl/api/palettes/apply.php';
  static const String paletteDelete = '$baseUrl/api/palettes/delete.php';

  // Typing
  static const String typingSet = '$baseUrl/api/typing/set.php';

  // Push
  static const String pushRegister = '$baseUrl/api/push/register.php';
}
