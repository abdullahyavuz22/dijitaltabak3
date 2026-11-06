-- Dijital Tabağım - Kullanıcılar Tablosu
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın

CREATE TABLE IF NOT EXISTS kullanicilar (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  ad TEXT NOT NULL,
  soyad TEXT,
  email TEXT NOT NULL,
  telefon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE kullanicilar ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kullanici_okuma" ON kullanicilar
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "kullanici_ekleme" ON kullanicilar
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "kullanici_guncelleme" ON kullanicilar
  FOR UPDATE USING (auth.uid() = id);

-- =============================================
-- TEST KULLANICISI
-- E-posta : test@dijitaltabagim.com
-- Şifre   : Test1234!
-- =============================================
DO $$
DECLARE
  test_id UUID := gen_random_uuid();
BEGIN
  -- Auth kullanıcısı oluştur
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    confirmation_token,
    recovery_token
  ) VALUES (
    test_id,
    '00000000-0000-0000-0000-000000000000',
    'test@dijitaltabagim.com',
    crypt('Test1234!', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    'authenticated',
    'authenticated',
    '',
    ''
  );

  -- Auth identity kaydı (email provider için gerekli)
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    test_id,
    json_build_object('sub', test_id::text, 'email', 'test@dijitaltabagim.com'),
    'email',
    NOW(),
    NOW(),
    NOW()
  );

  -- kullanicilar tablosuna profil ekle
  INSERT INTO kullanicilar (id, ad, soyad, email)
  VALUES (test_id, 'Test', 'Kullanıcı', 'test@dijitaltabagim.com');
END $$;
