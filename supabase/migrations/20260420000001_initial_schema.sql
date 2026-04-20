-- ============================================================
-- AmaahPay v2 - Database Schema
-- Apply this in Supabase Dashboard → SQL Editor
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES (extends Supabase auth.users)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  phone         TEXT,
  shop_name     TEXT,
  role          TEXT NOT NULL DEFAULT 'merchant' CHECK (role IN ('admin', 'merchant')),
  is_active     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, role, is_active)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Unknown'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'merchant'),
    FALSE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- BILLING PLANS (admin sets per merchant)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.billing_plans (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  admin_id        UUID NOT NULL REFERENCES public.profiles(id),
  cycle           TEXT NOT NULL CHECK (cycle IN ('monthly', 'yearly')),
  price_usd       NUMERIC(10, 2) NOT NULL DEFAULT 0,
  activated_at    TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- CUSTOMERS (per merchant)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.customers (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  phone             TEXT,
  credit_balance    NUMERIC(12, 2) NOT NULL DEFAULT 0,
  deposit_balance   NUMERIC(12, 2) NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- PRODUCTS (per merchant)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.products (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  unit                TEXT NOT NULL DEFAULT 'piece',
  default_price_usd   NUMERIC(10, 2) NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- SALES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.sales (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  customer_id       UUID NOT NULL REFERENCES public.customers(id),
  total_usd         NUMERIC(12, 2) NOT NULL DEFAULT 0,
  cash_paid_usd     NUMERIC(12, 2) NOT NULL DEFAULT 0,
  deposit_used_usd  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  credit_added_usd  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  conversion_rate   NUMERIC(10, 2) NOT NULL DEFAULT 2700,
  notes             TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- SALE ITEMS (products per sale)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.sale_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sale_id       UUID NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  product_id    UUID REFERENCES public.products(id),
  product_name  TEXT NOT NULL,
  unit          TEXT NOT NULL DEFAULT 'piece',
  quantity      NUMERIC(10, 3) NOT NULL DEFAULT 1,
  price_usd     NUMERIC(10, 2) NOT NULL DEFAULT 0
);


-- ============================================================
-- LEDGER (running log per customer)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ledger (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  customer_id         UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  sale_id             UUID REFERENCES public.sales(id),
  type                TEXT NOT NULL CHECK (type IN ('credit', 'deposit', 'payment', 'sale')),
  amount_usd          NUMERIC(12, 2) NOT NULL DEFAULT 0,
  credit_balance_after  NUMERIC(12, 2) NOT NULL DEFAULT 0,
  deposit_balance_after NUMERIC(12, 2) NOT NULL DEFAULT 0,
  conversion_rate     NUMERIC(10, 2) NOT NULL DEFAULT 2700,
  note                TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.billing_plans   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger          ENABLE ROW LEVEL SECURITY;

-- Profiles: Users see their own, admins see all
CREATE POLICY "profiles_self" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_admin" ON public.profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Customers: Only the owning merchant
CREATE POLICY "customers_owner" ON public.customers
  FOR ALL USING (merchant_id = auth.uid());

-- Products: Only the owning merchant
CREATE POLICY "products_owner" ON public.products
  FOR ALL USING (merchant_id = auth.uid());

-- Sales: Only the owning merchant
CREATE POLICY "sales_owner" ON public.sales
  FOR ALL USING (merchant_id = auth.uid());

-- Sale Items: Through owning merchant's sales
CREATE POLICY "sale_items_owner" ON public.sale_items
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.sales WHERE id = sale_id AND merchant_id = auth.uid())
  );

-- Ledger: Only the owning merchant
CREATE POLICY "ledger_owner" ON public.ledger
  FOR ALL USING (merchant_id = auth.uid());

-- Billing: Admins manage, merchants read their own
CREATE POLICY "billing_admin" ON public.billing_plans
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "billing_merchant_read" ON public.billing_plans
  FOR SELECT USING (merchant_id = auth.uid());


-- ============================================================
-- UPDATED_AT trigger helper
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
