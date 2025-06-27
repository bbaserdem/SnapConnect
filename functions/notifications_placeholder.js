/**
 * Cloud Functions placeholder – Group Message Notifications
 * ---------------------------------------------------------
 * This file is a stub to demonstrate where notification logic will live
 * in Phase 2 (backend work).  It is *not* deployed in Phase 1.
 *
 * Desired behaviour:
 *   • Trigger: onCreate of documents in /messages/{messageId} where isGroupMessage == true
 *   • Read conversationId and participantIds
 *   • For each participant (except sender) look up FCM token and send a notification
 *   • Include unread count badge in payload (future)
 *
 * The actual implementation will require:
 *   • Firebase Admin SDK initialisation
 *   • FCM send logic
 *   • Firestore security for service account
 */

// eslint-disable-next-line @typescript-eslint/no-unused-vars
exports.onGroupMessageCreate = (change, context) => {
  // no-op placeholder
  console.log('onGroupMessageCreate placeholder – implement in Phase 2');
}; 