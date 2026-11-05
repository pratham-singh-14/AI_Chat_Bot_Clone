import 'package:get/get.dart';
import '../modules/chat/binding/chat_binding.dart';
import '../modules/chat/view/chat_view.dart';
import '../modules/chat_list/binding/chat_list_binding.dart';
import '../modules/chat_list/view/chat_list_view.dart';
import '../modules/pdf_chat/binding/pdf_chat_binding.dart';
import '../modules/pdf_chat/view/pdf_chat_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.chatList;

  static final routes = [
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListView(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.pdfChat,
      page: () => const PdfChatView(),
      binding: PdfChatBinding(),
    ),
  ];
}
