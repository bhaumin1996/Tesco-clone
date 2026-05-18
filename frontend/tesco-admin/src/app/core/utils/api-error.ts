/**
 * Extracts the human-readable error message from the API's standard error envelope.
 *
 * API response shape:
 *   { "success": false, "error": { "code": "...", "message": "...", "details": [] } }
 *
 * Usage:
 *   error: (err) => this.message.set(extractApiError(err, 'Default fallback message.'))
 */
export function extractApiError(err: unknown, fallback = 'An unexpected error occurred. Please try again.'): string {
  if (!err || typeof err !== 'object') return fallback;
  const httpErr = err as { error?: { error?: { message?: string }; message?: string } };
  // Standard envelope:  err.error.error.message
  const enveloped = httpErr.error?.error?.message;
  if (enveloped && typeof enveloped === 'string' && enveloped.trim()) return enveloped.trim();
  // Flat shape:  err.error.message  (legacy / some endpoints)
  const flat = httpErr.error?.message;
  if (flat && typeof flat === 'string' && flat.trim()) return flat.trim();
  return fallback;
}
