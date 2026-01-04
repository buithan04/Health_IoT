const socketIo = require('socket.io');
const jwt = require('jsonwebtoken');
const chatService = require('./services/chat_service');
const notifService = require('./services/notification_service');
const callHistoryService = require('./services/call_history_service');
const { pool } = require('./config/db');

let io;
const onlineUsers = new Map(); // Lưu map: userId -> socketId

const initSocket = (server) => {
    io = socketIo(server, {
        cors: { origin: "*" }
    });
    global.io = io;

    io.use((socket, next) => {
        const token = socket.handshake.auth.token || socket.handshake.query.token;
        if (!token) return next(new Error("Authentication error"));

        jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
            if (err) return next(new Error("Authentication error"));
            socket.user = user;
            next();
        });
    });

    io.on('connection', (socket) => {
        // Log khi user kết nối để debug
        const userId = socket.user.id.toString(); // Chuyển luôn sang String để đồng nhất
        console.log(`\n${'='.repeat(60)}`);
        console.log(`⚡ [SOCKET] USER CONNECTED`);
        console.log(`   User ID: ${userId}`);
        console.log(`   Socket ID: ${socket.id}`);
        console.log(`   User Email: ${socket.user.email || 'N/A'}`);
        console.log(`${'='.repeat(60)}\n`);

        onlineUsers.set(userId, socket.id);
        io.emit('user_status_change', { userId, isOnline: true });

        socket.on('join_conversation', (data, ack) => {
            // Ép kiểu sang String để đảm bảo room "10" (string) và 10 (int) là một
            const conversationId = data.conversationId || data;
            const room = conversationId.toString();
            socket.join(room);
            console.log(`\n🔗 [SOCKET] USER JOINED CONVERSATION`);
            console.log(`   User ID: ${userId}`);
            console.log(`   Conversation ID: ${room}`);
            console.log(`   Socket ID: ${socket.id}`);
            console.log(`${'='.repeat(60)}\n`);

            // Send acknowledgment back to client
            if (ack && typeof ack === 'function') {
                ack({ success: true, room: room, userId: userId });
            }
        });

        socket.on('leave_conversation', (data) => {
            const conversationId = data.conversationId || data;
            const room = conversationId.toString();
            socket.leave(room);
            console.log(`\n👋 [SOCKET] USER LEFT CONVERSATION`);
            console.log(`   User ID: ${userId}`);
            console.log(`   Conversation ID: ${room}`);
            console.log(`${'='.repeat(60)}\n`);
        });

        // 2. Xử lý khi User vào màn hình chat (Đã xem)
        socket.on('mark_read', async (data) => {
            try {
                const { conversationId, partnerId } = data;
                if (!conversationId) return;

                console.log(`\n👁️  [SOCKET] MARKING MESSAGES AS READ`);
                console.log(`   Conversation: ${conversationId}`);
                console.log(`   Reader: ${userId}`);

                // Update DB - Returns list of updated message IDs
                const updatedMessages = await chatService.markMessagesAsRead(conversationId, userId);

                console.log(`   ✅ Updated ${updatedMessages.length} messages to 'seen'`);

                // [FIX CRITICAL] Emit status update cho TỪNG message với messageId cụ thể
                updatedMessages.forEach(msg => {
                    console.log(`   📤 Emitting status update for message ${msg.id}`);

                    const statusData = {
                        conversationId: conversationId,
                        messageId: msg.id.toString(),
                        status: 'seen',
                        readerId: userId
                    };

                    // Emit vào ROOM (để người đang trong chat nhận)
                    io.to(conversationId.toString()).emit('message_status_update', statusData);

                    // [FIX] Emit TRỰC TIẾP tới sender CHỈ KHI sender KHÔNG trong room
                    const senderId = msg.sender_id.toString();
                    const senderSocketId = onlineUsers.get(senderId);
                    if (senderSocketId) {
                        const senderSocket = io.sockets.sockets.get(senderSocketId);
                        const isInRoom = senderSocket?.rooms.has(conversationId.toString());

                        if (!isInRoom) {
                            io.to(senderSocketId).emit('message_status_update', statusData);
                            console.log(`   ✅ Sent status update directly to sender ${senderId} (not in room)`);
                        } else {
                            console.log(`   ℹ️  Sender ${senderId} already in room - skip direct emit`);
                        }
                    }
                });

                console.log(`${'='.repeat(60)}\n`);

            } catch (error) {
                console.error("❌ Error in mark_read:", error);
            }
        });

        socket.on('send_message', async (data) => {
            try {
                // [FIX QUAN TRỌNG] Phải lấy dữ liệu từ 'data' ra trước
                const { conversationId, content, type } = data;
                const messageType = type || 'text';

                // Đảm bảo SenderId là String
                const senderId = socket.user.id.toString();

                console.log(`📩 Msg from ${senderId} to room ${conversationId}: ${content}`);

                // [FIX] Kiểm tra conversation có tồn tại không trước khi lưu
                const convCheck = await pool.query(
                    'SELECT id FROM conversations WHERE id = $1',
                    [conversationId]
                );

                if (convCheck.rows.length === 0) {
                    console.error(`❌ Conversation ${conversationId} không tồn tại!`);

                    // Gửi lỗi về client
                    socket.emit('message_error', {
                        error: 'CONVERSATION_NOT_FOUND',
                        message: `Cuộc trò chuyện không tồn tại. Vui lòng tạo mới.`,
                        conversationId: conversationId
                    });
                    return;
                }

                // Lưu vào DB
                const savedMsg = await chatService.saveMessage(conversationId, senderId, content, messageType);

                // [FIX CRITICAL] Lấy thông tin sender từ DB để đảm bảo có đầy đủ thông tin
                const senderInfo = await pool.query(
                    `SELECT u.id, u.avatar_url, pr.full_name 
                     FROM users u 
                     LEFT JOIN profiles pr ON u.id = pr.user_id 
                     WHERE u.id = $1`,
                    [senderId]
                );

                // Format message với đầy đủ thông tin
                const fullMessage = {
                    id: savedMsg.id,
                    conversationId: conversationId,
                    conversation_id: conversationId, // Support both formats
                    senderId: senderId,
                    sender_id: senderId, // Support both formats
                    content: content,
                    type: messageType,
                    created_at: savedMsg.created_at,
                    senderName: senderInfo.rows[0]?.full_name || 'User',
                    senderAvatar: senderInfo.rows[0]?.avatar_url || '',
                    status: 'sent'
                };

                // [FIX CRITICAL] Broadcast tới ROOM (tất cả người trong conversation)
                console.log(`📤 Broadcasting message to room: ${conversationId}`);
                io.to(conversationId.toString()).emit('new_message', fullMessage);

                // [MESSENGER LOGIC] Prepare last message content for chat list
                const lastMsgContent = messageType === 'text' ? content :
                    messageType === 'image' ? '[Hình ảnh]' : '[Tệp đính kèm]';

                // Get receiver info
                const participantRes = await pool.query(
                    `SELECT user_id FROM participants WHERE conversation_id = $1 AND user_id != $2`,
                    [conversationId, senderId]
                );

                if (participantRes.rows.length > 0) {
                    const receiverId = participantRes.rows[0].user_id.toString();
                    const receiverSocketId = onlineUsers.get(receiverId);

                    // [MESSENGER LOGIC] Nếu receiver online (dù ở chat list hay trong chat), set status = delivered
                    if (receiverSocketId) {
                        console.log(`✅ Receiver ${receiverId} is online - updating status to delivered`);

                        // [MESSENGER LOGIC] Update TẤT CẢ messages từ sender thành 'delivered' (nếu chưa delivered/seen)
                        const updateResult = await pool.query(
                            `UPDATE messages 
                             SET status = 'delivered' 
                             WHERE conversation_id = $1 
                             AND sender_id = $2 
                             AND status = 'sent'
                             RETURNING id`,
                            [conversationId, senderId]
                        );

                        console.log(`   📊 Updated ${updateResult.rows.length} messages to delivered`);

                        // Emit status update cho TỪ message được update
                        for (const row of updateResult.rows) {
                            const statusData = {
                                conversationId: conversationId,
                                messageId: row.id.toString(),
                                status: 'delivered',
                                updatedBy: receiverId
                            };

                            // Emit status update to ROOM (cả sender và receiver)
                            io.to(conversationId.toString()).emit('message_status_update', statusData);

                            // [FIX] Emit TRỰC TIẾP tới sender CHỈ KHI không trong room
                            const senderSocketId = onlineUsers.get(senderId);
                            if (senderSocketId) {
                                const senderSocket = io.sockets.sockets.get(senderSocketId);
                                const isInRoom = senderSocket?.rooms.has(conversationId.toString());

                                if (!isInRoom) {
                                    io.to(senderSocketId).emit('message_status_update', statusData);
                                } else {
                                    console.log(`   ℹ️  Skip direct emit - sender in room`);
                                }
                            }
                        }

                        console.log(`   ✅ Sent ${updateResult.rows.length} status updates to sender`);
                    }

                    // [NEW - MESSENGER LOGIC] Emit conversation_updated tới receiver để chat list update
                    io.to(receiverSocketId).emit('conversation_updated', {
                        conversationId: conversationId,
                        lastMessage: lastMsgContent,
                        lastMessageAt: new Date(),
                        senderId: senderId
                    });
                    console.log(`   📋 Sent conversation_updated to receiver's chat list`);
                }

                // [NEW - MESSENGER LOGIC] Emit conversation_updated tới sender để chat list update
                const senderSocketId = onlineUsers.get(senderId);
                if (senderSocketId) {
                    io.to(senderSocketId).emit('conversation_updated', {
                        conversationId: conversationId,
                        lastMessage: lastMsgContent,
                        lastMessageAt: new Date(),
                        senderId: senderId
                    });
                    console.log(`   📋 Sent conversation_updated to sender's chat list`);
                }

                // --- LOGIC THÔNG BÁO ---
                if (participantRes.rows.length > 0) {
                    const receiverId = participantRes.rows[0].user_id.toString();

                    const senderName = senderInfo.rows[0]?.full_name || "Bạn mới";
                    const senderAvatar = senderInfo.rows[0]?.avatar_url || '';

                    let notifContent = content;
                    if (messageType === 'image') notifContent = '[Hình ảnh]';
                    if (messageType === 'file') notifContent = '[Tệp đính kèm]';

                    // 1. Lưu DB Notification với additionalData cho navigation
                    const newNotif = await notifService.createNotification({
                        userId: receiverId,
                        title: `Tin nhắn từ ${senderName}`,
                        message: notifContent,
                        type: 'NEW_MESSAGE',
                        relatedId: conversationId,
                        additionalData: {
                            conversationId: conversationId.toString(),
                            partnerId: userId.toString(),
                            partnerName: senderName,
                            partnerAvatar: senderAvatar
                        }
                    });

                    // 2. Gửi Socket thông báo
                    const receiverSocketId = onlineUsers.get(receiverId);
                    if (receiverSocketId) {
                        io.to(receiverSocketId).emit('NEW_NOTIFICATION', newNotif);
                        console.log(`🔔 Sent notification socket to User ${receiverId}`);
                    }
                }
            } catch (e) {
                console.error("❌ Socket Error:", e);

                // Gửi lỗi về client
                socket.emit('message_error', {
                    error: 'SEND_MESSAGE_FAILED',
                    message: 'Không thể gửi tin nhắn. Vui lòng thử lại.',
                    details: e.message
                });
            }
        });

        // 4. Kiểm tra trạng thái Online của 1 người (Client hỏi)
        socket.on('check_online', (targetUserId) => {
            // [FIX] Kiểm tra targetUserId có tồn tại không trước khi toString()
            if (!targetUserId) {
                // console.warn("⚠️ check_online: targetUserId is missing");
                return;
            }

            const isOnline = onlineUsers.has(targetUserId.toString());
            socket.emit('online_status_result', { userId: targetUserId, isOnline });
        });

        socket.on('disconnect', () => {
            onlineUsers.delete(userId);
            io.emit('user_status_change', { userId, isOnline: false });
            console.log(`🔌 User Offline: ${userId}`);
        });

        // --- [MỚI] XỬ LÝ VIDEO CALL ---
        socket.on('start_call', async (data) => {
            // data gồm: { receiverId, chatId, callerName }
            const { receiverId, chatId, callerName } = data;

            console.log(`📞 User ${socket.user.id} is calling User ${receiverId} in Chat ${chatId}`);

            const receiverSocketId = onlineUsers.get(receiverId);

            // 1. Nếu người nhận đang Online -> Gửi Socket để hiện màn hình gọi ngay
            if (receiverSocketId) {
                io.to(receiverSocketId).emit('INCOMING_CALL', {
                    chatId: chatId,       // Dùng làm CallID
                    callerId: socket.user.id,
                    callerName: callerName || "Ai đó",
                    avatar: socket.user.avatar_url // Nếu có
                });
            }

            // 2. Gửi FCM (Thông báo đẩy) để máy rung nếu đang tắt màn hình
            // Cần import fcmService ở đầu file
            const notifService = require('./services/notification_service'); // Đảm bảo đường dẫn đúng
            // Hoặc gọi trực tiếp fcmService nếu notification_service đã gọi nó
            const fcmService = require('./services/fcm_service');

            await fcmService.sendPushNotification(
                receiverId,
                "Cuộc gọi video đến 📞",
                `${callerName} đang gọi cho bạn...`,
                {
                    type: 'INCOMING_CALL',
                    relatedId: chatId,
                    callerName: callerName
                }
            );
        });

        // --- [WEBRTC] SIGNALING EVENTS ---

        // Nhận offer từ caller và forward tới callee
        socket.on('webrtc_offer', (data) => {
            console.log(`\n${'='.repeat(60)}`);
            console.log(`📞 [WEBRTC] OFFER RECEIVED - RAW DATA`);
            console.log(`   Raw data:`, JSON.stringify(data, null, 2));
            console.log(`${'='.repeat(60)}`);

            const { to, offer, callerName, callerAvatar, callType } = data;

            // [FIX] Đảm bảo 'to' là string để match với onlineUsers
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`📞 [WEBRTC] OFFER RECEIVED`);
            console.log(`   From User: ${socket.user.id}`);
            console.log(`   From Name: ${callerName || socket.user.name}`);
            console.log(`   To User: ${to} (type: ${typeof to})`);
            console.log(`   To User String: ${targetUserId}`);
            console.log(`   Target Socket ID: ${targetSocketId || 'OFFLINE'}`);
            console.log(`   Offer Type: ${offer?.type}`);
            console.log(`   SDP Length: ${offer?.sdp?.length || 0} chars`);
            console.log(`   Online Users:`, Array.from(onlineUsers.keys()));

            if (targetSocketId) {
                io.to(targetSocketId).emit('webrtc_offer', {
                    from: socket.user.id,
                    fromName: callerName || socket.user.name,
                    fromAvatar: callerAvatar || socket.user.avatar_url,
                    offer: offer,
                    callType: callType || 'video', // 'video' or 'audio'
                });
                console.log(`   ✅ Offer forwarded to target`);
            } else {
                console.log(`   ⚠️  User ${targetUserId} is offline - sending call_ended`);
                socket.emit('call_ended', {
                    from: targetUserId,
                    reason: 'User offline'
                });
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // Nhận answer từ callee và forward tới caller
        socket.on('webrtc_answer', (data) => {
            const { to, answer } = data;
            // [FIX] Convert to string to match onlineUsers keys
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`✅ [WEBRTC] ANSWER RECEIVED`);
            console.log(`   From User: ${socket.user.id}`);
            console.log(`   To User: ${to} (type: ${typeof to})`);
            console.log(`   To User String: ${targetUserId}`);
            console.log(`   Target Socket ID: ${targetSocketId || 'OFFLINE'}`);
            console.log(`   Answer Type: ${answer.type}`);
            console.log(`   SDP Length: ${answer.sdp?.length || 0} chars`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('webrtc_answer', {
                    from: socket.user.id,
                    answer: answer,
                });
                console.log(`   ✅ Answer forwarded to target`);
            } else {
                console.log(`   ⚠️  User ${targetUserId} is offline`);
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // Nhận ICE candidate và forward
        socket.on('webrtc_ice_candidate', (data) => {
            const { to, candidate } = data;
            // [FIX] Convert to string to match onlineUsers keys
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n🧊 [WEBRTC] ICE CANDIDATE RECEIVED`);
            console.log(`   From: ${socket.user.id} → To: ${targetUserId}`);
            console.log(`   Candidate: ${candidate.candidate?.substring(0, 50) || 'N/A'}...`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('webrtc_ice_candidate', {
                    from: socket.user.id,
                    candidate: candidate,
                });
                console.log(`   ✅ ICE candidate forwarded`);
            } else {
                console.log(`   ⚠️  User ${targetUserId} is offline`);
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // Từ chối cuộc gọi (reject_call -> call_ended)
        socket.on('reject_call', (data) => {
            const { callerId } = data;
            const targetUserId = callerId?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`❌ [WEBRTC] CALL REJECTED`);
            console.log(`   Rejected by User: ${socket.user.id}`);
            console.log(`   Caller User: ${targetUserId}`);
            console.log(`   Target Socket ID: ${targetSocketId || 'OFFLINE'}`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('call_ended', {
                    from: socket.user.id,
                    reason: 'rejected'
                });
                console.log(`   ✅ Call rejection notification sent`);
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // Kết thúc cuộc gọi
        socket.on('call_ended', (data) => {
            const { to } = data;
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`📴 [WEBRTC] CALL ENDED`);
            console.log(`   From User: ${socket.user.id}`);
            console.log(`   To User: ${targetUserId}`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('call_ended', {
                    from: socket.user.id,
                    reason: 'ended'
                });
                console.log(`   ✅ Call ended notification sent`);
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // ========== ZEGOCLOUD CALL SIGNALING ==========

        // ZegoCloud: Call invitation (gọi đến)
        socket.on('zego_call_invitation', async (data) => {
            const { to, callId, isVideoCall } = data;
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);
            const callerId = socket.user.id.toString();

            console.log(`\n${'='.repeat(60)}`);
            console.log(`📞 [ZEGO] CALL INVITATION`);
            console.log(`   From User: ${callerId} (${socket.user.email || 'N/A'})`);
            console.log(`   To User: ${targetUserId}`);
            console.log(`   Call ID: ${callId}`);
            console.log(`   Video Call: ${isVideoCall}`);
            console.log(`   Target Socket ID: ${targetSocketId || 'OFFLINE'}`);

            // Get caller's profile info for better UI
            let callerName = socket.user.email || 'User';
            let callerAvatar = null;

            try {
                const callerProfile = await pool.query(
                    `SELECT pr.full_name, u.avatar_url 
                     FROM users u 
                     LEFT JOIN profiles pr ON u.id = pr.user_id 
                     WHERE u.id = $1`,
                    [callerId]
                );

                if (callerProfile.rows.length > 0) {
                    callerName = callerProfile.rows[0].full_name || callerName;
                    callerAvatar = callerProfile.rows[0].avatar_url;
                }
            } catch (err) {
                console.error('   ⚠️ Error fetching caller profile:', err);
            }

            if (targetSocketId) {
                // Gửi socket event cho người online
                io.to(targetSocketId).emit('zego_call_invitation', {
                    callerId: callerId,
                    callerName: callerName,
                    callerAvatar: callerAvatar,
                    callId: callId,
                    isVideoCall: isVideoCall
                });
                console.log(`   ✅ Call invitation sent with profile info`);
            } else {
                console.log(`   ⚠️  Target user is offline - Will send FCM`);
            }

            // 🔔 GỬI FCM NOTIFICATION (Cả online và offline)
            // Notification này sẽ rung và hiện popup ngay cả khi app đang tắt
            try {
                const fcmService = require('./services/fcm_service');
                const callType = isVideoCall ? '📹 Cuộc gọi video' : '📞 Cuộc gọi thoại';
                
                await fcmService.sendPushNotification(
                    targetUserId,
                    `${callType} từ ${callerName}`,
                    targetSocketId ? 'Đang gọi...' : 'Nhấn để xem',
                    {
                        type: 'video_call',
                        callId: callId,
                        callerId: callerId,
                        callerName: callerName,
                        callerAvatar: callerAvatar || '',
                        isVideoCall: isVideoCall ? 'true' : 'false'
                    }
                );
                console.log(`   🔔 FCM notification sent`);
            } catch (err) {
                console.error(`   ⚠️ Error sending FCM:`, err);
            }
                
            // Lưu call history
            try {
                await callHistoryService.saveCallHistory({
                    callId: callId,
                    callerId: callerId,
                    receiverId: targetUserId,
                    callType: isVideoCall ? 'video' : 'audio',
                    status: 'calling',
                    duration: null,
                    startTime: new Date(),
                    endTime: null
                });
                console.log(`   💾 Saved call history`);
            } catch (err) {
                console.error(`   ⚠️ Error saving call history:`, err);
            }
            
            console.log(`${'='.repeat(60)}\n`);
        });

        // ZegoCloud: Call accepted (chấp nhận cuộc gọi)
        socket.on('zego_call_accepted', async (data) => {
            const { to, callId } = data;
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`✅ [ZEGO] CALL ACCEPTED`);
            console.log(`   Accepted by User: ${socket.user.id}`);
            console.log(`   Caller User: ${targetUserId}`);
            console.log(`   Call ID: ${callId}`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('zego_call_accepted', {
                    callId: callId,
                    acceptedBy: socket.user.id.toString()
                });
                console.log(`   ✅ Acceptance notification sent`);
                
                // Cập nhật call history
                try {
                    await callHistoryService.updateCallStatus(callId, 'connected');
                    console.log(`   💾 Updated call history: connected`);
                } catch (err) {
                    console.error(`   ⚠️ Error updating call history:`, err);
                }
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // ZegoCloud: Call declined (từ chối cuộc gọi)
        socket.on('zego_call_declined', async (data) => {
            const { to, callId } = data;
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`❌ [ZEGO] CALL DECLINED`);
            console.log(`   Declined by User: ${socket.user.id}`);
            console.log(`   Caller User: ${targetUserId}`);
            console.log(`   Call ID: ${callId}`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('zego_call_declined', {
                    callId: callId,
                    declinedBy: socket.user.id.toString()
                });
                console.log(`   ✅ Decline notification sent`);
                
                // Cập nhật call history
                try {
                    await callHistoryService.updateCallStatus(
                        callId, 
                        'declined',
                        null,
                        new Date()
                    );
                    console.log(`   💾 Updated call history: declined`);
                } catch (err) {
                    console.error(`   ⚠️ Error updating call history:`, err);
                }
            }
            console.log(`${'='.repeat(60)}\n`);
        });

        // ZegoCloud: Call ended (kết thúc cuộc gọi)
        socket.on('zego_call_ended', async (data) => {
            const { to, callId, duration } = data;
            const targetUserId = to?.toString();
            const targetSocketId = onlineUsers.get(targetUserId);

            console.log(`\n${'='.repeat(60)}`);
            console.log(`📴 [ZEGO] CALL ENDED`);
            console.log(`   From User: ${socket.user.id}`);
            console.log(`   To User: ${targetUserId}`);
            console.log(`   Call ID: ${callId}`);
            console.log(`   Duration: ${duration || 0}s`);

            if (targetSocketId) {
                io.to(targetSocketId).emit('zego_call_ended', {
                    callId: callId,
                    endedBy: socket.user.id.toString()
                });
                console.log(`   ✅ End notification sent`);
            }
            
            // Cập nhật call history với duration
            try {
                const status = duration > 0 ? 'completed' : 'cancelled';
                await callHistoryService.updateCallStatus(
                    callId,
                    status,
                    duration || 0,
                    new Date()
                );
                console.log(`   💾 Updated call history: ${status} (${duration || 0}s)`);
            } catch (err) {
                console.error(`   ⚠️ Error updating call history:`, err);
            }
            
            console.log(`${'='.repeat(60)}\n`);
        });
    });
};

module.exports = { initSocket };