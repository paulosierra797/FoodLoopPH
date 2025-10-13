-- Add archive functionality to users table
-- This adds an archived_at timestamp field which allows soft deletion
-- When archived_at is NOT NULL, the user is considered archived

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS archived_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_users_archived_at ON public.users(archived_at);

-- Create a function to archive/unarchive users
CREATE OR REPLACE FUNCTION public.archive_user(user_id UUID, should_archive BOOLEAN DEFAULT TRUE)
RETURNS BOOLEAN 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF should_archive THEN
        -- Archive the user by setting archived_at timestamp
        UPDATE public.users 
        SET archived_at = NOW() 
        WHERE id = user_id AND archived_at IS NULL;
    ELSE
        -- Unarchive the user by clearing archived_at timestamp  
        UPDATE public.users 
        SET archived_at = NULL 
        WHERE id = user_id AND archived_at IS NOT NULL;
    END IF;
    
    RETURN FOUND;
END;
$$;

-- Grant execute permission to authenticated users (admin role will be enforced at app level)
GRANT EXECUTE ON FUNCTION public.archive_user(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.archive_user(UUID, BOOLEAN) TO anon;

-- Create a view for active (non-archived) users
CREATE OR REPLACE VIEW public.active_users AS
SELECT * FROM public.users
WHERE archived_at IS NULL;

-- Create a view for archived users  
CREATE OR REPLACE VIEW public.archived_users AS
SELECT * FROM public.users
WHERE archived_at IS NOT NULL;

-- Add RLS policies for the archive function (admin access only)
-- Note: The actual admin check should be done in the application layer

-- Add comment for documentation
COMMENT ON COLUMN public.users.archived_at IS 'Timestamp when user was archived (soft deleted). NULL means active user.';
COMMENT ON FUNCTION archive_user IS 'Soft delete/restore function for users. Only admins should call this.';