/*
  # Fix RLS policies for officers table

  1. Policy Updates
    - Update INSERT policy to allow admins to add officers
    - Ensure admins can perform all CRUD operations on officers table
    - Keep existing policies for officers to read/update their own data

  2. Security
    - Maintain RLS enabled on officers table
    - Allow admins full access while restricting officers to their own data
*/

-- Drop existing policies that might be too restrictive
DROP POLICY IF EXISTS "Admins can insert officers" ON officers;
DROP POLICY IF EXISTS "Admins can select officers" ON officers;
DROP POLICY IF EXISTS "Admins can update officers" ON officers;
DROP POLICY IF EXISTS "Admins can delete officers" ON officers;

-- Create comprehensive admin policies
CREATE POLICY "Admins can insert officers"
  ON officers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE id::text = auth.uid()::text
    )
  );

CREATE POLICY "Admins can select officers"
  ON officers
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE id::text = auth.uid()::text
    )
  );

CREATE POLICY "Admins can update officers"
  ON officers
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE id::text = auth.uid()::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE id::text = auth.uid()::text
    )
  );

CREATE POLICY "Admins can delete officers"
  ON officers
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE id::text = auth.uid()::text
    )
  );

-- Keep existing officer self-access policies (if they don't exist, create them)
DO $$
BEGIN
  -- Check if officer self-select policy exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'officers' 
    AND policyname = 'Officers can read own data'
  ) THEN
    CREATE POLICY "Officers can read own data"
      ON officers
      FOR SELECT
      TO authenticated
      USING (auth.uid()::text = id::text);
  END IF;

  -- Check if officer self-update policy exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'officers' 
    AND policyname = 'Officers can update own data'
  ) THEN
    CREATE POLICY "Officers can update own data"
      ON officers
      FOR UPDATE
      TO authenticated
      USING (auth.uid()::text = id::text)
      WITH CHECK (auth.uid()::text = id::text);
  END IF;
END $$;