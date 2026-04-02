-- Dijital Tabağım - Tüm Tablolar
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın
-- NOT: Önce 001_initial.sql çalıştırılmış olmalıdır (tarifler tablosu gerekli)

-- =============================================
-- PROFILLER TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.profiller (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    ad          TEXT        NOT NULL,
    soyad       TEXT,
    email       TEXT        UNIQUE,
    telefon     TEXT,
    bio         TEXT,
    avatar_url  TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiller ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiller herkese acik okuma"
    ON public.profiller FOR SELECT TO public USING (true);

INSERT INTO public.profiller (ad, soyad, email, telefon, bio) VALUES
    ('Doğukan', 'BAYESEN', 'dogukan.bayesen@rumeli.edu.tr', '+90 555 123 45 67',
     'Flutter geliştiricisi, tarif meraklısı.');

-- =============================================
-- VIDEOLU_TARIFLER TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.videolu_tarifler (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    baslik      TEXT        NOT NULL,
    video_id    TEXT        NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.videolu_tarifler ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Videolar herkese acik okuma"
    ON public.videolu_tarifler FOR SELECT TO public USING (true);

INSERT INTO public.videolu_tarifler (baslik, video_id) VALUES
    ('Menemen Tarifi',      'ajdSDri1c-U'),
    ('Kuru Fasulye Tarifi', '7rORG0W31aE');

-- =============================================
-- SORULAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.sorular (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    email       TEXT        NOT NULL,
    konu        TEXT        NOT NULL,
    soru        TEXT        NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.sorular ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Sorular herkese acik okuma"
    ON public.sorular FOR SELECT TO public USING (true);

CREATE POLICY "Herkes soru sorabilir"
    ON public.sorular FOR INSERT TO public WITH CHECK (true);

-- =============================================
-- VKI_KAYITLARI TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.vki_kayitlari (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    boy         NUMERIC(5,1) NOT NULL,
    kilo        NUMERIC(5,1) NOT NULL,
    vki         NUMERIC(5,2) NOT NULL,
    durum       TEXT         NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.vki_kayitlari ENABLE ROW LEVEL SECURITY;

CREATE POLICY "VKI kayitlari herkese acik okuma"
    ON public.vki_kayitlari FOR SELECT TO public USING (true);

CREATE POLICY "Herkes VKI kaydedebilir"
    ON public.vki_kayitlari FOR INSERT TO public WITH CHECK (true);

-- =============================================
-- FAVORILER TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.favoriler (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    tarif_id    UUID        REFERENCES public.tarifler(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.favoriler ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Favoriler herkese acik okuma"
    ON public.favoriler FOR SELECT TO public USING (true);

CREATE POLICY "Herkes favori ekleyebilir"
    ON public.favoriler FOR INSERT TO public WITH CHECK (true);

CREATE POLICY "Herkes favori silebilir"
    ON public.favoriler FOR DELETE TO public USING (true);
