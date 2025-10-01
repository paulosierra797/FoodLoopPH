-- Stored procedure to return users joined with their food listings
-- Aligns with Flutter app tables: public.users and public.food_listings
-- Maps food_listings.title -> food_name, food_listings.description -> food_description
-- Apply in your Supabase project's SQL editor.

create or replace function public.get_user_food_listings(
    p_posted_by uuid default null,
    p_status text default null,
    p_limit int default null,
    p_offset int default 0,
    p_order_by text default 'created_at',
    p_order_dir text default 'desc'
)
returns table (
    user_id uuid,
    user_email text,
    user_first_name text,
    user_last_name text,
    listing_id uuid,
    food_name text,
    food_description text,
  status text,
  created_at timestamp
)
language plpgsql
security invoker
as $$
declare
  _order_col text := lower(coalesce(p_order_by, 'created_at'));
  _order_dir text := lower(coalesce(p_order_dir, 'desc'));
  _col text;
  _dir text;
  _sql text;
begin
  -- validate and map order column to a safe identifier
  if _order_col = 'food_name' then
    _col := 'f.title';
  elsif _order_col = 'user_email' then
    _col := 'u.email';
  else
    _col := 'f.created_at';
  end if;

  if _order_dir = 'asc' then
    _dir := 'ASC';
  else
    _dir := 'DESC';
  end if;

  _sql := 'SELECT'
    || ' u.id AS user_id,'
    || ' u.email AS user_email,'
    || ' u.first_name AS user_first_name,'
    || ' u.last_name AS user_last_name,'
    || ' f.id AS listing_id,'
    || ' f.title AS food_name,'
    || ' f.description AS food_description,'
  || ' f.status,'
  || ' f.created_at'
    || ' FROM public.users u'
    || ' JOIN public.food_listings f ON f.posted_by = u.id'
    || ' WHERE 1=1';

  if p_posted_by is not null then
    _sql := _sql || ' AND f.posted_by = ' || quote_literal(p_posted_by);
  end if;

  if p_status is not null then
    _sql := _sql || ' AND f.status = ' || quote_literal(p_status);
  end if;

  _sql := _sql || ' ORDER BY ' || _col || ' ' || _dir;

  if p_limit is not null then
    _sql := _sql || ' LIMIT ' || p_limit;
  end if;

  if p_offset is not null and p_offset > 0 then
    _sql := _sql || ' OFFSET ' || p_offset;
  end if;

  return query execute _sql;
end;
$$;

-- Auth-scoped wrapper: returns only listings posted by the currently authenticated user
create or replace function public.get_my_food_listings(
    p_status text default null,
    p_limit int default null,
    p_offset int default 0,
    p_order_by text default 'created_at',
    p_order_dir text default 'desc'
)
returns table (
    user_id uuid,
    user_email text,
    user_first_name text,
    user_last_name text,
    listing_id uuid,
    food_name text,
    food_description text,
  status text,
  created_at timestamp
)
language plpgsql
security invoker
as $$
declare
  _order_col text := lower(coalesce(p_order_by, 'created_at'));
  _order_dir text := lower(coalesce(p_order_dir, 'desc'));
  _col text;
  _dir text;
  _sql text;
  _uid uuid := auth.uid();
begin
  if _uid is null then
    -- no authenticated user
    return;
  end if;

  if _order_col = 'food_name' then
    _col := 'f.title';
  elsif _order_col = 'user_email' then
    _col := 'u.email';
  else
    _col := 'f.created_at';
  end if;

  if _order_dir = 'asc' then
    _dir := 'ASC';
  else
    _dir := 'DESC';
  end if;

  _sql := 'SELECT'
    || ' u.id AS user_id,'
    || ' u.email AS user_email,'
    || ' u.first_name AS user_first_name,'
    || ' u.last_name AS user_last_name,'
    || ' f.id AS listing_id,'
    || ' f.title AS food_name,'
    || ' f.description AS food_description,'
  || ' f.status,'
  || ' f.created_at'
    || ' FROM public.users u'
    || ' JOIN public.food_listings f ON f.posted_by = u.id'
    || ' WHERE f.posted_by = ' || quote_literal(_uid::text);

  if p_status is not null then
    _sql := _sql || ' AND f.status = ' || quote_literal(p_status);
  end if;

  _sql := _sql || ' ORDER BY ' || _col || ' ' || _dir;

  if p_limit is not null then
    _sql := _sql || ' LIMIT ' || p_limit;
  end if;

  if p_offset is not null and p_offset > 0 then
    _sql := _sql || ' OFFSET ' || p_offset;
  end if;

  return query execute _sql;
end;
$$;
