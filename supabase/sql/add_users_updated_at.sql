-- Ensure users table has an updated_at column and a trigger to maintain it
-- This fixes errors like: record "new" has no field "updated_at"

-- 1) Add the column if missing
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

-- 2) Create a reusable trigger function to set updated_at on UPDATE
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;

-- 3) Attach/refresh the trigger on the users table
DROP TRIGGER IF EXISTS set_public_users_updated_at ON public.users;
CREATE TRIGGER set_public_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Optional: backfill existing rows' updated_at
-- UPDATE public.users SET updated_at = NOW() WHERE updated_at IS NULL;

-- Notes:
-- - If you already have another BEFORE UPDATE trigger that references NEW.updated_at,
--   simply adding this column resolves the error. Keeping this trigger ensures the
--   timestamp is kept current on subsequent updates.
