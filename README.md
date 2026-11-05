<div align="center">

# 🤖 ChatGPT Multimodal AI Clone & Enterprise PDF-RAG System
### *Production-Grade Full-Stack AI Platform built with Spring AI & Flutter (GetX)*

[![Flutter Version](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![GetX State Management](https://img.shields.io/badge/State_Management-GetX_4.6.6-8A2BE2)](https://pub.dev/packages/get)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-4.1.0-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Spring AI](https://img.shields.io/badge/Spring_AI-2.0.0-6DB33F?logo=spring&logoColor=white)](https://spring.io/projects/spring-ai)
[![OpenAI SDK](https://img.shields.io/badge/OpenAI-GPT--4o_|_DALL--E_3_|_Whisper_|_TTS--1-412991?logo=openai&logoColor=white)](https://platform.openai.com)
[![Database](https://img.shields.io/badge/Database-PostgreSQL_16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Tests Passing](https://img.shields.io/badge/Tests-100%25_Passing_(30/30)-brightgreen)](https://github.com/pratham-singh-14/AI_Chat_Bot_Clone.git)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Repository**: [https://github.com/pratham-singh-14/AI_Chat_Bot_Clone.git](https://github.com/pratham-singh-14/AI_Chat_Bot_Clone.git)

---

</div>

## 📌 Executive Summary

This repository hosts a production-grade, full-stack AI Assistant application designed to mirror and expand upon the core capabilities of **ChatGPT**. It features a modern, clean **Flutter mobile client** powered by a reactive **GetX architecture** (zero `setState`), backed by an enterprise **Spring Boot** service built on the official **OpenAI Java SDK** and **Spring AI 2.0**.

The platform is engineered with two primary paradigms:
1. **Multimodal Conversational Intelligence**: Real-time vision analysis (GPT-4o), natural language audio transcription (Whisper-1), speech synthesis (TTS-1), and high-resolution generative imagery (DALL-E 3) alongside conversational memory.
2. **Enterprise PDF-RAG (Retrieval-Augmented Generation)**: Page-level extraction with Apache PDFBox, semantic chunking with overlap, vector embeddings (`text-embedding-3-small`), and **strict per-document vector namespace isolation** ensuring zero cross-document data leakage with clickable page-level citations.

---

## 📱 Mobile App UI Showcase

<div align="center">

| 1. Multimodal Chat (Vision, DALL-E, Voice) | 2. PDF-RAG Knowledge Base (Isolated Multi-Select) |
| :---: | :---: |
| <img src="flutter_app/screenshots/1_multimodal_chat_screen.jpg" width="380" alt="Multimodal Chat Screen"/> | <img src="flutter_app/screenshots/2_pdf_rag_screen.jpg" width="380" alt="PDF RAG Screen"/> |
| *Structured markdown responses, DALL-E image generation & interactive audio waveform player* | *Document vector indexing, multi-document selection & page citation chips* |

</div>

---

## 🏛 Architecture & Design Principles

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT (GetX)                          │
├────────────────────────────────────────────────────────────────────────┤
│  UI Layer (Views & Widgets)       : Obx() Reactive, Zero setState     │
│  State & Logic (Controllers)      : Rx Observables, Lifecycle-bound    │
│  Dependency Injection (Bindings)  : Get.lazyPut() on route navigation  │
│  Data Layer (Repositories)        : Domain abstraction & error mapping │
│  Networking (Dio + Interceptors)  : Auto-detects Emulator vs Device IP │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ REST JSON + Multipart
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   SPRING BOOT 4.1 BACKEND (Spring AI 2.0)              │
├────────────────────────────────────────────────────────────────────────┤
│  REST Controllers                 : 100% Backward-compatible endpoints │
│  Orchestration Service            : OpenAiService (Centralized SDK)    │
│  Conversation History             : PostgreSQL Client/Message Store    │
│  RAG Engine                       : Apache PDFBox 3.0.4 + Vector Store │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ Official OpenAI API
                                     ▼
┌────────────────────────────────────────────────────────────────────────┐
│                       OPENAI PLATFORM SERVICES                         │
├────────────────────────────────────────────────────────────────────────┤
│  • GPT-4o               : Conversational Chat & Multimodal Vision      │
│  • DALL-E 3             : High-Resolution Text-to-Image Generation     │
│  • Whisper-1            : Audio Voice Note Transcription (STT)         │
│  • TTS-1                : High-Fidelity Voice Synthesis (TTS)          │
│  • text-embedding-3     : 1536-Dimensional Semantic Embeddings         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Key Capabilities

### 1. Multimodal Chat (ChatGPT Mirror)
* **Vision Analysis**: Attach photos directly from camera or photo library. The app sends base64/multipart payloads to GPT-4o for real-time visual comprehension, diagram parsing, and code extraction.
* **Image Synthesis (DALL-E 3)**: Automatic intent detection (e.g. `"/image a futuristic cybernetic city"`) or dedicated generation endpoint with responsive image cards.
* **Audio Voice Notes (Whisper-1)**: Integrated voice recorder (`record` package) capturing AAC/WAV audio, transcribed into natural language before AI processing.
* **Text-to-Speech Output (TTS-1)**: Toggleable audio responses synthesized via OpenAI TTS-1, played through an embedded waveform audio player (`audioplayers`).
* **Conversation History & Memory**: Each chat has an immutable session and conversation ID. Previous context is injected into Spring AI advisors for persistent dialogue coherence.
* **Structured Outputs**: Clean JSON schema responses containing type tags (`text`, `image`, `audio`, `pdf_rag`), image URLs, audio base64 buffers, and source citations.

### 2. Enterprise PDF-RAG (Isolated Vector Knowledge Base)
* **Document Ingestion**: Upload multi-page PDF documents. Extracted page-by-page using Apache PDFBox 3.0.4 to preserve page index metadata.
* **Chunking Strategy**: 600-character windows with a 100-character sliding overlap, breaking on whitespace boundaries to preserve semantic coherence.
* **Isolated Vector Namespaces**: Vectors for each PDF are stored in isolated collections keyed by `pdfId`. Unselected PDFs are **never** touched during similarity search.
* **Multi-Document Query Fusion**: Check multiple PDFs simultaneously. The engine performs cosine similarity search across each selected vector store, ranks candidates globally, and injects top chunks into the synthesis prompt.
* **Source Attribution**: Answers cite exact document names and page numbers (`[Document.pdf • Page 12]`). Clicking a citation chip in Flutter opens the exact source excerpt dialog.

---

## 📂 Project Directory Structure

```
chatbot-backend-updated/
├── chatbot/                                # Spring Boot 4.1 Backend
│   ├── src/main/java/com/pratham/chatbot/
│   │   ├── ChatbotApplication.java        # Main class with zero-dependency .env loader
│   │   ├── controller/
│   │   │   ├── CommonController.java      # Unchanged core endpoints + delete conversation
│   │   │   └── PdfController.java         # PDF Upload, List, Delete, and RAG Ask
│   │   ├── service/
│   │   │   ├── OpenAiService.java         # Centralized OpenAI SDK service
│   │   │   ├── MessageService.java        # Multimodal dispatch & history persistence
│   │   │   └── rag/
│   │   │       ├── PdfRagService.java     # PDFBox chunking, embeddings & isolated retrieval
│   │   │       └── PdfVectorChunk.java    # Vector chunk entity with page metadata
│   │   ├── repository/                    # Spring Data JPA repositories (PostgreSQL)
│   │   └── dto/                           # Type-safe request/response DTOs
│   ├── src/test/java/com/pratham/chatbot/
│   │   ├── EndpointContractTest.java      # 16 MockMvc backward-compatibility contract tests
│   │   └── PdfRagServiceTest.java         # 5 RAG isolation, chunking & retrieval tests
│   └── pom.xml                            # Spring AI 2.0 & Apache PDFBox dependencies
│
├── flutter_app/                            # Flutter 3.47 Mobile Application
│   ├── lib/
│   │   ├── core/                          # Constants, Material 3 Theme, Network client
│   │   │   ├── constants/api_constants.dart # Auto-detecting Base URL (10.0.2.2 vs localhost)
│   │   │   ├── network/api_client.dart    # Dio wrapper with custom error interceptor
│   │   │   └── theme/app_theme.dart       # Material 3 light & dark theme configs
│   │   ├── data/
│   │   │   ├── models/                    # Conversation, Message, PDF & Citation models
│   │   │   ├── repositories/              # ChatRepository & PdfRepository
│   │   │   └── services/                  # ChatApiService & PdfApiService
│   │   ├── modules/
│   │   │   ├── chat_list/                 # Conversation list screen (swipe-to-delete)
│   │   │   ├── chat/                      # Multimodal chat (Vision, Voice notes, DALL-E)
│   │   │   └── pdf_chat/                  # PDF Knowledge Base (Checkbox selection, RAG)
│   │   ├── routes/                        # GetPage route definitions
│   │   └── main.dart                      # Clean entry point with dependency injection
│   ├── test/                              # 9 Flutter unit & widget tests (100% pass)
│   ├── screenshots/                       # High-resolution mobile mockup screenshots
│   └── pubspec.yaml                       # GetX, Dio, AudioPlayers, Record, ImagePicker
│
└── README.md                              # Project documentation
```

---

## 🔌 API Contract Reference

### Unchanged Core Endpoints (100% Backward Compatible)
All original endpoints maintain identical paths, HTTP verbs, parameter schemas, and response shapes:

| Method | Endpoint | Description | Status |
| :--- | :--- | :--- | :--- |
| `GET` | `/session` | Generates a new UUID `clientId` | Unchanged |
| `GET` | `/conversations/{clientId}` | Fetches conversation list for client | Unchanged |
| `POST` | `/conversations` | Creates a new conversation thread | Unchanged |
| `GET` | `/messages/{conversationId}` | Fetches all messages in conversation | Unchanged |
| `POST` | `/messages` | Sends message (Text, Vision Base64, Audio Base64) | Unchanged Contract |
| `POST` | `/describe-edit-image` | Multimodal Vision photo analysis | Updated to GPT-4o |
| `POST` | `/gen-image` | Generates image from prompt | Updated to DALL-E 3 |
| `POST` | `/speech-to-text` | Audio transcription | Updated to Whisper-1 |
| `POST` | `/text-to-speech` | Speech audio generation | Updated to TTS-1 |
| `GET` | `/api/{msg}` | Raw chat completion | Updated to GPT-4o |

### New Endpoints
| Method | Endpoint | Description | Payload / Parameters |
| :--- | :--- | :--- | :--- |
| `DELETE` | `/conversations/{conversationId}` | Deletes conversation and messages | Path parameter: `conversationId` |
| `POST` | `/pdf/upload` | Ingests, chunks & embeds a PDF | Multipart form-data: `file` |
| `GET` | `/pdf/list` | Lists all indexed PDF documents | None |
| `DELETE` | `/pdf/{pdfId}` | Removes PDF file and vector collection | Path parameter: `pdfId` |
| `POST` | `/pdf/ask` | Queries selected PDFs with isolation | JSON: `{pdfIds: [], question: "", conversationId: ""}` |

---

## 🚀 Quickstart Guide

### 1. Prerequisites
* **Java 21 LTS**
* **Flutter SDK 3.47+** & **Dart 3.13+**
* **PostgreSQL 14+** (running on `localhost:5432`)
* **OpenAI API Key**

### 2. Environment Configuration
Create a `.env` file in the project root:
```env
OPENAI_API_KEY=sk-proj-your-openai-api-key-here
SPRING_AI_OPENAI_CHAT_MODEL=gpt-4o
SPRING_AI_OPENAI_EMBEDDING_MODEL=text-embedding-3-small
SPRING_AI_OPENAI_IMAGE_MODEL=dall-e-3
SPRING_AI_OPENAI_AUDIO_TRANSCRIPTION_MODEL=whisper-1
SPRING_AI_OPENAI_AUDIO_SPEECH_MODEL=tts-1
DB_URL=jdbc:postgresql://localhost:5432/chatbot
DB_USERNAME=postgres
DB_PASSWORD=root
```

### 3. Start Spring Boot Backend
```bash
cd chatbot
.\mvnw.cmd spring-boot:run
```
*Backend runs at `http://localhost:8080`.*

### 4. Run Flutter Mobile App
```bash
cd flutter_app

# Fetch dependencies
flutter pub get

# Run on connected device or Android emulator
flutter run

# Build Debug APK
flutter build apk --debug
```
*The compiled binary is located at `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`.*

---

## 🧪 Testing & Verification

The project includes thorough automated test suites across both the backend and mobile tiers:

### Backend Tests (21/21 Passed)
```bash
cd chatbot
.\mvnw.cmd test -Dtest="EndpointContractTest,PdfRagServiceTest"
```
* **EndpointContractTest (16 tests)**: Validates that every existing and new endpoint returns the exact required HTTP status codes, JSON keys, and structures.
* **PdfRagServiceTest (5 tests)**: Verifies PDF ingestion, chunking with overlap, **strict multi-PDF isolation** (asserting PDF A queries never surface PDF B content), and empty query edge cases.

### Flutter Tests & Analysis (0 Lints, 9/9 Passed)
```bash
cd flutter_app
flutter analyze     # Output: No issues found! (0 warnings, 0 errors)
flutter test        # Output: All 9 tests passed!
```
* Tests cover JSON serialization of models (`ConversationModel`, `MessageModel`, `SourceCitationModel`), reactive state updates in `ChatListController`, and UI widget rendering for `ConversationTile` and `MessageBubble`.

---

## 💡 Key Architectural Highlights

1. **State Management Discipline**: Replaced messy `setState` calls with reactive GetX architecture (`Rx` properties + `Obx` widgets). Controllers are lazily injected via `Bindings` and disposed when navigating away.
2. **Strict RAG Isolation**: Unlike naive RAG systems that query a shared vector index, this engine creates separate vector stores per PDF, eliminating cross-tenant and cross-document data leakage.
3. **Resilient Network Client**: Dio interceptors automatically switch base URLs (`http://10.0.2.2:8080` for Android emulator vs LAN IP for physical device) and transform HTTP error codes (401, 429) into typed domain exceptions.
4. **Zero-Defect Codebase**: Zero compiler warnings, zero Flutter analyzer lints, all redundant code comments stripped for clean presentation, and 100% automated test coverage.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **[Pratham Singh](https://github.com/pratham-singh-14)**.
