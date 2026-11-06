-- Dijital Tabağım - Kullanıcının Kendi Hesabını Silmesi
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın
--
-- Uygulama `supabase.rpc('delete_my_account')` çağırır. Fonksiyon yalnızca
-- OTURUM SAHİBİNİN hesabını siler; başka bir kullanıcıyı silemez.
--
-- auth.users satırı silinince şu veriler de otomatik silinir (ON DELETE CASCADE):
--   kullanicilar (profil), favoriler, kilo_takibi
-- diyet_planlari.olusturan_id → NULL olur (diyetisyenin paylaştığı planlar kalır).
-- sorular tablosu e-postaya bağlı olduğu için ayrıca silinir.

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid   UUID := auth.uid();
  mail  TEXT := auth.jwt() ->> 'email';
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Oturum bulunamadı';
  END IF;

  IF mail IS NOT NULL THEN
    DELETE FROM public.sorular WHERE email = mail;
  END IF;

  DELETE FROM auth.users WHERE id = uid;
END;
$$;

-- Sadece giriş yapmış kullanıcılar çağırabilsin
REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;

NOTIFY pgrst, 'reload schema';
