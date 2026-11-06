-- Dijital Tabağım - Diyet ve Video Favorileri
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın
-- NOT: Önce 006_favoriler_user_id.sql ve 008_diyetisyen.sql çalıştırılmış olmalıdır.
--
-- favoriler tablosuna diyet_id ve video_id sütunları eklenir. Her satır
-- tek bir öğeyi (tarif, diyet ya da video) işaret eder. Mevcut RLS
-- politikaları (kullanıcı sadece kendi favorilerini görür/ekler/siler)
-- aynen geçerlidir.

-- Sütun tipleri hedef tablonun id tipiyle aynı olsun (uuid / bigint fark etmez)
DO $$
DECLARE
  t TEXT;
BEGIN
  SELECT format_type(a.atttypid, a.atttypmod) INTO t
  FROM pg_attribute a
  WHERE a.attrelid = 'public.diyet_planlari'::regclass AND a.attname = 'id';

  EXECUTE format(
    'ALTER TABLE public.favoriler ADD COLUMN IF NOT EXISTS diyet_id %s
       REFERENCES public.diyet_planlari(id) ON DELETE CASCADE', t);

  SELECT format_type(a.atttypid, a.atttypmod) INTO t
  FROM pg_attribute a
  WHERE a.attrelid = 'public.videolu_tarifler'::regclass AND a.attname = 'id';

  EXECUTE format(
    'ALTER TABLE public.favoriler ADD COLUMN IF NOT EXISTS video_id %s
       REFERENCES public.videolu_tarifler(id) ON DELETE CASCADE', t);
END $$;

-- Aynı kullanıcı aynı diyeti / videoyu iki kez favorilemesin
CREATE UNIQUE INDEX IF NOT EXISTS favoriler_user_diyet_uq
  ON public.favoriler (user_id, diyet_id) WHERE diyet_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS favoriler_user_video_uq
  ON public.favoriler (user_id, video_id) WHERE video_id IS NOT NULL;

-- Video listesinin herkese açık okunabildiğinden emin ol
ALTER TABLE public.videolu_tarifler ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Videolar herkese acik okuma" ON public.videolu_tarifler;
CREATE POLICY "Videolar herkese acik okuma"
  ON public.videolu_tarifler FOR SELECT TO public USING (true);

-- PostgREST şema önbelleğini yenile (yeni sütunlar hemen görünsün)
NOTIFY pgrst, 'reload schema';
