/*
  # Add Translation System to Support Messages

  1. Changes to `support_messages` table:
    - Add `original_message` column (stores original message before translation)
    - Add `original_language` column (stores detected language code like 'en', 'tr', 'es')
    - Add `show_language` column (admin's preferred language, default 'tr')

  2. Migration Strategy:
    - Copy existing messages to original_message
    - Set default values for existing records
    - New messages will use translation system

  3. Usage:
    - Admin writes in Turkish → Translated to customer's language
    - Customer writes in any language → Translated to Turkish for admin
    - Both see each other's messages in their own language
    - Can toggle to see original text
*/

-- Add new columns for translation system
ALTER TABLE support_messages
ADD COLUMN IF NOT EXISTS original_message text,
ADD COLUMN IF NOT EXISTS original_language varchar(10),
ADD COLUMN IF NOT EXISTS show_language varchar(10) DEFAULT 'auto';

-- Copy existing messages to original_message for backward compatibility
UPDATE support_messages
SET original_message = message,
    original_language = 'unknown'
WHERE original_message IS NULL;

-- Create index for faster language filtering
CREATE INDEX IF NOT EXISTS idx_support_messages_language
ON support_messages(original_language);

-- Add comment for documentation
COMMENT ON COLUMN support_messages.original_message IS 'Original message before translation';
COMMENT ON COLUMN support_messages.original_language IS 'ISO 639-1 language code (e.g., en, tr, es, de, fr)';
COMMENT ON COLUMN support_messages.show_language IS 'Target language for display (auto = detect from user)';
