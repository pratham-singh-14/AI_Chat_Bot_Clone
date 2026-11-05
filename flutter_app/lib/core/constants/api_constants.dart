import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  static String baseUrl = defaultBaseUrl;

  static const String session = '/session';
  static const String conversations = '/conversations';
  static const String messages = '/messages';
  static const String describeEditImage = '/describe-edit-image';
  static const String genImage = '/gen-image';
  static const String speechToText = '/speech-to-text';
  static const String textToSpeech = '/text-to-speech';
  static const String embed = '/embed';
  static const String similarity = '/similarity';

  static const String pdfUpload = '/pdf/upload';
  static const String pdfList = '/pdf/list';
  static const String pdfAsk = '/pdf/ask';

  static String conversationHistory(String clientId) => '/conversations/$clientId';
  static String messageList(String conversationId) => '/messages/$conversationId';
  static String deleteConversation(String conversationId) => '/conversations/$conversationId';
  static String deletePdf(String pdfId) => '/pdf/$pdfId';
}
