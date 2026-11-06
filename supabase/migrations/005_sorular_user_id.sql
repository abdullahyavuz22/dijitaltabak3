-- sorular tablosu RLS politikaları (email üzerinden filtreleme)

ALTER TABLE public.sorular ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Sorular herkese acik okuma" ON public.sorular;
DROP POLICY IF EXISTS "Herkes soru sorabilir"      ON public.sorular;
DROP POLICY IF EXISTS "sorular_okuma"              ON public.sorular;
DROP POLICY IF EXISTS "sorular_ekleme"             ON public.sorular;

-- Kullanıcı sadece kendi e-postasıyla gönderilen soruları görebilir
CREATE POLICY "sorular_okuma" ON public.sorular
  FOR SELECT USING (email = auth.jwt() ->> 'email');

-- Kullanıcı sadece kendi e-postasıyla soru gönderebilir
CREATE POLICY "sorular_ekleme" ON public.sorular
  FOR INSERT WITH CHECK (email = auth.jwt() ->> 'email');
