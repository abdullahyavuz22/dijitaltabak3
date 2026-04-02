-- Dijital Tabağım - Recipes Tablosu RLS + Seed Verisi
-- Supabase Dashboard > SQL Editor'de bu dosyayı çalıştırın

-- =============================================
-- RECIPES TABLOSU - RLS POLİTİKALARI
-- =============================================
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Recipes herkese acik okuma" ON public.recipes;
CREATE POLICY "Recipes herkese acik okuma"
    ON public.recipes FOR SELECT TO public USING (true);

-- =============================================
-- SEED VERİSİ
-- =============================================
INSERT INTO public.recipes (name, image_url, category, duration, rating, ingredients, instructions) VALUES

(
  'Menemen',
  'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600',
  'Kahvaltı',
  '20 dk',
  4.7,
  ARRAY[
    '3 yumurta',
    '2 adet domates',
    '1 adet yeşil biber',
    '1 adet soğan',
    '2 yemek kaşığı zeytinyağı',
    'Tuz, karabiber, pul biber'
  ],
  ARRAY[
    'Soğanı ince doğrayın, zeytinyağında kavurun.',
    'Biberi küçük doğrayıp ekleyin, 2-3 dakika kavurun.',
    'Domatesleri doğrayıp tavaya ekleyin, suyunu çekene kadar pişirin.',
    'Yumurtaları kırın, tuz ve baharatları ekleyin.',
    'İstediğiniz kıvama getirip sıcak servis edin.'
  ]
),

(
  'Kuru Fasulye',
  'https://images.unsplash.com/photo-1547592180-85f173990554?w=600',
  'Ana Yemek',
  '1 sa 30 dk',
  4.8,
  ARRAY[
    '500 g kuru fasulye',
    '200 g dana kavurma veya sucuk',
    '2 adet domates',
    '1 adet soğan',
    '2 yemek kaşığı salça',
    '2 yemek kaşığı zeytinyağı',
    'Tuz, karabiber'
  ],
  ARRAY[
    'Fasulyeyi bir gece önceden ıslatın.',
    'Islatılmış fasulyeyi tuzlu suda 30 dakika haşlayın, suyunu dökün.',
    'Tencerede yağı ısıtın, soğanı kavurun.',
    'Et veya sucuğu ekleyip kavurun.',
    'Salça ve domatesi ekleyin, birkaç dakika pişirin.',
    'Fasulyeleri ekleyin, üzerine sıcak su ilave edin.',
    'Kısık ateşte fasulyeler yumuşayana kadar pişirin (yaklaşık 45 dk).'
  ]
),

(
  'Kayseri Mantısı',
  'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600',
  'Ana Yemek',
  '1 saat',
  4.9,
  ARRAY[
    '2 su bardağı un',
    '1 yumurta',
    'Tuz, su (hamur için)',
    '200 g kıyma',
    '1 soğan (iç için)',
    'Karabiber',
    'Yoğurt, sarımsak, tereyağı, pul biber (sos için)'
  ],
  ARRAY[
    'Hamur malzemelerini yoğurun, 30 dakika dinlendirin.',
    'Soğanı rendeleyin, kıymayla karıştırın, tuzlayın.',
    'Hamuru ince açın, küçük kareler kesin.',
    'Her kareye az iç koyup köşelerini birleştirin.',
    'Tuzlu kaynar suda mantılar yüzene kadar haşlayın.',
    'Sarımsaklı yoğurdu üzerine dökün.',
    'Tereyağında pul biberi kızdırıp gezdirin.'
  ]
),

(
  'Fıstıklı Baklava',
  'https://images.unsplash.com/photo-1619221882220-947b3d3c8861?w=600',
  'Tatlı',
  '2 saat',
  4.9,
  ARRAY[
    '500 g yufka',
    '300 g antep fıstığı (öğütülmüş)',
    '250 g eritilmiş tereyağı',
    '2 su bardağı şeker',
    '1.5 su bardağı su',
    '1 tatlı kaşığı limon suyu'
  ],
  ARRAY[
    'Şerbeti hazırlayın: şeker ve suyu kaynatın, limon suyu ekleyin, soğumaya bırakın.',
    'Yufkaları eritilmiş tereyağı sürerek tepsiye dizin (10 kat).',
    'Öğütülmüş fıstığı düzgünce yayın.',
    'Üstüne kalan yufkaları yağlayarak serin.',
    'Dilimleyip 180°C fırında 35-40 dakika altın rengi alana kadar pişirin.',
    'Fırından çıkınca soğuk şerbeti dökün.',
    '2 saat dinlendirin.'
  ]
),

(
  'Mercimek Çorbası',
  'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600',
  'Çorba',
  '35 dk',
  4.6,
  ARRAY[
    '1 su bardağı kırmızı mercimek',
    '1 adet soğan',
    '1 adet havuç',
    '1 adet patates',
    '2 yemek kaşığı tereyağı',
    'Tuz, karabiber, kimyon, pul biber'
  ],
  ARRAY[
    'Soğan, havuç ve patatesi doğrayın.',
    'Tencerede tereyağını eritin, soğanı kavurun.',
    'Havuç ve patatesi ekleyin, 2-3 dakika kavurun.',
    'Yıkanmış mercimeği ekleyin, üzerini geçecek kadar su ekleyin.',
    'Yumuşayana kadar pişirin (yaklaşık 20 dk).',
    'Blenderdan geçirin, kıvamını ayarlayın.',
    'Tereyağında pul biber kızdırıp üzerine dökün.'
  ]
),

(
  'İmam Bayıldı',
  'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=600',
  'Sebze Yemeği',
  '1 sa 10 dk',
  4.5,
  ARRAY[
    '4 adet patlıcan',
    '3 adet soğan',
    '4 diş sarımsak',
    '4 adet domates',
    '1 adet yeşil biber',
    '½ su bardağı zeytinyağı',
    'Tuz, karabiber, maydanoz'
  ],
  ARRAY[
    'Patlıcanları almaşık soyun, tuzlu suda 15 dakika bekletin.',
    'Zeytinyağında patlıcanları hafifçe kavurun.',
    'Ayrı bir tencerede soğan, sarımsak ve biberi kavurun.',
    'Domatesi ekleyin, tuz ve baharatlarla pişirin.',
    'Patlıcanların ortasını çatallayın, iç harcı doldurun.',
    'Tencereye dizin, üzerine biraz su ve zeytinyağı ekleyin.',
    'Kapağı kapalı, kısık ateşte 40 dakika pişirin.'
  ]
);
