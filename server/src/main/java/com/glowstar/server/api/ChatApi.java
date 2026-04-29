package com.glowstar.server.api;

import com.glowstar.server.model.Message;
import com.glowstar.server.service.NotificationService;
import spark.Request;
import spark.Response;
import spark.Route;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Chat API for GlowStar
 * 
 * Handles messaging, conversations, and real-time chat
 */
public class ChatApi {
    private Map<String, List<Message>> conversations = new ConcurrentHashMap<>();
    private NotificationService notificationService;

    public ChatApi(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    /**
     * Send message
     */
    public Route sendMessage = (Request request, Response response) -> {
        String conversationId = request.params(":conversationId");
        String senderId = request.queryParams("senderId");
        String content = request.queryParams("content");

        Message message = new Message(
            UUID.randomUUID().toString(),
            conversationId,
            senderId,
            content,
            System.currentTimeMillis()
        );

        conversations.computeIfAbsent(conversationId, k -> new ArrayList<>()).add(message);

        // Send notification to recipient
        String recipientId = getRecipientId(conversationId, senderId);
        if (recipientId != null) {
            notificationService.sendNotification(
                recipientId,
                NotificationService.NotificationType.MESSAGE,
                "新消息",
                content
            );
        }

        response.status(201);
        return Map.of("success", true, "messageId", message.getId());
    };

    /**
     * Get conversation messages
     */
    public Route getMessages = (Request request, Response response) -> {
        String conversationId = request.params(":conversationId");
        List<Message> messages = conversations.getOrDefault(conversationId, new ArrayList<>());

        return messages;
    };

    /**
     * Get user conversations
     */
    public Route getUserConversations = (Request request, Response response) -> {
        String userId = request.params(":userId");

        List<Map<String, Object>> userConversations = new ArrayList<>();
        for (Map.Entry<String, List<Message>> entry : conversations.entrySet()) {
            String conversationId = entry.getKey();
            List<Message> messages = entry.getValue();

            // Check if user is part of this conversation
            boolean isParticipant = messages.stream()
                .anyMatch(m -> m.getSenderId().equals(userId));

            if (isParticipant) {
                userConversations.add(Map.of(
                    "conversationId", conversationId,
                    "lastMessage", messages.isEmpty() ? "" : messages.get(messages.size() - 1).getContent(),
                    "messageCount", messages.size(),
                    "timestamp", messages.isEmpty() ? 0 : messages.get(messages.size() - 1).getTimestamp()
                ));
            }
        }

        return userConversations;
    };

    /**
     * Mark message as read
     */
    public Route markAsRead = (Request request, Response response) -> {
        String messageId = request.params(":messageId");
        String userId = request.queryParams("userId");

        // Find and mark message as read
        for (List<Message> messages : conversations.values()) {
            for (Message message : messages) {
                if (message.getId().equals(messageId)) {
                    message.setRead(true);
                    return Map.of("success", true);
                }
            }
        }

        response.status(404);
        return Map.of("error", "Message not found");
    };

    /**
     * Delete message
     */
    public Route deleteMessage = (Request request, Response response) -> {
        String messageId = request.params(":messageId");
        String userId = request.queryParams("userId");

        // Find and delete message
        for (List<Message> messages : conversations.values()) {
            messages.removeIf(m -> m.getId().equals(messageId) && m.getSenderId().equals(userId));
        }

        return Map.of("success", true);
    };

    /**
     * Helper method to get recipient ID
     */
    private String getRecipientId(String conversationId, String senderId) {
        List<Message> messages = conversations.get(conversationId);
        if (messages == null || messages.isEmpty()) return null;

        return messages.stream()
            .map(Message::getSenderId)
            .filter(id -> !id.equals(senderId))
            .findFirst()
            .orElse(null);
    }
}
