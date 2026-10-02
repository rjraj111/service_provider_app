-- ============================================================================
-- UTSHO MARKETPLACE ECOSYSTEM - POSTGRESQL DATABASE SCHEMA FOR SUPABASE
-- ARCHITECTURALLY HARDENED & AUDITED PRODUCTION SCHEMA
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. USERS & PROFILES TABLE
-- Linked directly to Supabase auth.users
-- Supports both Email and Phone OTP (SMS) authentication flows seamlessly.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'provider', 'admin')),
    is_kyc_verified BOOLEAN NOT NULL DEFAULT false,
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.00 CHECK (rating >= 1.00 AND rating <= 5.00),
    total_jobs INTEGER NOT NULL DEFAULT 0 CHECK (total_jobs >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    CONSTRAINT users_contact_method_check CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

COMMENT ON TABLE public.users IS 'Extended user profile for customers, service providers, and admins.';

-- ============================================================================
-- 2. CATEGORIES TABLE
-- Marketplace service categories with Bengali localization support
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_bn TEXT,
    icon TEXT NOT NULL DEFAULT 'build_rounded',
    image_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.categories IS 'Hierarchical categories for marketplace services.';

-- ============================================================================
-- 3. ITEMS (SERVICE OFFERINGS) TABLE
-- Specific services provided by registered and verified technicians
-- Category deletion uses RESTRICT to avoid catastrophic cascade loss of services.
-- Includes soft-delete support via is_deleted and is_available.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    discount_price NUMERIC(10, 2) CHECK (discount_price IS NULL OR discount_price >= 0),
    duration_minutes INTEGER NOT NULL DEFAULT 60 CHECK (duration_minutes > 0),
    image_url TEXT,
    rating NUMERIC(3, 2) NOT NULL DEFAULT 5.00 CHECK (rating >= 1.00 AND rating <= 5.00),
    review_count INTEGER NOT NULL DEFAULT 0 CHECK (review_count >= 0),
    is_available BOOLEAN NOT NULL DEFAULT true,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE public.items IS 'Service offerings catalog published by providers.';

-- ============================================================================
-- 4. ORDERS (SERVICE BOOKINGS & ESCROW PAYMENTS) TABLE
-- Tracks lifecycle of service appointments, pricing, and escrow states.
-- item_id uses ON DELETE SET NULL + snapshot fields (item_title, item_price)
-- so historical bookings and financial receipts remain intact if a service is deleted.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    item_id UUID REFERENCES public.items(id) ON DELETE SET NULL,
    item_title TEXT NOT NULL DEFAULT '',
    item_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (item_price >= 0),
    booking_date TIMESTAMPTZ NOT NULL,
    time_slot TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'held_in_escrow', 'released', 'refunded')),
    service_fee NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (service_fee >= 0),
    platform_fee NUMERIC(10, 2) NOT NULL DEFAULT 20.00 CHECK (platform_fee >= 0),
    discount_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    address TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE public.orders IS 'Customer bookings and escrow transactions.';

