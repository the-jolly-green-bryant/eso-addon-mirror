# Conductor v4.6.1-dev1.9

## Raid Plan transfer stabilization

- Added one exclusive Conductor transport lease while a Raid Plan is being shared.
- Pauses capability/profile traffic before the transfer begins and resumes one fresh profile after completion.
- Prevents already-running profile queues from continuing to compete with Raid Plan chunks.
- Removed redundant Raid Plan fields from the wire payload and reconstructs them after receipt.
- Keeps one data chunk in flight at a time and relies on LibGroupBroadcast queueing and local delivery confirmation.
- Added a transfer-size-aware timeout instead of a fixed three-minute deadline.
- Releases the transport lease on completion, cancellation, queue failure, timeout, and reload initialization.
- Preserves checksums, schema validation, sender validation, recipient roster validation, and Accept/Decline behavior.
