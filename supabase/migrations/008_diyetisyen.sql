-- Dijital Tabağım - Diyetisyen Rolü + Diyet Planları
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın
-- NOT: Önce 007_roller.sql çalıştırılmış olmalıdır (is_admin() gerekli)

-- =============================================
-- ROL SÜTUNU — 'diyetisyen' değerine izin ver
-- =============================================
ALTER TABLE public.kullanicilar
  DROP CONSTRAINT IF EXISTS kullanicilar_role_check;

ALTER TABLE public.kullanicilar
  ADD CONSTRAINT kullanicilar_role_check
  CHECK (role IN ('user', 'admin', 'diyetisyen'));

-- =============================================
-- is_diyetisyen() — oturum sahibi diyetisyen mi?
-- =============================================
CREATE OR REPLACE FUNCTION public.is_diyetisyen()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.kullanicilar
    WHERE id = auth.uid() AND role = 'diyetisyen'
  );
$$;

-- =============================================
-- DIYET_PLANLARI TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.diyet_planlari (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    baslik      TEXT        NOT NULL,
    diyetisyen  TEXT        NOT NULL,
    aciklama    TEXT,
    kalori      INTEGER,
    sure        TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Planı ekleyen kullanıcı (diyetisyen kendi planlarını düzenleyebilsin diye)
ALTER TABLE public.diyet_planlari
  ADD COLUMN IF NOT EXISTS olusturan_id UUID
  REFERENCES auth.users(id) ON DELETE SET NULL
  DEFAULT auth.uid();

ALTER TABLE public.diyet_planlari ENABLE ROW LEVEL SECURITY;

-- Okuma herkese açık
DROP POLICY IF EXISTS "diyet_planlari_okuma" ON public.diyet_planlari;
CREATE POLICY "diyet_planlari_okuma" ON public.diyet_planlari
  FOR SELECT USING (true);

-- 007'deki admin-only politikaları kaldır, admin + diyetisyen olarak yeniden kur
DROP POLICY IF EXISTS "diyet_planlari_admin_ekleme"     ON public.diyet_planlari;
DROP POLICY IF EXISTS "diyet_planlari_admin_guncelleme" ON public.diyet_planlari;
DROP POLICY IF EXISTS "diyet_planlari_admin_silme"      ON public.diyet_planlari;
DROP POLICY IF EXISTS "diyet_planlari_ekleme"           ON public.diyet_planlari;
DROP POLICY IF EXISTS "diyet_planlari_guncelleme"       ON public.diyet_planlari;
DROP POLICY IF EXISTS "diyet_planlari_silme"            ON public.diyet_planlari;

-- Admin her şeyi ekleyebilir; diyetisyen sadece kendi adına ekleyebilir
CREATE POLICY "diyet_planlari_ekleme" ON public.diyet_planlari
  FOR INSERT WITH CHECK (
    public.is_admin()
    OR (public.is_diyetisyen() AND olusturan_id = auth.uid())
  );

-- Admin hepsini, diyetisyen sadece kendi planlarını günceller / siler
CREATE POLICY "diyet_planlari_guncelleme" ON public.diyet_planlari
  FOR UPDATE
  USING (public.is_admin() OR (public.is_diyetisyen() AND olusturan_id = auth.uid()))
  WITH CHECK (public.is_admin() OR (public.is_diyetisyen() AND olusturan_id = auth.uid()));

CREATE POLICY "diyet_planlari_silme" ON public.diyet_planlari
  FOR DELETE USING (
    public.is_admin()
    OR (public.is_diyetisyen() AND olusturan_id = auth.uid())
  );

-- =============================================
-- DİYETİSYEN TEST KULLANICISI
-- E-posta : diyetisyen@dijitaltabagim.com
-- Şifre   : Diyet1234!
-- =============================================
DO $$
DECLARE
  d_id UUID;
BEGIN
  SELECT id INTO d_id FROM auth.users WHERE email = 'diyetisyen@dijitaltabagim.com';

  IF d_id IS NULL THEN
    d_id := gen_random_uuid();

    INSERT INTO auth.users (
      id, instance_id, email, encrypted_password, email_confirmed_at,
      created_at, updated_at, raw_app_meta_data, raw_user_meta_data,
      aud, role, confirmation_token, recovery_token
    ) VALUES (
      d_id,
      '00000000-0000-0000-0000-000000000000',
      'diyetisyen@dijitaltabagim.com',
      crypt('Diyet1234!', gen_salt('bf')),
      NOW(), NOW(), NOW(),
      '{"provider":"email","providers":["email"]}',
      '{}',
      'authenticated',
      'authenticated',
      '',
      ''
    );

    INSERT INTO auth.identities (
      id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    ) VALUES (
      gen_random_uuid(),
      d_id::text,  -- email provider'da provider_id = kullanıcı id'si
      d_id,
      json_build_object('sub', d_id::text, 'email', 'diyetisyen@dijitaltabagim.com'),
      'email',
      NOW(), NOW(), NOW()
    );
  END IF;

  -- Supabase Auth (GoTrue) bu token sütunlarında NULL görünce girişte
  -- "Database error querying schema" hatası verir — boş string yap.
  UPDATE auth.users SET
    email_change               = COALESCE(email_change, ''),
    email_change_token_new     = COALESCE(email_change_token_new, ''),
    email_change_token_current = COALESCE(email_change_token_current, ''),
    phone_change               = COALESCE(phone_change, ''),
    phone_change_token         = COALESCE(phone_change_token, ''),
    reauthentication_token     = COALESCE(reauthentication_token, '')
  WHERE id = d_id;

  INSERT INTO public.kullanicilar (id, ad, soyad, email, role)
  VALUES (d_id, 'Dyt. Ayşe', 'Yılmaz', 'diyetisyen@dijitaltabagim.com', 'diyetisyen')
  ON CONFLICT (id) DO UPDATE SET role = 'diyetisyen';
END $$;

-- Var olan bir kullanıcıyı diyetisyen yapmak için:
-- UPDATE public.kullanicilar SET role = 'diyetisyen' WHERE email = '...';
