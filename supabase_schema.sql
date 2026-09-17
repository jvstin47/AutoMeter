-- =========================================================
-- SMART FARE METER — SUPABASE SCHEMA (V1)
-- =========================================================

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Trips Table
CREATE TABLE IF NOT EXISTS public.trips (
    id TEXT PRIMARY KEY,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    distance NUMERIC(10, 3) NOT NULL DEFAULT 0.0,
    waiting_time INTEGER NOT NULL DEFAULT 0, -- seconds
    duration INTEGER NOT NULL DEFAULT 0,     -- seconds
    base_fare NUMERIC(10, 2) NOT NULL,
    distance_fare NUMERIC(10, 2) NOT NULL,
    waiting_fare NUMERIC(10, 2) NOT NULL,
    total_fare NUMERIC(10, 2) NOT NULL,
    payment_method TEXT DEFAULT 'unselected',
    payment_status TEXT DEFAULT 'not_started',
    payment_reference TEXT,
    start_latitude DOUBLE PRECISION,
    start_longitude DOUBLE PRECISION,
    end_latitude DOUBLE PRECISION,
    end_longitude DOUBLE PRECISION,
    is_demo BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- 2. Driver & Fare Configuration Table
CREATE TABLE IF NOT EXISTS public.driver_config (
    id TEXT PRIMARY KEY DEFAULT 'default_driver',
    driver_name TEXT NOT NULL DEFAULT 'Ramesh Kumar',
    upi_id TEXT NOT NULL DEFAULT 'ramesh.auto@okhdfcbank',
    vehicle_number TEXT DEFAULT 'KA-01-AB-4022',
    base_fare NUMERIC(10, 2) NOT NULL DEFAULT 30.00,
    per_km_rate NUMERIC(10, 2) NOT NULL DEFAULT 15.00,
    waiting_rate NUMERIC(10, 2) NOT NULL DEFAULT 1.50,
    currency TEXT DEFAULT '₹',
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS (Row Level Security) with public access for prototype
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read trips" ON public.trips FOR SELECT USING (true);
CREATE POLICY "Allow public insert trips" ON public.trips FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update trips" ON public.trips FOR UPDATE USING (true);

CREATE POLICY "Allow public read config" ON public.driver_config FOR SELECT USING (true);
CREATE POLICY "Allow public write config" ON public.driver_config FOR ALL USING (true);
