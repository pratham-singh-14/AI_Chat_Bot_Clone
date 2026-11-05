import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/pdf_repository.dart';
import 'data/services/chat_api_service.dart';
import 'data/services/pdf_api_service.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = Get.put<ApiClient>(ApiClient(), permanent: true);
  final chatApiService = Get.put<ChatApiService>(ChatApiService(apiClient), permanent: true);
  final pdfApiService = Get.put<PdfApiService>(PdfApiService(apiClient), permanent: true);

  Get.put<ChatRepository>(ChatRepository(chatApiService), permanent: true);
  Get.put<PdfRepository>(PdfRepository(pdfApiService), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenAI Multimodal Chatbot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
