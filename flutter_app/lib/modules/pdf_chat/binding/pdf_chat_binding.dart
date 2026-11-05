import 'package:get/get.dart';
import '../../../data/repositories/pdf_repository.dart';
import '../controller/pdf_chat_controller.dart';

class PdfChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfChatController>(
      () => PdfChatController(Get.find<PdfRepository>()),
    );
  }
}
