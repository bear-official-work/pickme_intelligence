/*
  # Fix Admin Access to Officers Table

  1. Security Changes
    - Remove restrictive RLS policies for admins
    - Create permissive policies for all admin operations
    - Ensure admins can INSERT, SELECT, UPDATE, DELETE without restrictions
    
  2. Policy Structure
    - Admin users get full access to officers table
    - Officers maintain limited self-access
    - No RLS violations for authenticated admin users
*/

-- Drop all existing policies for officers table
DROP POLICY IF EXISTS "Admins can delete officers" ON officers;
DROP POLICY IF EXISTS "Admins can insert officers" ON officers;
DROP POLICY IF EXISTS "Admins can select officers" ON officers;
DROP POLICY IF EXISTS "Admins can update officers" ON officers;
DROP POLICY IF EXISTS "Officers can read own data" ON officers;
DROP POLICY IF EXISTS "Officers can update own data" ON officers;

-- Create comprehensive admin policies with full access
CREATE POLICY "Admin full access - select"
  ON officers
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admin full access - insert"
  ON officers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admin full access - update"
  ON officers
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admin full access - delete"
  ON officers
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

-- Maintain officer self-access policies
CREATE POLICY "Officers can read own data"
  ON officers
  FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text);

CREATE POLICY "Officers can update own data"
  ON officers
  FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);