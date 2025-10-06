-- Create a view that joins users with their food listings
-- This provides a simpler alternative to calling the RPC function
-- Matches the actual food_listings table schema

CREATE OR REPLACE VIEW public.user_food_view AS
SELECT 
    u.id AS user_id,
    u.email AS user_email,
    u.first_name,
    u.last_name,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    f.id AS food_listing_id,
    f.title AS food_name,
    f.description,
    f.images,
    f.category,
    f.location,
    f.quantity,
    f.expiration_date,
    f.contact_number,
    f.is_urgent,
    f.status,
    f.posted_by,
    f.created_at
FROM public.users u
INNER JOIN public.food_listings f ON f.posted_by = u.id;

-- Grant access to authenticated users
GRANT SELECT ON public.user_food_view TO authenticated;
GRANT SELECT ON public.user_food_view TO anon;
