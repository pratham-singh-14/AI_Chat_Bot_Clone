import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/chat_repository.dart';
import '../controller/chat_list_controller.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListController>(
      () => ChatListController(Get.find<ChatRepository>(), Get.find<ApiClient>()),
    );
  }
}
