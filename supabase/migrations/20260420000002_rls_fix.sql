-- Fix for Infinite Recursion in public.profiles

-- 1. Drop the broken policy
DROP POLICY IF EXISTS "profiles_admin" ON public.profiles;

-- 2. Create a Security Definer function that bypasses RLS to check for admin status
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- 3. Re-create the policy using the secure function
CREATE POLICY "profiles_admin" ON public.profiles
  FOR ALL USING ( public.is_admin() );
