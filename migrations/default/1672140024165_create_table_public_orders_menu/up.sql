CREATE TABLE "public"."orders_menu" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "order_id" uuid NOT NULL, "menu_id" uuid NOT NULL, PRIMARY KEY ("id") );
CREATE EXTENSION IF NOT EXISTS pgcrypto;