-- ============================================================================
-- 5. REVIEWS, RATINGS & TIPS TABLE
-- Verified feedback submitted by customers after job completion
-- Exactly one review per order enforced by UNIQUE (order_id)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    tip_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (tip_amount >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.reviews IS 'Verified customer reviews and tips.';

-- ============================================================================
-- 6. INDEXES FOR HIGH-PERFORMANCE QUERIES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_kyc_verified ON public.users(is_kyc_verified);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_categories_is_active_sort ON public.categories(is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_items_category_id ON public.items(category_id);
CREATE INDEX IF NOT EXISTS idx_items_provider_id ON public.items(provider_id);
CREATE INDEX IF NOT EXISTS idx_items_available_active ON public.items(is_available, is_deleted, rating DESC);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_provider_id ON public.orders(provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_item_id ON public.orders(item_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_reviews_provider_id ON public.reviews(provider_id);
CREATE INDEX IF NOT EXISTS idx_reviews_order_id ON public.reviews(order_id);

-- ============================================================================
-- 7. AUTOMATED UPDATED_AT TRIGGER FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_items_modtime
    BEFORE UPDATE ON public.items
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_orders_modtime
    BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- 8. AUTOMATIC PROFILE CREATION ON AUTH SIGNUP
-- Handles both Email signups and Phone OTP signups reliably.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
DECLARE
    v_phone TEXT;
    v_name TEXT;
    v_role TEXT;
BEGIN
    v_phone := COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone');
    v_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        v_phone,
        split_part(NEW.email, '@', 1),
        'Utsho User'
    );
    v_role := COALESCE(NEW.raw_user_meta_data->>'role', 'customer');

    INSERT INTO public.users (
        id,
        email,
        full_name,
        phone,
        avatar_url,
        role
    )
    VALUES (
        NEW.id,
        NEW.email,
        v_name,
        v_phone,
        NEW.raw_user_meta_data->>'avatar_url',
        v_role
    )
    ON CONFLICT (id) DO UPDATE
    SET
        email = COALESCE(EXCLUDED.email, public.users.email),
        full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
        phone = COALESCE(EXCLUDED.phone, public.users.phone),
        avatar_url = COALESCE(EXCLUDED.avatar_url, public.users.avatar_url);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- ============================================================================
-- 9. USER PRIVILEGE ESCALATION PROTECTION TRIGGER
-- Prevents regular authenticated users from altering sensitive system fields.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.protect_user_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- If update is initiated by a regular authenticated user, freeze protected fields
    IF (auth.jwt() ->> 'role' != 'service_role') THEN
        NEW.role = OLD.role;
        NEW.is_kyc_verified = OLD.is_kyc_verified;
        NEW.rating = OLD.rating;
        NEW.total_jobs = OLD.total_jobs;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER protect_user_fields_trigger
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.protect_user_fields();

-- ============================================================================
-- 10. RECALCULATE RATINGS TRIGGER ON REVIEW INSERT / UPDATE / DELETE
-- Updates both the provider rating in users table AND the item rating in items table!
-- ============================================================================
CREATE OR REPLACE FUNCTION public.recalculate_ratings()
RETURNS TRIGGER AS $$
DECLARE
    v_provider_id UUID;
    v_order_id UUID;
    v_item_id UUID;
BEGIN
    v_provider_id := COALESCE(NEW.provider_id, OLD.provider_id);
    v_order_id := COALESCE(NEW.order_id, OLD.order_id);

    -- 1. Recalculate provider overall rating
    UPDATE public.users
    SET rating = COALESCE((
        SELECT ROUND(AVG(rating)::numeric, 2)
        FROM public.reviews
        WHERE provider_id = v_provider_id
    ), 5.00)
    WHERE id = v_provider_id;

    -- 2. Recalculate item rating and review count
    SELECT item_id INTO v_item_id
    FROM public.orders
    WHERE id = v_order_id;

    IF v_item_id IS NOT NULL THEN
        UPDATE public.items
        SET
            rating = COALESCE((
                SELECT ROUND(AVG(r.rating)::numeric, 2)
                FROM public.reviews r
                JOIN public.orders o ON r.order_id = o.id
                WHERE o.item_id = v_item_id
            ), 5.00),
            review_count = (
                SELECT COUNT(r.id)
                FROM public.reviews r
                JOIN public.orders o ON r.order_id = o.id
                WHERE o.item_id = v_item_id
            )
        WHERE id = v_item_id;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER on_review_changed_update_ratings
    AFTER INSERT OR UPDATE OR DELETE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.recalculate_ratings();

-- ============================================================================
-- 11. RECALCULATE PROVIDER COMPLETED JOBS COUNT ON ORDER STATUS CHANGE
-- Updates users.total_jobs accurately whenever an order transitions to/from 'completed'
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_order_completed_jobs()
RETURNS TRIGGER AS $$
DECLARE
    v_provider_id UUID;
BEGIN
    v_provider_id := COALESCE(NEW.provider_id, OLD.provider_id);

    UPDATE public.users
    SET total_jobs = (
        SELECT COUNT(*)
        FROM public.orders
        WHERE provider_id = v_provider_id AND status = 'completed'
    )
    WHERE id = v_provider_id;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER on_order_status_update_total_jobs
    AFTER INSERT OR UPDATE OF status OR DELETE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_order_completed_jobs();

-- ============================================================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- ── Users Policies ──────────────────────────────────────────────────────────
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.users FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- ── Categories Policies ──────────────────────────────────────────────────────
CREATE POLICY "Categories are viewable by everyone"
    ON public.categories FOR SELECT
    USING (is_active = true);

-- ── Items Policies ───────────────────────────────────────────────────────────
CREATE POLICY "Items are viewable by everyone"
    ON public.items FOR SELECT
    USING (is_available = true AND is_deleted = false);

CREATE POLICY "Providers can create items"
    ON public.items FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update their own items"
    ON public.items FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete their own items"
    ON public.items FOR DELETE
    USING (auth.uid() = provider_id);

-- ── Orders Policies ──────────────────────────────────────────────────────────
CREATE POLICY "Users can view their own orders as customer or provider"
    ON public.orders FOR SELECT
    USING (auth.uid() = customer_id OR auth.uid() = provider_id);

CREATE POLICY "Customers can create bookings"
    ON public.orders FOR INSERT
    WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Participants can update order details"
    ON public.orders FOR UPDATE
    USING (auth.uid() = customer_id OR auth.uid() = provider_id);

-- ── Reviews Policies ─────────────────────────────────────────────────────────
CREATE POLICY "Reviews are viewable by everyone"
    ON public.reviews FOR SELECT
    USING (true);

CREATE POLICY "Customers can create reviews for completed orders"
    ON public.reviews FOR INSERT
    WITH CHECK (
        auth.uid() = customer_id
        AND EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = reviews.order_id
              AND orders.customer_id = auth.uid()
              AND orders.provider_id = reviews.provider_id
              AND orders.status = 'completed'
        )
    );

-- ============================================================================
-- 13. DEFAULT SEED CATEGORIES FOR UTSHO
-- ============================================================================
INSERT INTO public.categories (name, name_bn, icon, sort_order)
VALUES
    ('AC Servicing & Repair', 'এসি সার্ভিসিং ও মেরামত', 'ac_unit_rounded', 1),
    ('Plumbing & Sanitary', 'প্লাম্বিং ও স্যানিটারি', 'plumbing_rounded', 2),
    ('Electrical Services', 'ইলেকট্রিক্যাল সার্ভিস', 'electrical_services_rounded', 3),
    ('Home Cleaning', 'হোম ক্লিনিং', 'cleaning_services_rounded', 4),
    ('Appliance Repair', 'হোম অ্যাপ্লায়েন্স মেরামত', 'home_repair_service_rounded', 5),
    ('Painting & Renovation', 'রং ও রেনোভেশন', 'format_paint_rounded', 6),
    ('Carpentry & Woodwork', 'কার্পেন্ট্রি ও কাঠের কাজ', 'carpenter_rounded', 7),
    ('Shifting & Moving', 'বাসা বদল ও শিফটিং', 'local_shipping_rounded', 8)
ON CONFLICT DO NOTHING;
