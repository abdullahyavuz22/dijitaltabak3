-- Dijital Tabağım - İlk Veritabanı Şeması
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın

-- UUID desteği
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- TARIFLER TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS public.tarifler (
    id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    isim        TEXT        NOT NULL,
    resim       TEXT,
    kategori    TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security etkinleştir
ALTER TABLE public.tarifler ENABLE ROW LEVEL SECURITY;

-- Herkese okuma izni (public read)
CREATE POLICY "Tarifler herkese acik okuma"
    ON public.tarifler
    FOR SELECT
    TO public
    USING (true);

-- =============================================
-- BASLANGIC VERISI
-- =============================================
INSERT INTO public.tarifler (isim, resim, kategori) VALUES
    ('Menemen',      'assets/images/soganli-menemen.jpg',     'Kahvaltı'),
    ('Kuru Fasulye', 'assets/images/kuru-fasulye-yemekcom.jpg', 'Öğle Yemeği'),
    ('Mantı',        'assets/images/kayseri-mantisi.jpg',     'Akşam Yemeği'),
    ('Baklava',      'assets/images/fistikli-baklava.jpg',    'Tatlı');
