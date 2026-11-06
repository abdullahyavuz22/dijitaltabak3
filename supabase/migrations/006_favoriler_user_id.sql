-- favoriler tablosuna recipe_id ve user_id ekle, RLS'i kullanıcıya özel yap

ALTER TABLE public.favoriler
  ADD COLUMN IF NOT EXISTS recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE;

ALTER TABLE public.favoriler
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Eski politikaları kaldır
DROP POLICY IF EXISTS "Favoriler herkese acik okuma" ON public.favoriler;
DROP POLICY IF EXISTS "Herkes favori ekleyebilir"   ON public.favoriler;
DROP POLICY IF EXISTS "Herkes favori silebilir"     ON public.favoriler;
DROP POLICY IF EXISTS "favoriler_okuma"             ON public.favoriler;
DROP POLICY IF EXISTS "favoriler_ekleme"            ON public.favoriler;
DROP POLICY IF EXISTS "favoriler_silme"             ON public.favoriler;

-- Kullanıcı sadece kendi favorilerini görür / ekler / siler
CREATE POLICY "favoriler_okuma" ON public.favoriler
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "favoriler_ekleme" ON public.favoriler
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "favoriler_silme" ON public.favoriler
  FOR DELETE USING (auth.uid() = user_id);
