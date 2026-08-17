'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import api from '@/services/api';
import { getMediaUrl } from '@/services/media';
import ProductCard from '@/components/ProductCard';
import StoryViewer from '@/components/StoryViewer';
import { 
  ChevronRight, 
  ShoppingBag, 
  ArrowRight, 
  Star, 
  ShieldCheck, 
  RefreshCw, 
  CreditCard,
  ChevronLeft,
  ArrowUpRight
} from 'lucide-react';

import { useRouter } from 'next/navigation';
import { useCartStore } from '@/store/cartStore';

const getSkuProductName = (sku: string, products: any[]) => {
   for (const prod of products) {
      if (prod.variants?.some((v: any) => v.sku === sku)) {
         return prod.name;
      }
   }
   return sku;
};

export default function Home() {
   const router = useRouter();
   const addItem = useCartStore((state) => state.addItem);

   const [newArrivals, setNewArrivals] = useState<any[]>([]);
   const [bestsellers, setBestsellers] = useState<any[]>([]);
   const [favoriteProducts, setFavoriteProducts] = useState<any[]>([]);
   const [homepageOffers, setHomepageOffers] = useState<any[]>([]);
   const [categories, setCategories] = useState<any[]>([]);
   const [loyaltyRewards, setLoyaltyRewards] = useState<any[]>([]);
   const [brands, setBrands] = useState<any[]>([]);
   const [loading, setLoading] = useState(true);
   const [currentSlide, setCurrentSlide] = useState(0);
   const [currentPromoIdx, setCurrentPromoIdx] = useState(0);
   const [cmsLayout, setCmsLayout] = useState<any>(null);
   const [activeStoryIdx, setActiveStoryIdx] = useState<number | null>(null);
   const [seenCategories, setSeenCategories] = useState<string[]>([]);
   const [currentAds1, setCurrentAds1] = useState(0);
   const [currentAds2, setCurrentAds2] = useState(0);
   const [currentAds3, setCurrentAds3] = useState(0);

   // Touch swipe states
   const [heroTouchStart, setHeroTouchStart] = useState<number | null>(null);
   const [heroTouchEnd, setHeroTouchEnd] = useState<number | null>(null);
   const [promoTouchStart, setPromoTouchStart] = useState<number | null>(null);
   const [promoTouchEnd, setPromoTouchEnd] = useState<number | null>(null);

   const minSwipeDistance = 40;

   const handleAddProductToCart = (prod: any, e?: React.MouseEvent) => {
      if (e) {
         e.preventDefault();
         e.stopPropagation();
      }
      const variant = prod.variants?.[0];
      if (!variant) return;
      addItem({
         id: variant.id,
         productId: prod.id,
         slug: prod.slug,
         name: prod.name,
         variantName: variant.sku,
         price: variant.selling_price,
         image: getMediaUrl(prod.images?.[0] || prod.image),
         quantity: 1,
         sizeMl: variant.size_ml,
         loyaltyPoints: variant.loyalty_points,
      });
   };

   const handleBuyNowProduct = (prod: any, e?: React.MouseEvent) => {
      if (e) {
         e.preventDefault();
         e.stopPropagation();
      }
      handleAddProductToCart(prod);
      router.push('/checkout');
   };

   useEffect(() => {
      if (typeof window !== 'undefined') {
         try {
            const seen = JSON.parse(sessionStorage.getItem('seen_stories') || '[]');
            setSeenCategories(seen);
         } catch (e) {
            console.error('Failed to load seen stories', e);
         }
      }
   }, []);

   const markCategoryAsSeen = (catId: string) => {
      setSeenCategories((prev) => {
         if (prev.includes(catId)) return prev;
         const updated = [...prev, catId];
         if (typeof window !== 'undefined') {
            sessionStorage.setItem('seen_stories', JSON.stringify(updated));
         }
         return updated;
      });
   };

   const activeSlides = cmsLayout?.hero_slides?.length ? cmsLayout.hero_slides : [];
   const heroSlidesToUse = activeSlides.length > 0 ? activeSlides : homepageOffers;

   useEffect(() => {
      if (heroSlidesToUse.length === 0) return;
      const interval = setInterval(() => {
         setCurrentSlide((prev) => (prev + 1) % heroSlidesToUse.length);
      }, 6000);
      return () => clearInterval(interval);
   }, [heroSlidesToUse]);

   // Flash Offers auto-slide timer (6 seconds)
   useEffect(() => {
      if (homepageOffers.length <= 1) return;
      const interval = setInterval(() => {
         setCurrentPromoIdx((prev) => (prev + 1) % homepageOffers.length);
      }, 6000);
      return () => clearInterval(interval);
   }, [homepageOffers.length]);

   // Touch swipe handlers
   const onHeroTouchStart = (e: React.TouchEvent) => {
      setHeroTouchEnd(null);
      setHeroTouchStart(e.targetTouches[0].clientX);
   };
   const onHeroTouchMove = (e: React.TouchEvent) => {
      setHeroTouchEnd(e.targetTouches[0].clientX);
   };
   const onHeroTouchEnd = () => {
      if (!heroTouchStart || !heroTouchEnd) return;
      const distance = heroTouchStart - heroTouchEnd;
      if (distance > minSwipeDistance) {
         setCurrentSlide((prev) => (prev + 1) % heroSlidesToUse.length);
      } else if (distance < -minSwipeDistance) {
         setCurrentSlide((prev) => (prev === 0 ? heroSlidesToUse.length - 1 : prev - 1));
      }
   };

   const onPromoTouchStart = (e: React.TouchEvent) => {
      setPromoTouchEnd(null);
      setPromoTouchStart(e.targetTouches[0].clientX);
   };
   const onPromoTouchMove = (e: React.TouchEvent) => {
      setPromoTouchEnd(e.targetTouches[0].clientX);
   };
   const onPromoTouchEnd = () => {
      if (!promoTouchStart || !promoTouchEnd) return;
      const distance = promoTouchStart - promoTouchEnd;
      if (distance > minSwipeDistance) {
         setCurrentPromoIdx((prev) => (prev + 1) % homepageOffers.length);
      } else if (distance < -minSwipeDistance) {
         setCurrentPromoIdx((prev) => (prev === 0 ? homepageOffers.length - 1 : prev - 1));
      }
   };

   useEffect(() => {
      const len = Array.isArray(cmsLayout?.grid_ads_1) ? cmsLayout.grid_ads_1.length : 1;
      if (len <= 1) return;
      const interval = setInterval(() => {
         setCurrentAds1((prev) => (prev + 1) % len);
      }, 6000);
      return () => clearInterval(interval);
   }, [cmsLayout?.grid_ads_1]);

   useEffect(() => {
      const len = Array.isArray(cmsLayout?.grid_ads_2) ? cmsLayout.grid_ads_2.length : 1;
      if (len <= 1) return;
      const interval = setInterval(() => {
         setCurrentAds2((prev) => (prev + 1) % len);
      }, 6000);
      return () => clearInterval(interval);
   }, [cmsLayout?.grid_ads_2]);

   useEffect(() => {
      const len = Array.isArray(cmsLayout?.grid_ads_3) ? cmsLayout.grid_ads_3.length : 1;
      if (len <= 1) return;
      const interval = setInterval(() => {
         setCurrentAds3((prev) => (prev + 1) % len);
      }, 6000);
      return () => clearInterval(interval);
   }, [cmsLayout?.grid_ads_3]);

   useEffect(() => {
      const fetchHomeData = async () => {
         try {
            const res = await api.get('/homepage');
            const data = res.data || {};
            
            setNewArrivals(data.new_arrivals || []);
            setBestsellers(data.bestsellers || []);
            setFavoriteProducts(data.favorites || []);
            setCategories(data.categories || []);
            setHomepageOffers(data.offers || []);
            setCmsLayout(data.layout || {});
            setLoyaltyRewards(data.rewards || []);
            setBrands(data.brands || []);
         } catch (err) {
            console.error('Failed to fetch home data', err);
         } finally {
            setLoading(false);
         }
      };
      fetchHomeData();
   }, []);

   if (loading) {
      return (
         <div className="fixed inset-0 bg-white z-[9999] flex flex-col items-center justify-center font-sans">
            <div className="relative mb-8 text-center">
               <img src="/logo.png" alt="Kozmocart Logo" className="h-16 md:h-20 object-contain animate-pulse mx-auto" />
               <div className="absolute -bottom-4 left-0 w-full h-[1px] bg-neutral-100 overflow-hidden">
                  <div className="h-full bg-accent animate-[loading_2s_ease-in-out_infinite]" />
               </div>
            </div>
            <span className="text-[10px] font-bold tracking-[0.4em] text-neutral-400 uppercase animate-pulse">Establishing Connection...</span>
            <style jsx>{`
               @keyframes loading {
                  0% { transform: translateX(-100%); }
                  100% { transform: translateX(100%); }
               }
            `}</style>
         </div>
      );
   }

    const getProductRedirectUrl = (productId: string | null | undefined): string => {
       if (!productId) return '/shop';
       const combined = [...newArrivals, ...bestsellers, ...favoriteProducts];
       const match: any = combined.find((p: any) => p.id === productId);
       if (match) return `/product/${match.slug}`;
       return `/shop?product_id=${productId}`;
    };

    // Resolve array layout for Grid Ads 1
    const gridAds1Raw = cmsLayout?.grid_ads_1;
    const gridAds1List: any[] = Array.isArray(gridAds1Raw) 
       ? gridAds1Raw 
       : (gridAds1Raw && typeof gridAds1Raw === 'object' && Object.keys(gridAds1Raw).length > 0)
          ? [gridAds1Raw] 
          : [];
    
    const gridAds1ToUse = gridAds1List.length > 0 ? gridAds1List.map((item: any) => ({
       left_image: item.left_image || '/model-banner-1.png',
       left_title: item.left_title || 'Exclusive Fragrance',
       left_subtitle: item.left_subtitle || 'Exquisite Collection',
       left_desc: item.left_desc || 'We offer the best niche fragrances on the market selected by our team of experts.',
       left_product_id: item.left_product_id || '',
       right_image: item.right_image || '/model-banner-2.png',
       right_title: item.right_title || 'Premium Fragrances',
       right_subtitle: item.right_subtitle || 'Prestige Selection',
       right_desc: item.right_desc || 'We offer the best niche fragrances on the market selected by our team of experts.',
       right_product_id: item.right_product_id || ''
    })) : [{
       left_image: '/model-banner-1.png',
       left_title: 'Exclusive Fragrance',
       left_subtitle: 'Exquisite Collection',
       left_desc: 'We offer the best niche fragrances on the market selected by our team of experts.',
       left_product_id: '',
       right_image: '/model-banner-2.png',
       right_title: 'Premium Fragrances',
       right_subtitle: 'Prestige Selection',
       right_desc: 'We offer the best niche fragrances on the market selected by our team of experts.',
       right_product_id: ''
    }];

    // Resolve array layout for Grid Ads 2
    const gridAds2Raw = cmsLayout?.grid_ads_2;
    const gridAds2List: any[] = Array.isArray(gridAds2Raw) 
       ? gridAds2Raw 
       : (gridAds2Raw && typeof gridAds2Raw === 'object' && Object.keys(gridAds2Raw).length > 0)
          ? [gridAds2Raw] 
          : [];

    const gridAds2ToUse = gridAds2List.length > 0 ? gridAds2List.map((item: any) => ({
       image: item.image || '/model-banner-3.png',
       title: item.title || 'Top Curated Fragrances',
       subtitle: item.subtitle || 'Prestige Selection',
       desc: item.desc || 'We offer the best niche fragrances on the market selected by our team of experts. Experience a masterfully curated collection of prestige fragrances, hand-selected to define your signature presence.',
       product_id: item.product_id || ''
    })) : [{
       image: '/model-banner-3.png',
       title: 'Top Curated Fragrances',
       subtitle: 'Prestige Selection',
       desc: 'We offer the best niche fragrances on the market selected by our team of experts. Experience a masterfully curated collection of prestige fragrances, hand-selected to define your signature presence.',
       product_id: ''
    }];

    // Resolve array layout for Grid Ads 3
    const gridAds3Raw = cmsLayout?.grid_ads_3;
    const gridAds3List: any[] = Array.isArray(gridAds3Raw) 
       ? gridAds3Raw 
       : (gridAds3Raw && typeof gridAds3Raw === 'object' && Object.keys(gridAds3Raw).length > 0)
          ? [gridAds3Raw] 
          : [];

    const gridAds3ToUse = gridAds3List.length > 0 ? gridAds3List.map((item: any) => ({
       left_image: item.left_image || '/model-banner-1.png',
       left_title: item.left_title || 'Top Curated Fragrances',
       left_subtitle: item.left_subtitle || 'Exquisite Collection',
       left_desc: item.left_desc || 'We offer the best niche fragrances on the market selected by our team of experts.',
       left_product_id: item.left_product_id || '',
       right_image: item.right_image || '/model-banner-3.png',
       right_title: item.right_title || 'Top Curated Fragrances',
       right_subtitle: item.right_subtitle || 'Prestige Selection',
       right_desc: item.right_desc || 'We offer the best niche fragrances on the market selected by our team of experts.',
       right_product_id: item.right_product_id || ''
    })) : [{
       left_image: '/model-banner-1.png',
       left_title: 'Top Curated Fragrances',
       left_subtitle: 'Exquisite Collection',
       left_desc: 'We offer the best niche fragrances on the market selected by our team of experts.',
       left_product_id: '',
       right_image: '/model-banner-3.png',
       right_title: 'Top Curated Fragrances',
       right_subtitle: 'Prestige Selection',
       right_desc: 'We offer the best niche fragrances on the market selected by our team of experts.',
       right_product_id: ''
    }];

   return (
      <div className="flex flex-col w-full bg-white">

          {/* Main Hero Banner Slider - Standard HD (1920x530) & 4K (2560x710) [3.6:1] | Mobile (1080x1350) [4:5] */}
          {heroSlidesToUse.length > 0 && (
          <section 
             onTouchStart={onHeroTouchStart}
             onTouchMove={onHeroTouchMove}
             onTouchEnd={onHeroTouchEnd}
             className="relative w-full aspect-[4/5] sm:aspect-[16/9] md:aspect-[3.6/1] h-auto min-h-[380px] sm:h-[420px] md:h-[480px] lg:h-[520px] max-h-[520px] bg-neutral-950 overflow-hidden select-none"
          >
             {heroSlidesToUse.map((slide: any, idx: number) => {
                const isPromo = !!slide.discount_type;
                const slideImage = getMediaUrl(slide.banner_url || slide.image);
                const slideTitle = slide.title;
                const slideSubtitle = isPromo ? `${slide.discount_type} • CODE: ${slide.code}` : slide.subtitle;
                const slideDesc = isPromo ? (slide.subtitle || 'Exclusive fragrance savings & curated collections.') : slide.desc;
                const slideCta = isPromo ? 'Claim Offer' : (slide.cta || 'Shop Collection');
                
                let slideLink = isPromo ? '/offers' : '/shop';
                if (slide.link_type === 'product' && slide.product_slug) {
                   slideLink = `/product/${slide.product_slug}`;
                } else if (slide.link_type === 'product' && slide.product_id) {
                   slideLink = getProductRedirectUrl(slide.product_id);
                } else if (slide.link_type === 'offer') {
                   slideLink = slide.offer_id ? `/offers?id=${slide.offer_id}` : '/offers';
                } else if (slide.link_type === 'custom' && slide.custom_link) {
                   slideLink = slide.custom_link;
                } else {
                   if (slide.product_slug) {
                      slideLink = `/product/${slide.product_slug}`;
                   } else if (slide.product_id) {
                      slideLink = getProductRedirectUrl(slide.product_id);
                   } else if (slide.offer_id) {
                      slideLink = `/offers?id=${slide.offer_id}`;
                   } else if (slide.custom_link) {
                      slideLink = slide.custom_link;
                   }
                }
                
                return (
                   <div
                      key={idx}
                      className={`absolute inset-0 w-full h-full transition-all duration-[1500ms] ease-in-out transform ${idx === currentSlide ? 'opacity-100 scale-100 z-10' : 'opacity-0 scale-105 z-0'
                         }`}
                   >
                      {/* Desktop/Web display - Crisp 1920x530 HD / 2560x710 4K Ultra-HD (3.6:1) - NO CROP, NO STRETCHING */}
                      <img
                         src={slideImage}
                         alt={slideTitle}
                         fetchPriority={idx === 0 ? "high" : "low"}
                         loading={idx === 0 ? "eager" : "lazy"}
                         decoding="async"
                         className="hidden md:block absolute inset-0 w-full h-full object-contain object-center transform-gpu"
                      />
                      {/* Mobile display - Crisp 1080x1350 (4:5) - NO CROP, NO STRETCHING */}
                      <img
                         src={getMediaUrl(slide.image_mobile || slide.banner_url_mobile || slide.banner_url || slide.image)}
                         alt={slideTitle}
                         fetchPriority={idx === 0 ? "high" : "low"}
                         loading={idx === 0 ? "eager" : "lazy"}
                         decoding="async"
                         className="block md:hidden absolute inset-0 w-full h-full object-contain object-center transform-gpu"
                      />
                      {/* Softened background gradient overlay so graphics & text inside banners remain 100% sharp */}
                      <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent pointer-events-none" />

                     <div className="absolute inset-0 flex items-end pb-10 sm:pb-12 md:pb-14">
                        <div className="max-w-[1400px] mx-auto w-full px-6 md:px-20 flex flex-col items-start text-left">
                           <span className={`text-[9px] md:text-xs font-semibold tracking-[0.3em] text-accent uppercase mb-1 md:mb-2 transition-all duration-1000 delay-300 transform ${idx === currentSlide ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                              } font-montserrat`}>
                              {slideSubtitle}
                           </span>
                           <h1 className={`text-2xl sm:text-4xl md:text-5xl lg:text-6xl font-serif font-normal text-[#d4af37] leading-tight md:leading-none tracking-wide mb-2 md:mb-3 uppercase transition-all duration-1000 delay-500 transform ${idx === currentSlide ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                              }`}>
                              {slideTitle}
                           </h1>
                           <p className={`hidden sm:block text-neutral-100 font-light font-montserrat text-[10px] md:text-xs lg:text-sm uppercase tracking-[0.4em] max-w-sm md:max-w-xl mb-4 md:mb-5 transition-all duration-1000 delay-700 transform ${idx === currentSlide ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'
                              }`}>
                              {slideDesc}
                           </p>
                           <Link 
                              href={slideLink} 
                              className={`bg-transparent border border-white/80 hover:bg-white text-white hover:text-black px-5 py-2 md:px-6 md:py-2.5 text-[10px] md:text-xs font-semibold tracking-[0.2em] uppercase transition-all duration-700 delay-900 transform ${idx === currentSlide ? 'translate-y-0 opacity-100' : 'translate-y-8 opacity-0'} font-montserrat rounded-full`}
                           >
                              {slideCta}
                           </Link>
                        </div>
                     </div>
                  </div>
               );
            })}

            {/* Prominent High-Contrast Left & Right Transition Arrow Buttons */}
            <button 
               onClick={() => setCurrentSlide(p => (p === 0 ? heroSlidesToUse.length - 1 : p - 1))}
               aria-label="Previous Banner Slide"
               className="absolute left-3 sm:left-6 top-1/2 -translate-y-1/2 z-30 w-10 h-10 sm:w-12 sm:h-12 bg-black/75 hover:bg-accent text-white hover:text-black rounded-full flex items-center justify-center backdrop-blur-xl shadow-2xl transition-all duration-300 border border-white/20 hover:scale-110 active:scale-95 cursor-pointer"
            >
               <ChevronLeft className="w-5 h-5 sm:w-6 sm:h-6" strokeWidth={2} />
            </button>
            <button 
               onClick={() => setCurrentSlide(p => (p === heroSlidesToUse.length - 1 ? 0 : p + 1))}
               aria-label="Next Banner Slide"
               className="absolute right-3 sm:right-6 top-1/2 -translate-y-1/2 z-30 w-10 h-10 sm:w-12 sm:h-12 bg-black/75 hover:bg-accent text-white hover:text-black rounded-full flex items-center justify-center backdrop-blur-xl shadow-2xl transition-all duration-300 border border-white/20 hover:scale-110 active:scale-95 cursor-pointer"
            >
               <ChevronRight className="w-5 h-5 sm:w-6 sm:h-6" strokeWidth={2} />
            </button>

            <div className="absolute bottom-5 left-1/2 -translate-x-1/2 z-20 flex items-center space-x-3">
               {heroSlidesToUse.map((_: any, idx: number) => (
                  <button
                     key={idx}
                     onClick={() => setCurrentSlide(idx)}
                     className={`w-10 sm:w-12 h-0.5 transition-all duration-500 ${idx === currentSlide ? 'bg-accent' : 'bg-white/30 hover:bg-white/60'
                        }`}
                  />
               ))}
            </div>
         </section>
         )}

         {/* Trust Badges - always visible */}
         <section className="bg-neutral-50 py-5 border-b border-neutral-100">
            <div className="max-w-[1400px] mx-auto px-4 grid grid-cols-2 md:flex md:flex-wrap md:justify-between gap-x-4 gap-y-5 justify-items-center">
               {(cmsLayout?.trust_badges?.length > 0 ? cmsLayout.trust_badges : [
                 { title: 'Free Shipping', sub: 'On orders over ₹999/-', icon: '🚚' },
                 { title: '100% Authentic', sub: 'Genuine & original products only', icon: '✅' },
                 { title: 'Easy Returns', sub: '7-day hassle-free return policy', icon: '🔄' },
                 { title: 'Secure Payments', sub: 'UPI, Cards, Razorpay accepted', icon: '🔒' },
               ]).map((item: any, idx: number) => (
                  <div key={idx} className="flex items-center space-x-3 min-w-[140px] sm:min-w-[190px]">
                     <div className="text-xl flex-shrink-0">{item.icon || '★'}</div>
                     <div>
                        <p className="text-[10px] font-black tracking-widest uppercase text-black">{item.title}</p>
                        <p className="text-[9px] font-medium text-neutral-500 tracking-wider">{item.sub}</p>
                     </div>
                  </div>
               ))}
            </div>
         </section>

         {/* Signature Categories */}
         {categories.length > 0 && (
          <section className="pt-12 pb-6 bg-white border-b border-neutral-50 overflow-hidden">
             <div className="max-w-[1400px] mx-auto px-6 lg:px-12 text-center mb-4">
                <span className="text-[9px] font-medium tracking-[0.25em] text-neutral-400 uppercase mb-2 block">Discover More</span>
                <h2 className="text-2xl md:text-3xl font-nelphim font-medium text-black leading-none inline-block uppercase tracking-wide">
                   Signature Categories
                </h2>
                <div className="w-12 h-[2.5px] bg-accent mx-auto mt-2.5" />
             </div>

             <div className="relative w-full overflow-hidden">
                <div className="flex gap-6 md:gap-10 overflow-x-auto py-2 px-6 md:px-12 scrollbar-hide select-none w-full justify-start md:justify-center">
                   {categories.map((cat: any, idx: number) => {
                      const name = cat.name;
                      const image = getMediaUrl(cat.image_url || cat.images?.[0] || cat.banner_url);
                      
                      return (
                         <Link
                            key={cat.id || idx}
                            href={`/shop?category=${cat.slug || cat.id}`}
                            className="group/cat flex flex-col items-center space-y-3 flex-shrink-0 cursor-pointer focus:outline-none"
                         >
                            {/* Outer Ring: elegant gradient border */}
                            <div className="relative p-[3px] rounded-full transition-all duration-500 transform group-hover/cat:scale-105 active:scale-95 bg-gradient-to-tr from-amber-400 via-rose-500 to-accent">
                               {/* White Spacer Gap */}
                               <div className="p-[2px] bg-white rounded-full">
                                  {/* Circular Image wrapper */}
                                  <div className="w-20 h-20 md:w-28 md:h-28 rounded-full overflow-hidden bg-neutral-50 flex items-center justify-center border border-neutral-100/80 shadow-sm group-hover/cat:shadow-md transition-all duration-700">
                                     <img 
                                        src={image} 
                                        alt={name} 
                                        loading="lazy"
                                        decoding="async"
                                        className="w-full h-full object-cover group-hover/cat:scale-110 transition-transform duration-[1.5s]" 
                                        onError={(e: any) => { e.target.src = '/placeholder-perfume.png' }}
                                     />
                                  </div>
                               </div>
                            </div>
                            
                            {/* Text label */}
                            <span className="text-[9px] md:text-[10px] font-medium tracking-wider text-neutral-700 uppercase transition-all group-hover/cat:text-accent font-sans whitespace-nowrap">
                               {name}
                            </span>
                         </Link>
                      );
                   })}
                </div>
                
                {/* Left/Right fading edges for long scrollable content */}
                {categories.length >= 6 && (
                   <>
                      <div className="absolute inset-y-0 left-0 w-16 bg-gradient-to-r from-white to-transparent pointer-events-none z-10" />
                      <div className="absolute inset-y-0 right-0 w-16 bg-gradient-to-l from-white to-transparent pointer-events-none z-10" />
                   </>
                )}
             </div>
          </section>
          )}

         {/* Bestsellers Grid */}
         <section className="py-24 bg-neutral-50 border-t border-b border-neutral-100">
            <div className="max-w-[1400px] mx-auto px-6 lg:px-12">
               <div className="flex justify-between items-end mb-16">
                  <div>
                     <span className="text-[9px] font-bold tracking-[0.2em] text-neutral-400 uppercase mb-3 block">Store Favorites</span>
                     <h2 className="text-2xl md:text-3xl font-serif font-normal text-black leading-none uppercase tracking-wide">Popular Picks</h2>
                  </div>
                  <Link href="/shop" className="group flex items-center space-x-3 text-[11px] font-bold tracking-widest text-black uppercase hover:text-accent transition-colors font-sans">
                     <span>Explore All</span>
                     <ChevronRight size={14} className="group-hover:translate-x-1.5 transition-transform text-accent" />
                  </Link>
               </div>

               <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                  {loading ? (
                     [...Array(5)].map((_, i) => <div key={i} className="aspect-[3/4] bg-white animate-pulse rounded-sm border border-neutral-100" />)
                  ) : (
                     bestsellers.slice(0, 10).map((product: any) => (
                        <ProductCard key={product.id} product={product} />
                     ))
                  )}
               </div>
            </div>
          </section>

          {/* High-Converting Flash Offers & Dynamic Product Layout - Only show when valid offer exists */}
          {homepageOffers.length > 0 && (() => {
             const offersToDisplay = homepageOffers;
             const activePromo = offersToDisplay[currentPromoIdx] || offersToDisplay[0];
             
             // Dynamic side product card resolution
             const availableProds = (activePromo?.products?.length > 0) ? activePromo.products : (bestsellers.length > 0 ? bestsellers : newArrivals);
             const leftProduct = availableProds[currentPromoIdx % availableProds.length] || newArrivals[0];
             const rightProduct = availableProds[(currentPromoIdx + 1) % availableProds.length] || bestsellers[1] || newArrivals[1];

             return (
             <section className="bg-gradient-to-b from-neutral-50 via-white to-neutral-100/60 border-y border-neutral-200/80 py-12 md:py-16 overflow-hidden">
                <div className="max-w-[1550px] mx-auto px-4 sm:px-6 lg:px-10">
                   
                   {/* Section Title */}
                   <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end mb-8 sm:mb-10 gap-2">
                      <div>
                         <span className="text-[9px] font-bold tracking-[0.25em] text-accent uppercase mb-1.5 block font-sans">Curated Promotions</span>
                         <h2 className="text-2xl sm:text-3xl font-serif font-normal text-neutral-900 uppercase tracking-wide leading-tight">
                            Flash Offers & Special Curations
                         </h2>
                      </div>
                      <Link href="/offers" className="group flex items-center gap-2 text-[10px] font-bold tracking-widest text-black uppercase hover:text-accent transition-colors font-sans">
                         <span>View All Offers ({offersToDisplay.length})</span>
                         <ChevronRight size={14} className="group-hover:translate-x-1 transition-transform text-accent" />
                      </Link>
                   </div>

                   {/* Banner + Side Product Cards Grid */}
                   <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                      
                      {/* XL Widescreen Displays: Left Product Card */}
                      {leftProduct && (
                         <div className="hidden xl:flex xl:col-span-3 flex-col bg-white border border-neutral-200/90 rounded-2xl p-5 shadow-sm hover:shadow-md transition-all duration-300 group">
                            <div className="relative aspect-square w-full bg-neutral-50 rounded-xl overflow-hidden mb-4 border border-neutral-100">
                               <span className="absolute top-2.5 left-2.5 z-10 bg-accent text-white text-[8px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full">
                                  Featured Offer
                               </span>
                               <img 
                                  src={getMediaUrl(leftProduct.images?.[0] || leftProduct.image)} 
                                  alt={leftProduct.name} 
                                  className="w-full h-full object-contain p-4 group-hover:scale-105 transition-transform duration-500"
                                  onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                               />
                            </div>
                            <span className="text-[9px] font-bold text-neutral-400 uppercase tracking-widest mb-1 truncate">
                               {leftProduct.brand_name || 'Exclusive Curation'}
                            </span>
                            <h3 className="text-sm font-semibold text-neutral-900 uppercase truncate mb-2 group-hover:text-accent transition-colors">
                               {leftProduct.name}
                            </h3>
                            <div className="flex items-center gap-2 mb-4">
                               <span className="text-sm font-bold font-mono text-black">
                                  ₹{(leftProduct.variants?.[0]?.selling_price || leftProduct.selling_price || 0).toLocaleString('en-IN')}
                               </span>
                               {leftProduct.variants?.[0]?.compare_at_price > (leftProduct.variants?.[0]?.selling_price || 0) && (
                                  <span className="text-xs text-neutral-400 line-through font-mono">
                                     ₹{leftProduct.variants[0].compare_at_price.toLocaleString('en-IN')}
                                  </span>
                               )}
                            </div>
                            <div className="grid grid-cols-2 gap-2 mt-auto">
                               <button
                                  onClick={(e) => handleAddProductToCart(leftProduct, e)}
                                  className="w-full bg-neutral-900 hover:bg-black text-white text-[9px] font-bold uppercase tracking-wider py-2.5 px-2 rounded-lg transition-colors flex items-center justify-center gap-1"
                               >
                                  <ShoppingBag size={12} />
                                  Add
                               </button>
                               <button
                                  onClick={(e) => handleBuyNowProduct(leftProduct, e)}
                                  className="w-full bg-accent hover:bg-amber-600 text-white text-[9px] font-bold uppercase tracking-wider py-2.5 px-2 rounded-lg transition-colors text-center"
                               >
                                  Buy Now
                               </button>
                            </div>
                         </div>
                      )}

                      {/* Central Flash Offer Banner Slider */}
                      <div className="col-span-12 xl:col-span-6 relative aspect-[16/9] sm:aspect-[2.2/1] md:aspect-[2.5/1] xl:aspect-[1.9/1] max-h-[460px] rounded-2xl overflow-hidden shadow-xl border border-neutral-200/90 group bg-neutral-900">
                         {offersToDisplay.map((promo: any, idx: number) => (
                            <div 
                               key={promo.id || idx}
                               onTouchStart={onPromoTouchStart}
                               onTouchMove={onPromoTouchMove}
                               onTouchEnd={onPromoTouchEnd}
                               className={`absolute inset-0 transition-all duration-1000 ease-in-out select-none ${
                                  idx === currentPromoIdx ? 'opacity-100 scale-100 z-10' : 'opacity-0 scale-105 z-0 pointer-events-none'
                               }`}
                            >
                               <Link href="/offers" className="absolute inset-0 block cursor-pointer">
                                  <img 
                                     src={promo.banner_url ? getMediaUrl(promo.banner_url) : 'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&q=80&w=1000'} 
                                     alt={promo.title} 
                                     className="w-full h-full object-cover object-center group-hover:scale-[1.02] transition-transform duration-[3s]"
                                  />
                               </Link>

                               {/* Softened Background Overlay */}
                               <div className="absolute inset-0 bg-gradient-to-t from-black/45 via-transparent to-transparent pointer-events-none" />

                               {/* Ultra-Sleek Bottom Floating Pill Bar */}
                               <div className="absolute bottom-4 sm:bottom-5 left-1/2 -translate-x-1/2 z-20 flex items-center gap-2 sm:gap-3 bg-black/85 backdrop-blur-md px-4 sm:px-6 py-2 sm:py-2.5 rounded-full border border-white/15 shadow-2xl max-w-[92%] sm:max-w-none">
                                  <span className="text-[9px] sm:text-[10px] font-bold tracking-widest text-amber-400 uppercase flex-shrink-0">
                                     {promo.discount_type || 'SPECIAL OFFER'}
                                  </span>
                                  <span className="w-[1px] h-3.5 bg-white/20 flex-shrink-0" />
                                  <span className="text-[10px] sm:text-[11px] font-semibold text-white truncate max-w-[140px] sm:max-w-[220px] tracking-wide">
                                     {promo.title}
                                  </span>
                                  <Link 
                                     href="/offers" 
                                     className="ml-1 bg-white hover:bg-amber-400 text-black px-3 sm:px-4 py-1 text-[8px] sm:text-[9px] font-bold tracking-widest uppercase rounded-full transition-all duration-300 flex-shrink-0 shadow-md"
                                  >
                                     Claim Offer
                                  </Link>
                               </div>
                            </div>
                         ))}

                         {/* Side Arrows on Banner */}
                         <button 
                            onClick={() => setCurrentPromoIdx(p => (p === 0 ? offersToDisplay.length - 1 : p - 1))}
                            className="absolute left-3 top-1/2 -translate-y-1/2 z-20 w-8 h-8 sm:w-10 sm:h-10 bg-black/40 hover:bg-black/80 text-white rounded-full flex items-center justify-center backdrop-blur-md transition-all duration-300 border border-white/10 opacity-80 hover:opacity-100"
                         >
                            <ChevronLeft size={18} />
                         </button>
                         <button 
                            onClick={() => setCurrentPromoIdx(p => (p === offersToDisplay.length - 1 ? 0 : p + 1))}
                            className="absolute right-3 top-1/2 -translate-y-1/2 z-20 w-8 h-8 sm:w-10 sm:h-10 bg-black/40 hover:bg-black/80 text-white rounded-full flex items-center justify-center backdrop-blur-md transition-all duration-300 border border-white/10 opacity-80 hover:opacity-100"
                         >
                            <ChevronRight size={18} />
                         </button>

                         {/* Bottom Navigation Dots Indicator */}
                         <div className="absolute top-4 right-4 z-20 flex items-center gap-1.5 bg-black/60 backdrop-blur-md px-3 py-1 rounded-full border border-white/10">
                            <span className="text-[9px] font-bold text-white font-mono">
                               0{currentPromoIdx + 1} / 0{offersToDisplay.length}
                            </span>
                         </div>
                      </div>

                      {/* XL Widescreen Displays: Right Product Card */}
                      {rightProduct && (
                         <div className="hidden xl:flex xl:col-span-3 flex-col bg-white border border-neutral-200/90 rounded-2xl p-5 shadow-sm hover:shadow-md transition-all duration-300 group">
                            <div className="relative aspect-square w-full bg-neutral-50 rounded-xl overflow-hidden mb-4 border border-neutral-100">
                               <span className="absolute top-2.5 left-2.5 z-10 bg-black text-white text-[8px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full">
                                  Top Match
                               </span>
                               <img 
                                  src={getMediaUrl(rightProduct.images?.[0] || rightProduct.image)} 
                                  alt={rightProduct.name} 
                                  className="w-full h-full object-contain p-4 group-hover:scale-105 transition-transform duration-500"
                                  onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                               />
                            </div>
                            <span className="text-[9px] font-bold text-neutral-400 uppercase tracking-widest mb-1 truncate">
                               {rightProduct.brand_name || 'Prestige Selection'}
                            </span>
                            <h3 className="text-sm font-semibold text-neutral-900 uppercase truncate mb-2 group-hover:text-accent transition-colors">
                               {rightProduct.name}
                            </h3>
                            <div className="flex items-center gap-2 mb-4">
                               <span className="text-sm font-bold font-mono text-black">
                                  ₹{(rightProduct.variants?.[0]?.selling_price || rightProduct.selling_price || 0).toLocaleString('en-IN')}
                               </span>
                               {rightProduct.variants?.[0]?.compare_at_price > (rightProduct.variants?.[0]?.selling_price || 0) && (
                                  <span className="text-xs text-neutral-400 line-through font-mono">
                                     ₹{rightProduct.variants[0].compare_at_price.toLocaleString('en-IN')}
                                  </span>
                               )}
                            </div>
                            <div className="grid grid-cols-2 gap-2 mt-auto">
                               <button
                                  onClick={(e) => handleAddProductToCart(rightProduct, e)}
                                  className="w-full bg-neutral-900 hover:bg-black text-white text-[9px] font-bold uppercase tracking-wider py-2.5 px-2 rounded-lg transition-colors flex items-center justify-center gap-1"
                               >
                                  <ShoppingBag size={12} />
                                  Add
                               </button>
                               <button
                                  onClick={(e) => handleBuyNowProduct(rightProduct, e)}
                                  className="w-full bg-accent hover:bg-amber-600 text-white text-[9px] font-bold uppercase tracking-wider py-2.5 px-2 rounded-lg transition-colors text-center"
                               >
                                  Buy Now
                               </button>
                            </div>
                         </div>
                      )}

                   </div>
                </div>
             </section>
             );
          })()}

         {/* New Arrivals Grid */}
         <section className="pt-24 pb-12 md:pt-32 md:pb-16 bg-white">
            <div className="max-w-[1400px] mx-auto px-6 lg:px-12">
               <div className="flex justify-between items-end mb-16">
                  <div>
                     <span className="text-[9px] font-bold tracking-[0.2em] text-neutral-400 uppercase mb-3 block">Just Arrived</span>
                     <h2 className="text-2xl md:text-3xl font-serif font-normal text-black leading-none uppercase tracking-wide">New Arrivals</h2>
                  </div>
                  <Link href="/shop" className="group flex items-center space-x-3 text-[11px] font-bold tracking-widest text-black uppercase hover:text-accent transition-colors font-sans">
                     <span>View Collection</span>
                     <ChevronRight size={14} className="group-hover:translate-x-1.5 transition-transform text-accent" />
                  </Link>
               </div>

               {loading ? (
                  <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                     {[...Array(5)].map((_, i) => <div key={i} className="aspect-[3/4] bg-neutral-50 animate-pulse border border-neutral-100" />)}
                  </div>
               ) : (
                  <div className="flex flex-col">
                     {/* First 2 rows (Products 1-10) */}
                     <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 mb-16">
                        {newArrivals.slice(0, 10).map((product: any) => (
                           <ProductCard key={product.id} product={product} />
                        ))}
                     </div>

                     {/* Dynamic Block 1: Side-by-Side Ad Banners Carousel */}
                     {newArrivals.length > 0 && (
                        <div className="relative w-full h-[470px] md:h-[300px] mb-16 overflow-hidden">
                           {gridAds1ToUse.map((slide: any, idx: number) => (
                              <div 
                                 key={idx} 
                                 className={`absolute inset-0 w-full h-full transition-all duration-[1200ms] ease-in-out grid grid-cols-1 md:grid-cols-2 gap-8 font-sans ${
                                    idx === currentAds1 ? 'opacity-100 scale-100 z-10' : 'opacity-0 scale-98 z-0 pointer-events-none'
                                 }`}
                              >
                                 {/* Left Ad Banner */}
                                 <div className="relative overflow-hidden group rounded-sm border border-neutral-100 flex h-[220px] sm:h-[260px] md:h-[300px]">
                                    {/* Left half: Image */}
                                    <div className="w-[45%] h-full relative overflow-hidden bg-neutral-50">
                                       {/* Desktop image */}
                                       <img 
                                          src={getMediaUrl(slide.left_image)} 
                                          alt={slide.left_title} 
                                          className="hidden md:block w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                          onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                       />
                                       {/* Mobile image */}
                                       <img 
                                          src={getMediaUrl(slide.left_image_mobile || slide.left_image)} 
                                          alt={slide.left_title} 
                                          className="block md:hidden w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                          onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                       />
                                    </div>
                                    {/* Right half: Text Content */}
                                    <div className="w-[55%] bg-[#a5682a] p-4 sm:p-6 md:p-8 flex flex-col justify-center text-left text-white">
                                       <span className="text-[8px] sm:text-[9px] font-black tracking-[0.2em] text-white/75 uppercase mb-1 sm:mb-2">{slide.left_subtitle}</span>
                                       <h3 className="text-base sm:text-lg md:text-2xl font-serif tracking-wide uppercase leading-tight mb-2 truncate">{slide.left_title}</h3>
                                       <p className="text-[10px] text-white/80 leading-relaxed font-light mb-4 sm:mb-6 tracking-wide line-clamp-2 md:line-clamp-3">
                                          {slide.left_desc}
                                       </p>
                                       <Link 
                                          href={getProductRedirectUrl(slide.left_product_id)} 
                                          className="bg-black hover:bg-neutral-900 text-white text-[9px] font-bold tracking-[0.2em] uppercase py-2.5 px-5 sm:py-3 sm:px-6 text-center max-w-[130px] transition-all duration-300 rounded-sm"
                                       >
                                          Buy Now
                                       </Link>
                                    </div>
                                 </div>

                                 {/* Right Ad Banner */}
                                 <div className="relative overflow-hidden group rounded-sm border border-neutral-100 flex h-[220px] sm:h-[260px] md:h-[300px]">
                                    {/* Left half: Image */}
                                    <div className="w-[45%] h-full relative overflow-hidden bg-neutral-50">
                                       {/* Desktop image */}
                                       <img 
                                          src={getMediaUrl(slide.right_image)} 
                                          alt={slide.right_title} 
                                          className="hidden md:block w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                          onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                       />
                                       {/* Mobile image */}
                                       <img 
                                          src={getMediaUrl(slide.right_image_mobile || slide.right_image)} 
                                          alt={slide.right_title} 
                                          className="block md:hidden w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                          onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                       />
                                    </div>
                                    {/* Right half: Text Content */}
                                    <div className="w-[55%] bg-[#5c4033] p-4 sm:p-6 md:p-8 flex flex-col justify-center text-left text-white">
                                       <span className="text-[8px] sm:text-[9px] font-black tracking-[0.2em] text-white/75 uppercase mb-1 sm:mb-2">{slide.right_subtitle}</span>
                                       <h3 className="text-base sm:text-lg md:text-2xl font-serif tracking-wide uppercase leading-tight mb-2 truncate">{slide.right_title}</h3>
                                       <p className="text-[10px] text-white/80 leading-relaxed font-light mb-4 sm:mb-6 tracking-wide line-clamp-2 md:line-clamp-3">
                                          {slide.right_desc}
                                       </p>
                                       <Link 
                                          href={getProductRedirectUrl(slide.right_product_id)} 
                                          className="bg-black hover:bg-neutral-900 text-white text-[9px] font-bold tracking-[0.2em] uppercase py-2.5 px-5 sm:py-3 sm:px-6 text-center max-w-[130px] transition-all duration-300 rounded-sm"
                                       >
                                          Buy Now
                                       </Link>
                                    </div>
                                 </div>
                              </div>
                           ))}

                           {/* Navigation Indicators */}
                           {gridAds1ToUse.length > 1 && (
                              <div className="absolute bottom-2 left-1/2 -translate-x-1/2 z-20 flex space-x-2">
                                 {gridAds1ToUse.map((_: any, idx: number) => (
                                    <button
                                       key={idx}
                                       onClick={() => setCurrentAds1(idx)}
                                       className={`w-2 h-2 rounded-full transition-all duration-300 ${
                                          idx === currentAds1 ? 'bg-accent w-4' : 'bg-neutral-300 hover:bg-neutral-400'
                                       }`}
                                    />
                                 ))}
                               </div>
                           )}
                        </div>
                     )}

                     {/* Second 2 rows (Products 11-20) */}
                     {newArrivals.length > 10 && (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 mb-16">
                           {newArrivals.slice(10, 20).map((product: any) => (
                              <ProductCard key={product.id} product={product} />
                           ))}
                        </div>
                     )}

                     {/* Dynamic Block 2: Full-Width Ad Banner Carousel */}
                     {newArrivals.length > 10 && (
                        <div className={`relative w-full h-[440px] md:min-h-0 md:h-[320px] overflow-hidden ${
                           newArrivals.length > 20 ? 'mb-16' : 'mb-6'
                        }`}>
                           {gridAds2ToUse.map((slide: any, idx: number) => (
                              <div
                                 key={idx}
                                 className={`absolute inset-0 w-full h-full transition-all duration-[1200ms] ease-in-out bg-neutral-900 overflow-hidden group rounded-sm flex flex-col md:flex-row border border-neutral-800 ${
                                    idx === currentAds2 ? 'opacity-100 scale-100 z-10' : 'opacity-0 scale-98 z-0 pointer-events-none'
                                 }`}
                              >
                                 {/* Left: Text Content */}
                                 <div className="w-full md:w-[60%] h-[260px] md:h-full bg-[#1b3b22] p-6 sm:p-10 md:p-12 flex flex-col justify-center text-left text-white">
                                    <span className="text-[8px] sm:text-[9px] font-black tracking-[0.25em] text-white/75 uppercase mb-2 block font-sans">{slide.subtitle}</span>
                                    <h2 className="text-2xl sm:text-3xl md:text-4xl font-serif tracking-wide uppercase leading-none mb-3">{slide.title}</h2>
                                    <p className="text-[11px] sm:text-xs text-white/80 leading-relaxed font-light mb-5 sm:mb-6 tracking-wide max-w-xl line-clamp-3">
                                       {slide.desc}
                                    </p>
                                    <Link 
                                       href={getProductRedirectUrl(slide.product_id)} 
                                       className="bg-black hover:bg-neutral-900 text-white text-[9px] sm:text-[10px] font-bold tracking-[0.2em] uppercase py-2.5 px-6 sm:py-3.5 sm:px-8 text-center max-w-[150px] sm:max-w-[180px] transition-all duration-300 rounded-sm font-sans"
                                    >
                                       Buy Now
                                    </Link>
                                 </div>
                                 {/* Right: Large Image */}
                                 <div className="w-full md:w-[40%] h-[180px] sm:h-[220px] md:h-full relative overflow-hidden bg-neutral-950">
                                    {/* Desktop image */}
                                    <img 
                                       src={getMediaUrl(slide.image)} 
                                       alt={slide.title} 
                                       className="hidden md:block w-full h-full object-cover group-hover:scale-105 transition-transform duration-[3s]"
                                       onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                    />
                                    {/* Mobile image */}
                                    <img 
                                       src={getMediaUrl(slide.image_mobile || slide.image)} 
                                       alt={slide.title} 
                                       className="block md:hidden w-full h-full object-cover group-hover:scale-105 transition-transform duration-[3s]"
                                       onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                    />
                                 </div>
                              </div>
                           ))}

                           {/* Navigation Indicators */}
                           {gridAds2ToUse.length > 1 && (
                              <div className="absolute bottom-4 left-6 z-20 flex space-x-2">
                                 {gridAds2ToUse.map((_: any, idx: number) => (
                                    <button
                                       key={idx}
                                       onClick={() => setCurrentAds2(idx)}
                                       className={`w-2 h-2 rounded-full transition-all duration-300 ${
                                          idx === currentAds2 ? 'bg-accent w-4' : 'bg-white/40 hover:bg-white/60'
                                       }`}
                                    />
                                 ))}
                              </div>
                           )}
                        </div>
                     )}

                     {/* Remaining products (Products 21+) */}
                     {newArrivals.length > 20 && (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                           {newArrivals.slice(20).map((product: any) => (
                              <ProductCard key={product.id} product={product} />
                           ))}
                        </div>
                     )}
                  </div>
               )}
            </div>
         </section>

         {/* Favorite Products Grid */}
         {favoriteProducts.length > 0 && (
         <section className="py-24 md:py-32 bg-neutral-50 border-t border-b border-neutral-100">
            <div className="max-w-[1400px] mx-auto px-6 lg:px-12">
               <div className="flex justify-between items-end mb-16">
                  <div>
                     <span className="text-[9px] font-bold tracking-[0.2em] text-neutral-400 uppercase mb-3 block">Curated Selection</span>
                     <h2 className="text-2xl md:text-3xl font-serif font-normal text-black leading-none uppercase tracking-wide">Favorite Products</h2>
                  </div>
                  <Link href="/shop" className="group flex items-center space-x-3 text-[11px] font-bold tracking-widest text-black uppercase hover:text-accent transition-colors font-sans">
                     <span>Explore Collection</span>
                     <ChevronRight size={14} className="group-hover:translate-x-1.5 transition-transform text-accent" />
                  </Link>
               </div>

               <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                  {favoriteProducts.map((product: any) => (
                     <ProductCard key={product.id} product={product} />
                  ))}
               </div>
            </div>
         </section>
         )/* Dynamic Block 3: Brand Spotlight Ad Banners (Above Brands) */}
         <section className="pb-16 bg-white">
            <div className="max-w-[1400px] mx-auto px-6 lg:px-12">
               <div className="relative w-full h-[470px] md:h-[300px] overflow-hidden">
                  {gridAds3ToUse.map((slide: any, idx: number) => (
                     <div 
                        key={idx} 
                        className={`absolute inset-0 w-full h-full transition-all duration-[1200ms] ease-in-out grid grid-cols-1 md:grid-cols-2 gap-8 font-sans ${
                           idx === currentAds3 ? 'opacity-100 scale-100 z-10' : 'opacity-0 scale-98 z-0 pointer-events-none'
                        }`}
                     >
                        {/* Left Ad Banner */}
                        <div className="relative overflow-hidden group rounded-sm border border-neutral-100 flex h-[220px] sm:h-[260px] md:h-[300px]">
                           {/* Left half: Image */}
                           <div className="w-[45%] h-full relative overflow-hidden bg-neutral-50">
                              {/* Desktop image */}
                              <img 
                                 src={getMediaUrl(slide.left_image)} 
                                 alt={slide.left_title} 
                                 className="hidden md:block w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                 onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                              />
                              {/* Mobile image */}
                              <img 
                                 src={getMediaUrl(slide.left_image_mobile || slide.left_image)} 
                                 alt={slide.left_title} 
                                 className="block md:hidden w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                 onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                              />
                           </div>
                           {/* Right half: Text Content */}
                           <div className="w-[55%] bg-[#8c5a2b] p-4 sm:p-6 md:p-8 flex flex-col justify-center text-left text-white">
                              <span className="text-[8px] sm:text-[9px] font-black tracking-[0.2em] text-white/75 uppercase mb-1 sm:mb-2">{slide.left_subtitle}</span>
                              <h3 className="text-base sm:text-lg md:text-2xl font-serif tracking-wide uppercase leading-tight mb-2 truncate">{slide.left_title}</h3>
                              <p className="text-[10px] text-white/80 leading-relaxed font-light mb-4 sm:mb-6 tracking-wide line-clamp-2 md:line-clamp-3">
                                 {slide.left_desc}
                              </p>
                              <Link 
                                 href={getProductRedirectUrl(slide.left_product_id)} 
                                 className="bg-black hover:bg-neutral-900 text-white text-[9px] font-bold tracking-[0.2em] uppercase py-2.5 px-5 sm:py-3 sm:px-6 text-center max-w-[130px] transition-all duration-300 rounded-sm"
                              >
                                 Buy Now
                              </Link>
                           </div>
                        </div>

                        {/* Right Ad Banner */}
                        <div className="relative overflow-hidden group rounded-sm border border-neutral-100 flex h-[220px] sm:h-[260px] md:h-[300px]">
                           {/* Left half: Image */}
                           <div className="w-[45%] h-full relative overflow-hidden bg-neutral-50">
                              {/* Desktop image */}
                              <img 
                                 src={getMediaUrl(slide.right_image)} 
                                 alt={slide.right_title} 
                                 className="hidden md:block w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                 onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                              />
                              {/* Mobile image */}
                              <img 
                                 src={getMediaUrl(slide.right_image_mobile || slide.right_image)} 
                                 alt={slide.right_title} 
                                 className="block md:hidden w-full h-full object-cover group-hover:scale-105 transition-transform duration-[2s]"
                                 onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                              />
                           </div>
                           {/* Right half: Text Content */}
                           <div className="w-[55%] bg-[#1b3b22] p-4 sm:p-6 md:p-8 flex flex-col justify-center text-left text-white">
                              <span className="text-[8px] sm:text-[9px] font-black tracking-[0.2em] text-white/75 uppercase mb-1 sm:mb-2">{slide.right_subtitle}</span>
                              <h3 className="text-base sm:text-lg md:text-2xl font-serif tracking-wide uppercase leading-tight mb-2 truncate">{slide.right_title}</h3>
                              <p className="text-[10px] text-white/80 leading-relaxed font-light mb-4 sm:mb-6 tracking-wide line-clamp-2 md:line-clamp-3">
                                 {slide.right_desc}
                              </p>
                              <Link 
                                 href={getProductRedirectUrl(slide.right_product_id)} 
                                 className="bg-black hover:bg-neutral-900 text-white text-[9px] font-bold tracking-[0.2em] uppercase py-2.5 px-5 sm:py-3 sm:px-6 text-center max-w-[130px] transition-all duration-300 rounded-sm"
                              >
                                 Buy Now
                              </Link>
                           </div>
                        </div>
                     </div>
                  ))}

                  {/* Navigation Indicators */}
                  {gridAds3ToUse.length > 1 && (
                     <div className="absolute bottom-2 left-1/2 -translate-x-1/2 z-20 flex space-x-2">
                        {gridAds3ToUse.map((_: any, idx: number) => (
                           <button
                              key={idx}
                              onClick={() => setCurrentAds3(idx)}
                              className={`w-2 h-2 rounded-full transition-all duration-300 ${
                                 idx === currentAds3 ? 'bg-accent w-4' : 'bg-neutral-300 hover:bg-neutral-400'
                              }`}
                           />
                        ))}
                     </div>
                  )}
               </div>
            </div>
         </section>

          {/* Elite Brand Houses */}
          {brands.length > 0 && (
          <section className="py-10 md:py-12 bg-[#FAF8F5] border-t border-b border-neutral-100 relative overflow-hidden">
             <div className="max-w-[1400px] mx-auto px-8 mb-6 flex justify-between items-end font-sans">
                <div>
                   <span className="text-[9px] font-medium tracking-[0.2em] text-accent uppercase mb-3 block">The Global Houses</span>
                   <h2 className="text-2xl md:text-3xl font-serif font-normal text-neutral-900 leading-none uppercase tracking-wide">Elite Perfumery</h2>
                </div>
                <Link href="/brands" className="text-neutral-900 text-[11px] font-medium tracking-[0.2em] uppercase border-b border-neutral-900/10 pb-2 hover:border-accent hover:text-accent hover:border-accent transition-all duration-700">
                   Explore All Houses
                </Link>
             </div>

             {brands.length <= 2 ? (
                 /* Premium Luxury Spotlight circles for 1-2 Brands */
                 <div className="max-w-[1400px] mx-auto px-8">
                    <div className="flex flex-col md:flex-row gap-6 items-stretch w-full justify-center">
                       {brands.map((brand: any, idx: number) => {
                          // Find first product for this brand from loaded product arrays
                          const allProducts: any[] = [...newArrivals, ...bestsellers, ...favoriteProducts];
                          const brandProduct = allProducts.find(
                             (p: any) => p.brand_id === brand.id || p.brand === brand.id || p.brand === brand.name
                          );
                          const productImage = brandProduct?.images?.[0]
                             ? getMediaUrl(brandProduct.images[0])
                             : brandProduct?.image
                             ? getMediaUrl(brandProduct.image)
                             : null;
                          const image = brand.brand_banner 
                             ? getMediaUrl(brand.brand_banner) 
                             : (brand.banner_url 
                                ? getMediaUrl(brand.banner_url) 
                                : (productImage || null));
                          const desc = brand.description || `Discover the signature collections and exclusive raw extractions crafted by the luxury house of ${brand.name}.`;
                          
                          return (
                             <Link
                                key={brand.id || idx}
                                href={`/shop?brand=${brand.id}`}
                                className="group relative flex-1 bg-gradient-to-b from-white to-neutral-50/50 rounded-lg border border-neutral-200/50 hover:border-accent/40 flex flex-col items-center text-center transition-all duration-700 hover:-translate-y-1.5 shadow-lg overflow-hidden"
                             >
                                {/* Subtle spotlight gradient on hover */}
                                <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(212,175,55,0.06)_0%,transparent_70%)] opacity-0 group-hover:opacity-100 transition-opacity duration-1000 pointer-events-none" />

                                {/* Top Banner Image */}
                                <div className="w-full h-36 md:h-44 relative overflow-hidden bg-neutral-100 flex-shrink-0">
                                   <img
                                      src={image || '/placeholder-perfume.png'}
                                      alt={`${brand.name} banner`}
                                      className="w-full h-full object-cover transition-transform duration-[2.5s] group-hover:scale-105 ease-out"
                                      onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                   />
                                   <div className="absolute inset-0 bg-black/10 group-hover:bg-black/5 transition-colors duration-700" />
                                </div>

                                {/* Floating Logo Avatar */}
                                <div className="relative -mt-10 sm:-mt-12 mb-3 w-20 h-20 sm:w-24 sm:h-24 rounded-full overflow-hidden border-4 border-white bg-white shadow-md z-10 flex items-center justify-center group-hover:border-accent transition-all duration-700">
                                   {brand.logo_url ? (
                                      <img
                                         src={getMediaUrl(brand.logo_url)}
                                         alt={`${brand.name} logo`}
                                         className="max-w-[80%] max-h-[80%] object-contain mix-blend-multiply group-hover:scale-105 transition-transform duration-500"
                                         onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }}
                                      />
                                   ) : (
                                      <div className="w-full h-full bg-gradient-to-br from-accent/20 to-accent/5 flex items-center justify-center">
                                         <span className="text-accent text-xl font-serif italic">{brand.name?.[0] || '✦'}</span>
                                      </div>
                                   )}
                                </div>

                                {/* Content Details */}
                                <div className="p-6 pt-1 pb-8 flex flex-col items-center text-center flex-1 w-full">
                                   <span className="text-[9px] font-bold tracking-[0.25em] text-accent uppercase mb-2 block font-sans">
                                      Signature House
                                   </span>

                                   <h3 className="text-xl sm:text-2xl font-serif font-normal text-neutral-900 uppercase tracking-wider mb-2 leading-none group-hover:text-accent transition-colors">
                                      {brand.name}
                                   </h3>

                                   <p className="text-[11px] text-neutral-600 leading-relaxed font-light max-w-sm mb-5 tracking-wide line-clamp-2">
                                      {desc}
                                   </p>

                                   <div className="bg-transparent border border-neutral-200 group-hover:border-accent group-hover:bg-accent text-neutral-800 group-hover:text-white py-2.5 px-6 text-[9px] font-bold tracking-[0.25em] uppercase transition-all duration-500 rounded-full flex items-center gap-2 mt-auto font-sans">
                                      <span>Explore House</span>
                                      <ChevronRight size={10} className="group-hover:translate-x-1 transition-transform" />
                                   </div>
                                </div>
                             </Link>
                          );
                       })}
                    </div>
                 </div>
              ) : (
                /* Horizontal Grid Layout for 3+ Brands */
                <div className="relative w-full overflow-hidden">
                   <div className="flex gap-6 md:gap-8 overflow-x-auto py-3 px-8 scrollbar-hide select-none w-full justify-start md:justify-center">
                      {brands.map((brand: any, idx: number) => {
                         const hasBanner = !!brand.brand_banner;
                         return hasBanner ? (
                            <Link 
                               key={brand.id || idx} 
                               href={`/shop?brand=${brand.id}`}
                               className="group/brand relative w-[140px] h-[140px] flex-shrink-0 overflow-hidden bg-white shadow-md hover:-translate-y-1.5 hover:shadow-lg transition-all duration-700 rounded-sm"
                            >
                               <img 
                                  src={getMediaUrl(brand.brand_banner)} 
                                  alt={brand.name} 
                                  loading="lazy"
                                  decoding="async"
                                  className={`absolute inset-0 w-full h-full object-cover transition-all duration-[2s] ease-out ${
                                     idx % 3 === 0 ? 'animate-kenburns-1' : idx % 3 === 1 ? 'animate-kenburns-2' : 'animate-kenburns-3'
                                  }`} 
                                  onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }} 
                               />
                               {brand.logo_url && (
                                  <div className="absolute inset-0 flex items-center justify-center p-4 bg-black/10 group-hover/brand:bg-black/5 transition-all duration-700">
                                     <img 
                                        src={getMediaUrl(brand.logo_url)} 
                                        alt={`${brand.name} logo`} 
                                        className="max-w-[75%] max-h-[35%] object-contain filter invert brightness-0" 
                                     />
                                  </div>
                               )}
                               <div className="brand-card-shine" />
                               <div className="absolute inset-0 bg-gradient-to-t from-black via-black/45 to-black/10 group-hover/brand:via-black/25 transition-all duration-700" />
                               <div className="absolute top-0 left-0 right-0 h-[2px] bg-accent scale-x-0 group-hover/brand:scale-x-100 transition-transform duration-700 origin-left z-20" />
                               <div className="absolute bottom-0 left-0 right-0 p-3 z-10 text-center">
                                  <span className="block text-[9px] font-medium tracking-[0.25em] text-white uppercase group-hover/brand:text-accent transition-all duration-700 leading-none">{brand.name}</span>
                               </div>
                               <div className="absolute inset-0 border border-white/0 group-hover/brand:border-accent/30 transition-all duration-700 pointer-events-none z-20" />
                            </Link>
                         ) : (
                            <Link 
                               key={brand.id || idx} 
                               href={`/shop?brand=${brand.id}`}
                               className="group/brand relative w-[140px] h-[140px] flex-shrink-0 overflow-hidden bg-gradient-to-b from-white to-neutral-50/50 border border-neutral-200/50 shadow-md hover:-translate-y-1.5 hover:shadow-lg transition-all duration-700 flex flex-col items-center justify-center p-3 rounded-sm"
                            >
                               <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(212,175,55,0.08)_0%,transparent_65%)] opacity-0 group-hover/brand:opacity-100 transition-opacity duration-1000 pointer-events-none" />
                               
                               <div className="w-[76px] h-[76px] bg-white flex items-center justify-center p-2 rounded-xs shadow-sm border border-neutral-100 group-hover/brand:border-accent/30 transition-all duration-700 mb-2">
                                  {brand.logo_url ? (
                                     <img 
                                        src={getMediaUrl(brand.logo_url)} 
                                        alt={brand.name} 
                                        loading="lazy"
                                        decoding="async"
                                        className="max-w-full max-h-full object-contain mix-blend-multiply group-hover/brand:scale-105 transition-transform duration-500"
                                        onError={(e: any) => { e.target.src = '/placeholder-perfume.png'; }} 
                                     />
                                  ) : (
                                     <span className="font-serif italic font-black text-lg uppercase tracking-tight text-neutral-800">
                                        {brand.name.substring(0, 2)}
                                     </span>
                                  )}
                               </div>
                               
                               <span className="block text-[9px] font-medium tracking-[0.2em] text-neutral-800 group-hover/brand:text-accent transition-all duration-700 leading-none text-center">{brand.name}</span>
                               <div className="absolute top-0 left-0 right-0 h-[2px] bg-accent scale-x-0 group-hover/brand:scale-x-100 transition-transform duration-700 origin-center z-20" />
                               <div className="absolute inset-0 border border-transparent group-hover/brand:border-accent/30 transition-all duration-700 pointer-events-none z-20" />
                            </Link>
                         );
                      })}
                   </div>
                </div>
             )}
          </section>
          )}


          {/* Combined Gender and Privilege Collection Editorial Section */}
          {loyaltyRewards.length > 0 ? (
             <section className="bg-white py-12 md:py-16">
               <div className="max-w-[1400px] mx-auto px-6 lg:px-12">
                  <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-stretch">
                     
                     {/* Column 1: For Him */}
                     <div className="relative h-[340px] sm:h-[380px] md:h-[420px] group overflow-hidden bg-neutral-900 rounded shadow-xl">
                        {/* Desktop image */}
                        <img 
                           src={getMediaUrl(cmsLayout?.split_banners?.men)} 
                           alt="Shop Men" 
                           className="hidden md:block absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2.5s] ease-out" 
                        />
                        {/* Mobile image */}
                        <img 
                           src={getMediaUrl(cmsLayout?.split_banners?.men_mobile || cmsLayout?.split_banners?.men)} 
                           alt="Shop Men" 
                           className="block md:hidden absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2.5s] ease-out" 
                        />
                        <div className="absolute inset-0 bg-black/35 group-hover:bg-black/20 transition-colors duration-1000" />
                        <div className="absolute inset-0 flex flex-col items-center justify-end p-8 text-center pb-12">
                           <h3 className="text-[10px] font-bold tracking-[0.25em] uppercase text-neutral-300 mb-2 font-sans">Refined & Bold</h3>
                           <h2 className="text-3xl md:text-4xl font-serif font-normal tracking-wider mb-6 uppercase text-white">For Him</h2>
                           <Link 
                              href="/shop?gender=Men" 
                              className="bg-transparent border border-white hover:bg-white text-white hover:text-black text-[10px] font-bold tracking-[0.2em] uppercase px-8 py-3.5 transition-all duration-700 rounded-full font-sans"
                           >
                              Shop Men
                           </Link>
                        </div>
                     </div>

                     {/* Column 2: The Privilege Collection */}
                     <div className="bg-neutral-50 border border-neutral-100/80 rounded shadow-sm p-6 sm:p-8 flex flex-col justify-between items-center text-center h-[340px] sm:h-[380px] md:h-[420px]">
                        <div className="w-full">
                           <span className="text-[9px] font-bold tracking-[0.3em] text-neutral-400 uppercase mb-2 block">Kozmo Rewards</span>
                           <h3 className="text-xl md:text-2xl font-nelphim font-black text-neutral-900 uppercase tracking-wider mb-2">The Privilege Collection.</h3>
                           <div className="w-8 h-[1.5px] bg-accent mx-auto mb-6" />
                        </div>

                        {/* Central Reward card */}
                        <div className="w-full max-w-[270px] flex-grow flex items-center justify-center">
                           {loyaltyRewards.slice(0, 1).map((reward: any, i: number) => (
                              <Link 
                                 key={reward.id || i} 
                                 href={`/rewards#${reward.id}`}
                                 className="group relative w-full h-[150px] sm:h-[175px] md:h-[195px] overflow-hidden bg-neutral-900 shadow-md hover:-translate-y-2 transition-all duration-700 block text-left rounded-sm"
                              >
                                 <img
                                    src={getMediaUrl(reward.image_url)}
                                    alt={reward.name}
                                    className="absolute inset-0 w-full h-full object-cover opacity-50 group-hover:opacity-75 group-hover:scale-105 transition-all duration-[2.5s] ease-out"
                                 />
                                 <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent" />

                                 <div className="absolute inset-0 p-5 flex flex-col justify-end">
                                    <div>
                                       <span className="text-[8px] font-black tracking-[0.3em] text-yellow-500 uppercase block mb-1">{reward.reward_type}</span>
                                       <h3 className="text-sm font-serif italic text-white mb-2 tracking-tight line-clamp-1">{reward.name}</h3>
                                       <p className="text-[10px] text-neutral-300 leading-relaxed font-light opacity-80 group-hover:opacity-100 transition-opacity duration-700 line-clamp-2">
                                          {reward.description}
                                       </p>
                                    </div>
                                    <div className="flex items-center space-x-2 text-[9px] font-black tracking-[0.2em] text-white mt-3 border-t border-white/10 pt-3 transform translate-y-2 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-500">
                                       <span>{reward.point_cost ? `${reward.point_cost} POINTS` : 'EXPLORE'}</span>
                                       <ArrowRight size={10} className="group-hover:translate-x-1.5 transition-transform duration-500" />
                                    </div>
                                 </div>
                              </Link>
                           ))}
                        </div>

                        <Link
                           href="/rewards"
                           className="text-[9px] font-black tracking-[0.3em] uppercase border-b border-neutral-950/20 hover:border-neutral-950 pb-1 hover:text-accent transition-all duration-500 mt-6"
                        >
                           View Full Gallery
                        </Link>
                     </div>

                     {/* Column 3: For Her */}
                     <div className="relative h-[340px] sm:h-[380px] md:h-[420px] group overflow-hidden bg-neutral-900 rounded shadow-xl">
                        {/* Desktop image */}
                        <img 
                           src={getMediaUrl(cmsLayout?.split_banners?.women)} 
                           alt="Shop Women" 
                           className="hidden md:block absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2.5s] ease-out" 
                        />
                        {/* Mobile image */}
                        <img 
                           src={getMediaUrl(cmsLayout?.split_banners?.women_mobile || cmsLayout?.split_banners?.women)} 
                           alt="Shop Women" 
                           className="block md:hidden absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2.5s] ease-out" 
                        />
                        <div className="absolute inset-0 bg-black/35 group-hover:bg-black/20 transition-colors duration-1000" />
                        <div className="absolute inset-0 flex flex-col items-center justify-end p-8 text-center pb-12">
                           <h3 className="text-[10px] font-bold tracking-[0.25em] uppercase text-neutral-300 mb-2 font-sans">Elegant & Sweet</h3>
                           <h2 className="text-3xl md:text-4xl font-serif font-normal tracking-wider mb-6 uppercase text-white">For Her</h2>
                           <Link 
                              href="/shop?gender=Women" 
                              className="bg-transparent border border-white hover:bg-white text-white hover:text-black text-[10px] font-bold tracking-[0.2em] uppercase px-8 py-3.5 transition-all duration-700 rounded-full font-sans"
                           >
                              Shop Women
                           </Link>
                        </div>
                     </div>

                  </div>
               </div>
            </section>
         ) : (
            /* Fallback Split Banner Promos when no loyalty rewards are available */
            <section className="grid grid-cols-1 md:grid-cols-2 gap-1 py-1 bg-white">
               <div className="relative h-[500px] md:h-[600px] group overflow-hidden bg-neutral-900">
                  {/* Desktop image */}
                  <img src={getMediaUrl(cmsLayout?.split_banners?.men)} alt="Shop Men" className="hidden md:block absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2s]" />
                  {/* Mobile image */}
                  <img src={getMediaUrl(cmsLayout?.split_banners?.men_mobile || cmsLayout?.split_banners?.men)} alt="Shop Men" className="block md:hidden absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2s]" />
                  <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-colors duration-1000" />
                  <div className="absolute inset-0 flex flex-col items-center justify-center text-white p-12 text-center">
                     <h3 className="text-[10px] font-bold tracking-[0.2em] uppercase text-neutral-300 mb-3 font-sans">Refined & Bold</h3>
                     <h2 className="text-4xl md:text-5xl font-serif font-normal tracking-wide mb-6 uppercase">For Him</h2>
                     <Link href="/shop?gender=Men" className="bg-white hover:bg-accent text-black hover:text-white text-[11px] font-bold tracking-[0.25em] uppercase px-12 py-4 transition-all duration-700 shadow-2xl font-sans">
                        Shop Men
                     </Link>
                  </div>
               </div>

               <div className="relative h-[500px] md:h-[600px] group overflow-hidden bg-neutral-900">
                  {/* Desktop image */}
                  <img src={getMediaUrl(cmsLayout?.split_banners?.women)} alt="Shop Women" className="hidden md:block absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2s]" />
                  {/* Mobile image */}
                  <img src={getMediaUrl(cmsLayout?.split_banners?.women_mobile || cmsLayout?.split_banners?.women)} alt="Shop Women" className="block md:hidden absolute inset-0 w-full h-full object-cover opacity-70 group-hover:scale-105 transition-transform duration-[2s]" />
                  <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-colors duration-1000" />
                  <div className="absolute inset-0 flex flex-col items-center justify-center text-white p-12 text-center">
                     <h3 className="text-[10px] font-bold tracking-[0.2em] uppercase text-neutral-300 mb-3 font-sans">Elegant & Sweet</h3>
                     <h2 className="text-4xl md:text-5xl font-serif font-normal tracking-wide mb-6 uppercase">For Her</h2>
                     <Link href="/shop?gender=Women" className="bg-white hover:bg-accent text-black hover:text-white text-[11px] font-bold tracking-[0.25em] uppercase px-12 py-4 transition-all duration-700 shadow-2xl font-sans">
                        Shop Women
                     </Link>
                  </div>
               </div>
            </section>
         )}

          {/* Mid Quote Banner - Essence of Beauty */}
          <section className="relative overflow-hidden bg-[#FAF8F5] text-neutral-800 py-12 md:py-20 flex items-center justify-center text-center border-t border-b border-neutral-100">
             {/* Subtle radial glow */}
             <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_60%_at_50%_50%,rgba(212,175,55,0.03)_0%,transparent_70%)] pointer-events-none" />
             {/* Subtle corner vignettes */}
             <div className="absolute top-0 left-0 w-[40%] h-[40%] bg-[radial-gradient(circle_at_0%_0%,rgba(212,175,55,0.02)_0%,transparent_60%)] pointer-events-none" />
             <div className="absolute bottom-0 right-0 w-[40%] h-[40%] bg-[radial-gradient(circle_at_100%_100%,rgba(212,175,55,0.02)_0%,transparent_60%)] pointer-events-none" />
             {/* Decorative hairlines */}
             <div className="absolute left-0 right-0 top-1/2 -translate-y-1/2 h-[1px] bg-gradient-to-r from-transparent via-neutral-200/50 to-transparent pointer-events-none" />
             <div className="absolute top-0 bottom-0 left-1/2 -translate-x-1/2 w-[1px] bg-gradient-to-b from-transparent via-neutral-200/30 to-transparent pointer-events-none" />
             {/* Oversized watermark logo */}
             <div className="absolute inset-0 flex items-center justify-center pointer-events-none select-none overflow-hidden">
                <img src="/logo.png" alt="" className="w-[50vw] max-w-[500px] object-contain opacity-[0.015] mix-blend-multiply" />
             </div>
             {/* Small corner ornaments */}
             <svg className="absolute top-4 left-4 w-8 h-8 text-neutral-300/60" viewBox="0 0 48 48" fill="none"><path d="M1 47V1h46" stroke="currentColor" strokeWidth="1"/></svg>
             <svg className="absolute top-4 right-4 w-8 h-8 text-neutral-300/60" viewBox="0 0 48 48" fill="none"><path d="M47 47V1H1" stroke="currentColor" strokeWidth="1"/></svg>
             <svg className="absolute bottom-4 left-4 w-8 h-8 text-neutral-300/60" viewBox="0 0 48 48" fill="none"><path d="M1 1v46h46" stroke="currentColor" strokeWidth="1"/></svg>
             <svg className="absolute bottom-4 right-4 w-8 h-8 text-neutral-300/60" viewBox="0 0 48 48" fill="none"><path d="M47 1v46H1" stroke="currentColor" strokeWidth="1"/></svg>

             <div className="relative z-10 max-w-3xl px-6 md:px-8">
                {/* Eyebrow label */}
                <div className="flex items-center justify-center gap-3 mb-5">
                   <div className="w-8 h-[1px] bg-accent/40" />
                   <span className="text-[9px] font-bold tracking-[0.4em] text-accent uppercase font-sans">
                      {cmsLayout?.mid_quote?.author || 'The Essence of Beauty'}
                   </span>
                   <div className="w-8 h-[1px] bg-accent/40" />
                </div>

                {/* Main quote */}
                <blockquote className="relative text-xl sm:text-2xl md:text-[2.25rem] font-serif font-normal uppercase tracking-wide text-neutral-800 leading-[1.3] mb-6 px-6">
                   <span className="text-neutral-200 text-5xl leading-none absolute -top-4 -left-1 select-none font-serif">&ldquo;</span>
                   {cmsLayout?.mid_quote?.text || "Perfume follows you; it chases you and lingers behind you. It\u2019s a reference mark."}
                   <span className="text-neutral-200 text-5xl leading-none absolute -bottom-8 -right-1 select-none font-serif">&rdquo;</span>
                </blockquote>

                {/* Divider */}
                <div className="flex items-center justify-center gap-2 mb-5">
                   <div className="w-4 h-4 rotate-45 border border-neutral-200" />
                   <div className="w-16 h-[1px] bg-gradient-to-r from-neutral-200 via-neutral-400 to-neutral-200" />
                   <div className="w-1.5 h-1.5 rounded-full bg-accent" />
                   <div className="w-16 h-[1px] bg-gradient-to-r from-neutral-200 via-neutral-400 to-neutral-200" />
                   <div className="w-4 h-4 rotate-45 border border-neutral-200" />
                </div>

                {/* Tagline + CTA */}
                <p className="text-[9px] font-medium tracking-[0.4em] uppercase text-neutral-400 font-sans mb-6">Authentic Fragrances Only</p>
                <Link href="/shop" className="group inline-flex items-center gap-3 border border-neutral-800 hover:border-accent hover:bg-accent/5 text-neutral-800 hover:text-accent text-[9px] font-bold tracking-[0.3em] uppercase px-6 py-3 transition-all duration-500 font-sans rounded-sm">
                   <span>Explore Collection</span>
                   <ArrowRight size={10} className="group-hover:translate-x-1 transition-transform duration-300" />
                </Link>
             </div>
          </section>


         {/* House Favorites Arches - only shown if configured in Storefront CMS */}
         {cmsLayout?.house_favorites?.length > 0 && (
         <section className="relative w-full bg-[#fcfcfc] py-12 md:py-16 overflow-hidden border-t border-neutral-100">
            <div className="max-w-[1400px] mx-auto px-8 text-center mb-8 md:mb-10 relative z-20">
               <span className="text-[10px] font-bold tracking-[0.3em] text-neutral-400 uppercase mb-3 block">The Elite List</span>
               <h2 className="text-3xl md:text-4xl font-nelphim font-black text-black leading-normal uppercase tracking-wider">House Favorites</h2>
               <div className="w-12 h-[2px] bg-accent mx-auto mt-3" />
            </div>

            <div className="absolute top-[55%] left-1/2 -translate-x-1/2 -translate-y-1/2 z-30 w-full text-center pointer-events-none">
               <h2 className="text-white text-5xl md:text-[7rem] font-black tracking-[0.2em] leading-none mix-blend-overlay uppercase filter drop-shadow-2xl opacity-70">
                  LEGENDARY
               </h2>
            </div>

            <div className="max-w-[1700px] mx-auto w-full h-full flex md:grid md:grid-cols-5 gap-6 md:gap-8 overflow-x-auto md:overflow-visible scrollbar-hide px-6 md:px-12 relative z-10 pt-0 items-end">
               {cmsLayout.house_favorites.map((item: any, idx: number) => (
                  <div
                     key={idx}
                     className="group relative flex flex-col justify-end overflow-hidden flex-shrink-0 w-[70vw] sm:w-[45vw] md:w-auto h-[55vh] md:h-[75vh] rounded-t-full shadow-2xl hover:shadow-[0_20px_60px_-15px_rgba(0,0,0,0.3)] transition-all duration-1000 hover:-translate-y-6 border border-neutral-100"
                  >
                     <img
                        src={getMediaUrl(item.img)}
                        alt={item.name}
                        className="absolute inset-0 w-full h-full object-cover group-hover:scale-110 transition-transform duration-[3s] ease-out"
                     />
                     <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-black/40" />

                     <div className="relative z-10 bg-gradient-to-t from-black via-black/80 to-transparent pt-12 pb-6 text-center flex justify-center items-center min-h-[80px] border-t border-white/5 backdrop-blur-[2px]">
                        <span className="text-white font-black text-[12px] tracking-[0.2em] uppercase group-hover:tracking-[0.4em] transition-all duration-700">
                           {item.name}
                        </span>
                     </div>
                  </div>
               ))}
            </div>
         </section>
         )}
      </div>
   );
}
