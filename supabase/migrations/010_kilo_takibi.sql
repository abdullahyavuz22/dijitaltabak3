-- Dijital Tabağım - Kilo Takibi
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın
--
-- Her kullanıcı kendi kilo kayıtlarını görür / ekler / siler.

CREATE TABLE IF NOT EXISTS public.kilo_takibi (
    id          UUID          DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id     UUID          NOT NULL DEFAULT auth.uid()
                              REFERENCES auth.users(id) ON DELETE CASCADE,
    kilo        NUMERIC(5,1)  NOT NULL CHECK (kilo > 0 AND kilo < 500),
    tarih       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_at  TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS kilo_takibi_user_tarih_idx
  ON public.kilo_takibi (user_id, tarih);

ALTER TABLE public.kilo_takibi ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "kilo_okuma"   ON public.kilo_takibi;
DROP POLICY IF EXISTS "kilo_ekleme"  ON public.kilo_takibi;
DROP POLICY IF EXISTS "kilo_silme"   ON public.kilo_takibi;

CREATE POLICY "kilo_okuma" ON public.kilo_takibi
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "kilo_ekleme" ON public.kilo_takibi
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "kilo_silme" ON public.kilo_takibi
  FOR DELETE USING (auth.uid() = user_id);

NOTIFY pgrst, 'reload schema';
