import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/student_sync_service.dart';

/// Read-only learner sync state. Authentication is automatic and this widget
/// intentionally contains no email/password controls.
class StudentSyncStatusIndicator extends StatelessWidget {
  const StudentSyncStatusIndicator({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final sync = state.sync;
    final storageError = state.storageError;
    final (icon, label, color) = storageError != null
        ? (
            Icons.sd_storage_outlined,
            state.text('Storage unavailable', 'Hindi ma-save sa storage'),
            const Color(0xFFB91C1C),
          )
        : switch (sync.phase) {
            SyncPhase.local => (
                Icons.save_outlined,
                state.text('Saved on this device', 'Naka-save sa device'),
                const Color(0xFF475569),
              ),
            SyncPhase.pending => (
                Icons.cloud_upload_outlined,
                state.text('Pending upload', 'Naghihintay i-upload'),
                const Color(0xFFB45309),
              ),
            SyncPhase.syncing => (
                Icons.sync,
                state.text('Syncing', 'Nagsi-sync'),
                const Color(0xFF0369A1),
              ),
            SyncPhase.synced => (
                Icons.cloud_done_outlined,
                state.text('Synced', 'Naka-sync'),
                const Color(0xFF047857),
              ),
            SyncPhase.error => (
                Icons.cloud_off_outlined,
                state.text('Sync failed', 'Hindi nag-sync'),
                const Color(0xFFB91C1C),
              ),
          };

    return Semantics(
      liveRegion: true,
      label: label,
      child: Tooltip(
        message: storageError ?? sync.lastError ?? label,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (sync.phase == SyncPhase.syncing)
                SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
