-- Dijital Tabağım - Kullanıcı Rolleri (user / admin)
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın

-- =============================================
-- ROL SÜTUNU
-- =============================================
ALTER TABLE public.kullanicilar
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';

ALTER TABLE public.kullanicilar
  DROP CONSTRAINT IF EXISTS kullanicilar_role_check;

ALTER TABLE public.kullanicilar
  ADD CONSTRAINT kullanicilar_role_check CHECK (role IN ('user', 'admin'));

-- =============================================
-- is_admin() — oturum sahibi admin mi?
-- SECURITY DEFINER: diğer tabloların RLS politikalarından
-- (recipes, videolu_tarifler, ...) güvenle çağrılabilsin diye.
-- =============================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.kullanicilar
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- =============================================
-- KULLANICILAR TABLOSU — rol yükseltmeyi engelle
-- =============================================

-- Kayıt olurken herkes sadece 'user' rolüyle kendi satırını ekleyebilir.
DROP POLICY IF EXISTS "kullanici_ekleme" ON public.kullanicilar;
CREATE POLICY "kullanici_ekleme" ON public.kullanicilar
  FOR INSERT WITH CHECK (auth.uid() = id AND role = 'user');

-- Kullanıcı kendi profilini günceller, ama role alanını değiştiremez
-- (aşağıdaki trigger ile korunuyor). Admin ise herkesin rolünü değiştirebilir.
DROP POLICY IF EXISTS "kullanici_admin_okuma" ON public.kullanicilar;
CREATE POLICY "kullanici_admin_okuma" ON public.kullanicilar
  FOR SELECT USING (public.is_admin());

DROP POLICY IF EXISTS "kullanici_admin_guncelleme" ON public.kullanicilar;
CREATE POLICY "kullanici_admin_guncelleme" ON public.kullanicilar
  FOR UPDATE USING (public.is_admin());

CREATE OR REPLACE FUNCTION public.kullanicilar_role_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Admin olmayan biri kendi rolünü değiştirmeye çalışırsa eski değer korunur.
  IF NEW.role IS DISTINCT FROM OLD.role AND NOT public.is_admin() THEN
    NEW.role := OLD.role;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_kullanicilar_role_guard ON public.kullanicilar;
CREATE TRIGGER trg_kullanicilar_role_guard
  BEFORE UPDATE ON public.kullanicilar
  FOR EACH ROW EXECUTE FUNCTION public.kullanicilar_role_guard();

-- =============================================
-- İÇERİK TABLOLARI — ekleme/güncelleme/silme sadece admin
-- Okuma herkese açık kalır (mevcut "... herkese acik okuma" politikaları).
-- =============================================

DROP POLICY IF EXISTS "recipes_admin_ekleme" ON public.recipes;
CREATE POLICY "recipes_admin_ekleme" ON public.recipes
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "recipes_admin_guncelleme" ON public.recipes;
CREATE POLICY "recipes_admin_guncelleme" ON public.recipes
  FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "recipes_admin_silme" ON public.recipes;
CREATE POLICY "recipes_admin_silme" ON public.recipes
  FOR DELETE USING (public.is_admin());

DROP POLICY IF EXISTS "tarifler_admin_ekleme" ON public.tarifler;
CREATE POLICY "tarifler_admin_ekleme" ON public.tarifler
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "tarifler_admin_guncelleme" ON public.tarifler;
CREATE POLICY "tarifler_admin_guncelleme" ON public.tarifler
  FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "tarifler_admin_silme" ON public.tarifler;
CREATE POLICY "tarifler_admin_silme" ON public.tarifler
  FOR DELETE USING (public.is_admin());

DROP POLICY IF EXISTS "videolu_tarifler_admin_ekleme" ON public.videolu_tarifler;
CREATE POLICY "videolu_tarifler_admin_ekleme" ON public.videolu_tarifler
  FOR INSERT WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "videolu_tarifler_admin_guncelleme" ON public.videolu_tarifler;
CREATE POLICY "videolu_tarifler_admin_guncelleme" ON public.videolu_tarifler
  FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "videolu_tarifler_admin_silme" ON public.videolu_tarifler;
CREATE POLICY "videolu_tarifler_admin_silme" ON public.videolu_tarifler
  FOR DELETE USING (public.is_admin());

-- diyet_planlari uygulamada kullanılıyor ama bu migration setinde
-- CREATE TABLE'ı yok — varsa aynı admin-only yazma kuralını uygula.
DO $$
BEGIN
  IF to_regclass('public.diyet_planlari') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE public.diyet_planlari ENABLE ROW LEVEL SECURITY';

    EXECUTE 'DROP POLICY IF EXISTS "diyet_planlari_admin_ekleme" ON public.diyet_planlari';
    EXECUTE 'CREATE POLICY "diyet_planlari_admin_ekleme" ON public.diyet_planlari
              FOR INSERT WITH CHECK (public.is_admin())';

    EXECUTE 'DROP POLICY IF EXISTS "diyet_planlari_admin_guncelleme" ON public.diyet_planlari';
    EXECUTE 'CREATE POLICY "diyet_planlari_admin_guncelleme" ON public.diyet_planlari
              FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin())';

    EXECUTE 'DROP POLICY IF EXISTS "diyet_planlari_admin_silme" ON public.diyet_planlari';
    EXECUTE 'CREATE POLICY "diyet_planlari_admin_silme" ON public.diyet_planlari
              FOR DELETE USING (public.is_admin())';
  END IF;
END $$;

-- =============================================
-- Admin ata (isteğe bağlı — istemiyorsan bu satırları silin)
-- NOT: dogukan.bayesen@rumeli.edu.tr, kullanicilar tablosunda ancak
-- bu e-posta ile uygulamaya kayıt olunduysa var olur; aksi halde bu
-- UPDATE hiçbir satırı etkilemez (hata vermez, sessizce 0 satır günceller).
-- =============================================
UPDATE public.kullanicilar SET role = 'admin'
  WHERE email = 'test@dijitaltabagim.com';

UPDATE public.kullanicilar SET role = 'admin'
  WHERE email = 'dogukan.bayesen@rumeli.edu.tr';
