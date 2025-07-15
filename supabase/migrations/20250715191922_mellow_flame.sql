/*
  # Comprehensive RLS Fix for Officers Table

  1. Security Changes
    - Drop all existing restrictive policies on officers table
    - Create new permissive policies for admin users
    - Allow authenticated admin users full CRUD access
    - Maintain officer self-access policies

  2. Policy Details
    - Admins (users in admin_users table) get full access to all operations
    - Officers can read and update their own records only
    - No restrictions on admin operations once authenticated
*/

-- Drop all existing policies on officers table
DROP POLICY IF EXISTS "Admin full access - delete" ON officers;
DROP POLICY IF EXISTS "Admin full access - insert" ON officers;
DROP POLICY IF EXISTS "Admin full access - select" ON officers;
DROP POLICY IF EXISTS "Admin full access - update" ON officers;
DROP POLICY IF EXISTS "Officers can read own data" ON officers;
DROP POLICY IF EXISTS "Officers can update own data" ON officers;

-- Create comprehensive admin policies
CREATE POLICY "Admins can select all officers"
  ON officers
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can insert officers"
  ON officers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can update officers"
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

CREATE POLICY "Admins can delete officers"
  ON officers
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE admin_users.id = auth.uid()
    )
  );

-- Create officer self-access policies
CREATE POLICY "Officers can read own profile"
  ON officers
  FOR SELECT
  TO authenticated
  USING (auth.uid()::text = id::text);

CREATE POLICY "Officers can update own profile"
  ON officers
  FOR UPDATE
  TO authenticated
  USING (auth.uid()::text = id::text)
  WITH CHECK (auth.uid()::text = id::text);

-- Ensure RLS is enabled
ALTER TABLE officers ENABLE ROW LEVEL SECURITY;