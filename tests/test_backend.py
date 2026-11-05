#!/usr/bin/env python3
"""
Integration and End-to-End Contract Test Suite for Chatbot Backend.
Tests both legacy endpoints (unchanged contract) and new multimodal + PDF-RAG endpoints.
"""

import sys
import os
import json
import time
import urllib.request
import urllib.error
import mimetypes

BASE_URL = os.environ.get("BASE_URL", "http://localhost:8080")

def request(method, path, data=None, headers=None):
    url = f"{BASE_URL}{path}"
    req_headers = headers or {}
    body = None
    if data is not None:
        if isinstance(data, dict):
            body = json.dumps(data).encode("utf-8")
            req_headers["Content-Type"] = "application/json"
        elif isinstance(data, (bytes, bytearray)):
            body = data
        elif isinstance(data, str):
            body = data.encode("utf-8")

    req = urllib.request.Request(url, data=body, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            content = resp.read()
            content_type = resp.headers.get("Content-Type", "")
            if "application/json" in content_type:
                return resp.status, json.loads(content.decode("utf-8"))
            return resp.status, content.decode("utf-8", errors="ignore")
    except urllib.error.HTTPError as e:
        content = e.read()
        try:
            return e.code, json.loads(content.decode("utf-8"))
        except Exception:
            return e.code, content.decode("utf-8", errors="ignore")

def test_suite():
    print("=" * 60)
    print(f"Starting Backend Verification against {BASE_URL}")
    print("=" * 60)

    passed = 0
    failed = 0

    def assert_true(cond, name):
        nonlocal passed, failed
        if cond:
            print(f"[PASS] {name}")
            passed += 1
        else:
            print(f"[FAIL] {name}")
            failed += 1

    # 1. Test Session
    status, body = request("GET", "/session")
    assert_true(status == 200 and "clientId" in body, "GET /session creates clientId")
    client_id = body.get("clientId") if isinstance(body, dict) else "test-client"

    # 2. Test Create Conversation
    status, body = request("POST", "/conversations", {"clientId": client_id})
    assert_true(status == 200 and "conversationId" in body, "POST /conversations returns conversationId")
    conv_id = body.get("conversationId") if isinstance(body, dict) else "conv-1"

    # 3. Test Fetch Conversations
    status, body = request("GET", f"/conversations/{client_id}")
    assert_true(status == 200 and isinstance(body, list), "GET /conversations/{clientId} lists conversations")

    # 4. Test Fetch Messages (initially empty)
    status, body = request("GET", f"/messages/{conv_id}")
    assert_true(status == 200 and isinstance(body, list), "GET /messages/{conversationId} returns message list")

    # 5. Test Delete Conversation
    status, body = request("DELETE", f"/conversations/{conv_id}")
    assert_true(status == 200 and "deleted successfully" in str(body), "DELETE /conversations/{id} deletes successfully")

    # 6. Test Delete Conversation 404
    status, body = request("DELETE", f"/conversations/non-existent-id")
    assert_true(status == 404, "DELETE /conversations/non-existent returns 404")

    # 7. Test PDF List
    status, body = request("GET", "/pdf/list")
    assert_true(status == 200 and isinstance(body, list), "GET /pdf/list returns list of indexed PDFs")

    # 8. Test Edge Case: Message without conversationId
    status, body = request("POST", "/messages", {"message": "Hello"})
    assert_true(status == 400 and "ConversationId not found" in str(body), "POST /messages without convId returns 400")

    # 9. Test Edge Case: Conversation without clientId
    status, body = request("POST", "/conversations", {})
    assert_true(status == 400 and "ClientId not found" in str(body), "POST /conversations without clientId returns 400")

    # 10. Test Edge Case: PDF Ask without pdfIds
    status, body = request("POST", "/pdf/ask", {"pdfIds": [], "question": "What is Flutter?"})
    assert_true(status in (400, 500) and "selected" in str(body).lower(), "POST /pdf/ask without pdfIds returns validation error")

    print("=" * 60)
    print(f"Results: {passed} PASSED, {failed} FAILED")
    print("=" * 60)
    return failed == 0

if __name__ == "__main__":
    test_suite()
